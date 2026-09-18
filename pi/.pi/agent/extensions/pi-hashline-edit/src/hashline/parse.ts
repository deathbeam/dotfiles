/**
 * Parsing — prefix regexes, anchor ref parsing, edit item validation, resolveEditAnchors.
 *
 * Vendored & adapted from oh-my-pi (MIT, github.com/can1357/oh-my-pi).
 */

import { NIBBLE_STR, HASH_ALPHABET_RE, HASH_LENGTH } from "./hash";

// ─── Types ──────────────────────────────────────────────────────────────

export type Anchor = { line: number; hash: string; textHint?: string };
export type HashlineEdit =
	| { op: "replace"; pos: Anchor; end?: Anchor; lines: string[] }
	| { op: "append"; pos?: Anchor; lines: string[] }
	| { op: "prepend"; pos?: Anchor; lines: string[] };

export type HashlineToolEdit = {
	op: string;
	pos?: string;
	end?: string;
	lines?: string[];
};

/** Example anchor used in error messages; 3 characters from the alphabet. */
const EXAMPLE_ANCHOR = "5#MQQ";

/**
 * Display-prefix rejection regexes. These patterns detect (and reject)
 * hashline display prefixes inside edit payloads. The runtime no longer
 * strips them — the model must send literal file content. Matching any of
 * these triggers `[E_INVALID_PATCH]`.
 *
 * They match all hash lengths seen in older sessions (2–4), not just the
 * current 3: the rejection semantics are "this is rendered read/diff
 * output", and rendered output can come from a stale transcript. A 5+-char
 * run backtracks to no match — that shape is not a valid display prefix
 * under any configuration and passes as literal content.
 */
const DISPLAY_HASH_QUANT = `[${NIBBLE_STR}]{2,4}`;
const DISPLAY_PREFIX_RE = new RegExp(
	`^\\s*(?:\\d+\\s*#\\s*|#\\s*)${DISPLAY_HASH_QUANT}:`,
);
const DISPLAY_PREFIX_PLUS_RE = new RegExp(
	`^\\+\\s*(?:\\d+\\s*#\\s*|#\\s*)${DISPLAY_HASH_QUANT}:`,
);

const DIFF_MINUS_RE = /^-\s*\d+\s{4}/;

/**
 * Bare hashline prefix: a 3-char hash followed by ":" with no "LINE#" part
 * (e.g. "MQQ:### heading"). Capture group 1 is the hash.
 *
 * This is the partial-hash failure mode: the model copies a hash it saw in
 * `read` output into the line content but drops the "LINE#" part. A single
 * such line is genuinely ambiguous — short uppercase keys and abbreviations
 * are legitimate content — so it is never rejected on shape alone.
 * Disambiguation happens against the file's actual hash set in
 * `warnBareHashPrefixLines`.
 */
export const BARE_PREFIX_RE = new RegExp(`^\\s*([${NIBBLE_STR}]{${HASH_LENGTH}}):`);

// ─── Parsing ────────────────────────────────────────────────────────────

/**
 * Validate an anchor's hash for the fixed session length. Returns an error
 * message, or null when the hash is well-formed.
 */
function diagnoseHash(ref: string, hash: string): string | null {
	if (hash.length !== HASH_LENGTH) {
		// Distinguish: looks like a valid anchor from an older session's hash
		// length vs. plain invalid.
		if (HASH_ALPHABET_RE.test(hash) && hash.length >= 2 && hash.length <= 4) {
			return `[E_BAD_REF] Invalid line reference "${ref}": hashes are ${HASH_LENGTH} characters in this session, but this anchor has ${hash.length} — it looks like an anchor from a stale context or an older session. Re-read the file to get current anchors.`;
		}
		return `[E_BAD_REF] Invalid line reference "${ref}": hash must be exactly ${HASH_LENGTH} characters from ${NIBBLE_STR} (e.g. "${EXAMPLE_ANCHOR}").`;
	}
	if (!HASH_ALPHABET_RE.test(hash)) {
		return `[E_BAD_REF] Invalid line reference "${ref}": hash uses invalid characters, hashes use alphabet ${NIBBLE_STR} only.`;
	}
	return null;
}

function diagnoseLineRef(ref: string): string {
	const trimmed = ref.trim();
	const core = ref.replace(/^\s*[>+-]*\s*/, "").trim();

	if (!core.length) {
		return `[E_BAD_REF] Invalid line reference "${ref}". Expected "LINE#HASH" (e.g. "${EXAMPLE_ANCHOR}").`;
	}
	if (/^\d+\s*$/.test(core)) {
		return `[E_BAD_REF] Invalid line reference "${ref}": missing hash, use "LINE#HASH" from read output (e.g. "${EXAMPLE_ANCHOR}").`;
	}
	if (/^\d+\s*:/.test(core)) {
		return `[E_BAD_REF] Invalid line reference "${ref}": wrong separator, use "LINE#HASH" instead of "LINE:...".`;
	}

	const hashMatch = core.match(/^(\d+)\s*#\s*([^\s:]+)(?:\s*:.*)?$/);
	if (hashMatch) {
		const line = Number.parseInt(hashMatch[1]!, 10);
		const hash = hashMatch[2]!;
		if (line < 1) {
			return `[E_BAD_REF] Line number must be >= 1, got ${line} in "${ref}".`;
		}
		const hashError = diagnoseHash(ref, hash);
		if (hashError) {
			return hashError;
		}
	}

	const missingHashMatch = core.match(/^(\d+)\s*#\s*$/);
	if (missingHashMatch) {
		return `[E_BAD_REF] Invalid line reference "${ref}": missing hash after "#", use "LINE#HASH" from read output.`;
	}

	if (/^0+\s*#/.test(core)) {
		return `[E_BAD_REF] Line number must be >= 1, got 0 in "${ref}".`;
	}

	return `[E_BAD_REF] Invalid line reference "${trimmed || ref}". Expected "LINE#HASH" (e.g. "${EXAMPLE_ANCHOR}").`;
}

// Parses LINE#HASH format, tolerating leading ">+-" and whitespace (from
// mismatch/diff display) and an optional trailing ":content" display suffix,
// which is preserved as `textHint` for fuzzy anchor validation.
function parseAnchorRef(ref: string): Anchor {
	const core = ref.replace(/^\s*[>+-]*\s*/, "").trimEnd();
	const match = core.match(/^([0-9]+)\s*#\s*([^\s:]+)(?:\s*:(.*))?$/s);
	if (!match) {
		throw new Error(diagnoseLineRef(ref));
	}

	const line = Number.parseInt(match[1]!, 10);
	if (line < 1) {
		throw new Error(
			`[E_BAD_REF] Line number must be >= 1, got ${line} in "${ref}".`,
		);
	}

	const hash = match[2]!;
	const hashError = diagnoseHash(ref, hash);
	if (hashError) {
		throw new Error(hashError);
	}

	const textHint = match[3];
	return {
		line,
		hash,
		...(textHint !== undefined ? { textHint } : {}),
	};
}

// ─── Content preprocessing ─────────────────────────────────────────────────────

/**
 * Reject hashline display prefixes in edit payloads. Strict semantics: the
 * model must send literal file content for `lines`, not the rendered read /
 * diff form: display prefixes are rejected rather than stripped.
 *
 * This covers the unambiguous full `LINE#HASH:` / diff `+/-` forms, rejectable
 * on shape alone. The bare `HH:` variant is context-dependent and lives in
 * `warnBareHashPrefixLines` (apply.ts).
 */
function assertNoDisplayPrefixes(lines: string[]): void {
	for (const line of lines) {
		if (!line.length) continue;
		if (
			DISPLAY_PREFIX_RE.test(line) ||
			DISPLAY_PREFIX_PLUS_RE.test(line) ||
			DIFF_MINUS_RE.test(line)
		) {
			throw new Error(
				`[E_INVALID_PATCH] "lines" must contain literal file content, not rendered "LINE#HASH:" or diff "+/-" prefixes. Offending line: ${JSON.stringify(line)}`,
			);
		}
	}
}

/**
 * Validate and return replacement lines.
 *
 * Array input is preserved verbatim so explicitly provided blank lines remain
 * intact. Display prefixes (full `LINE#HASH:` and diff `+/-` forms) are
 * rejected by `assertNoDisplayPrefixes` — the model must send literal file
 * content, never rendered read or diff output.
 */
function hashlineParseText(edit: string[] | undefined): string[] {
	const lines = edit ?? [];
	assertNoDisplayPrefixes(lines);
	return lines;
}

/**
 * Validate + parse flat tool-schema edits into typed internal representations.
 *
 * Backstop validation + anchor parsing. Payloads arriving through pi's
 * agent loop were already validated against the published TypeBox schema
 * (additionalProperties, op union, required fields, types), so most of
 * these checks are unreachable there — they exist for direct execute()
 * callers, where they keep garbage from crashing parseAnchorRef or
 * silently no-opping unsupported ops.
 *
 * Strict: provided anchors must parse successfully. Missing anchors are
 * fine for append (→ EOF) and prepend (→ BOF), but a malformed anchor
 * that was explicitly supplied is always an error.
 *
 * - replace + pos only → single-line replace
 * - replace + pos + end → range replace
 * - append + pos → append after that anchor
 * - prepend + pos → prepend before that anchor
 * - no anchors → file-level append/prepend (only for those ops)
 */

const ITEM_KEYS = new Set(["op", "pos", "end", "lines"]);

function isStringArray(value: unknown): value is string[] {
	return (
		Array.isArray(value) && value.every((item) => typeof item === "string")
	);
}

function isTextReplaceKey(key: string): boolean {
	return (
		key === "oldText" ||
		key === "newText" ||
		key === "old_text" ||
		key === "new_text"
	);
}

function assertEditItem(edit: Record<string, unknown>, index: number): void {
	const unknownKeys = Object.keys(edit).filter((key) => !ITEM_KEYS.has(key));
	if (unknownKeys.length > 0) {
		if (unknownKeys.some(isTextReplaceKey)) {
			throw new Error(
				`Edit ${index} contains unsupported fields: ${unknownKeys.join(", ")}. Text-replace edits are not supported; re-read the file and use "replace", "append", or "prepend" with LINE#HASH anchors.`,
			);
		}
		throw new Error(
			`Edit ${index} contains unknown or unsupported fields: ${unknownKeys.join(", ")}.`,
		);
	}

	if (typeof edit.op !== "string") {
		throw new Error(`Edit ${index} requires an "op" string.`);
	}
	if (edit.op === "replace_text") {
		throw new Error(
			`[E_BAD_OP] Edit ${index}: the replace_text op is no longer supported. Re-read the file and use "replace", "append", or "prepend" with LINE#HASH anchors.`,
		);
	}
	if (edit.op !== "replace" && edit.op !== "append" && edit.op !== "prepend") {
		throw new Error(
			`[E_BAD_OP] Edit ${index} uses unknown op "${edit.op}". Expected "replace", "append", or "prepend".`,
		);
	}

	if ("pos" in edit && typeof edit.pos !== "string") {
		throw new Error(
			`Edit ${index} field "pos" must be a string when provided.`,
		);
	}
	if ("end" in edit && typeof edit.end !== "string") {
		throw new Error(
			`Edit ${index} field "end" must be a string when provided.`,
		);
	}
	if ("lines" in edit && !isStringArray(edit.lines)) {
		throw new Error(`Edit ${index} field "lines" must be a string array.`);
	}

	if (!("lines" in edit)) {
		throw new Error(`Edit ${index} requires a "lines" field.`);
	}

	if (edit.op === "replace" && typeof edit.pos !== "string") {
		throw new Error(
			`[E_BAD_OP] Edit ${index} with op "replace" requires a "pos" anchor string.`,
		);
	}

	if ((edit.op === "append" || edit.op === "prepend") && "end" in edit) {
		throw new Error(
			`[E_BAD_OP] Edit ${index} with op "${edit.op}" does not support "end". Use "pos" or omit it for file boundary insertion.`,
		);
	}
}

export function resolveEditAnchors(edits: HashlineToolEdit[]): HashlineEdit[] {
	const result: HashlineEdit[] = [];
	for (const [index, edit] of edits.entries()) {
		assertEditItem(edit as Record<string, unknown>, index);

		const op = edit.op;
		switch (op) {
			case "replace": {
				result.push({
					op: "replace",
					pos: parseAnchorRef(edit.pos!),
					...(edit.end ? { end: parseAnchorRef(edit.end) } : {}),
					lines: hashlineParseText(edit.lines),
				});
				break;
			}
			case "append": {
				result.push({
					op: "append",
					...(edit.pos ? { pos: parseAnchorRef(edit.pos) } : {}),
					lines: hashlineParseText(edit.lines),
				});
				break;
			}
			case "prepend": {
				result.push({
					op: "prepend",
					...(edit.pos ? { pos: parseAnchorRef(edit.pos) } : {}),
					lines: hashlineParseText(edit.lines),
				});
				break;
			}
		}
	}
	return result;
}
