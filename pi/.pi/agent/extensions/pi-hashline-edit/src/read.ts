import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	createReadTool,
	formatSize,
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	truncateHead,
	type TruncationResult,
} from "@earendil-works/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { access as fsAccess } from "fs/promises";
import { constants } from "fs";
import { normalizeToLF, stripBom } from "./edit-diff";
import { loadFileKindAndText } from "./file-kind";
import { formatHashlineRegion, splitVisibleLines } from "./hashline";
import { resolveToCwd } from "./path-utils";
import { loadPrompt, loadPromptGuidelines } from "./prompt-loader";
import { throwIfAborted } from "./runtime";
import { resolveMutationTargetPath } from "./fs-write";
import { rememberReadSnapshot } from "./read-snapshot";
import { clearAppliedPayload } from "./noop-loop-guard";

const READ_DESC = loadPrompt(new URL("../prompts/read.md", import.meta.url))
	.replaceAll("{{DEFAULT_MAX_LINES}}", String(DEFAULT_MAX_LINES))
	.replaceAll("{{DEFAULT_MAX_BYTES}}", formatSize(DEFAULT_MAX_BYTES))
	.trim();

const READ_PROMPT_SNIPPET = loadPrompt(
	new URL("../prompts/read-snippet.md", import.meta.url),
).trim();

const READ_PROMPT_GUIDELINES = loadPromptGuidelines(
	new URL("../prompts/read-guidelines.md", import.meta.url),
);

function normalizePositiveInteger(
	value: number | undefined,
	name: "offset" | "limit",
): number | undefined {
	if (value === undefined) {
		return undefined;
	}

	if (!Number.isInteger(value) || value < 1) {
		throw new Error(`Read request field "${name}" must be a positive integer.`);
	}

	return value;
}

function formatHashlineReadPreview(
	text: string,
	options: { offset?: number; limit?: number; raw?: boolean },
): { text: string; truncation?: TruncationResult; nextOffset?: number } {
	const allLines = splitVisibleLines(text);
	const totalLines = allLines.length;
	const startLine = normalizePositiveInteger(options.offset, "offset") ?? 1;
	if (totalLines === 0) {
		if (startLine === 1) {
			return {
				text: "File is empty. Use edit with prepend or append and omit pos to insert content.",
			};
		}

		return {
			text: `Offset ${startLine} is beyond end of file (0 lines total). The file is empty. Use edit with prepend or append and omit pos to insert content.`,
		};
	}

	if (startLine > totalLines) {
		return {
			text: `Offset ${startLine} is beyond end of file (${totalLines} lines total). Use offset=1 to read from the start, or offset=${totalLines} to read the last line.`,
		};
	}

	const limit = normalizePositiveInteger(options.limit, "limit");
	const endIdx = limit
		? Math.min(startLine - 1 + limit, totalLines)
		: totalLines;
	// Raw mode skips LINE#HASH prefixes. The selection, truncation, and
	// continuation notices are identical to hashline mode — single code path
	// so the two modes cannot drift on edge cases.
	const formatted = options.raw
		? allLines.slice(startLine - 1, endIdx).join("\n")
		: formatHashlineRegion(allLines, startLine, endIdx);

	const truncation = truncateHead(formatted);
	if (truncation.firstLineExceedsLimit) {
		return {
			text: options.raw
				? `[Line ${startLine} exceeds ${formatSize(truncation.maxBytes)}; a single line this large cannot be displayed. Use bash to inspect it.]`
				: `[Line ${startLine} exceeds ${formatSize(truncation.maxBytes)}. Hashline output requires full lines; cannot compute hashes for a truncated preview. Use bash to inspect it.]`,
			truncation,
		};
	}

	let preview = truncation.content;
	let nextOffset: number | undefined;
	if (truncation.truncated) {
		const endLineDisplay = startLine + truncation.outputLines - 1;
		nextOffset = endLineDisplay + 1;
		if (truncation.truncatedBy === "lines") {
			preview += `\n\n[Showing lines ${startLine}-${endLineDisplay} of ${totalLines}. Use offset=${nextOffset} to continue.]`;
		} else {
			preview += `\n\n[Showing lines ${startLine}-${endLineDisplay} of ${totalLines} (${formatSize(truncation.maxBytes)} limit). Use offset=${nextOffset} to continue.]`;
		}
	} else if (endIdx < totalLines) {
		nextOffset = endIdx + 1;
		preview += `\n\n[Showing lines ${startLine}-${endIdx} of ${totalLines}. Use offset=${nextOffset} to continue.]`;
	}

	return {
		text: preview,
		truncation: truncation.truncated ? truncation : undefined,
		...(nextOffset !== undefined ? { nextOffset } : {}),
	};
}

export function registerReadTool(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "read",
		label: "Read",
		description: READ_DESC,
		promptSnippet: READ_PROMPT_SNIPPET,
		promptGuidelines: READ_PROMPT_GUIDELINES,
		parameters: Type.Object({
			path: Type.String({
				description: "Path to the file to read (relative or absolute)",
			}),
			offset: Type.Optional(
				Type.Integer({
					minimum: 1,
					description: "Line number to start reading from (1-indexed)",
				}),
			),
			limit: Type.Optional(
				Type.Integer({
					minimum: 1,
					description: "Maximum number of lines to read",
				}),
			),
			raw: Type.Optional(
				Type.Boolean({
					description:
						"Return plain text without LINE#HASH anchors. Saves tokens when you do not plan to edit this file.",
				}),
			),
		}),

		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const rawPath = params.path;
			const absolutePath = resolveToCwd(rawPath, ctx.cwd);

			throwIfAborted(signal);
			try {
				await fsAccess(absolutePath, constants.R_OK);
			} catch (error: unknown) {
				const code =
					error instanceof Error
						? (error as NodeJS.ErrnoException).code
						: undefined;
				if (code === "ENOENT") {
					throw new Error(`File not found: ${rawPath}`);
				}
				if (code === "EACCES" || code === "EPERM") {
					throw new Error(`File is not readable: ${rawPath}`);
				}
				throw new Error(`Cannot access file: ${rawPath}`);
			}

			throwIfAborted(signal);
			const file = await loadFileKindAndText(absolutePath);
			if (file.kind === "directory") {
				throw new Error(
					`Path is a directory: ${rawPath}. Use ls to inspect directories.`,
				);
			}

			if (file.kind === "binary") {
				throw new Error(
					`Path is a binary file: ${rawPath} (${file.description}). Hashline read only supports text files and supported images.`,
				);
			}

			if (file.kind === "image") {
				const builtinRead = createReadTool(ctx.cwd);
				const executeBuiltinRead = builtinRead.execute as unknown as (
					toolCallId: string,
					input: typeof params,
					abortSignal: typeof signal,
					onUpdate: typeof _onUpdate,
					context: typeof ctx,
				) => ReturnType<typeof builtinRead.execute>;
				return executeBuiltinRead(_toolCallId, params, signal, _onUpdate, ctx);
			}

			throwIfAborted(signal);
			const normalized = normalizeToLF(stripBom(file.text).text);
			const preview = formatHashlineReadPreview(normalized, {
				offset: params.offset,
				limit: params.limit,
				raw: params.raw,
			});
			// Capture snapshot for stale-anchor recovery. Only hashline (non-raw)
			// reads mint anchors, so raw reads must not update the slot — anchors
			// from a raw read do not exist, so there is nothing to recover against.
			if (!params.raw) {
				const canonicalWritePath = await resolveMutationTargetPath(absolutePath);
				rememberReadSnapshot(canonicalWritePath, normalized);
				// A deliberate re-read after an edit clears the duplicate-edit guard
				// for this path — the model has seen the current state and any
				// subsequent identical payload is intentional, not a retry loop.
				clearAppliedPayload(canonicalWritePath);
			}

			// Invalid UTF-8 bytes are decoded as U+FFFD, matching Pi's built-in
			// tools. Warn only when the decoder reported invalid bytes; a literal,
			// valid U+FFFD in a UTF-8 file should not be treated as lossy decoding.
			const previewText =
				file.hadUtf8DecodeErrors === true
					? `${preview.text}\n\n[Non-UTF-8 bytes shown as U+FFFD; editing rewrites the file as UTF-8.]`
					: preview.text;

			return {
				content: [{ type: "text", text: previewText }],
			details: {
				truncation: preview.truncation,
					...(preview.nextOffset !== undefined
						? { nextOffset: preview.nextOffset }
						: {}),
				},
			};
		},
	});
}
