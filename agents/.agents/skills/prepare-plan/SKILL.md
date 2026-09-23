---
name: prepare-plan
description: Create or revise a .plans/<name>.md implementation plan before coding; use when work needs a detailed, executable task breakdown.
---

# Prepare Plan

Write a `.plans/<name>.md` file that another session can execute without reconstructing the decisions. Keep one Markdown file; detail should resolve uncertainty, not predict every edit. Planning changes only that file.

## Process

1. **Orient.** Use the user's name or derive a kebab-case name from the goal. If the file exists, read it first and revise it in place, preserving completed tasks and execution notes. Read the request, repo instructions, relevant code, callers, existing tests, and prior patterns before choosing an approach. Stop when you can identify the behavior to change, its seam, and how to verify it.
2. **Resolve decisions.** Look up facts yourself. Ask the user only for decisions that materially change the plan; use `grilling` when several dependent decisions are open, `research` for external facts, and `codebase-design` when the seam is uncertain. Record assumptions and unresolved choices explicitly; if a choice blocks a task, settle it before presenting the plan as ready.
3. **Write the plan.** Prefer existing code and the smallest viable change. Break work into dependent, independently verifiable tasks; each should fit a focused session and leave the repo in a working state. For features, prefer complete behavior slices over separate setup/logic/UI piles. For a wide mechanical refactor that cannot stay green in one slice, plan expand → migrate → contract instead. Add detail where an executor would otherwise have to guess.
4. **Self-check and hand off.** Trace every requirement to a task and every task to a concrete completion check. Check names and interfaces across tasks; replace placeholders such as "handle edge cases" or "write tests" with the specific behavior and check. Report the plan path and the decisions still needing input. Plan only: wait for an execution request.

## Format

Use the existing plan's structure when revising it. For new plans:

```markdown
# Plan: <name>

## Goal
<observable outcome>

## Context
<current behavior, relevant code and existing seams, decisions, constraints, out of scope; include a spec/link when one exists>

## Tasks
- [ ] <deliverable/behavior>
  - Where: `path/to/existing-file` and `path/to/test-file` (or label likely paths). Name interfaces other tasks depend on.
  - Blocked by: none (or name the prerequisite task).
  - Done when: <observable result>; run `<actual repo command>` → <expected result>.
- [ ] <second independently verifiable deliverable>
  - Where: `path/to/file`
  - Blocked by: <task name or none>
  - Done when: <observable result>; run `<command>` → <expected result>.

## Open questions
<only unresolved non-blocking choices or discoveries needed later; omit if none>

## Notes
<design context and execution decisions; omit if empty>
```

Use exact paths and commands when found; label paths as likely when not yet confirmed. For manual or visual work, describe the observation and how to reproduce it instead of inventing an automated check. Keep task prose as short as clarity allows. An existing one-line task list remains valid: enrich vague tasks rather than reformatting the whole file.
