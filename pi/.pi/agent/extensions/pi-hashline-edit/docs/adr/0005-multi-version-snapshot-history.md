# ADR 0005: Multi-version snapshot history for stale-anchor recovery

## Status

Accepted

## Context

ADR 0004 introduced snapshot-merge recovery: when a model's edit anchors are stale against the live file, the runtime replays the edit against the model's last read snapshot and 3-way-merges the result onto the live file. ADR 0004 itself acknowledged the limitation of its single-slot design:

> "Single slot means only the most recently read (or edited) file is recoverable; a model that reads multiple files and then edits them out of order may not benefit from recovery on all files."

User feedback confirmed a closely related failure mode: weaker models sometimes use anchors from several reads ago — for example, after reading the same file twice with an intervening external change, the model sends an edit using anchors from the first read. The single-slot store has already been overwritten by the second read, so recovery fails and the model receives a bare `[E_STALE_ANCHOR]` error with no useful diagnostic.

Additionally, when recovery fails the existing error gives no hint as to *why* — whether the anchors were almost right (valid against an older version but merge-conflicting) or completely wrong (hash not found in any recent read).

## Decision

### Multi-version LRU store

Replace the single-slot `read-snapshot.ts` with a per-path multi-version LRU store, governed by three limits:

| Constant | Value | Rationale |
|---|---|---|
| `MAX_PATHS` | 8 | Bounds the number of distinct files held in memory. |
| `MAX_VERSIONS_PER_PATH` | 4 | Covers the common "read → external change → read → edit with v1 anchors" flow. |
| `MAX_TOTAL_BYTES` | 32 MiB (UTF-16 length) | Absolute memory ceiling. UTF-16 `.length` is a slight under-count for astral-plane characters; the approximation is acceptable for a soft cap. |

Eviction rules (applied in order on each write):

1. **Read fusion**: if the incoming content is byte-identical to the most recent version for the same path, do not push a new entry; only refresh the path's MRU position.
2. **Version cap**: the oldest version for a path is evicted when that path exceeds `MAX_VERSIONS_PER_PATH`.
3. **Path cap**: the globally least-recently-used path is evicted when `MAX_PATHS` is reached.
4. **Byte budget**: if the total byte estimate exceeds `MAX_TOTAL_BYTES` after the above, the oldest version of the LRU path is evicted repeatedly until the ceiling is met.

### Recovery loop

The recovery block in `executeEditPipeline` (edit.ts) now iterates `getReadSnapshotVersions(canonicalPath)` (newest-first) instead of consulting the single slot. Each version is tried in turn: replay with `applyHashlineEdits`, then 3-way-merge with `threeWayMerge` (fuzzFactor: 0). The first successful merge is returned.

Two diagnostic facts are tracked across the loop for use in the final error message:

- **anyAnchorValid**: at least one version produced a valid replay (anchors matched) before the merge failed.

If no version succeeds, the original `[E_STALE_ANCHOR]` error is augmented with a suffix chosen by these facts:

| Condition | Suffix |
|---|---|
| `anyAnchorValid == true` | `(Recovery attempted: your anchors match an older read of this file, but replaying that edit conflicts with changes made since. Re-read to get current anchors.)` |
| `anyAnchorValid == false` | `(Your anchors do not match any recent read of this file — they may be from a stale context or copied incorrectly. Re-read before editing.)` |
| No usable versions (empty after filtering live content) | Original error surfaced unchanged (matches ADR 0004 behaviour). |

### Public API additions to `read-snapshot.ts`

`getReadSnapshotVersions(path: string): string[]` — returns all versions for a path in newest-first order. The existing `getReadSnapshot(path)` and `rememberReadSnapshot(path, content)` signatures are unchanged; `getReadSnapshot` continues to return only the newest version, preserving the duplicate-edit guard semantics introduced in the previous task.

## Consequences

- **Coverage expanded**: recovery now succeeds for the "anchors from several reads ago" failure mode that motivated this change. Any version within `MAX_VERSIONS_PER_PATH` of the current snapshot is a valid replay base.
- **Richer error messages**: when recovery fails, the model receives an actionable explanation — either "almost right, but conflicting" or "completely wrong, re-read required" — rather than a bare stale-anchor list.
- **Memory bound**: at most 8 paths × 4 versions each, capped at 32 MiB total. Peak usage in practice (2–4 edited files per session) stays well below the ceiling.
- **No fuzz-relocation**: `fuzzFactor: 0` is preserved — hunk context must match exactly, with no fuzzed context lines. (*Amended 2026-09:* `applyPatch` still scans for the exactly-matching context window, so a hunk can land at a duplicated context elsewhere; see the amendment in ADR 0004.)
- **Recovered edits still carry a warning**: the mandatory recovery warning from ADR 0004 is preserved regardless of which historical version was used for replay.
- **Very old snapshot merge**: if a very old snapshot (e.g. version 4 of 4) is used for recovery, the merge warning still fires, giving the model and host a signal to review the diff — the review matters, since the merge is context-matched rather than position-pinned.
