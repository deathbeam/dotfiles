/**
 * Hash computation — NIBBLE_STR alphabet, xxh32, per-line hash.
 *
 * Vendored & adapted from oh-my-pi (MIT, github.com/can1357/oh-my-pi).
 */

import * as XXH from "xxhashjs";

/**
 * Fixed session hash length. 3 characters = 12 bits of the 3-line-window
 * xxh32 — a 2^-12 silent false-accept floor per stale anchor, on top of the
 * line-number primary key and the textHint content veto.
 */
export const HASH_LENGTH = 3;

/**
 * Custom 16-character hash alphabet. Deliberately excludes:
 * - Most hex digits: A, C, D, E, F (B is retained to reach 16 letters, so a
 *   hash such as "BBB" can still coincide with a hex-ish token)
 * - Visually confusable letters: D, G, I, L, O (look like digits 0, 6, 1, 1, 0)
 * - Common vowels A, E, I, O, U (prevents accidental English words)
 *
 * 16 characters means each hash character encodes exactly one nibble (4 bits),
 * so an N-char hash is a direct read of the low 4·N bits of xxh32 — no base
 * conversion, and the length↔entropy relationship stays obvious.
 *
 * At 3 characters, tokens drawn from real uppercase identifiers may
 * coincidentally share the character set. Detectors must not rely on shape
 * alone to distinguish anchors from content — context and position remain
 * the authoritative signals.
 */
export const NIBBLE_STR = "ZPMQVRWSNKTXJBYH";
/** Anchor hashes are displayed uppercase; input matching tolerates any case. */
export const HASH_ALPHABET_RE = new RegExp(`^[${NIBBLE_STR}]+$`, "i");

/** Lines containing no alphanumeric character (only punctuation/symbols/whitespace). */
export const RE_SIGNIFICANT = /[\p{L}\p{N}]/u;

/**
 * Normalize a line for hash input: strip \r, trimEnd. Leading indentation
 * IS hashed — two lines differing only in indent get different hashes.
 */
export function normalizeHashInput(line: string): string {
    return line.replace(/\r/g, "").trimEnd();
}

/**
 * Compute the hash from a line's content and its immediate neighbors.
 * Using prev + "\0" + curr + "\0" + next as the hash input ensures:
 * - Distant edits no longer invalidate anchors (only same/adjacent lines affected).
 * - Adjacent-edit invalidation is intentional: editing near an anchor makes it stale.
 * - Silent collisions now require the entire 3-line window to match.
 * All three inputs must already be normalized via normalizeHashInput.
 */
export function computeHashFromContext(prev: string, curr: string, next: string): string {
    const h =
        XXH.h32(0)
            .update(prev + "\0" + curr + "\0" + next)
            .digest()
            .toNumber() >>> 0;
    // Extract HASH_LENGTH nibbles from the low 4*HASH_LENGTH bits.
    let result = "";
    for (let i = HASH_LENGTH - 1; i >= 0; i--) {
        result += NIBBLE_STR[(h >>> (i * 4)) & 0x0f]!;
    }
    return result;
}

/**
 * Compute the hash for a line at a given 0-based index within a file.
 * Neighbors outside the file boundaries use "" as their normalized value.
 */
export function computeLineHash(fileLines: readonly string[], index: number): string {
    const prev = normalizeHashInput(index > 0 ? fileLines[index - 1]! : "");
    const curr = normalizeHashInput(fileLines[index]!);
    const next = normalizeHashInput(index < fileLines.length - 1 ? fileLines[index + 1]! : "");
    return computeHashFromContext(prev, curr, next);
}

/** Fuzzy-match Unicode replacement regexes for anchor textHint validation. */
const FUZZY_SINGLE_QUOTES_RE = /[\u2018\u2019\u201A\u201B]/g;
const FUZZY_DOUBLE_QUOTES_RE = /[\u201C\u201D\u201E\u201F]/g;
const FUZZY_HYPHENS_RE = /[\u2010\u2011\u2012\u2013\u2014\u2015\u2212]/g;
const FUZZY_UNICODE_SPACES_RE = /[\u00A0\u2002-\u200A\u202F\u205F\u3000]/g;

/**
 * Whitespace on BOTH ends is normalized away. Trailing drift is classic
 * copy noise; leading drift covers both a space typed after the ":"
 * separator of an anchor ("12#ABC: content") and re-typed indentation.
 * Hashes themselves stay whitespace-exact — see normalizeHashInput.
 */
function normalizeFuzzyLine(text: string): string {
    return text
        .trim()
        .replace(FUZZY_SINGLE_QUOTES_RE, "'")
        .replace(FUZZY_DOUBLE_QUOTES_RE, '"')
        .replace(FUZZY_HYPHENS_RE, "-")
        .replace(FUZZY_UNICODE_SPACES_RE, " ");
}

export function isFuzzyEquivalentLine(expected: string, actual: string): boolean {
    return normalizeFuzzyLine(expected) === normalizeFuzzyLine(actual);
}

/** First ASCII "..." or Unicode "…" in a hint marks it as model-truncated content. */
const ELLIPSIS_RE = /\.{3}|…/;

/**
 * Match a textHint against an actual file line for anchor validation.
 *
 * A full hint must be fuzzy-equivalent to the line. A hint containing an
 * ellipsis is treated as truncated content copied by the model (e.g.
 * "console.log(...)" for "console.log('hello world')"): only the
 * fuzzy-normalized prefix before the first ellipsis must match the start of
 * the line. An ellipsis-leading hint has an empty prefix and never vetoes.
 */
export function hintMatchesLine(hint: string, line: string): boolean {
    const normalizedHint = normalizeFuzzyLine(hint);
    const ellipsisIndex = normalizedHint.search(ELLIPSIS_RE);
    if (ellipsisIndex === -1) {
        return normalizedHint === normalizeFuzzyLine(line);
    }
    const prefix = normalizedHint.slice(0, ellipsisIndex);
    return normalizeFuzzyLine(line).startsWith(prefix);
}

/**
 * True when a hint can discriminate between lines: non-empty content before
 * any ellipsis. No-signal hints (empty or ellipsis-leading) would match every
 * line, so candidate scanning must skip them.
 */
export function hintHasSignal(hint: string): boolean {
    const normalizedHint = normalizeFuzzyLine(hint);
    const ellipsisIndex = normalizedHint.search(ELLIPSIS_RE);
    const prefix = ellipsisIndex === -1 ? normalizedHint : normalizedHint.slice(0, ellipsisIndex);
    return prefix.length > 0;
}
