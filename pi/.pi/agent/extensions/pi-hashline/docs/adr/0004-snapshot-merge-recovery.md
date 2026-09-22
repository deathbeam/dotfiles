# ADR 0004: Snapshot-merge stale-anchor recovery

## Status

Accepted

## Context

When a model reads a file and then edits it, a concurrent external write to the file between those two operations causes the stored anchors to become stale against the live file. Today `applyHashlineEdits` throws `[E_STALE_ANCHOR]` and the model must re-read before retrying. This round-trip is unnecessary when the model's intended edit is unambiguous against the content it actually read: the edit is perfectly valid, just aimed at a now-outdated version of the file.

Multiple independent hashline implementations converged on the same recovery strategy: replay the model's edit against the snapshot of what the model read, then 3-way-merge the result onto the live file.

A fuzzy-relocation tier (sliding stale anchors to nearby lines) was also prototyped elsewhere and then deliberately removed. Fuzzy relocation masked stale agent memory — it could silently apply an edit to the wrong line — and that risk was judged worse than the extra re-read round-trip.

## Decision

Add a two-tier stale-anchor flow:

1. **Exact match** — anchors are valid against the live file; apply directly (existing behavior).
2. **Snapshot merge** — anchors are stale against the live file but valid against the model's last read snapshot; replay the edit against the snapshot and 3-way-merge the result onto the live file using `structuredPatch` / `applyPatch` with `fuzzFactor: 0`.

Implementation details:

- A single-slot in-memory store (`src/read-snapshot.ts`) holds the most recent hashline (non-raw) read content, keyed by canonical mutation-target path. Single slot keeps memory bounded and covers the dominant read→edit→edit flow.
- The snapshot slot is updated after every successful non-raw `read` and after every successfully applied `edit`, so chained edits work without an intervening re-read.
- `fuzzFactor: 0` — hunk context lines must match exactly (no fuzzed context). *Amended 2026-09:* jsdiff's `applyPatch` still scans backwards/forwards from the hunk's recorded position to find an exactly-matching context window, so recovery is context-matched, not position-pinned — a hunk whose full context window is duplicated elsewhere in the live file can land there. The sliding is what makes recovery work after a shifted file; the recovery warning and returned diff are the model's chance to catch a misplaced merge.
- Recovery emits a mandatory warning in the tool response so hosts and models can audit the merge.
- If the snapshot is absent, matches the live content, or the merge fails (conflict), the original `[E_STALE_ANCHOR]` error surfaces unchanged — recovery degrades gracefully to today's behavior.
- Non-stale errors (`E_BAD_REF`, `E_INVALID_PATCH`, `E_WOULD_EMPTY`, `E_NOOP_LOOP`) are never intercepted by recovery.

## Consequences

- Correct-by-construction success path for the common case of a distant external change concurrent with a model edit.
- Merge failure (conflicting overlap between external change and model edit) degrades to the existing `[E_STALE_ANCHOR]` error — no silent data loss.
- Single slot means only the most recently read (or edited) file is recoverable; a model that reads multiple files and then edits them out of order may not benefit from recovery on all files.
- Recovered edits always carry a warning, giving hosts and models an explicit signal to review the diff.
- No fuzzy-relocation tier; that path was implemented and deliberately removed to avoid masking stale agent memory.
