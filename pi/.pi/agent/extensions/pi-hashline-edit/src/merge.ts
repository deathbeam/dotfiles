/**
 * Three-way merge helper for stale-anchor recovery.
 *
 * fuzzFactor 0: hunk context lines must match exactly (no fuzzed context),
 * and jsdiff's applyPatch still scans backwards and forwards from the hunk's
 * recorded position to find an exactly-matching context window. That scanning
 * is load-bearing — it is what lets a replayed hunk apply after an external
 * insert shifted the file — but it also means a hunk whose full context
 * window is duplicated elsewhere in the live file can land at that other
 * occurrence. Recovery is therefore "context-matched", not position-pinned:
 * callers must word their warning accordingly, and the returned diff is the
 * model's chance to catch a misplaced merge.
 */

import { structuredPatch, applyPatch } from "diff";

/**
 * Replay the changes made from `base` → `baseEdited` onto `current`.
 *
 * Returns the merged text, or null when:
 * - the patch cannot apply to `current` with fuzzFactor 0, or
 * - the merged result is identical to `current` (nothing new to write).
 *
 * Short-circuit: if `base === current`, return `baseEdited` directly.
 */
export function threeWayMerge(
	base: string,
	baseEdited: string,
	current: string,
): string | null {
	if (base === current) {
		return baseEdited;
	}

	const patch = structuredPatch("a", "b", base, baseEdited, "", "", { context: 3 });
	const merged = applyPatch(current, patch, { fuzzFactor: 0 });

	if (merged === false || typeof merged !== "string") {
		return null;
	}

	if (merged === current) {
		return null;
	}

	return merged;
}
