import { Text } from "@earendil-works/pi-tui";
import type {
	ExtensionAPI,
	ToolDefinition,
} from "@earendil-works/pi-coding-agent";
import { withFileMutationQueue } from "@earendil-works/pi-coding-agent";
import { Type, type TSchema } from "@sinclair/typebox";
import { constants } from "fs";
import { access as fsAccess } from "fs/promises";
import {
	detectLineEnding,
	generateDiffString,
	hasMixedLineEndings,
	normalizeToLF,
	restoreLineEndings,
	stripBom,
} from "./edit-diff";
import { isRecord, normalizeEditRequest } from "./edit-normalize";
import { resolveMutationTargetPath, writeFileAtomically } from "./fs-write";
import {
	applyHashlineEdits,
	computeChangedLineRange,
	resolveEditAnchors,
	type HashlineToolEdit,
} from "./hashline";
import { loadFileKindAndText } from "./file-kind";
import { resolveToCwd } from "./path-utils";
import { loadPrompt, loadPromptGuidelines } from "./prompt-loader";
import { throwIfAborted } from "./runtime";
import {
	buildChangedResponse,
	buildNoopResponse,
	type EditMeta,
	type HashlineEditToolDetails,
} from "./edit-response";
import {
	isDuplicateAppliedPayload,
	recordAppliedEdit,
	recordNoopEdit,
} from "./noop-loop-guard";
import { getReadSnapshot, getReadSnapshotVersions, rememberReadSnapshot } from "./read-snapshot";
import { threeWayMerge } from "./merge";
import {
	formatEditCall,
	formatEditResultText,
	getRenderablePreviewInput,
	getRenderedEditTextContent,
	type EditPreview,
	type EditRenderState,
} from "./edit-render";

function literalStringSchema<const Value extends string>(
	value: Value,
	options: { description: string },
) {
	return Type.Unsafe<Value>({
		type: "string",
		enum: [value],
		description: options.description,
	});
}

const hashlineEditLinesSchema = Type.Array(Type.String(), {
	description:
		"replacement content, one array entry per line, no LINE#HASH prefix",
});

const hashlineReplaceEditSchema = Type.Object(
	{
		op: literalStringSchema("replace", {
			description:
				"replace one line at pos, or an inclusive pos..end range, with lines",
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
		pos: Type.Optional(
			Type.String({ description: "anchor (LINE#HASH from read) to insert after" }),
		),
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
	[
		hashlineReplaceEditSchema,
		hashlineAppendEditSchema,
		hashlinePrependEditSchema,
	],
	{
		description:
			'discriminated edit item. "replace" uses pos/end/lines; "append" and "prepend" use optional pos + lines.',
	},
);
const hashlineEditToolSchema = Type.Object(
	{
		path: Type.String({ description: "path" }),
		edits: Type.Array(hashlineEditItemSchema, { description: "edits over $path" }),
		// Dialect noise (file_path alias, JSON-string edits) is folded into the
		// canonical `edits` shape by normalizeEditRequest in the prepareArguments
		// hook, which runs before this schema is validated. Native text-replace
		// payloads are not folded — they fail validation with anchor guidance.
	},
	{ additionalProperties: false },
);
export type EditRequestParams = {
	path: string;
	edits: HashlineToolEdit[];
};

type EditPipelineResult = {
	path: string;
	originalNormalized: string;
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

const EDIT_PROMPT_SNIPPET = loadPrompt(
	new URL("../prompts/edit-snippet.md", import.meta.url),
).trim();

const EDIT_PROMPT_GUIDELINES = loadPromptGuidelines(
	new URL("../prompts/edit-guidelines.md", import.meta.url),
);

const ROOT_KEYS = new Set(["path", "edits"]);

// Validates the edit request envelope after normalizeEditRequest has
// converged dialect noise. This runs in prepareArguments — BEFORE pi's
// schema validation — so it can turn native oldText/newText payloads into a
// teaching error instead of AJV's mechanical one, and it also backs up
// direct execute() callers that bypass the agent loop's validation.
// Envelope only: path, edits array, unknown root keys. Per-edit validation
// is delegated to resolveEditAnchors (src/hashline/parse.ts).
function assertEditRequest(
	request: unknown,
): asserts request is EditRequestParams {
	if (!isRecord(request)) {
		throw new Error("Edit request must be an object.");
	}

	const unknownRootKeys = Object.keys(request).filter(
		(key) => !ROOT_KEYS.has(key),
	);
	if (unknownRootKeys.length > 0) {
		const isTextReplace = unknownRootKeys.some(
			(key) =>
				key === "oldText" ||
				key === "newText" ||
				key === "old_text" ||
				key === "new_text",
		);
		if (isTextReplace) {
			throw new Error(
				`Edit request contains unsupported fields: ${unknownRootKeys.join(", ")}. Text-replace edits are not supported; re-read the file and use "replace", "append", or "prepend" with LINE#HASH anchors.`,
			);
		}
		throw new Error(
			`Edit request contains unknown or unsupported fields: ${unknownRootKeys.join(", ")}.`,
		);
	}

	if (typeof request.path !== "string" || request.path.length === 0) {
		throw new Error('Edit request requires a non-empty "path" string.');
	}

	if (!Array.isArray(request.edits)) {
		throw new Error('Edit request requires an "edits" array.');
	}

	// Per-edit validation lives in resolveEditAnchors — the single source of
	// truth for edit-item shape, op constraints, and anchor parsing.
}

/**
 * Shared edit pipeline: read file, resolve anchors, and apply edits. Public
 * entrypoints normalize + validate before calling this; access mode controls
 * whether the file must be writable.
 */
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
			const accessLabel =
				accessMode & constants.W_OK ? "not writable" : "not readable";
			throw new Error(`File is ${accessLabel}: ${path}`);
		}
		throw new Error(`Cannot access file: ${path}`);
	}

	throwIfAborted(signal);
	const file = await loadFileKindAndText(absolutePath);
	if (file.kind === "directory") {
		throw new Error(
			`Path is a directory: ${path}. Use ls to inspect directories.`,
		);
	}
	if (file.kind === "image") {
		throw new Error(
			`Path is an image file: ${path}. Hashline edit only supports text files.`,
		);
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

	// Both the direct-apply and snapshot-recovery paths return the same shape,
	// differing only in the applied content, its per-result warnings, and the
	// changed-line range. Build the common envelope once.
	const buildResult = (parts: {
		result: string;
		resultWarnings?: string[];
		noopEdits?: EditPipelineResult["noopEdits"];
		firstChangedLine?: number;
		lastChangedLine?: number;
	}): EditPipelineResult => ({
		path,
		originalNormalized,
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

	// Attempt to apply the edits directly. On E_STALE_ANCHOR, fall through to
	// the multi-version snapshot recovery block below.
	let directResult: ReturnType<typeof applyHashlineEdits> | null = null;
	let primaryError: unknown = null;

	try {
		directResult = applyHashlineEdits(originalNormalized, resolved, signal);
	} catch (err: unknown) {
		primaryError = err;
	}

	if (primaryError !== null) {
		// Only attempt snapshot recovery for stale-anchor errors.
		const isStale =
			primaryError instanceof Error &&
			primaryError.message.startsWith("[E_STALE_ANCHOR]");

		if (!isStale || !absolutePath) {
			throw primaryError;
		}

		// absolutePath is the canonical mutation-target path when resolvedPath was
		// provided (execute path); fall back gracefully when not (preview path).
		const canonicalPath = absolutePath;

		// Try each stored version (newest first), skipping any that matches the
		// live content (those would give a trivially identical replay and cannot
		// help). Track whether any version had valid anchors but a merge conflict,
		// for a more informative error if all versions fail.
		const versions = getReadSnapshotVersions(canonicalPath).filter(
			(v) => v !== originalNormalized,
		);

		if (versions.length === 0) {
			// No usable snapshot history: surface original error unchanged.
			throw primaryError;
		}

		let anyAnchorValid = false;

		for (const snapshot of versions) {
			// Try replaying the edits against this historical snapshot.
			let snapshotResult: ReturnType<typeof applyHashlineEdits>;
			try {
				snapshotResult = applyHashlineEdits(snapshot, resolved, signal);
			} catch {
				// Anchors not valid against this version — try older ones.
				continue;
			}

			anyAnchorValid = true;

			// 3-way merge: base=snapshot, base-edited=snapshotResult, current=live.
			const merged = threeWayMerge(snapshot, snapshotResult.content, originalNormalized);
			if (merged === null) {
				// Merge conflict for this version — try older ones.
				continue;
			}

			// Recompute changed-line range against the live file.
			const mergedRange = computeChangedLineRange(originalNormalized, merged);

			extraWarnings.push(
				"Recovered stale anchors by replaying this edit against a recent read of this file and merging onto the current content (context-matched merge). Review the diff to confirm the result.",
			);

			// Recovery succeeded: return the merged result.
			return buildResult({
				result: merged,
				resultWarnings: snapshotResult.warnings,
				noopEdits: snapshotResult.noopEdits,
				firstChangedLine: mergedRange?.firstChangedLine,
				lastChangedLine: mergedRange?.lastChangedLine,
			});
		}

		// All versions exhausted without a successful merge.
		// Append a diagnostic suffix to the original error for easier triage.
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

	// Direct apply succeeded.
	const anchorResult = directResult!;
	return buildResult({
		result: anchorResult.content,
		resultWarnings: anchorResult.warnings,
		noopEdits: anchorResult.noopEdits,
		firstChangedLine: anchorResult.firstChangedLine,
		lastChangedLine: anchorResult.lastChangedLine,
	});
}

async function computeEditPreview(
	request: unknown,
	cwd: string,
): Promise<EditPreview> {
	try {
		const normalized = normalizeEditRequest(request);
		assertEditRequest(normalized);
		const { path, originalNormalized, result } = await executeEditPipeline(
			normalized,
			cwd,
			constants.R_OK,
		);

		if (originalNormalized === result) {
			return {
				error: `No changes made to ${path}. The edits produced identical content.`,
			};
		}

		return { diff: generateDiffString(originalNormalized, result).diff };
	} catch (error: unknown) {
		return { error: error instanceof Error ? error.message : String(error) };
	}
}

// TParams is intentionally TSchema, not typeof hashlineEditToolSchema. The
// published `parameters` schema stays strict (discriminated anyOf) for the
// model, but the internal prepareArguments/execute surface treats params as
// unknown and defers per-item validation to resolveEditAnchors during
// execute. Typing it as Static<typeof hashlineEditToolSchema> would claim
// per-item conformance that prepareArguments does not actually enforce
// (assertEditRequest only validates the envelope).
type EditToolDefinition = ToolDefinition<
	TSchema,
	HashlineEditToolDetails,
	EditRenderState
> & { renderShell?: "default" | "self" };

function reuseTextComponent(lastComponent: unknown): Text {
	return lastComponent instanceof Text ? lastComponent : new Text("", 0, 0);
}

function renderTextResult(
	lastComponent: unknown,
	textContent: string | undefined,
): Text {
	if (!textContent) {
		return new Text("", 0, 0);
	}
	const text = reuseTextComponent(lastComponent);
	text.setText(textContent);
	return text;
}

function buildEditToolDefinition(): EditToolDefinition {
	return {
	name: "edit",
	label: "Edit",
	description: EDIT_DESC,
		parameters: hashlineEditToolSchema,
	promptSnippet: EDIT_PROMPT_SNIPPET,
	promptGuidelines: EDIT_PROMPT_GUIDELINES,
		// Absorb dialect noise (file_path alias, JSON-string edits) before pi
		// validates and before execute(). See src/edit-normalize.ts.
		prepareArguments: (args: unknown) => {
			const normalized = normalizeEditRequest(args);
			assertEditRequest(normalized);
			return normalized;
		},
	// Force the default tool shell (Box with pending/success/error background) so
	// we don't inherit renderShell: "self" from the built-in edit tool of the
	// same name, which would drop the shared background color block.
	renderShell: "default",
	renderCall(args, theme, context) {
		const previewInput = getRenderablePreviewInput(args);
		const resetPreview = () => {
			context.state.argsKey = undefined;
			context.state.preview = undefined;
			context.state.previewGeneration =
				(context.state.previewGeneration ?? 0) + 1;
		};
		if (context.executionStarted) {
			resetPreview();
		} else if (!context.argsComplete || !previewInput) {
			resetPreview();
		} else {
			const argsKey = JSON.stringify(previewInput);
			if (context.state.argsKey !== argsKey) {
				context.state.argsKey = argsKey;
				context.state.preview = undefined;
				const previewGeneration = (context.state.previewGeneration ?? 0) + 1;
				context.state.previewGeneration = previewGeneration;
				computeEditPreview(previewInput, context.cwd)
					.then((preview) => {
						if (
							context.state.argsKey === argsKey &&
							context.state.previewGeneration === previewGeneration
						) {
							context.state.preview = preview;
							context.invalidate();
						}
					})
					.catch((err: unknown) => {
						if (
							context.state.argsKey === argsKey &&
							context.state.previewGeneration === previewGeneration
						) {
							context.state.preview = {
								error: err instanceof Error ? err.message : String(err),
							};
							context.invalidate();
						}
					});
			}
		}
		const text =
			(context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
		text.setText(
			formatEditCall(
				previewInput ?? undefined,
				context.state as EditRenderState,
				theme,
			),
		);
		return text;
	},

	renderResult(result, { isPartial }, theme, context) {
		if (isPartial) {
			const text =
				(context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
			text.setText(theme.fg("warning", "Editing..."));
			return text;
		}

		const typedResult = result as {
			content?: Array<{ type: string; text?: string }>;
			details?: HashlineEditToolDetails;
		};
		const renderedText = getRenderedEditTextContent(typedResult);

		const renderState = context.state as EditRenderState | undefined;
		const previewBeforeResult = renderState?.preview;
		if (renderState) {
			renderState.preview = undefined;
			renderState.previewGeneration = (renderState.previewGeneration ?? 0) + 1;
		}

		if (context.isError) {
			return renderTextResult(
				context.lastComponent,
				renderedText ? `\n${theme.fg("error", renderedText)}` : undefined,
			);
		}

		return renderTextResult(
			context.lastComponent,
			formatEditResultText(typedResult, previewBeforeResult),
		);
	},

	async execute(_toolCallId, params, signal, _onUpdate, ctx) {
		// prepareArguments has already normalized the request (file_path alias,
		// JSON-string edits) and pi has validated the result against the
		// published schema before execute() runs — params is canonical.
		const { path, edits } = params as EditRequestParams;
		const absolutePath = resolveToCwd(path, ctx.cwd);
		const mutationTargetPath = await resolveMutationTargetPath(absolutePath);
		return withFileMutationQueue(mutationTargetPath, async () => {
			throwIfAborted(signal);

			// Duplicate-edit guard: if the incoming payload is byte-identical to the
			// last successfully applied payload for this path, and the file has not
			// changed since that edit (read-snapshot still matches current content),
			// reject before running the pipeline — the pipeline would otherwise throw
			// E_STALE_ANCHOR before we could detect the duplicate.
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
				const { count, escalate } = recordNoopEdit(
					mutationTargetPath,
					appliedPayloadKey,
				);
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
				warnings.push(
					"Non-UTF-8 bytes were shown as U+FFFD; this edit rewrote the file as UTF-8.",
				);
			}

			throwIfAborted(signal);
			await writeFileAtomically(
				mutationTargetPath,
				bom + restoreLineEndings(result, originalEnding),
				{ alreadyResolved: true },
			);
			recordAppliedEdit(mutationTargetPath, appliedPayloadKey);

			// Update the snapshot slot with the post-edit content so chained edits
			// using anchors from this edit's response can recover if a distant
			// external change arrives between this edit and the next one.
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
