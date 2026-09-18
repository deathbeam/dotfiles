/**
 * TUI rendering for the edit tool.
 *
 * The call renderer keeps the anchor-aware live diff preview — pi's built-in
 * edit renderer only previews oldText/newText-shaped edits, which hashline
 * edits never are. Result rendering delegates to pi's standard renderDiff.
 */

import { renderDiff, type Theme } from "@earendil-works/pi-coding-agent";
import { isRecord, normalizeEditRequest } from "./edit-normalize";
import type { EditRequestParams } from "./edit";
import type { HashlineEditToolDetails } from "./edit-response";

// ─── Theme type aliases ─────────────────────────────────────────────────

export type FgTheme = Pick<Theme, "fg">;
export type CallTheme = Pick<Theme, "fg" | "bold">;

// ─── Render state ───────────────────────────────────────────────────────

export type EditPreview = { diff: string } | { error: string };

export type EditRenderState = {
	argsKey?: string;
	preview?: EditPreview;
	previewGeneration?: number;
};

// ─── Preview input extraction ───────────────────────────────────────────

export function getRenderablePreviewInput(
	args: unknown,
): EditRequestParams | null {
	let normalized: unknown;
	try {
		normalized = normalizeEditRequest(args);
	} catch {
		return null;
	}
	if (
		!isRecord(normalized) ||
		typeof normalized.path !== "string" ||
		!Array.isArray(normalized.edits)
	) {
		return null;
	}

	return {
		path: normalized.path,
		edits: normalized.edits,
	} as EditRequestParams;
}

// ─── Edit call formatting ───────────────────────────────────────────────

export function formatEditCall(
	args: EditRequestParams | undefined,
	state: EditRenderState,
	theme: CallTheme,
): string {
	const path = args?.path;
	const pathDisplay =
		typeof path === "string" && path.length > 0
			? theme.fg("accent", path)
			: theme.fg("toolOutput", "...");
	let text = `${theme.fg("toolTitle", theme.bold("edit"))} ${pathDisplay}`;

	if (!state.preview) {
		return text;
	}

	if ("error" in state.preview) {
		text += `\n\n${theme.fg("error", state.preview.error)}`;
		return text;
	}

	text += `\n\n${renderDiff(state.preview.diff)}`;
	return text;
}

// ─── Result text extraction ─────────────────────────────────────────────

export function getRenderedEditTextContent(result: {
	content?: Array<{ type: string; text?: string }>;
}): string | undefined {
	const textContent = result.content?.find(
		(entry): entry is { type: "text"; text: string } =>
			entry.type === "text" && typeof entry.text === "string",
	);
	return textContent?.text;
}

// ─── Result rendering ───────────────────────────────────────────────────

/**
 * Build the rendered result text for a settled edit result:
 * the diff (via pi's standard renderDiff, skipped when the call already
 * previewed the same diff), warnings, and — for noop results, which carry
 * no diff — the model-facing text.
 */
export function formatEditResultText(
	result: {
		content?: Array<{ type: string; text?: string }>;
		details?: HashlineEditToolDetails;
	},
	previewBeforeResult: EditPreview | undefined,
): string | undefined {
	const details = result.details;
	const previewDiff =
		previewBeforeResult && !("error" in previewBeforeResult)
			? previewBeforeResult.diff
			: undefined;
	const sections: string[] = [];

	if (details?.diff && details.diff !== previewDiff) {
		sections.push(renderDiff(details.diff));
	}

	if (details?.warnings.length) {
		sections.push(["Warnings:", ...details.warnings].join("\n"));
	}

	if (!details?.diff) {
		const text = getRenderedEditTextContent(result);
		if (text) {
			sections.push(text);
		}
	}

	return sections.length > 0 ? sections.join("\n\n") : undefined;
}
