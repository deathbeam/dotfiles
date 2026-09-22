# ADR 0001: Keep two-character hashline hashes

## Status

Accepted (length made configurable by ADR 0006; now fixed at 3 by ADR 0008)

## Context

Every `read` line includes `LINE#HH:`. Longer hashes reduce collision risk but increase model-visible token cost on every line. This interface is token-sensitive because anchors are copied into subsequent `edit` calls.

## Decision

Keep 2-character hashes.

## Consequences

- Lower token cost remains priority: roughly 2 hash tokens per line.
- Collision risk stays accepted trade-off.
- Anchor validation must remain strict and fail stale/mismatched anchors instead of guessing relocation.
- Future reviews should not reopen hash length without new collision evidence or changed token economics.
