# ADR 0003: Context-based line hashing

## Status

Accepted

## Context

Before ADR 0003, each line's 2-char hash was computed from its content alone (plus a line-number seed for symbol-only lines). This meant two identical `}` lines at different positions in a file could collide in hash space unless they happened to be at different line numbers — a fragile disambiguation that depended on file position, not content. More importantly, a distant edit at line 80 left the hash of line 5 unchanged, but an edit anywhere on the file could shift line numbers, silently staling all symbol-only anchors (whose seed was their old line number).

The `textHint` field (the `:content` suffix on an anchor) already provided a cross-check path, but the forgiveness logic recomputed the hint's hash using the old `(lineNum, hint)` signature — not the current file's neighbor context — making it inconsistent with how the main hash was computed.

## Decision

Replace the per-line hash function with a context-sensitive one:

- Factor out `normalizeHashInput(line)` for stripping `\r` and trimming trailing whitespace.
- Export `computeHashFromContext(prev, curr, next)`: xxHash32 over `prev + "\0" + curr + "\0" + next` (all three already normalized), seed 0, mapped through the existing DICT/NIBBLE\_STR alphabet. Seed 0 is always used; the line-number seed is removed entirely.
- Export `computeLineHash(fileLines, index)` where `index` is 0-based. Neighbors outside file boundaries use `""`. This is the primary hash entry point.
- `formatHashlineRegion` receives the full file lines array and 1-based inclusive `startLine`/`endLine`. Hashes at region edges depend on neighbors outside the region, so a slice can never be passed.
- `textHint` forgiveness: on hash mismatch with `textHint` present, recompute the hint's hash using the current file's neighbors: `computeHashFromContext(normalized prev from file, normalized textHint, normalized next from file)`. Accept only if that equals the reference hash and `isFuzzyEquivalentLine(textHint, actualLine)`.
- `textHint` questioning: when the hash matches but `textHint` is present and does not fuzzy-match the actual line, treat the anchor as stale. This closes the silent 1/256 collision path — a model that copied `LINE#HASH:content` gets the content cross-checked at zero extra token cost.

## Consequences

- Every hash value changes. This is a breaking change; anchors from earlier context-free hashline sessions are all stale by definition.
- Editing line N invalidates anchors for lines N−1, N, and N+1 (they are now adjacent). This is intentional: an anchor immediately next to a changed line should be treated as unsafe.
- Distant edits (outside the ±1 window) leave an anchor's hash unchanged, reducing spurious stale errors on large files.
- Two identical lines with different immediate neighbors receive different hashes, eliminating the symbol-only line-number seed workaround.
- Two identical 3-line windows still produce the same hash — the same collision trade-off family as ADR 0001. This is accepted.
- ADR 0001's 2-character hash decision is unaffected; the alphabet and length are unchanged.
