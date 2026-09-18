// Models empirically ignore soft noop hints and can loop hundreds of times
// re-sending byte-identical payloads. A thrown tool error is what actually
// breaks the cycle — it surfaces as a visible error in the agent trace and
// forces the model to re-read the file before retrying.

const NOOP_HARD_LIMIT = 3;

interface NoopEntry {
	payloadKey: string;
	count: number;
}

const noopTracker = new Map<string, NoopEntry>();

// Tracks the payloadKey of the last successfully applied edit per path.
// Used to detect duplicate-applied payloads (e.g. append sent twice after
// a false-failure assumption by a weak model).
const appliedPayloadTracker = new Map<string, string>();

/**
 * Record a noop edit attempt for the given canonical mutation target path.
 * A different payloadKey resets the count (the model changed payload = progress).
 * Returns the current count and whether the hard limit has been hit.
 */
export function recordNoopEdit(
	path: string,
	payloadKey: string,
): { count: number; escalate: boolean } {
	const existing = noopTracker.get(path);
	if (existing && existing.payloadKey === payloadKey) {
		existing.count += 1;
	} else {
		noopTracker.set(path, { payloadKey, count: 1 });
	}
	const count = noopTracker.get(path)!.count;
	return { count, escalate: count >= NOOP_HARD_LIMIT };
}

/**
 * Clear the noop counter for a path and record the payloadKey of the
 * successfully applied edit, for duplicate-applied-payload detection.
 */
export function recordAppliedEdit(path: string, payloadKey: string): void {
	noopTracker.delete(path);
	appliedPayloadTracker.set(path, payloadKey);
}

/**
 * Returns true when the incoming payloadKey matches the last successfully
 * applied payload for the path. The caller must additionally verify the
 * file has not changed since that edit before treating this as a duplicate.
 */
export function isDuplicateAppliedPayload(path: string, payloadKey: string): boolean {
	return appliedPayloadTracker.get(path) === payloadKey;
}

/**
 * Clear the applied-payload record for a path. Called when the model
 * re-reads the file — a deliberate re-read followed by the same payload
 * is intentional and must be allowed through.
 */
export function clearAppliedPayload(path: string): void {
	appliedPayloadTracker.delete(path);
}
