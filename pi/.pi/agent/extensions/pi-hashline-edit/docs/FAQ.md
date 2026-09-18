# FAQ

### Why 3 hash characters?

Hash length changes exactly one number: the probability that a *stale* anchor silently passes validation because the changed content at that line number coincidentally hashes to the same value — 2⁻¹² per stale anchor at length 3. That path is already triple-guarded: hashes cover the whole 3-line window (ADR 0003), the line number is the primary key, and a `textHint` vetoes collisions outright when present. What longer hashes do *not* buy: they don't reduce `[E_STALE_ANCHOR]` frequency at all (staleness comes from the file changing, not from hash width), and they can surface *more* visible errors, because mis-copied or fabricated anchors that would have slipped through at 12 bits get rejected at 16. The length is fixed at 3 in this fork (ADR 0008). If you want more safety per token, prefer keeping the `:content` suffix on anchors (see `textHint` below): it costs tokens only at edit time and blocks collisions by content, not probability.

### Why a custom 16-character alphabet instead of Base64 or hex?

Sixteen characters means each hash character encodes exactly one nibble: an N-char hash is a direct read of the low 4·N bits of xxh32, with no base conversion and an obvious length↔entropy relationship. Within that budget the letters are chosen for legibility: no vowels (A, E, I, O, U), so short hashes can't spell English words, and none of the digit-lookalikes D, G, L, O, I. Most hex digits are also excluded so anchors rarely read as hex literals — though `B` survives to fill the set, and at 3 characters real uppercase identifiers drawn from the alphabet can coincide with real tokens. That is why nothing in the pipeline trusts shape alone: hash-shaped content is never rejected on shape, and dedicated guards (the `[E_INVALID_PATCH]` display-prefix check, the bare-`HHH:` warning) handle the cases where a model confuses rendered anchors with file content.

### What happens with repeated lines — blank lines, repeated JSON, identical braces?

The hash is stateless: it depends on the current line plus its immediate neighbors (`prev + curr + next`), never on position or occurrence count. Two identical lines in different contexts get different hashes. When the context is also identical (consecutive blank lines, repeated identical objects), the line number in the anchor (e.g. `11#KTV`) breaks the tie. No hidden counter, no global state. Editing one line never invalidates anchors dozens of lines away.

### Why does editing line N invalidate anchors for N−1 and N+1?

Because each line's hash is computed from `prev + curr + next`. When line N changes, the "next" input for line N−1 and the "prev" input for line N+1 both change, so their hashes change too. This is an intended safety property: if the content around an anchor has shifted, even by a single neighbor edit, the anchor goes stale rather than silently pointing at a semantically different context. The blast radius is always exactly ±1 line — distant anchors remain stable.

### Why `E_STALE_ANCHOR` errors instead of silently fixing the offset?

Silent patching corrupts code. When an anchor goes stale, the system first tries a 3-way snapshot merge. If the merge applies with exact context match, it applies — with a mandatory warning to review the diff, because the merge is context-matched, not position-pinned. If the merge fails (conflict), the system fails loudly with `E_STALE_ANCHOR` and tells you to re-read; when the stale anchor included a text hint, the error may also list content-matched candidate anchors. No heuristic relocation to a "close enough" line. In production code editing, determinism beats convenience every time.

### Why does the snapshot merge require exact context match (fuzzFactor 0)?

Any fuzz tolerance in the merge would undermine the entire point of hash-anchored editing — it would reintroduce the same class of silent wrong-line rewrites that hashlines exist to prevent. fuzzFactor 0 means the merge either aligns on an exactly-matching context window or rejects. Note the scan: jsdiff searches for that exact window near the recorded position (that is what makes recovery work after the file shifted), so a hunk whose full context is duplicated elsewhere could land there — which is why recovery always emits a review warning and returns the diff.

### Why not have the model pass back an explicit Snapshot_ID?

Asking the model to track state adds failure modes: it can fabricate, misuse, or forget the ID. The anchors the model returns are the snapshot fingerprint. The system matches that set of `LINE#HASH` references against its internal pool and finds the version the model saw, with zero token overhead, no model-side tracking, and no risk of hallucinated IDs.

### What is `textHint` (e.g. `11#KTV:console.log(...)`) and why is it optional?

When an anchor keeps the `:content` suffix from read output, that content becomes a second factor with two roles. *Questioning*: if the hash matches but the content clearly isn't what's on that line — the 1/4096 case where the file changed and the new 3-line window collides into the same hash — the anchor is treated as stale, closing the silent-collision path outright. *Forgiveness*: if the hash mismatches only because the line drifted in whitespace (either end) or Unicode punctuation, a hint that still validates in the current context rescues the edit, with a warning. Truncated hints are understood: `console.log(...)` matches by the prefix before the ellipsis.

It is optional because it rides on copying behavior the model already has: anchors work bare (`12#MQQ`), and the hint engages whenever the full rendered line is copied instead. The tool prompt recommends keeping the content for high-risk anchors such as range endpoints — the cost is that line's tokens at edit time, which buys more safety than paying for longer hashes on every read line.

### Why is `grep` always registered?

Hashline-anchored grep closes the grep→edit loop: matches come back as `LINE#HASH:content` anchors, usable directly in `edit` without a prior `read`. For a personal deployment the tool-surface argument for opt-in (ADR 0006) does not apply. It still self-gates on ripgrep being available on `PATH`.

### Why does `E_NOOP_LOOP` trigger after 3 consecutive identical edits, not 1?

A single no-op edit is legitimate — the model may be confirming the file is already in the desired state or may have slightly misjudged what needs changing. Two is suspicious but still plausible in a retry flow. Three consecutive byte-identical no-op payloads on the same content is a strong signal that the model is stuck in a loop and will not self-correct. The threshold balances catching genuine loops against not being trigger-happy on normal retry behavior.
