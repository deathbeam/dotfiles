Patch a text file at `LINE#HASH` anchors copied verbatim from the latest read/grep result or the anchors block of a previous edit.

Batch every change to a file into one `edit` call: all operations go in the `edits` array, every edit sets `op`, and all anchors must come from the same pre-edit read. Edits validate against one snapshot and apply together, so line numbers never shift between entries of the same call.

Ops:
- `replace` — replace the single line at `pos`, or the inclusive span `pos`..`end`. `lines` is the complete new content for the whole span; `lines: []` deletes it. Without `end`, exactly one line is replaced no matter how many entries `lines` has.
- `append` — insert `lines` after `pos`; omit `pos` to append at end of file.
- `prepend` — insert `lines` before `pos`; omit `pos` to insert at start of file.

Example — single-line and span replace in one call:
```json
{ "path": "src/main.ts", "edits": [
  { "op": "replace", "pos": "12#MQQ", "lines": ["const x = 1;"] },
  { "op": "replace", "pos": "5#VRQ", "end": "8#QVQ", "lines": [
    "function greet(name) {",
    "  return `Hello, ${name}`;",
    "}"
  ] }
] }
```

Rules:
- `lines` is literal file content with exact indentation. Never include `LINE#HASH:` or bare `HHH:` prefixes, diff `+`/`-` markers, or a copy of a neighboring line — the `:content` part of an anchor is context for you, not payload, and repeating a boundary line duplicates it in the file.
- Anchors are opaque: copy them exactly, never compute, shift, or guess one.
- An anchor may keep the `:content` suffix from read output (`"12#MQQ:const x = 1;"`). The runtime cross-checks that content against the file — catching hash collisions and recovering whitespace-only drift — so keep it for high-risk anchors such as range endpoints. Copy the content exactly as rendered; if you shorten it, keep the start of the line and mark the cut with `...`.
- Edits in one call must not overlap or touch adjacent lines — merge such changes into a single edit.
