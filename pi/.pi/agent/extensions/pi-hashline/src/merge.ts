/**
 * Three-way merge helper for stale-anchor recovery.
 *
 * fuzzFactor 0: hunk context lines must match exactly (no fuzzed context),
 * and jsdiff's applyPatch still scans backwards and forwards from the hunk's
 * recorded position to find an exactly-matching context window. That scanning
 * is load-bearing — it is what lets a replayed hunk apply after an external
 * insert shifted the file — but it means the hunk lands at the *nearest*
 * matching window, not necessarily the intended one. When a hunk's window is
 * duplicated in the live file the replay is refused (see {@link isAmbiguous}),
 * so recovery is context-matched but never a coin flip.
 */

import { structuredPatch, applyPatch, type StructuredPatchHunk } from "diff";

/**
 * Source-side lines a hunk searches for: its context lines plus the lines it
 * removes. Added lines consume no source line, so they are not part of it;
 * jsdiff's `\ No newline at end of file` markers are not content either.
 */
function hunkSearchPattern(hunk: StructuredPatchHunk): string[] {
    const pattern: string[] = [];
    for (const line of hunk.lines) {
        if (line.startsWith("+") || line.startsWith("\\")) continue;
        pattern.push(line.slice(1));
    }
    return pattern;
}

/**
 * True when `pattern` occurs at more than one position in `lines`.
 * Overlapping scans count separately: jsdiff may fit a hunk at either one.
 */
function isAmbiguous(lines: readonly string[], pattern: readonly string[]): boolean {
    let seen = 0;
    for (let i = 0; i + pattern.length <= lines.length && seen < 2; i++) {
        let matches = true;
        for (let j = 0; j < pattern.length; j++) {
            if (lines[i + j] !== pattern[j]) {
                matches = false;
                break;
            }
        }
        if (matches) seen++;
    }
    return seen > 1;
}

/**
 * Replay the changes made from `base` → `baseEdited` onto `current`.
 *
 * Returns the merged text, or null when:
 * - a hunk's search window is duplicated in `current` (ambiguous placement),
 * - the patch cannot apply to `current` with fuzzFactor 0, or
 * - the merged result is identical to `current` (nothing new to write).
 *
 * Short-circuit: if `base === current`, return `baseEdited` directly.
 */
export function threeWayMerge(base: string, baseEdited: string, current: string): string | null {
    if (base === current) {
        return baseEdited;
    }

    const patch = structuredPatch("a", "b", base, baseEdited, "", "", { context: 3 });

    // Refuse ambiguous placement: a duplicated search window means jsdiff could
    // apply the hunk at the wrong occurrence. Failing here surfaces the
    // stale-anchor error instead of writing a plausible-looking wrong edit.
    const currentLines = current.split("\n");
    for (const hunk of patch.hunks) {
        const pattern = hunkSearchPattern(hunk);
        if (pattern.length > 0 && isAmbiguous(currentLines, pattern)) {
            return null;
        }
    }

    const merged = applyPatch(current, patch, { fuzzFactor: 0 });

    if (merged === false || typeof merged !== "string") {
        return null;
    }

    if (merged === current) {
        return null;
    }

    return merged;
}
