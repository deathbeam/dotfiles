/**
 * pi-archive — searchable archive of all past + current pi session transcripts.
 *
 * pi already persists every session (including compacted-away content) as jsonl
 * under ~/.pi/agent/sessions/<encoded-cwd>/. This extension makes that archive
 * reachable from the model:
 *
 *  - search_archive tool: case-insensitive AND-terms search over all session
 *    transcripts (messages + compaction summaries), current session ranked
 *    first, then same-project sessions, then everything else newest-first.
 *  - Proactive memory: on the first turn of a new session, injects a short
 *    digest of recent sessions in the same project so the model knows past
 *    context exists and can retrieve it via search_archive.
 */

import fs from "node:fs";
import path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_TOTAL_BYTES = 400 * 1024 * 1024;
const MAX_PER_FILE = 3; // max matches per session file

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

/** Parse one jsonl line, or null. */
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

/** Extract searchable text from a session entry; null if nothing to search. */
export function entryText(entry: unknown): { role: string; text: string } | null {
	const e = entry as Record<string, any>;
	if (e?.type === "message" && Array.isArray(e.message?.content)) {
		const text = (e.message.content as any[])
			.filter((c) => c?.type === "text" && typeof c.text === "string")
			.map((c) => c.text)
			.join("\n");
		if (!text) return null;
		return { role: String(e.message.role ?? "?"), text };
	}
	if (e?.type === "compaction" && typeof e.summary === "string") {
		return { role: "summary", text: e.summary };
	}
	return null;
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

/** Search a sessions root dir. Returns matches in rank order.
 *  Async: reports progress per file (which also yields, keeping the UI responsive) and honors `signal`. */
export async function searchSessions(
	root: string,
	query: string,
	opts: SearchOptions = {},
	signal?: AbortSignal,
	onProgress?: (filesScanned: number, matches: number) => void,
): Promise<{ matches: ArchiveMatch[]; bytesScanned: number; filesScanned: number; truncated: boolean }> {
	const terms = parseTerms(query);
	const limit = opts.limit ?? 20;
	if (terms.length === 0) return { matches: [], bytesScanned: 0, filesScanned: 0, truncated: false };
	const filter = opts.sessionFilter?.toLowerCase();

	// Gather candidate session files, then rank: current session first, then same project, then rest — newest first within each rank.
	const files: { file: string; dir: string; name: string; mtime: number }[] = [];
	let dirs: string[];
	try {
		dirs = fs
			.readdirSync(root, { withFileTypes: true })
			.filter((d) => d.isDirectory())
			.map((d) => d.name);
	} catch {
		return { matches: [], bytesScanned: 0, filesScanned: 0, truncated: false };
	}
	for (const dirName of dirs) {
		if (filter && !dirName.toLowerCase().includes(filter)) continue;
		const dir = path.join(root, dirName);
		for (const f of fs.readdirSync(dir, { withFileTypes: true })) {
			if (!f.isFile() || !f.name.endsWith(".jsonl")) continue;
			const file = path.join(dir, f.name);
			files.push({ file, dir: dirName, name: f.name, mtime: fs.statSync(file).mtimeMs });
		}
	}
	// Rank: current session first, then same project, then rest — newest first within each rank.
	const currentDirName = opts.currentDir ? path.basename(opts.currentDir) : undefined;
	const rank = (f: (typeof files)[number]) =>
		f.file === opts.currentFile ? 0 : currentDirName && f.dir === currentDirName ? 1 : 2;
	files.sort((a, b) => rank(a) - rank(b) || b.mtime - a.mtime);

	const matches: ArchiveMatch[] = [];
	let bytes = 0;
	let filesScanned = 0;
	let truncated = false;
	for (const { file, dir, name } of files) {
		if (signal?.aborted) {
			truncated = true;
			break;
		}
		if (matches.length >= limit || bytes >= MAX_TOTAL_BYTES) {
			truncated = true;
			break;
		}
		await new Promise(setImmediate); // yield: progress callback can render, abort can land
		onProgress?.(filesScanned, matches.length);
		let content: string;
		try {
			const stat = fs.statSync(file);
			if (stat.size === 0) continue;
			bytes += stat.size;
			content = fs.readFileSync(file, "utf8");
		} catch {
			continue;
		}
		filesScanned++;
		let fileMatches = 0;
		for (const line of content.split("\n")) {
			if (fileMatches >= MAX_PER_FILE || matches.length >= limit) break;
			if (!line || !terms.some((t) => line.toLowerCase().includes(t))) continue; // cheap pre-filter
			const parsed = parseJsonLine(line);
			if (!parsed) continue;
			const et = entryText(parsed);
			if (!et || !matchesAll(et.text, terms)) continue;
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
		}
	}
	return { matches, bytesScanned: bytes, filesScanned, truncated };
}

/** First user message of a session file, truncated — used as a session title. */
export function firstUserTitle(file: string, maxLen = 120): string | null {
	try {
		for (const line of fs.readFileSync(file, "utf8").split("\n")) {
			const et = entryText(parseJsonLine(line));
			if (et?.role !== "user" || !et.text.trim()) continue;
			return et.text.length > maxLen ? et.text.slice(0, maxLen) + "…" : et.text;
		}
	} catch {
		/* unreadable file — skip */
	}
	return null;
}

/** Recent session files in a project dir (encoded cwd), newest first. */
export function recentSessions(sessionDir: string, excludeFile: string | undefined, count: number): { file: string; name: string }[] {
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

function formatResults(query: string, result: ReturnType<typeof searchSessions>): string {
	if (result.matches.length === 0) {
		return `No matches for "${query}" in the session archive (${result.filesScanned} session files scanned).`;
	}
	const lines = result.matches.map(
		(m) =>
			`${m.file}\n[${m.currentSession ? "this session" : m.sameProject ? "this project" : m.project} | ${m.date} | ${m.role}] ${m.excerpt.replace(/\s+/g, " ")}`,
	);
	const note = result.truncated
		? `\n\n(Search budget reached — older sessions not fully scanned. Narrow with the session filter or fewer terms.)`
		: "";
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
			limit: Type.Optional(Type.Number({ description: "Max matches (default 20)" })),
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
				(files, hits) => onUpdate?.({ content: [{ type: "text", text: `Scanning archive… ${files} files, ${hits} match(es) so far` }] }),
			);
			return {
				content: [{ type: "text", text: formatResults(params.query, result) }],
				details: { matchCount: result.matches.length, filesScanned: result.filesScanned },
			};
		},
	});
	pi.registerTool(searchArchive);

	// Proactive memory: on the first turn of a fresh conversation, point the
	// model at recent past sessions in this project (titles only — retrieval
	// stays lazy via search_archive).
	let memoryInjected = false;
	pi.on("before_agent_start", async (_event, ctx) => {
		if (memoryInjected) return;
		memoryInjected = true;
		const hasConversation = ctx.sessionManager
			.getEntries()
			.some((e: any) => e.type === "message");
		if (hasConversation) return;
		const sessionDir = ctx.sessionManager.getSessionDir();
		const current = ctx.sessionManager.getSessionFile();
		const recent = recentSessions(sessionDir, current, 5);
		if (recent.length === 0) return;
		const lines = recent.map(({ file, name }) => {
			const title = firstUserTitle(file) ?? "(no user message)";
			return `- ${fileDate(name)}: ${title}`;
		});
		if (lines.length === 0) return;
		return {
			message: {
				customType: "archive-memory",
				content:
					`[pi-archive] Recent past sessions in this project (retrievable in full via the search_archive tool):\n${lines.join("\n")}`,
				display: false,
			},
		};
	});
}
