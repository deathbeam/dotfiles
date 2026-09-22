# ADR 0002: Delete edit return payload modes

## Status

Accepted

## Context

`edit` supported `returnMode: "full" | "ranges"` plus `returnRanges`. After token-efficiency changes, those modes placed large post-edit payloads into host-only `details` while visible text did not carry fresh anchors for model follow-up. Models could choose modes that made their next action worse.

## Decision

Delete `returnMode`, `returnRanges`, `details.fullContent`, `details.returnedRanges`, `details.structureOutline`, and related structure-outline/range-preview machinery.

`edit` now has one success response shape: changed anchors in model-visible text plus host-only metrics/diff details. If broader context is needed, model must call `read` after edit.

## Consequences

- Model-facing contract is smaller and harder to misuse.
- `edit-response` no longer depends on `read` formatting helpers.
- Details contract has one authority at response-builder seam.
- Breaking change accepted; callers using deleted fields must switch to `read`.
