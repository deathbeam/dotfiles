import type { ExtensionAPI, ToolDefinition } from "@earendil-works/pi-coding-agent";
import { keyHint, renderDiff, withFileMutationQueue, type Theme } from "@earendil-works/pi-coding-agent";
import { Box, Text } from "@earendil-works/pi-tui";
import { Type, type TSchema } from "@sinclair/typebox";
import { constants } from "fs";
import { access as fsAccess } from "fs/promises";
import { detectLineEnding, hasMixedLineEndings, normalizeToLF, restoreLineEndings, stripBom } from "./edit-diff";
import { isRecord, normalizeEditRequest } from "./edit-normalize";
import { resolveMutationTargetPath, writeFileAtomically } from "./fs-write";
import { applyHashlineEdits, computeChangedLineRange, resolveEditAnchors, type HashlineToolEdit } from "./hashline";
import { loadFileKindAndText } from "./file-kind";
import { resolveToCwd } from "./path-utils";
import { loadPrompt, loadPromptGuidelines } from "./prompt-loader";
import { throwIfAborted } from "./runtime";
import { buildChangedResponse, buildNoopResponse, type EditMeta, type HashlineEditToolDetails } from "./edit-response";
import { isDuplicateAppliedPayload, recordAppliedEdit, recordNoopEdit } from "./noop-loop-guard";
import { getReadSnapshot, getReadSnapshotVersions, rememberReadSnapshot } from "./read-snapshot";
import { threeWayMerge } from "./merge";

function literalStringSchema<const Value extends string>(value: Value, options: { description: string }) {
    return Type.Unsafe<Value>({
        type: "string",
        enum: [value],
        description: options.description,
    });
}

const hashlineEditLinesSchema = Type.Array(Type.String(), {
    description: "replacement content, one array entry per line, no LINE#HASH prefix",
});

const hashlineReplaceEditSchema = Type.Object(
    {
        op: literalStringSchema("replace", {
            description: "replace one line at pos, or an inclusive pos..end range, with lines",
        }),
        pos: Type.String({ description: "start anchor (LINE#HASH from read)" }),
        end: Type.Optional(
            Type.String({
                description:
                    "inclusive end anchor (LINE#HASH) of the range to replace; omit to replace only the line at pos",
            }),
        ),
        lines: hashlineEditLinesSchema,
    },
    { additionalProperties: false },
);

const hashlineAppendEditSchema = Type.Object(
    {
        op: literalStringSchema("append", {
            description: "insert lines after pos; omit pos to append at EOF",
        }),
        pos: Type.Optional(Type.String({ description: "anchor (LINE#HASH from read) to insert after" })),
        lines: hashlineEditLinesSchema,
    },
    { additionalProperties: false },
);

const hashlinePrependEditSchema = Type.Object(
    {
        op: literalStringSchema("prepend", {
            description: "insert lines before pos; omit pos to prepend at BOF",
        }),
        pos: Type.Optional(
            Type.String({
                description: "anchor (LINE#HASH from read) to insert before",
            }),
        ),
        lines: hashlineEditLinesSchema,
    },
    { additionalProperties: false },
);

const hashlineEditItemSchema = Type.Union(
    [hashlineReplaceEditSchema, hashlineAppendEditSchema, hashlinePrependEditSchema],
    {
        description:
            'discriminated edit item. "replace" uses pos/end/lines; "append" and "prepend" use optional pos + lines.',
    },
);
const hashlineEditToolSchema = Type.Object(
    {
        path: Type.String({ description: "path" }),
        edits: Type.Array(hashlineEditItemSchema, { description: "edits over $path" }),
    },
    { additionalProperties: false },
);
type EditRequestParams = {
    path: string;
    edits: HashlineToolEdit[];
};

type EditPipelineResult = {
    path: string;
    originalNormalized: string;
    originalContent: string;
    result: string;
    bom: string;
    originalEnding: "\r\n" | "\n";
    hadUtf8DecodeErrors: boolean;
    warnings: string[];
    noopEdits?: { editIndex: number; loc: string; currentContent: string }[];
    firstChangedLine?: number;
    lastChangedLine?: number;
};

const EDIT_DESC = loadPrompt(new URL("../prompts/edit.md", import.meta.url)).trim();

const EDIT_PROMPT_SNIPPET = loadPrompt(new URL("../prompts/edit-snippet.md", import.meta.url)).trim();

const EDIT_PROMPT_GUIDELINES = loadPromptGuidelines(new URL("../prompts/edit-guidelines.md", import.meta.url));

const ROOT_KEYS = new Set(["path", "edits"]);

// prepareArguments runs before Pi's schema validation; reject native text-replace
// with anchor guidance here, leaving edit-item validation to resolveEditAnchors.
function assertEditRequest(request: unknown): asserts request is EditRequestParams {
    if (!isRecord(request)) {
        throw new Error("Edit request must be an object.");
    }

    const unknownRootKeys = Object.keys(request).filter((key) => !ROOT_KEYS.has(key));
    if (unknownRootKeys.length > 0) {
        const isTextReplace = unknownRootKeys.some(
            (key) => key === "oldText" || key === "newText" || key === "old_text" || key === "new_text",
        );
        if (isTextReplace) {
            throw new Error(
                `Edit request contains unsupported fields: ${unknownRootKeys.join(", ")}. Text-replace edits are not supported; re-read the file and use "replace", "append", or "prepend" with LINE#HASH anchors.`,
            );
        }
        throw new Error(`Edit request contains unknown or unsupported fields: ${unknownRootKeys.join(", ")}.`);
    }

    if (typeof request.path !== "string" || request.path.length === 0) {
        throw new Error('Edit request requires a non-empty "path" string.');
    }

    if (!Array.isArray(request.edits)) {
        throw new Error('Edit request requires an "edits" array.');
    }
}

/** Shared preview/execute pipeline; accessMode controls writability. */
async function executeEditPipeline(
    params: EditRequestParams,
    cwd: string,
    accessMode: number,
    signal?: AbortSignal,
    resolvedPath?: string,
): Promise<EditPipelineResult> {
    const path = params.path;
    const absolutePath = resolvedPath ?? resolveToCwd(path, cwd);
    const toolEdits = params.edits;

    if (toolEdits.length === 0) {
        throw new Error("No edits provided.");
    }

    throwIfAborted(signal);
    try {
        await fsAccess(absolutePath, accessMode);
    } catch (error: unknown) {
        const code = (error as NodeJS.ErrnoException).code;
        if (code === "ENOENT") {
            throw new Error(`File not found: ${path}. Use the write tool to create new files.`);
        }
        if (code === "EACCES" || code === "EPERM") {
            const accessLabel = accessMode & constants.W_OK ? "not writable" : "not readable";
            throw new Error(`File is ${accessLabel}: ${path}`);
        }
        throw new Error(`Cannot access file: ${path}`);
    }

    throwIfAborted(signal);
    const file = await loadFileKindAndText(absolutePath);
    if (file.kind === "directory") {
        throw new Error(`Path is a directory: ${path}. Use ls to inspect directories.`);
    }
    if (file.kind === "image") {
        throw new Error(`Path is an image file: ${path}. Hashline edit only supports text files.`);
    }
    if (file.kind === "binary") {
        throw new Error(
            `Path is a binary file: ${path} (${file.description}). Hashline edit only supports text files.`,
        );
    }

    throwIfAborted(signal);
    const { bom, text: rawContent } = stripBom(file.text);
    const originalEnding = detectLineEnding(rawContent);
    const mixedEndingWarning = hasMixedLineEndings(rawContent)
        ? `File had mixed line endings (CRLF and LF); this edit rewrote it uniformly as ${originalEnding === "\r\n" ? "CRLF" : "LF"}.`
        : undefined;
    const originalNormalized = normalizeToLF(rawContent);

    const resolved = resolveEditAnchors(toolEdits);

    const extraWarnings: string[] = [];

    const buildResult = (parts: {
        result: string;
        resultWarnings?: string[];
        noopEdits?: EditPipelineResult["noopEdits"];
        firstChangedLine?: number;
        lastChangedLine?: number;
    }): EditPipelineResult => ({
        path,
        originalNormalized,
        originalContent: bom + rawContent,
        result: parts.result,
        bom,
        originalEnding,
        hadUtf8DecodeErrors: file.hadUtf8DecodeErrors === true,
        warnings: [
            ...(mixedEndingWarning ? [mixedEndingWarning] : []),
            ...extraWarnings,
            ...(parts.resultWarnings ?? []),
        ],
        noopEdits: parts.noopEdits,
        firstChangedLine: parts.firstChangedLine,
        lastChangedLine: parts.lastChangedLine,
    });

    // Stale anchors may be replayed against recent read snapshots below.
    let directResult: ReturnType<typeof applyHashlineEdits> | null = null;
    let primaryError: unknown = null;

    try {
        directResult = applyHashlineEdits(originalNormalized, resolved, signal);
    } catch (err: unknown) {
        primaryError = err;
    }

    if (primaryError !== null) {
        const isStale = primaryError instanceof Error && primaryError.message.startsWith("[E_STALE_ANCHOR]");

        if (!isStale) {
            throw primaryError;
        }

        // Skip the live version; only historical reads can help recover stale anchors.
        const versions = getReadSnapshotVersions(absolutePath).filter((v) => v !== originalNormalized);

        if (versions.length === 0) {
            throw primaryError;
        }

        let anyAnchorValid = false;

        for (const snapshot of versions) {
            let snapshotResult: ReturnType<typeof applyHashlineEdits>;
            try {
                snapshotResult = applyHashlineEdits(snapshot, resolved, signal);
            } catch {
                continue;
            }

            anyAnchorValid = true;

            // 3-way merge: base=snapshot, base-edited=snapshotResult, current=live.
            const merged = threeWayMerge(snapshot, snapshotResult.content, originalNormalized);
            if (merged === null) {
                continue;
            }

            const mergedRange = computeChangedLineRange(originalNormalized, merged);

            extraWarnings.push(
                "Recovered stale anchors by replaying this edit against a recent read of this file and merging onto the current content (context-matched merge). Review the diff to confirm the result.",
            );

            return buildResult({
                result: merged,
                resultWarnings: snapshotResult.warnings,
                noopEdits: snapshotResult.noopEdits,
                firstChangedLine: mergedRange?.firstChangedLine,
                lastChangedLine: mergedRange?.lastChangedLine,
            });
        }

        let suffix: string;
        if (anyAnchorValid) {
            suffix =
                "\n(Recovery attempted: your anchors match an older read of this file, but replaying that edit conflicts with changes made since. Re-read to get current anchors.)";
        } else {
            suffix =
                "\n(Your anchors do not match any recent read of this file — they may be from a stale context or copied incorrectly. Re-read before editing.)";
        }
        throw new Error(`${(primaryError as Error).message}${suffix}`);
    }

    const anchorResult = directResult!;
    return buildResult({
        result: anchorResult.content,
        resultWarnings: anchorResult.warnings,
        noopEdits: anchorResult.noopEdits,
        firstChangedLine: anchorResult.firstChangedLine,
        lastChangedLine: anchorResult.lastChangedLine,
    });
}

// TParams is intentionally TSchema, not typeof hashlineEditToolSchema. The
// published `parameters` schema stays strict (discriminated anyOf) for the
// model, but prepareArguments treats params as unknown and defers per-item
// validation to resolveEditAnchors during execute; typing it as
// Static<typeof hashlineEditToolSchema> would claim conformance that
// prepareArguments does not enforce (assertEditRequest is envelope-only).
type EditToolDefinition = ToolDefinition<TSchema, HashlineEditToolDetails>;

const COLLAPSED_DIFF_LINES = 15;

/** Collapse the diff but never hide warnings. */
function capDiffPreview(diff: string, expanded: boolean, theme: Pick<Theme, "fg">): string {
    const lines = diff.split("\n");
    if (expanded || lines.length <= COLLAPSED_DIFF_LINES) {
        return diff;
    }
    const remaining = lines.length - COLLAPSED_DIFF_LINES;
    return [
        ...lines.slice(0, COLLAPSED_DIFF_LINES),
        `${theme.fg("muted", `... (${remaining} more diff lines,`)} ${keyHint("app.tools.expand", "to expand")}${theme.fg("muted", ")")}`,
    ].join("\n");
}

function buildEditToolDefinition(): EditToolDefinition {
    return {
        name: "edit",
        label: "Edit",
        description: EDIT_DESC,
        parameters: hashlineEditToolSchema,
        promptSnippet: EDIT_PROMPT_SNIPPET,
        promptGuidelines: EDIT_PROMPT_GUIDELINES,
        prepareArguments: (args: unknown) => {
            const normalized = normalizeEditRequest(args);
            assertEditRequest(normalized);
            return normalized;
        },
        // Pi keeps the built-in call renderer; replace its result renderer to show
        // recovery warnings and no-op results that its diff-only view would hide.
        renderResult(result, { expanded, isPartial }, theme, context) {
            const text = (context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
            if (isPartial) {
                text.setText(theme.fg("warning", "Editing..."));
                return text;
            }

            // Match Pi's built-in success/error shell coloring.
            const callComponent = (context.state as { callComponent?: unknown }).callComponent;
            if (callComponent instanceof Box) {
                callComponent.setBgFn((value) => theme.bg(context.isError ? "toolErrorBg" : "toolSuccessBg", value));
            }

            const typed = result as {
                content?: Array<{ type: string; text?: string }>;
                details?: HashlineEditToolDetails;
            };
            const modelText = typed.content?.find((entry) => entry.type === "text")?.text;

            if (context.isError) {
                text.setText(modelText ? theme.fg("error", modelText) : "");
                return text;
            }

            const details = typed.details;
            const sections: string[] = [];
            if (details?.diff) {
                sections.push(capDiffPreview(renderDiff(details.diff), expanded, theme));
            }
            if (details && details.warnings.length > 0) {
                sections.push(details.warnings.map((warning) => theme.fg("warning", warning)).join("\n"));
            }
            if (!details?.diff && modelText) {
                sections.push(modelText);
            }
            // No leading newline: the call block is a Box with its own bottom
            // padding, and adding one here doubles the gap above the diff.
            text.setText(sections.join("\n\n"));
            return text;
        },

        // Avoid wrapping Pi's own Box in another tool shell.
        renderShell: "self",

        async execute(_toolCallId, params, signal, _onUpdate, ctx) {
            const { path, edits } = params as EditRequestParams;
            const absolutePath = resolveToCwd(path, ctx.cwd);
            const mutationTargetPath = await resolveMutationTargetPath(absolutePath);
            return withFileMutationQueue(mutationTargetPath, async () => {
                throwIfAborted(signal);

                // Detect a repeated applied payload before stale-anchor validation
                // masks the duplication with E_STALE_ANCHOR.
                const appliedPayloadKey = JSON.stringify(edits);
                if (isDuplicateAppliedPayload(mutationTargetPath, appliedPayloadKey)) {
                    const snapshot = getReadSnapshot(mutationTargetPath);
                    if (snapshot !== null) {
                        const currentFile = await loadFileKindAndText(mutationTargetPath);
                        if (currentFile.kind === "text") {
                            const currentNormalized = normalizeToLF(stripBom(currentFile.text).text);
                            if (snapshot === currentNormalized) {
                                throw new Error(
                                    `[E_DUPLICATE_EDIT] This exact edit was already applied to ${path} by your previous edit call — the file already contains this change. Do NOT resend the same payload: that would duplicate the inserted lines. Re-read the file to see the current state before editing again.`,
                                );
                            }
                        }
                    }
                }

                const {
                    originalNormalized,
                    originalContent,
                    result,
                    bom,
                    originalEnding,
                    hadUtf8DecodeErrors,
                    warnings,
                    noopEdits,
                    firstChangedLine,
                    lastChangedLine,
                } = await executeEditPipeline(
                    { path, edits },
                    ctx.cwd,
                    constants.R_OK | constants.W_OK,
                    signal,
                    mutationTargetPath,
                );

                if (originalNormalized === result) {
                    const { count, escalate } = recordNoopEdit(mutationTargetPath, appliedPayloadKey);
                    if (escalate) {
                        throw new Error(
                            `[E_NOOP_LOOP] Edit to ${path} was a byte-identical no-op ${count} times in a row. STOP re-sending this payload. Re-read the file — the content you are trying to write already exists, or your anchors point at the wrong lines.`,
                        );
                    }
                    return buildNoopResponse({
                        path,
                        noopEdits,
                        warnings,
                    });
                }

                if (hadUtf8DecodeErrors) {
                    warnings.push("Non-UTF-8 bytes were shown as U+FFFD; this edit rewrote the file as UTF-8.");
                }

                throwIfAborted(signal);
                await writeFileAtomically(mutationTargetPath, bom + restoreLineEndings(result, originalEnding), {
                    alreadyResolved: true,
                    expectedContent: originalContent,
                });
                recordAppliedEdit(mutationTargetPath, appliedPayloadKey);

                // Keep response anchors mergeable after later external changes.
                rememberReadSnapshot(mutationTargetPath, result);

                const editMeta: EditMeta = {
                    firstChangedLine,
                    lastChangedLine,
                };

                return buildChangedResponse({
                    originalNormalized,
                    result,
                    warnings,
                    editMeta,
                });
            });
        },
    };
}

export function registerEditTool(pi: ExtensionAPI): void {
    pi.registerTool(buildEditToolDefinition());
}
