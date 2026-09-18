import * as Diff from "diff";

// ─── Line ending normalization ──────────────────────────────────────────

export function detectLineEnding(content: string): "\r\n" | "\n" {
	const crlfIdx = content.indexOf("\r\n");
	const lfIdx = content.indexOf("\n");
	if (lfIdx === -1 || crlfIdx === -1) return "\n";
	return crlfIdx < lfIdx ? "\r\n" : "\n";
}

export function normalizeToLF(text: string): string {
	return text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
}

export function restoreLineEndings(
	text: string,
	ending: "\r\n" | "\n",
): string {
	return ending === "\r\n" ? text.replace(/\n/g, "\r\n") : text;
}

// Returns true when normalizeToLF + restoreLineEndings will not round-trip the
// file's endings: mixed styles (CRLF plus bare LF, or lone CR mixed with
// anything), or a pure classic-Mac CR file (detectLineEnding has no CR branch,
// so an edit rewrites it as LF). A file uniform in LF or CRLF returns false.
export function hasMixedLineEndings(content: string): boolean {
	const hasCrlf = /\r\n/.test(content);
	// Bare LF: a \n not immediately preceded by \r
	const hasBareLf = /(?<!\r)\n/.test(content);
	// Lone CR: a \r not followed by \n
	const hasLoneCr = /\r(?!\n)/.test(content);

	const styleCount = [hasCrlf, hasBareLf, hasLoneCr].filter(Boolean).length;
	return styleCount > 1 || hasLoneCr;
}

export function stripBom(content: string): { bom: string; text: string } {
	return content.startsWith("\uFEFF")
		? { bom: "\uFEFF", text: content.slice(1) }
		: { bom: "", text: content };
}

// ─── Diff generation ────────────────────────────────────────────────────

// Emits pi's standard diff line format (`+N content` / `-N content` /
// ` N content`) so the TUI renders it with the shared renderDiff (colored
// lines, intra-line highlighting). The diff string is display-only — the
// model sees the anchors block, never this string.
function formatDiffPreviewLine(
	prefix: " " | "+" | "-",
	lineNum: number,
	lineNumWidth: number,
	line: string,
): string {
	const paddedLineNum = String(lineNum).padStart(lineNumWidth, " ");
	return `${prefix}${paddedLineNum} ${line}`;
}

export function generateDiffString(
	oldContent: string,
	newContent: string,
	contextLines = 4,
): { diff: string } {
	const parts = Diff.diffLines(oldContent, newContent);
	const output: string[] = [];
	const maxLineNum = Math.max(
		oldContent.split("\n").length,
		newContent.split("\n").length,
	);
	const lineNumWidth = String(maxLineNum).length;
	let oldLineNum = 1;
	let newLineNum = 1;
	let lastWasChange = false;

	for (let i = 0; i < parts.length; i++) {
		const part = parts[i]!;
		const raw = part.value.split("\n");
		if (raw[raw.length - 1] === "") raw.pop();

		if (part.added || part.removed) {
			for (const line of raw) {
				if (part.added) {
					output.push(
						formatDiffPreviewLine("+", newLineNum, lineNumWidth, line),
					);
					newLineNum++;
				} else {
					output.push(
						formatDiffPreviewLine("-", oldLineNum, lineNumWidth, line),
					);
					oldLineNum++;
				}
			}
			lastWasChange = true;
			continue;
		}

		const nextPartIsChange =
			i < parts.length - 1 && (parts[i + 1]!.added || parts[i + 1]!.removed);
		if (lastWasChange || nextPartIsChange) {
			let linesToShow = raw;
			let skipStart = 0;
			let skipEnd = 0;

			if (!lastWasChange) {
				skipStart = Math.max(0, raw.length - contextLines);
				linesToShow = raw.slice(skipStart);
			}
			if (!nextPartIsChange && linesToShow.length > contextLines) {
				skipEnd = linesToShow.length - contextLines;
				linesToShow = linesToShow.slice(0, contextLines);
			}

			if (skipStart > 0) {
				output.push(` ${"".padStart(lineNumWidth, " ")} ...`);
				oldLineNum += skipStart;
				newLineNum += skipStart;
			}
			for (const line of linesToShow) {
				output.push(
					formatDiffPreviewLine(" ", newLineNum, lineNumWidth, line),
				);
				oldLineNum++;
				newLineNum++;
			}
			if (skipEnd > 0) {
				output.push(` ${"".padStart(lineNumWidth, " ")} ...`);
				oldLineNum += skipEnd;
				newLineNum += skipEnd;
			}
		} else {
			oldLineNum += raw.length;
			newLineNum += raw.length;
		}
		lastWasChange = false;
	}

	return { diff: output.join("\n") };
}
