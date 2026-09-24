import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
    createReadTool,
    formatSize,
    DEFAULT_MAX_BYTES,
    DEFAULT_MAX_LINES,
    getLanguageFromPath,
    highlightCode,
    truncateHead,
    type Theme,
    type TruncationResult,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "@sinclair/typebox";
import { access as fsAccess } from "fs/promises";
import { constants } from "fs";
import { normalizeToLF, stripBom } from "./edit-diff";
import { loadFileKindAndText } from "./file-kind";
import {
    HASH_LENGTH,
    formatHashlineRegion,
    sanitizeOutput,
    splitVisibleLines,
    stripHashlinePrefixes,
} from "./hashline";
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

const READ_PROMPT_SNIPPET = loadPrompt(new URL("../prompts/read-snippet.md", import.meta.url)).trim();

const READ_PROMPT_GUIDELINES = loadPromptGuidelines(new URL("../prompts/read-guidelines.md", import.meta.url));

function normalizePositiveInteger(value: number | undefined, name: "offset" | "limit"): number | undefined {
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
    const requestedEnd = limit ? Math.min(startLine - 1 + limit, totalLines) : totalLines;
    // Reserve two lines and 1KB for the continuation notice.
    const candidateEnd = Math.min(requestedEnd, startLine + DEFAULT_MAX_LINES - 3);
    let capReason: "lines" | "bytes" | undefined = candidateEnd < requestedEnd ? "lines" : undefined;
    const lineNumberWidth = String(candidateEnd).length;
    const prefixBytes = options.raw
        ? 0
        : Buffer.byteLength(String(candidateEnd).padStart(lineNumberWidth, " ")) + HASH_LENGTH + 2;
    let endLine = startLine - 1;
    let outputBytes = 0;
    for (let lineNum = startLine; lineNum <= candidateEnd; lineNum++) {
        const lineBytes =
            prefixBytes + Buffer.byteLength(allLines[lineNum - 1]!, "utf8") + (lineNum > startLine ? 1 : 0);
        if (outputBytes + lineBytes > DEFAULT_MAX_BYTES - 1024) break;
        outputBytes += lineBytes;
        endLine = lineNum;
    }
    if (endLine < candidateEnd) capReason = "bytes";

    // Anchors cannot be truncated mid-line, including when pagination needs space.
    if (endLine < startLine) {
        const line = allLines[startLine - 1]!;
        const oversized = options.raw
            ? line
            : `${String(startLine).padStart(lineNumberWidth, " ")}#${"Z".repeat(HASH_LENGTH)}:${line}`;
        return {
            text: `[Line ${startLine} cannot fit as a complete ${options.raw ? "raw" : "hashline"} line within ${formatSize(DEFAULT_MAX_BYTES)} of output (including pagination). Use bash to inspect it.]`,
            truncation: truncateHead(oversized, { maxBytes: DEFAULT_MAX_BYTES - 1024 }),
        };
    }

    // Hash against the full file so the last displayed line retains its next-line context.
    const formatted = options.raw
        ? allLines.slice(startLine - 1, endLine).join("\n")
        : formatHashlineRegion(allLines, startLine, endLine);
    const measured = truncateHead(formatted);
    const truncation: TruncationResult | undefined = capReason
        ? {
              ...measured,
              truncated: true,
              truncatedBy: capReason,
              totalLines,
              totalBytes: Buffer.byteLength(text, "utf8"),
              outputLines: endLine - startLine + 1,
              outputBytes,
          }
        : undefined;
    let preview = formatted;
    let nextOffset: number | undefined;
    if (truncation) {
        nextOffset = endLine + 1;
        const limitLabel = truncation.truncatedBy === "lines" ? "" : ` (${formatSize(DEFAULT_MAX_BYTES)} limit)`;
        preview += `\n\n[Showing lines ${startLine}-${endLine} of ${totalLines}${limitLabel}. Use offset=${nextOffset} to continue.]`;
    } else if (endLine < totalLines) {
        nextOffset = endLine + 1;
        preview += `\n\n[Showing lines ${startLine}-${endLine} of ${totalLines}. Use offset=${nextOffset} to continue.]`;
    }

    return {
        text: preview,
        truncation,
        ...(nextOffset !== undefined ? { nextOffset } : {}),
    };
}

/** Strip anchors only in the TUI: highlighting treats `#ABC:` as a comment. */
function formatReadResultText(output: string, lang: string | undefined, theme: Pick<Theme, "fg">): string {
    const lines = stripHashlinePrefixes(output).split("\n");
    while (lines.length > 0 && lines[lines.length - 1] === "") {
        lines.pop();
    }

    const rendered = lang ? highlightCode(lines.join("\n"), lang) : lines.map((line) => theme.fg("toolOutput", line));
    return `\n${rendered.join("\n")}`;
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
                const code = error instanceof Error ? (error as NodeJS.ErrnoException).code : undefined;
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
                throw new Error(`Path is a directory: ${rawPath}. Use ls to inspect directories.`);
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
                    ...(preview.nextOffset !== undefined ? { nextOffset: preview.nextOffset } : {}),
                },
            };
        },

        // pi's built-in read renderer highlights the raw text, where the
        // `LINE#HASH:` prefix makes every line look like a comment; this one
        // strips the prefix first. Collapsed results stay empty (same as pi).
        renderResult(result, { expanded }, theme, context) {
            const text = (context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
            if (!expanded && !context.isError) {
                text.setText("");
                return text;
            }

            const typed = result as {
                content?: Array<{ type: string; text?: string }>;
            };
            const output = (typed.content ?? [])
                .filter((entry) => entry.type === "text")
                .map((entry) => sanitizeOutput(entry.text ?? "").replace(/\r/g, ""))
                .join("\n");
            const rawPath = (context.args as { path?: unknown } | undefined)?.path;
            const lang = !context.isError && typeof rawPath === "string" ? getLanguageFromPath(rawPath) : undefined;
            text.setText(formatReadResultText(output, lang, theme));
            return text;
        },
    });
}
