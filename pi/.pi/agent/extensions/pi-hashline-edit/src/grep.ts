import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { keyHint } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "@sinclair/typebox";
import { spawn, spawnSync } from "child_process";
import { createInterface } from "readline";
import { normalizeToLF, stripBom } from "./edit-diff";
import { resolveMutationTargetPath } from "./fs-write";
import { loadFileKindAndText } from "./file-kind";
import {
	formatHashlineRegion,
	sanitizeOutput,
	splitVisibleLines,
	stripHashlinePrefixes,
} from "./hashline";
import { resolveToCwd } from "./path-utils";
import { loadPrompt } from "./prompt-loader";
import { rememberReadSnapshot } from "./read-snapshot";
import { throwIfAborted } from "./runtime";

const GREP_DESC = loadPrompt(new URL("../prompts/grep.md", import.meta.url)).trim();

const GREP_PROMPT_SNIPPET = loadPrompt(
	new URL("../prompts/grep-snippet.md", import.meta.url),
).trim();

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

/** rg --json match event. */
interface RgMatchEvent {
	type: "match";
	data: {
		path: { text: string };
		line_number: number;
	};
}

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
	matchesByFile: Map<string, number[]>;
	matches: number;
	truncated: boolean;
}

function addMatch(
	matchesByFile: Map<string, number[]>,
	filePath: string,
	lineNum: number,
): void {
	if (!matchesByFile.has(filePath)) {
		matchesByFile.set(filePath, []);
	}
	matchesByFile.get(filePath)!.push(lineNum);
}

function parseMatchLine(line: string): { filePath: string; lineNum: number } | null {
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
	};
}

function appendLimitedStderr(current: string, chunk: string): string {
	const combined = current + chunk;
	if (Buffer.byteLength(combined, "utf8") <= STDERR_MAX_BYTES) {
		return combined;
	}
	return Buffer.from(combined, "utf8")
		.subarray(0, STDERR_MAX_BYTES)
		.toString("utf8");
}

/**
 * Run rg asynchronously, returning at most `limit` match events. Honors
 * AbortSignal by killing the child process. The limit is process-level: we only
 * mark truncated after seeing match number limit + 1, then kill rg and resolve
 * with the first `limit` matches.
 *
 * rg exit codes: 0 = matches found, 1 = no matches, 2 = error.
 */
function runRg(
	args: string[],
	limit: number,
	signal: AbortSignal | undefined,
): Promise<RgSearchResult> {
	return new Promise((resolve, reject) => {
		if (signal?.aborted) {
			reject(new Error("Aborted"));
			return;
		}

		const child = spawn(RG_BIN, args);
		const rl = createInterface({ input: child.stdout });
		const matchesByFile = new Map<string, number[]>();
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

			addMatch(matchesByFile, match.filePath, match.lineNum);
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
			// code === null means the process was killed (signal) or spawn failed
			if (code === null) {
				settleReject(new Error("ripgrep process terminated unexpectedly"));
				return;
			}
			// rg exits 2 for actual errors (invalid regex, unreadable path, etc.)
			if (code === 2) {
				settleReject(new Error(`ripgrep error: ${stderr.trim() || "unknown error"}`));
				return;
			}
			// code 0 (matches) and 1 (no matches) are both success from our perspective
			settleResolve();
		});
	});
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

		// pi's built-in grep renderCall (pattern/path/glob header) is merged in
		// by tool name; the result renderer mirrors the built-in (plain lines,
		// 15-line collapsed preview) but strips the model-facing LINE#HASH
		// prefixes so the view matches pi's built-in grep.
		renderResult(result, { expanded }, theme, context) {
			const text =
				(context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
			const typed = result as {
				content?: Array<{ type: string; text?: string }>;
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

			const maxLines = expanded ? lines.length : 15;
			const shown = lines
				.slice(0, maxLines)
				.map((line) => theme.fg("toolOutput", line));
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

			const searchPath = params.path
				? resolveToCwd(params.path, ctx.cwd)
				: ctx.cwd;

			const limit = params.limit ?? DEFAULT_LIMIT;
			const contextLines = params.context ?? 0;

			const rgArgs: string[] = ["--json"];
			if (params.ignoreCase) rgArgs.push("--ignore-case");
			if (params.literal) rgArgs.push("--fixed-strings");
			if (params.glob) rgArgs.push("--glob", params.glob);
			rgArgs.push("--", params.pattern, searchPath);

			// Async spawn: does not block the event loop; honors AbortSignal.
			// runRg throws on process-level failures — never silently returns empty.
			const { matchesByFile, matches: totalMatched, truncated } = await runRg(
				rgArgs,
				limit,
				signal,
			);

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
			let fileCount = 0;
			let shownMatches = 0;

			for (const [filePath, matchLines] of matchesByFile) {
				throwIfAborted(signal);

				// Load file to compute context-correct hashes
				let fileLines: string[];
				try {
					const loaded = await loadFileKindAndText(filePath);
					if (
						loaded.kind === "binary" ||
						loaded.kind === "image" ||
						loaded.kind === "directory"
					) {
						continue;
					}
					const normalized = normalizeToLF(stripBom(loaded.text).text);
					fileLines = splitVisibleLines(normalized);

					// Record snapshot so that edit's stale-anchor recovery and
					// duplicate-edit guard work identically whether anchors came from
					// read or grep. Uses the same canonical path convention as read.ts.
					const canonicalWritePath = await resolveMutationTargetPath(filePath);
					rememberReadSnapshot(canonicalWritePath, normalized);
				} catch {
					continue;
				}

				const totalFileLines = fileLines.length;

				// Guard against a race where the file was truncated between rg reading
				// it and our loadFileKindAndText call. Out-of-bounds line numbers would
				// make formatHashlineRegion push empty strings; filter them out first.
				const validMatchLines = matchLines.filter((n) => n <= totalFileLines);
				if (validMatchLines.length === 0) continue;

				const ranges: LineRange[] = [];
				for (const lineNum of validMatchLines) {
					const start = Math.max(1, lineNum - contextLines);
					const end = Math.min(totalFileLines, lineNum + contextLines);
					mergeRange(ranges, { start, end });
				}

				fileCount++;
				shownMatches += validMatchLines.length;

				// Relative path for display
				const displayPath = filePath.startsWith(ctx.cwd + "/")
					? filePath.slice(ctx.cwd.length + 1)
					: filePath;

				outputParts.push(`${displayPath}:`);

				let prevRangeEnd = -1;
				for (const range of ranges) {
					if (prevRangeEnd !== -1) {
						outputParts.push("    ...");
					}
					outputParts.push(formatHashlineRegion(fileLines, range.start, range.end));
					prevRangeEnd = range.end;
				}

				outputParts.push("---");
			}

			// Count from the rendered output, not the raw rg tally: files skipped
			// during rendering (binary/image/unreadable/raced) must not appear in
			// the summary.
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
			const summary = `${shownMatches} match${shownMatches !== 1 ? "es" : ""} in ${fileCount} file${fileCount !== 1 ? "s" : ""}.${truncated ? ` (truncated at ${limit})` : ""}`;
			outputParts.push(summary);

			return {
				content: [
					{
						type: "text",
						text: outputParts.join("\n"),
					},
				],
				details: {
					matches: shownMatches,
					files: fileCount,
					truncated,
				},
			};
		},
	});
}
