/**
 * Edit response builders.
 *
 * `changed` response is only model-facing success mode. Rich post-edit payloads
 * belong in fresh `read` calls, not invisible `details` branches.
 */

import { generateDiffString } from "./edit-diff";
import { computeAffectedLineRange, formatHashlineRegion, splitVisibleLines } from "./hashline";

const CHANGED_ANCHOR_TEXT_BUDGET_BYTES = 50 * 1024;

type ToolResult = {
	content: Array<{ type: "text"; text: string }>;
	isError?: boolean;
	details: HashlineEditToolDetails;
};

export type EditClassification = "applied" | "noop";

export type HashlineEditToolDetails = {
	diff: string;
	firstChangedLine?: number;
	classification: EditClassification;
	warnings: string[];
};

export type EditMeta = {
	firstChangedLine?: number;
	lastChangedLine?: number;
};

type NoopEditEntry = {
	editIndex: number;
	loc: string;
	currentContent: string;
};

export interface NoopResponseInput {
	path: string;
	noopEdits: NoopEditEntry[] | undefined;
	warnings: string[] | undefined;
}

export interface SuccessResponseInput {
	originalNormalized: string;
	result: string;
	warnings: string[] | undefined;
	editMeta: EditMeta;
}

function warningsBlockOf(warnings: string[] | undefined): string {
	return warnings?.length ? `\n\nWarnings:\n${warnings.join("\n")}` : "";
}

const ANCHORS_OMITTED_TEXT = "Anchors omitted; use read for subsequent edits.";

/**
 * Model-facing anchor block for the changed region: fresh LINE#HASH lines the
 * model can chain into nearby follow-up edits without a re-read. Falls back to
 * a re-read hint when the region is unbounded or exceeds the text budget.
 */
function buildAnchorsBlock(
	resultLines: string[],
	anchorRange: { start: number; end: number } | null,
): string {
	if (!anchorRange) { return ANCHORS_OMITTED_TEXT; }
	const formatted = formatHashlineRegion(resultLines, anchorRange.start, anchorRange.end);
	const block = `--- Anchors ${anchorRange.start}-${anchorRange.end} ---\n${formatted}`;
	return Buffer.byteLength(block, "utf8") <= CHANGED_ANCHOR_TEXT_BUDGET_BYTES
		? block
		: ANCHORS_OMITTED_TEXT;
}

export function buildNoopResponse(input: NoopResponseInput): ToolResult {
	const { path, noopEdits, warnings } = input;

	const noopDetailsText = noopEdits?.length
		? noopEdits
				.map(
					(edit) =>
						`Edit ${edit.editIndex}: replacement for ${edit.loc} is identical to current content:\n  ${edit.loc}: ${edit.currentContent}`,
				)
				.join("\n")
		: "The edits produced identical content.";

	return {
		content: [
			{
				type: "text",
				text: `No changes made to ${path}\nClassification: noop\n${noopDetailsText}${warningsBlockOf(warnings)}`,
			},
		],
		details: {
			diff: "",
			firstChangedLine: undefined,
			classification: "noop",
			warnings: warnings ?? [],
		},
	};
}

export function buildChangedResponse(input: SuccessResponseInput): ToolResult {
	const { result, warnings, originalNormalized, editMeta } = input;

	const diffResult = generateDiffString(originalNormalized, result);
	const warningsBlock = warningsBlockOf(warnings);

	const resultLines = splitVisibleLines(result);
	const anchorRange = computeAffectedLineRange(
		editMeta.firstChangedLine,
		editMeta.lastChangedLine,
		resultLines.length,
	);
	const anchorsBlock = buildAnchorsBlock(resultLines, anchorRange);

	const text = [anchorsBlock, warningsBlock.trimStart()]
		.filter((section) => section.length > 0)
		.join("\n\n");

	return {
		content: [{ type: "text", text }],
		details: {
			diff: diffResult.diff,
			firstChangedLine: editMeta.firstChangedLine,
			classification: "applied",
			warnings: warnings ?? [],
		},
	};
}
