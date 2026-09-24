/** Recent snapshots let stale anchors recover across reads; the size cap is soft because JS counts UTF-16 code units. */

const MAX_PATHS = 8;
const MAX_VERSIONS_PER_PATH = 4;
const MAX_TOTAL_BYTES = 32 * 1024 * 1024;

// Paths and their versions are both newest-first.
const pathOrder: string[] = [];
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

function evictOldestVersion(): void {
    for (let i = pathOrder.length - 1; i >= 0; i--) {
        const p = pathOrder[i]!;
        const versions = pathMap.get(p);
        if (versions && versions.length > 0) {
            versions.pop();
            if (versions.length === 0) {
                pathMap.delete(p);
                pathOrder.splice(i, 1);
            }
            return;
        }
    }
}

export function rememberReadSnapshot(canonicalPath: string, content: string): void {
    const existing = pathMap.get(canonicalPath);

    if (existing && existing.length > 0 && existing[0] === content) {
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

    while (totalSize() > MAX_TOTAL_BYTES) {
        evictOldestVersion();
        if (pathMap.size === 0) break;
    }
}

// Duplicate-edit detection compares against the newest snapshot only.
export function getReadSnapshot(canonicalPath: string): string | null {
    const versions = pathMap.get(canonicalPath);
    return versions && versions.length > 0 ? versions[0]! : null;
}

export function getReadSnapshotVersions(canonicalPath: string): string[] {
    const versions = pathMap.get(canonicalPath);
    return versions ? [...versions] : [];
}
