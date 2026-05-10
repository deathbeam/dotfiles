---
name: prepare-plan
description: Use when the user wants to create a new plan, edit an existing plan, or structure work before implementation. Use when there is no clear plan yet or the existing plan needs updating.
---

# Prepare Plan

Create or update a plan file in `.plans/<plan>.md`. Plans are lightweight markdown task lists — no schemas, no CLI dependencies.

## When to Use

- User says "let's plan this" or "I need a plan for X"
- User wants to update an existing plan
- Before starting work that spans multiple steps

## Plan Format

```markdown
# Plan: <name>

## Goal
What we are building or fixing.

## Context
Relevant background, constraints, or links.

## Tasks
- [ ] Task one
- [ ] Task two
- [ ] Task three

## Notes
Free-form scratch space for design decisions, open questions, etc.
```

## Steps

1. **Get or confirm the plan name**
   - If user provided a name, use it (kebab-case preferred).
   - If not, ask: "What should we name this plan?"
   - Example: `refactor-auth` → `.plans/refactor-auth.md`

2. **Check if plan exists**
   - If `.plans/<name>.md` exists, read it and show the user.
   - Ask what to change: append tasks, edit goal/context, or rewrite.

3. **Create or update the file**
   - New plan: write the template above, filling in what you know from context.
   - Existing plan: apply the user's edits directly. Preserve completed checkboxes unless the user asks to reset them.

4. **Confirm**
   - Show the final plan path and a 1-line summary.
   - If new: "Plan created at .plans/<name>.md. Run `/execute-plan <name>` to start working through it."
   - If updated: "Plan updated. Ready to execute or make further changes."

## Guardrails

- Keep plans short and actionable. If a task is vague, split it.
- Do not invent tasks you don't have context for. Ask the user to fill gaps.
- `.plans/` directory is auto-created if it doesn't exist.
