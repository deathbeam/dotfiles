/** Search Pi's persisted JSONL transcripts, including compacted-away entries. */

import fs from "node:fs";
import path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_TOTAL_BYTES = 400 * 1024 * 1024;
const MAX_PER_FILE = 3; // max matches per session file
const MAX_SEARCH_LIMIT = 100;
const READ_CHUNK_BYTES = 64 * 1024;
const MAX_LINE_BYTES = 16 * 1024 * 1024;
// ponytail: 16 MiB record ceiling; raise only if real sessions exceed it, or add incremental JSON parsing.

export interface ArchiveMatch {
    file: string;
    project: string; // short project label, e.g. "git/dotfiles"
    date: string; // from file name, e.g. "2026-09-07"
    role: string;
    excerpt: string;
    currentSession: boolean;
    sameProject: boolean;
}

export interface SearchOptions {
    currentFile?: string;
    currentDir?: string;
    sessionFilter?: string; // substring matched against the encoded cwd dir name
    limit?: number;
}

function parseJsonLine(line: string): any | null {
    try {
        return JSON.parse(line);
    } catch {
        return null;
    }
}

export function projectLabel(dirName: string): string {
    const parts = dirName.replace(/^-+|-+$/g, "").split("-");
    return parts.length <= 2 ? parts.join("/") : parts.slice(-2).join("/");
}

export function fileDate(fileName: string): string {
    return fileName.slice(0, 10);
}

export function entryText(entry: unknown): { role: string; text: string } | null {
    const e = entry as Record<string, any>;
    const content = e?.message?.content;
    if (
        e?.type === "message" &&
        (Array.isArray(content) || (e.message.role === "user" && typeof content === "string"))
    ) {
        const text =
            typeof content === "string"
                ? content
                : content
                      .filter((c: any) => c?.type === "text" && typeof c.text === "string")
                      .map((c: any) => c.text)
                      .join("\n");
        if (!text) return null;
        return { role: String(e.message.role ?? "?"), text };
    }
    if (e?.type === "compaction" && typeof e.summary === "string") {
        return { role: "summary", text: e.summary };
    }
    return null;
}

/** LF-only JSONL: readline also splits literal U+2028/U+2029 inside JSON strings. */
async function scanJsonLines(
    file: string,
    maxBytes: number,
    signal: AbortSignal | undefined,
    onLine: (line: string) => boolean,
): Promise<{ bytes: number; incomplete: boolean; oversizedLines: number }> {
    const empty = { bytes: 0, incomplete: false, oversizedLines: 0 };
    if (signal?.aborted || maxBytes <= 0) return { ...empty, incomplete: maxBytes <= 0 };

    let size: number;
    try {
        size = (await fs.promises.stat(file)).size;
    } catch {
        return { ...empty, incomplete: true };
    }
    if (size === 0) return empty;

    const stream = fs.createReadStream(file, {
        start: 0,
        end: Math.min(size, maxBytes) - 1,
        encoding: "utf8",
        highWaterMark: READ_CHUNK_BYTES,
    });
    let bytes = 0;
    let pending = "";
    let pendingBytes = 0;
    let skippingLine = false;
    let oversizedLines = 0;
    let stopped = false;

    const consume = (text: string): boolean => {
        let start = 0;
        while (start < text.length) {
            const newline = text.indexOf("\n", start);
            const end = newline === -1 ? text.length : newline + 1;
            if (skippingLine) {
                if (newline !== -1) skippingLine = false;
            } else {
                const part = text.slice(start, end);
                pending += part;
                pendingBytes += Buffer.byteLength(part);
                if (pendingBytes > MAX_LINE_BYTES) {
                    oversizedLines++;
                    pending = "";
                    pendingBytes = 0;
                    skippingLine = newline === -1;
                } else if (newline !== -1) {
                    if (!onLine(pending.slice(0, -1))) return false;
                    pending = "";
                    pendingBytes = 0;
                }
            }
            if (newline === -1) return true;
            start = end;
        }
        return true;
    };

    try {
        for await (const chunk of stream) {
            if (signal?.aborted) {
                stopped = true;
                break;
            }
            const text = chunk as string;
            bytes += Buffer.byteLength(text);
            if (!consume(text)) {
                stopped = true;
                break;
            }
        }
        if (!stopped && !signal?.aborted && pending && !skippingLine) onLine(pending);
        let incomplete = size > maxBytes;
        if (!incomplete && !stopped && !signal?.aborted) {
            try {
                incomplete = (await fs.promises.stat(file)).size > bytes;
            } catch {
                incomplete = true;
            }
        }
        return { bytes, incomplete, oversizedLines };
    } catch {
        return { bytes, incomplete: true, oversizedLines };
    }
}

export function parseTerms(query: string): string[] {
    return query.toLowerCase().split(/\s+/).filter(Boolean);
}

export function matchesAll(text: string, terms: string[]): boolean {
    const lower = text.toLowerCase();
    return terms.every((t) => lower.includes(t));
}

export function excerptAround(text: string, terms: string[], radius = 150): string {
    const lower = text.toLowerCase();
    let idx = -1;
    for (const t of terms) {
        const i = lower.indexOf(t);
        if (i >= 0 && (idx === -1 || i < idx)) idx = i;
    }
    const start = idx === -1 ? 0 : Math.max(0, idx - radius);
    const end = idx === -1 ? radius * 2 : idx + radius;
    return (start > 0 ? "…" : "") + text.slice(start, end) + (end < text.length ? "…" : "");
}

/** Rank the current session first, then this project, then other projects newest-first. */
export async function searchSessions(
    root: string,
    query: string,
    opts: SearchOptions = {},
    signal?: AbortSignal,
    onProgress?: (filesScanned: number, matches: number) => void,
): Promise<{ matches: ArchiveMatch[]; bytesScanned: number; filesScanned: number; truncated: boolean }> {
    const terms = parseTerms(query);
    if (
        opts.limit !== undefined &&
        (!Number.isSafeInteger(opts.limit) || opts.limit < 1 || opts.limit > MAX_SEARCH_LIMIT)
    ) {
        throw new RangeError(`limit must be an integer from 1 to ${MAX_SEARCH_LIMIT}`);
    }
    if (terms.length === 0) return { matches: [], bytesScanned: 0, filesScanned: 0, truncated: false };
    const limit = opts.limit ?? 20;
    const filter = opts.sessionFilter?.toLowerCase();

    const files: { file: string; dir: string; name: string; mtime: number }[] = [];
    let rootEntries: fs.Dirent[];
    try {
        rootEntries = await fs.promises.readdir(root, { withFileTypes: true });
    } catch {
        return { matches: [], bytesScanned: 0, filesScanned: 0, truncated: false };
    }
    for (const entry of rootEntries) {
        if (signal?.aborted) break;
        if (!entry.isDirectory()) continue;
        const dirName = entry.name;
        if (filter && !dirName.toLowerCase().includes(filter)) continue;
        const dir = path.join(root, dirName);
        let entries: fs.Dirent[];
        try {
            entries = await fs.promises.readdir(dir, { withFileTypes: true });
        } catch {
            continue; // directory changed or became unreadable
        }
        for (const fileEntry of entries) {
            if (signal?.aborted) break;
            if (!fileEntry.isFile() || !fileEntry.name.endsWith(".jsonl")) continue;
            const file = path.join(dir, fileEntry.name);
            try {
                files.push({ file, dir: dirName, name: fileEntry.name, mtime: (await fs.promises.stat(file)).mtimeMs });
            } catch {}
        }
    }
    if (signal?.aborted) return { matches: [], bytesScanned: 0, filesScanned: 0, truncated: true };

    const currentDirName = opts.currentDir ? path.basename(opts.currentDir) : undefined;
    const rank = (f: (typeof files)[number]) =>
        f.file === opts.currentFile ? 0 : currentDirName && f.dir === currentDirName ? 1 : 2;
    files.sort((a, b) => rank(a) - rank(b) || b.mtime - a.mtime);

    const matches: ArchiveMatch[] = [];
    let bytes = 0;
    let filesScanned = 0;
    let truncated = false;
    for (const { file, dir, name } of files) {
        if (signal?.aborted || bytes >= MAX_TOTAL_BYTES) {
            truncated = true;
            break;
        }
        onProgress?.(filesScanned, matches.length);
        let fileMatches = 0;
        const scan = await scanJsonLines(file, MAX_TOTAL_BYTES - bytes, signal, (line) => {
            if (fileMatches >= MAX_PER_FILE || matches.length >= limit) return false;
            if (!line || !terms.some((t) => line.toLowerCase().includes(t))) return true;
            const parsed = parseJsonLine(line);
            if (!parsed) return true;
            const et = entryText(parsed);
            if (!et || !matchesAll(et.text, terms)) return true;
            matches.push({
                file,
                project: projectLabel(dir),
                date: fileDate(name),
                role: et.role,
                excerpt: excerptAround(et.text, terms),
                currentSession: file === opts.currentFile,
                sameProject: currentDirName !== undefined && dir === currentDirName,
            });
            fileMatches++;
            return fileMatches < MAX_PER_FILE && matches.length < limit;
        });
        bytes += scan.bytes;
        filesScanned++;
        if (signal?.aborted || matches.length >= limit || scan.incomplete) {
            truncated = true;
            break;
        }
        if (scan.oversizedLines > 0) truncated = true;
    }
    return { matches, bytesScanned: bytes, filesScanned, truncated };
}

export async function firstUserTitle(file: string, maxLen = 120): Promise<string | null> {
    let title: string | null = null;
    await scanJsonLines(file, Number.MAX_SAFE_INTEGER, undefined, (line) => {
        const et = entryText(parseJsonLine(line));
        if (et?.role !== "user" || !et.text.trim()) return true;
        title = et.text.length > maxLen ? et.text.slice(0, maxLen) + "…" : et.text;
        return false;
    });
    return title;
}

/** Recent session files in a project dir (encoded cwd), newest first. */
export function recentSessions(
    sessionDir: string,
    excludeFile: string | undefined,
    count: number,
): { file: string; name: string }[] {
    let names: string[];
    try {
        names = fs.readdirSync(sessionDir).filter((n) => n.endsWith(".jsonl"));
    } catch {
        return [];
    }
    const out: { file: string; name: string; mtime: number }[] = [];
    for (const name of names) {
        const file = path.join(sessionDir, name);
        if (file === excludeFile) continue;
        try {
            out.push({ file, name, mtime: fs.statSync(file).mtimeMs });
        } catch {
            /* skip */
        }
    }
    out.sort((a, b) => b.mtime - a.mtime);
    return out.slice(0, count).map(({ file, name }) => ({ file, name }));
}

export function formatResults(query: string, result: Awaited<ReturnType<typeof searchSessions>>): string {
    const note = result.truncated ? "\n(Search incomplete; narrow with the session filter.)" : "";
    if (result.matches.length === 0) {
        return `No matches for "${query}" in ${result.filesScanned} scanned session files.${note}`;
    }
    const lines = result.matches.map(
        (m) =>
            `${m.file}\n[${m.currentSession ? "this session" : m.sameProject ? "this project" : m.project} | ${m.date} | ${m.role}] ${m.excerpt.replace(/\s+/g, " ")}`,
    );
    return `Found ${result.matches.length} match(es) for "${query}" — each hit starts with the session file; read or grep it for full context:\n\n${lines.join("\n\n")}${note}`;
}

export default async function piArchive(pi: ExtensionAPI) {
    const { defineTool } = await import("@earendil-works/pi-coding-agent");
    const { Type } = await import("@earendil-works/pi-ai");

    const searchArchive = defineTool({
        name: "search_archive",
        label: "Search archive",
        description:
            "Search the full transcript archive of past and current pi sessions — including content that was compacted away. " +
            "Use when the current context is missing a detail: exact code, command output, error messages, or decisions from " +
            "earlier in this session (before compaction) or from previous sessions in this or other projects.",
        parameters: Type.Object({
            query: Type.String({ description: "Search terms; all must appear (case-insensitive)" }),
            session: Type.Optional(
                Type.String({ description: "Only search sessions whose project path contains this, e.g. 'dotfiles'" }),
            ),
            limit: Type.Optional(
                Type.Integer({
                    minimum: 1,
                    maximum: MAX_SEARCH_LIMIT,
                    description: `Max matches (default 20, max ${MAX_SEARCH_LIMIT})`,
                }),
            ),
        }),
        async execute(_toolCallId, params, signal, onUpdate, ctx) {
            const sessionDir = ctx.sessionManager.getSessionDir();
            const root = path.dirname(sessionDir);
            const result = await searchSessions(
                root,
                params.query,
                {
                    currentFile: ctx.sessionManager.getSessionFile(),
                    currentDir: sessionDir,
                    sessionFilter: params.session,
                    limit: params.limit,
                },
                signal,
                (files, hits) =>
                    onUpdate?.({
                        content: [{ type: "text", text: `Scanning archive… ${files} files, ${hits} match(es) so far` }],
                        details: {},
                    }),
            );
            return {
                content: [{ type: "text", text: formatResults(params.query, result) }],
                details: {
                    matchCount: result.matches.length,
                    filesScanned: result.filesScanned,
                    truncated: result.truncated,
                },
            };
        },
    });
    pi.registerTool(searchArchive);

    // Inject titles only; search_archive retrieves transcript details on demand.
    let memoryInjected = false;
    pi.on("before_agent_start", async (_event, ctx) => {
        if (memoryInjected) return;
        memoryInjected = true;
        const hasConversation = ctx.sessionManager.getEntries().some((e: any) => e.type === "message");
        if (hasConversation) return;
        const sessionDir = ctx.sessionManager.getSessionDir();
        const current = ctx.sessionManager.getSessionFile();
        const recent = recentSessions(sessionDir, current, 5);
        if (recent.length === 0) return;
        const titles = await Promise.all(recent.map(({ file }) => firstUserTitle(file)));
        const lines = recent.map(({ name }, i) => `- ${fileDate(name)}: ${titles[i] ?? "(no user message)"}`);
        return {
            message: {
                customType: "archive-memory",
                content: `[pi-archive] Recent past sessions in this project (retrievable in full via the search_archive tool):\n${lines.join("\n")}`,
                display: false,
            },
        };
    });
}
