// Repeated identical no-ops need a hard error; soft hints do not stop model loops.

const NOOP_HARD_LIMIT = 3;

interface NoopEntry {
    payloadKey: string;
    count: number;
}

const noopTracker = new Map<string, NoopEntry>();

// Prevent a model from repeating an already-applied append after assuming it failed.
const appliedPayloadTracker = new Map<string, string>();

export function recordNoopEdit(path: string, payloadKey: string): { count: number; escalate: boolean } {
    const existing = noopTracker.get(path);
    if (existing && existing.payloadKey === payloadKey) {
        existing.count += 1;
    } else {
        noopTracker.set(path, { payloadKey, count: 1 });
    }
    const count = noopTracker.get(path)!.count;
    return { count, escalate: count >= NOOP_HARD_LIMIT };
}

export function recordAppliedEdit(path: string, payloadKey: string): void {
    noopTracker.delete(path);
    appliedPayloadTracker.set(path, payloadKey);
}

// The caller must also verify that the file still has its post-edit content.
export function isDuplicateAppliedPayload(path: string, payloadKey: string): boolean {
    return appliedPayloadTracker.get(path) === payloadKey;
}

// A deliberate re-read permits the same payload again.
export function clearAppliedPayload(path: string): void {
    appliedPayloadTracker.delete(path);
}
