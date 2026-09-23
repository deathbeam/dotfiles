/**
 * Format helpers — hashline region rendering, affected-line range, changed-line range.
 *
 * Vendored & adapted from oh-my-pi (MIT, github.com/can1357/oh-my-pi).
 */

import { computeLineHash, HASH_LENGTH, NIBBLE_STR } from "./hash";

/** Matches a rendered anchor prefix, e.g. ` 12#ABC:`. */
const ANCHOR_PREFIX_RE = new RegExp(`^(\\s*\\d+#[${NIBBLE_STR}]{${HASH_LENGTH}}:)`);

/** Strip ANSI escapes and control characters so file content cannot inject terminal sequences. */
export function sanitizeOutput(text: string): string {
    return text.replace(/\u001b\[[0-9;]*[A-Za-z]/g, "").replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/g, "");
}

/**
 * Strip hashline display prefixes from annotated text, e.g. ` 12#ABC:const x`
 * becomes `const x`. The prefixes are model-facing (read/grep output keeps
 * them); TUI rendering drops them so the view matches pi's built-in tools.
 */
export function stripHashlinePrefixes(text: string): string {
    return text
        .split("\n")
        .map((line) => line.replace(ANCHOR_PREFIX_RE, ""))
        .join("\n");
}

/**
 * Split text into the lines the model sees in read output: the trailing
 * sentinel element produced by split("\n") on a newline-terminated file is
 * dropped.
 */
export function splitVisibleLines(text: string): string[] {
    if (text.length === 0) {
        return [];
    }
    const lines = text.split("\n");
    return text.endsWith("\n") ? lines.slice(0, -1) : lines;
}

// ─── Affected-line computation (for returning anchors after edit) ───────

const ANCHOR_CONTEXT_LINES = 2;
const ANCHOR_MAX_OUTPUT_LINES = 12;

/**
 * Compute the post-edit line range covering changed lines plus context.
 * Returns null if the range (with context) exceeds the output budget,
 * signalling that the LLM should re-read instead.
 */
export function computeAffectedLineRange(
    firstChangedLine: number | undefined,
    lastChangedLine: number | undefined,
    resultLineCount: number,
): { start: number; end: number } | null {
    if (firstChangedLine === undefined || lastChangedLine === undefined) {
        return null;
    }

    const start = Math.max(1, firstChangedLine - ANCHOR_CONTEXT_LINES);
    const end = Math.min(resultLineCount, lastChangedLine + ANCHOR_CONTEXT_LINES);

    // Degenerate range: an empty result document (resultLineCount 0) clamps
    // end below start. Unreachable from the edit tool (E_WOULD_EMPTY rejects
    // emptying writes upstream), but this is a pure exported helper, so it
    // keeps a sane null contract for that input rather than {start:1, end:0}.
    if (end < start) {
        return null;
    }

    if (end - start + 1 > ANCHOR_MAX_OUTPUT_LINES) {
        return null;
    }

    return { start, end };
}

export function formatHashlineRegion(fileLines: readonly string[], startLine: number, endLine: number): string {
    const lineNumberWidth = String(endLine).length;
    const out: string[] = [];
    for (let lineNum = startLine; lineNum <= endLine; lineNum++) {
        const line = fileLines[lineNum - 1]!;
        const hash = computeLineHash(fileLines, lineNum - 1);
        const paddedLineNumber = String(lineNum).padStart(lineNumberWidth, " ");
        out.push(`${paddedLineNumber}#${hash}:${line}`);
    }
    return out.join("\n");
}

// ─── Changed line range computation ─────────────────────────────────

/**
 * Compute first/last changed line numbers between two document versions.
 * Uses character-level diff to locate the changed span, then maps to line
 * numbers in the result document so downstream anchor chaining works.
 */
export function computeChangedLineRange(
    original: string,
    result: string,
): { firstChangedLine: number; lastChangedLine: number } | null {
    if (original === result) return null;

    function countVisibleLines(text: string): number {
        if (text.length === 0) {
            return 0;
        }
        let count = 1;
        let pos = text.indexOf("\n");
        while (pos !== -1) {
            count++;
            pos = text.indexOf("\n", pos + 1);
        }
        return text.endsWith("\n") ? count - 1 : count;
    }

    if (original.length === 0) {
        return {
            firstChangedLine: 1,
            lastChangedLine: countVisibleLines(result),
        };
    }

    if (result.startsWith(original) && original.endsWith("\n")) {
        return {
            firstChangedLine: countVisibleLines(original) + 1,
            lastChangedLine: countVisibleLines(result),
        };
    }

    let firstDiff = 0;
    const minLen = Math.min(original.length, result.length);
    while (firstDiff < minLen && original[firstDiff] === result[firstDiff]) {
        firstDiff++;
    }
    if (firstDiff === minLen && original.length === result.length) return null;

    let lastOrig = original.length - 1;
    let lastRes = result.length - 1;
    while (lastOrig >= firstDiff && lastRes >= firstDiff && original[lastOrig] === result[lastRes]) {
        lastOrig--;
        lastRes--;
    }

    function indexToLine(charIdx: number, text: string): number {
        let line = 1;
        for (let i = 0; i < charIdx && i < text.length; i++) {
            if (text[i] === "\n") line++;
        }
        return line;
    }

    const firstChangedLine = indexToLine(firstDiff + 1, result);
    let lastChangedLine: number;
    if (lastRes < firstDiff) {
        lastChangedLine = result.length === 0 ? 1 : countVisibleLines(result);
    } else if (firstDiff === 0 && original.length > 0 && result.endsWith(original)) {
        lastChangedLine = firstChangedLine;
    } else {
        lastChangedLine = indexToLine(lastRes + 1, result);
    }

    return { firstChangedLine, lastChangedLine };
}
