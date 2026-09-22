# ADR 0008: Remove user configuration — hardcode hash length 3, grep on, no replace_text

## Status

Accepted (supersedes ADR 0006 and ADR 0007, which are removed)

## Context

This repository is now a personal vendored fork (upstream: npm `pi-hashline-edit` 0.8.3, MIT). ADR 0006 added `~/.pi/agent/hashline.json` (hashLength 2–4, grep opt-in) and ADR 0007 added `replaceText` opt-out. In the deployment this fork serves, the config was always set to `{"hashLength": 3, "grep": true, "replaceText": false}` — the configurable surface bought nothing and cost real complexity:

- a 183-line config module with fail-safe validation and warning plumbing,
- two published edit schemas (with/without replace_text) plus a runtime guard,
- load-time prompt rewriting (anchor-example padding, replace_text bullet stripping),
- a family of `__set*ForTests` setters for a test suite that does not exist in this copy.

## Decision

- Delete `~/.pi/agent/hashline.json` and `src/config.ts`. No configuration file, no config code.
- Hash length is fixed at **3** characters (12 bits). Prompt examples are authored at 3 characters; cross-length diagnostics for 2- and 4-char anchors from stale transcripts remain as literals.
- The `grep` tool is registered whenever ripgrep is on `PATH`.
- The `replace_text` op is removed entirely: schema, normalization, parsing, apply engine, prompts. Native `oldText`/`newText` payloads fail loudly with a teaching error pointing at anchor edits.
- Test-support exports (config setters, `resetReadSnapshot`, `resetNoopLoopGuard`, exported `RG_BIN`/`NOOP_HARD_LIMIT`) are removed with the tests they served.

## Consequences

- Behavior for this deployment is unchanged (it already ran hashLength 3 / grep on / replace_text off); the machinery to make those choices movable is gone.
- Changing any of the three constants now requires editing source (hash length: `HASH_LENGTH` in `src/hashline/hash.ts`, plus the prompt examples).
- Sessions started before this change that carry 2-character anchors will see the stale-anchor diagnostic and must re-read — the recovery path handles the common case.
- The schema shrinks to three ops for every model, converging behavior without opt-in plumbing.
