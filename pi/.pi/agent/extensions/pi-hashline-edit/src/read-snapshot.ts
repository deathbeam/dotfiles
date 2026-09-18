/**
 * Per-path multi-version LRU snapshot store.
 *
 * Replaces the previous single-slot store. Rationale: weak models reuse
 * anchors from several reads ago; keeping MAX_VERSIONS_PER_PATH per path lets
 * the stale-anchor recovery in edit.ts attempt replay against any recent
 * snapshot, not just the most recent one.
 *
 * Memory bounds:
 *   MAX_PATHS × MAX_VERSIONS_PER_PATH entries, plus a total UTF-16 length cap
 *   (MAX_TOTAL_BYTES is an approximation — JS string .length counts UTF-16
 *   code units, not bytes, so this slightly under-counts for astral-plane
 *   characters, which is acceptable for a soft ceiling).
 */

const MAX_PATHS = 8;
const MAX_VERSIONS_PER_PATH = 4;
// 32 MiB soft ceiling, measured in UTF-16 code units (see module comment).
const MAX_TOTAL_BYTES = 32 * 1024 * 1024;

interface PathEntry {
	// Versions in newest-first order.
	versions: string[];
}

// Paths stored in MRU-first order (index 0 = most recently used).
const pathOrder: string[] = [];
const pathMap = new Map<string, PathEntry>();

function totalSize(): number {
	let n = 0;
	for (const entry of pathMap.values()) {
		for (const v of entry.versions) {
			n += v.length;
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
		const entry = pathMap.get(p);
		if (entry && entry.versions.length > 0) {
			entry.versions.pop(); // pop = remove oldest (last in newest-first array)
			if (entry.versions.length === 0) {
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

	// Read fusion: skip if identical to most recent version.
	if (existing && existing.versions.length > 0 && existing.versions[0] === content) {
		// Still promote to MRU position so subsequent reads keep it warm.
		const idx = pathOrder.indexOf(canonicalPath);
		if (idx > 0) {
			pathOrder.splice(idx, 1);
			pathOrder.unshift(canonicalPath);
		}
		return;
	}

	if (existing) {
		// Prepend new version (newest-first).
		existing.versions.unshift(content);
		// Trim to version limit for this path.
		while (existing.versions.length > MAX_VERSIONS_PER_PATH) {
			existing.versions.pop();
		}
		// Move to MRU position.
		const idx = pathOrder.indexOf(canonicalPath);
		if (idx > 0) {
			pathOrder.splice(idx, 1);
			pathOrder.unshift(canonicalPath);
		}
	} else {
		// New path: evict LRU path if at limit.
		if (pathOrder.length >= MAX_PATHS) {
			const lruPath = pathOrder[pathOrder.length - 1]!;
			pathMap.delete(lruPath);
			pathOrder.pop();
		}
		pathMap.set(canonicalPath, { versions: [content] });
		pathOrder.unshift(canonicalPath);
	}

	// Byte-budget eviction: remove oldest versions of the LRU path until
	// we are within the ceiling. This is a secondary constraint applied
	// after the path-count and version-count limits above.
	while (totalSize() > MAX_TOTAL_BYTES) {
		evictOldestVersion();
		if (pathMap.size === 0) break;
	}
}

/**
 * Return the most recent snapshot for canonicalPath, or null if none is stored.
 * Semantic unchanged from the single-slot implementation — duplicate-edit guard
 * in edit.ts depends on this returning the newest version only.
 */
export function getReadSnapshot(canonicalPath: string): string | null {
	const entry = pathMap.get(canonicalPath);
	return entry && entry.versions.length > 0 ? entry.versions[0]! : null;
}

/**
 * Return all stored versions for canonicalPath in newest-first order.
 * Returns an empty array when no snapshot exists for the path.
 */
export function getReadSnapshotVersions(canonicalPath: string): string[] {
	const entry = pathMap.get(canonicalPath);
	return entry ? [...entry.versions] : [];
}
