import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import {
    DEFAULT_MAX_BYTES,
    DEFAULT_MAX_LINES,
    formatSize,
    keyHint,
    truncateHead,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "@sinclair/typebox";
import { spawn, spawnSync } from "child_process";
import { createInterface } from "readline";
import { normalizeToLF, stripBom } from "./edit-diff";
import { resolveMutationTargetPath } from "./fs-write";
import { loadFileKindAndText } from "./file-kind";
import { formatHashlineRegion, sanitizeOutput, splitVisibleLines, stripHashlinePrefixes } from "./hashline";
import { resolveToCwd } from "./path-utils";
import { loadPrompt } from "./prompt-loader";
import { rememberReadSnapshot } from "./read-snapshot";
import { throwIfAborted } from "./runtime";

const GREP_DESC = loadPrompt(new URL("../prompts/grep.md", import.meta.url)).trim();

const GREP_PROMPT_SNIPPET = loadPrompt(new URL("../prompts/grep-snippet.md", import.meta.url)).trim();

const DEFAULT_LIMIT = 50;
const MAX_LIMIT = 200;
const STDERR_MAX_BYTES = 64 * 1024;

const RG_BIN = "rg";

/** Detect whether ripgrep is available on PATH. Only called at registration time. */
function isRgAvailable(): boolean {
    try {
        const result = spawnSync(RG_BIN, ["--version"], { encoding: "utf-8" });
        return result.error === undefined && result.status === 0;
    } catch {
        return false;
    }
}

/** rg --json submatch: byte offsets into `lines.text` (which includes the newline). */
interface RgSubmatch {
    start: number;
    end: number;
}

/** rg --json match event. */
interface RgMatchEvent {
    type: "match";
    data: {
        path: { text: string };
        line_number: number;
        lines?: { text?: string };
        submatches?: RgSubmatch[];
    };
}

/** Match char ranges within one line, relative to its content. */
type MatchRanges = Array<[number, number]>;

interface RgEvent {
    type: string;
    data: unknown;
}

/** Inclusive range [start, end] of 1-based line numbers. */
interface LineRange {
    start: number;
    end: number;
}

/** Merge a new range into an existing sorted, non-overlapping list. */
function mergeRange(ranges: LineRange[], range: LineRange): void {
    let merged = range;
    const remaining: LineRange[] = [];
    for (const r of ranges) {
        if (r.end < merged.start - 1 || r.start > merged.end + 1) {
            remaining.push(r);
        } else {
            merged = {
                start: Math.min(merged.start, r.start),
                end: Math.max(merged.end, r.end),
            };
        }
    }
    remaining.push(merged);
    remaining.sort((a, b) => a.start - b.start);
    ranges.splice(0, ranges.length, ...remaining);
}

interface RgSearchResult {
    matchesByFile: Map<string, Map<number, MatchRanges>>;
    matches: number;
    truncated: boolean;
}

function addMatch(
    matchesByFile: Map<string, Map<number, MatchRanges>>,
    filePath: string,
    lineNum: number,
    ranges: MatchRanges,
): void {
    let lineMap = matchesByFile.get(filePath);
    if (!lineMap) {
        lineMap = new Map();
        matchesByFile.set(filePath, lineMap);
    }
    // rg emits one event per matching line; merge defensively.
    const existing = lineMap.get(lineNum);
    if (existing) {
        existing.push(...ranges);
    } else {
        lineMap.set(lineNum, ranges);
    }
}

/**
 * Convert rg's UTF-8 byte offsets into JS string offsets (UTF-16 code units)
 * relative to the line content.
 */
function toMatchRanges(submatches: readonly RgSubmatch[] | undefined, lineText: string): MatchRanges {
    if (!submatches || submatches.length === 0) return [];
    const isAscii = lineText.length === Buffer.byteLength(lineText, "utf8");
    const bytes = isAscii ? null : Buffer.from(lineText, "utf8");
    const toCharOffset = (byteOffset: number): number =>
        isAscii ? byteOffset : bytes!.subarray(0, byteOffset).toString("utf8").length;
    return submatches.map((s) => [toCharOffset(s.start), toCharOffset(s.end)]);
}

function parseMatchLine(line: string): { filePath: string; lineNum: number; ranges: MatchRanges } | null {
    if (!line.trim()) return null;
    let event: RgEvent;
    try {
        event = JSON.parse(line) as RgEvent;
    } catch {
        return null;
    }
    if (event.type !== "match") return null;

    const matchEvent = event as RgMatchEvent;
    return {
        filePath: matchEvent.data.path.text,
        lineNum: matchEvent.data.line_number,
        ranges: toMatchRanges(matchEvent.data.submatches, matchEvent.data.lines?.text ?? ""),
    };
}

function appendLimitedStderr(current: string, chunk: string): string {
    const combined = current + chunk;
    if (Buffer.byteLength(combined, "utf8") <= STDERR_MAX_BYTES) {
        return combined;
    }
    return Buffer.from(combined, "utf8").subarray(0, STDERR_MAX_BYTES).toString("utf8");
}

/**
 * Run rg asynchronously, returning at most `limit` match events. Honors
 * AbortSignal by killing the child process. The limit is process-level: we only
 * mark truncated after seeing match number limit + 1, then kill rg and resolve
 * with the first `limit` matches.
 *
 * rg exit codes: 0 = matches found, 1 = no matches, 2 = error.
 */
function runRg(args: string[], limit: number, signal: AbortSignal | undefined): Promise<RgSearchResult> {
    return new Promise((resolve, reject) => {
        if (signal?.aborted) {
            reject(new Error("Aborted"));
            return;
        }

        const child = spawn(RG_BIN, args);
        const rl = createInterface({ input: child.stdout });
        const matchesByFile = new Map<string, Map<number, MatchRanges>>();
        let totalMatched = 0;
        let truncated = false;
        let stoppedByLimit = false;
        let settled = false;
        let stderr = "";

        const cleanup = () => {
            signal?.removeEventListener("abort", onAbort);
        };

        const settleResolve = () => {
            if (settled) return;
            settled = true;
            cleanup();
            resolve({ matchesByFile, matches: totalMatched, truncated });
        };

        const settleReject = (error: Error) => {
            if (settled) return;
            settled = true;
            cleanup();
            rl.close();
            reject(error);
        };

        const stopForLimit = () => {
            if (stoppedByLimit) return;
            truncated = true;
            stoppedByLimit = true;
            cleanup();
            rl.close();
            child.kill();
        };

        // setEncoding lets Node's stream decoder handle multi-byte UTF-8 sequences
        // that span chunk boundaries correctly — spawn's options.encoding is an exec
        // parameter and has no effect here, so we set encoding on the streams directly.
        child.stdout.setEncoding("utf-8");
        child.stderr.setEncoding("utf-8");

        rl.on("line", (line: string) => {
            if (settled || stoppedByLimit) return;
            const match = parseMatchLine(line);
            if (!match) return;

            if (totalMatched >= limit) {
                stopForLimit();
                return;
            }

            addMatch(matchesByFile, match.filePath, match.lineNum, match.ranges);
            totalMatched++;
        });

        child.stderr.on("data", (chunk: string) => {
            stderr = appendLimitedStderr(stderr, chunk);
        });

        const onAbort = () => {
            child.kill();
            settleReject(new Error("Aborted"));
        };
        signal?.addEventListener("abort", onAbort, { once: true });

        child.on("error", (err: Error) => {
            if (stoppedByLimit) return;
            settleReject(new Error(`ripgrep spawn error: ${err.message}`));
        });

        child.on("close", (code: number | null) => {
            if (settled) return;
            if (stoppedByLimit) {
                settleResolve();
                return;
            }
            if (signal?.aborted) {
                settleReject(new Error("Aborted"));
                return;
            }
            if (code === null) {
                settleReject(new Error("ripgrep process terminated unexpectedly"));
                return;
            }
            if (code === 2) {
                settleReject(new Error(`ripgrep error: ${stderr.trim() || "unknown error"}`));
                return;
            }
            settleResolve();
        });
    });
}

function highlightMatchRanges(line: string, ranges: MatchRanges, theme: Theme): string {
    const plain = (chunk: string) => theme.fg("toolOutput", chunk);
    const match = (chunk: string) => theme.bg("searchMatchBg", theme.fg("searchMatchText", chunk));
    const parts: string[] = [];
    let pos = 0;
    for (const [start, end] of ranges) {
        // Guard against drift: offsets come from the file as rg read it.
        if (start < pos || end > line.length || start >= end) continue;
        if (start > pos) parts.push(plain(line.slice(pos, start)));
        parts.push(match(line.slice(start, end)));
        pos = end;
    }
    if (pos < line.length) parts.push(plain(line.slice(pos)));
    return parts.length > 0 ? parts.join("") : plain(line);
}

export function registerGrepTool(pi: ExtensionAPI): void {
    if (!isRgAvailable()) {
        return;
    }

    pi.registerTool({
        name: "grep",
        label: "Grep",
        description: GREP_DESC,
        promptSnippet: GREP_PROMPT_SNIPPET,
        parameters: Type.Object({
            pattern: Type.String({
                description: "Search pattern (regex unless literal: true)",
            }),
            path: Type.Optional(
                Type.String({
                    description: "File or directory to search (defaults to cwd)",
                }),
            ),
            glob: Type.Optional(
                Type.String({
                    description: 'Filename glob filter, e.g. "**/*.ts"',
                }),
            ),
            ignoreCase: Type.Optional(
                Type.Boolean({
                    description: "Case-insensitive matching",
                }),
            ),
            literal: Type.Optional(
                Type.Boolean({
                    description: "Treat pattern as a literal string, not a regex",
                }),
            ),
            context: Type.Optional(
                Type.Integer({
                    minimum: 0,
                    maximum: 5,
                    description: "Number of context lines to show around each match (0–5, default 0)",
                }),
            ),
            limit: Type.Optional(
                Type.Integer({
                    minimum: 1,
                    maximum: MAX_LIMIT,
                    description: `Maximum matched lines to return (default ${DEFAULT_LIMIT}, max ${MAX_LIMIT})`,
                }),
            ),
        }),

        // Pi retains its built-in call renderer; strip anchors only in the result view.
        renderResult(result, { expanded }, theme, context) {
            const text = (context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
            const typed = result as {
                content?: Array<{ type: string; text?: string }>;
                details?: {
                    highlights?: Array<{ line: number; ranges: MatchRanges }>;
                };
            };
            const output = stripHashlinePrefixes(
                (typed.content ?? [])
                    .filter((entry) => entry.type === "text")
                    .map((entry) => sanitizeOutput(entry.text ?? ""))
                    .join("\n"),
            );
            const lines = output.split("\n");
            while (lines.length > 0 && lines[lines.length - 1] === "") {
                lines.pop();
            }

            const highlights = new Map<number, MatchRanges>();
            for (const entry of typed.details?.highlights ?? []) {
                highlights.set(entry.line, entry.ranges);
            }

            const maxLines = expanded ? lines.length : 15;
            const shown = lines.slice(0, maxLines).map((line, index) => {
                const ranges = highlights.get(index);
                return ranges ? highlightMatchRanges(line, ranges, theme) : theme.fg("toolOutput", line);
            });
            let rendered = `\n${shown.join("\n")}`;
            const remaining = lines.length - maxLines;
            if (remaining > 0) {
                rendered += `${theme.fg("muted", `\n... (${remaining} more lines,`)} ${keyHint("app.tools.expand", "to expand")}${theme.fg("muted", ")")}`;
            }
            text.setText(rendered);
            return text;
        },

        async execute(_toolCallId, params, signal, _onUpdate, ctx) {
            throwIfAborted(signal);

            const searchPath = params.path ? resolveToCwd(params.path, ctx.cwd) : ctx.cwd;

            const limit = params.limit ?? DEFAULT_LIMIT;
            const contextLines = params.context ?? 0;

            // Search dotfiles but not .git metadata; ripgrep still honors .gitignore.
            const rgArgs: string[] = ["--json", "--hidden", "--glob", "!.git"];
            if (params.ignoreCase) rgArgs.push("--ignore-case");
            if (params.literal) rgArgs.push("--fixed-strings");
            if (params.glob) rgArgs.push("--glob", params.glob);
            rgArgs.push("--", params.pattern, searchPath);

            const { matchesByFile, matches: totalMatched, truncated } = await runRg(rgArgs, limit, signal);

            throwIfAborted(signal);

            if (totalMatched === 0) {
                return {
                    content: [
                        {
                            type: "text",
                            text: `No matches found for ${params.pattern}.`,
                        },
                    ],
                    details: {
                        matches: 0,
                        files: 0,
                        truncated: false,
                    },
                };
            }

            throwIfAborted(signal);

            const outputParts: string[] = [];
            const highlights: Array<{ line: number; ranges: MatchRanges }> = [];
            let outputLineIndex = 0;
            let fileCount = 0;
            let shownMatches = 0;

            for (const [filePath, matchRangesByLine] of matchesByFile) {
                throwIfAborted(signal);

                // Load file to compute context-correct hashes
                let fileLines: string[];
                try {
                    const loaded = await loadFileKindAndText(filePath);
                    if (loaded.kind === "binary" || loaded.kind === "image" || loaded.kind === "directory") {
                        continue;
                    }
                    const normalized = normalizeToLF(stripBom(loaded.text).text);
                    fileLines = splitVisibleLines(normalized);

                    // Grep anchors need the same snapshot recovery as read anchors.
                    const canonicalWritePath = await resolveMutationTargetPath(filePath);
                    rememberReadSnapshot(canonicalWritePath, normalized);
                } catch {
                    continue;
                }

                const totalFileLines = fileLines.length;

                // rg's line numbers can outlive a file truncated before our reread.
                const validMatchLines = [...matchRangesByLine.keys()].filter((n) => n <= totalFileLines);
                if (validMatchLines.length === 0) continue;

                const ranges: LineRange[] = [];
                for (const lineNum of validMatchLines) {
                    const start = Math.max(1, lineNum - contextLines);
                    const end = Math.min(totalFileLines, lineNum + contextLines);
                    mergeRange(ranges, { start, end });
                }

                fileCount++;
                shownMatches += validMatchLines.length;

                const displayPath = filePath.startsWith(ctx.cwd + "/") ? filePath.slice(ctx.cwd.length + 1) : filePath;

                outputParts.push(`${displayPath}:`);
                outputLineIndex++;

                let prevRangeEnd = -1;
                for (const range of ranges) {
                    if (prevRangeEnd !== -1) {
                        outputParts.push("    ...");
                        outputLineIndex++;
                    }
                    outputParts.push(formatHashlineRegion(fileLines, range.start, range.end));
                    for (let lineNum = range.start; lineNum <= range.end; lineNum++) {
                        const rangesForLine = matchRangesByLine.get(lineNum);
                        if (rangesForLine && rangesForLine.length > 0) {
                            highlights.push({
                                line: outputLineIndex + (lineNum - range.start),
                                ranges: rangesForLine,
                            });
                        }
                    }
                    outputLineIndex += range.end - range.start + 1;
                    prevRangeEnd = range.end;
                }

                outputParts.push("---");
                outputLineIndex++;
            }

            // Count only readable matches; rg's count may include files that disappeared.
            if (fileCount === 0) {
                return {
                    content: [
                        {
                            type: "text",
                            text: `${totalMatched} match${totalMatched !== 1 ? "es" : ""} found, but none could be read back for display (binary, unreadable, or deleted files).`,
                        },
                    ],
                    details: {
                        matches: 0,
                        files: 0,
                        truncated,
                    },
                };
            }
            const summary = `${shownMatches} match${shownMatches !== 1 ? "es" : ""} in ${fileCount} file${fileCount !== 1 ? "s" : ""}.${truncated ? ` (stopped at match limit ${limit})` : ""}`;
            const rawOutput = `${outputParts.join("\n")}\n${summary}`;
            // Reserve room for the notice; Pi's truncateHead retains complete anchor lines.
            const truncation = truncateHead(rawOutput, {
                maxLines: DEFAULT_MAX_LINES - 2,
                maxBytes: DEFAULT_MAX_BYTES - 1024,
            });
            const notice = truncation.truncated
                ? `[Truncated at ${formatSize(DEFAULT_MAX_BYTES)} or ${DEFAULT_MAX_LINES} lines after ${shownMatches} selected matches. Narrow with path/glob or a more specific pattern, then rerun to continue.]`
                : truncated
                  ? `[Stopped at match limit ${limit}. Narrow with path/glob or raise the limit, then rerun to continue.]`
                  : undefined;
            const outputLines = truncation.content.split("\n");
            const visibleHighlights = highlights.filter((entry) => entry.line < outputLines.length);
            return {
                content: [
                    {
                        type: "text",
                        text: notice ? `${truncation.content}\n\n${notice}` : truncation.content,
                    },
                ],
                details: {
                    matches: shownMatches,
                    files: fileCount,
                    truncated: truncated || truncation.truncated,
                    ...(truncation.truncated ? { truncation } : {}),
                    ...(visibleHighlights.length > 0 ? { highlights: visibleHighlights } : {}),
                },
            };
        },
    });
}
