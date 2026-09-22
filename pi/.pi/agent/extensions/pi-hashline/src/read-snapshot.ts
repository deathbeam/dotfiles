/**
 * Per-path multi-version LRU snapshot store.
 *
 * Weak models reuse anchors from several reads ago; keeping
 * MAX_VERSIONS_PER_PATH per path lets the stale-anchor recovery in edit.ts
 * replay against any recent snapshot, not just the most recent one.
 *
 * Memory bounds: MAX_PATHS × MAX_VERSIONS_PER_PATH entries, plus a total
 * UTF-16 length cap (MAX_TOTAL_BYTES approximates bytes — JS string .length
 * counts UTF-16 code units, acceptable for a soft ceiling).
 */

const MAX_PATHS = 8;
const MAX_VERSIONS_PER_PATH = 4;
// 32 MiB soft ceiling, measured in UTF-16 code units (see module comment).
const MAX_TOTAL_BYTES = 32 * 1024 * 1024;

// Paths stored in MRU-first order (index 0 = most recently used).
const pathOrder: string[] = [];
// Per path: versions in newest-first order.
const pathMap = new Map<string, string[]>();

function totalSize(): number {
	let n = 0;
	for (const versions of pathMap.values()) {
		for (const version of versions) {
			n += version.length;
		}
	}
	return n;
}

/**
 * Evict the oldest version of the globally least-recently-used path.
 * If that path's version list becomes empty, remove the path entirely.
 */
function evictOldestVersion(): void {
	// LRU path is at the end of pathOrder.
	for (let i = pathOrder.length - 1; i >= 0; i--) {
		const p = pathOrder[i]!;
		const versions = pathMap.get(p);
		if (versions && versions.length > 0) {
			versions.pop(); // newest-first: the last entry is the oldest
			if (versions.length === 0) {
				pathMap.delete(p);
				pathOrder.splice(i, 1);
			}
			return;
		}
	}
}

/**
 * Record a hashline read snapshot for canonicalPath.
 *
 * - If content is byte-identical to the current newest version for this path,
 *   the call is a no-op (read fusion — avoids storing duplicates).
 * - Moves the path to MRU position on every non-fused write.
 * - Evicts oldest versions / paths to stay within all three limits.
 */
export function rememberReadSnapshot(canonicalPath: string, content: string): void {
	const existing = pathMap.get(canonicalPath);

	if (existing && existing.length > 0 && existing[0] === content) {
		// Read fusion: still promote so subsequent reads keep it warm.
		const idx = pathOrder.indexOf(canonicalPath);
		if (idx > 0) {
			pathOrder.splice(idx, 1);
			pathOrder.unshift(canonicalPath);
		}
		return;
	}

	if (existing) {
		existing.unshift(content);
		while (existing.length > MAX_VERSIONS_PER_PATH) {
			existing.pop();
		}
		const idx = pathOrder.indexOf(canonicalPath);
		if (idx > 0) {
			pathOrder.splice(idx, 1);
			pathOrder.unshift(canonicalPath);
		}
	} else {
		if (pathOrder.length >= MAX_PATHS) {
			const lruPath = pathOrder[pathOrder.length - 1]!;
			pathMap.delete(lruPath);
			pathOrder.pop();
		}
		pathMap.set(canonicalPath, [content]);
		pathOrder.unshift(canonicalPath);
	}

	// Secondary constraint, applied after the path-count and version-count
	// limits above: drop oldest versions until the byte budget is met.
	while (totalSize() > MAX_TOTAL_BYTES) {
		evictOldestVersion();
		if (pathMap.size === 0) break;
	}
}

/**
 * Return the most recent snapshot for canonicalPath, or null if none is
 * stored. The duplicate-edit guard in edit.ts depends on this returning the
 * newest version only.
 */
export function getReadSnapshot(canonicalPath: string): string | null {
	const versions = pathMap.get(canonicalPath);
	return versions && versions.length > 0 ? versions[0]! : null;
}

/**
 * Return all stored versions for canonicalPath in newest-first order.
 * Returns an empty array when no snapshot exists for the path.
 */
export function getReadSnapshotVersions(canonicalPath: string): string[] {
	const versions = pathMap.get(canonicalPath);
	return versions ? [...versions] : [];
}
