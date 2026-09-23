/**
 * Single normalization layer that absorbs the dialect noise a model may emit
 * onto the canonical hashline edit request before validation runs.
 *
 * Two dialects are absorbed:
 * - `file_path` → `path` alias.
 * - `edits` serialized as a JSON string → array (observed with some models).
 *
 * Everything else passes through untouched. Native text-replace payloads
 * (top-level `oldText`/`newText`, items without `op`) are deliberately NOT
 * converted: the `replace_text` op no longer exists, and validation rejects
 * them with anchor guidance instead of silently succeeding.
 *
 * This runs as the tool's `prepareArguments` hook, which pi executes before
 * AJV schema validation and before `execute()`.
 */

export function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}

function coerceEditsArray(edits: unknown): unknown {
    if (typeof edits !== "string") {
        return edits;
    }
    try {
        const parsed: unknown = JSON.parse(edits);
        return Array.isArray(parsed) ? parsed : edits;
    } catch {
        return edits;
    }
}

/**
 * Normalize a raw edit-tool request into the canonical hashline shape.
 *
 * Returns the input unchanged when it is not an object, so malformed payloads
 * still reach validation and surface a precise error there.
 */
export function normalizeEditRequest(input: unknown): unknown {
    if (!isRecord(input)) {
        return input;
    }

    const record: Record<string, unknown> = { ...input };

    // file_path → path alias.
    if (typeof record.path !== "string" && typeof record.file_path === "string") {
        record.path = record.file_path;
        delete record.file_path;
    }

    // edits-as-JSON-string → array.
    if (Object.hasOwn(record, "edits")) {
        record.edits = coerceEditsArray(record.edits);
    }

    return record;
}
