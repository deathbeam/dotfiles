/** prepareArguments runs before Pi validation: accept file_path and JSON-string edits,
 * but leave text-replace payloads for the anchor-guidance error. */

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

/** Leave malformed input intact for validation's more precise error. */
export function normalizeEditRequest(input: unknown): unknown {
    if (!isRecord(input)) {
        return input;
    }

    const record: Record<string, unknown> = { ...input };

    if (typeof record.path !== "string" && typeof record.file_path === "string") {
        record.path = record.file_path;
        delete record.file_path;
    }

    if (Object.hasOwn(record, "edits")) {
        record.edits = coerceEditsArray(record.edits);
    }

    return record;
}
