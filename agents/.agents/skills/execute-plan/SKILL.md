---
name: execute-plan
description: Use when the user wants to work through a plan, start implementation from a task list, or continue a partially completed plan. Use when tasks are already defined in a .plans/<plan>.md file.
---

# Execute Plan

Work through tasks from a `.plans/<plan>.md` file. Read the plan, implement tasks, and update checkboxes as you go.

## When to Use

- User says "let's build this" or "execute the plan" or "start working on X"
- User wants to continue a partially completed plan
- Implementation needs to follow a predefined task list

## Steps

1. **Select the plan**
   - If user named a plan, use it.
   - If not, list `.plans/*.md` and ask which one.
   - If no plans exist, prompt the user to run `/prepare-plan` first.

2. **Read the plan**
   - Load `.plans/<name>.md`.
   - Show the goal and task list with current progress.

3. **Execute tasks in order**
   - For each unchecked task:
     a. Announce the task.
     b. Do the work (edit code, run commands, etc.).
     c. When complete, update `- [ ]` → `- [x]` in the plan file.
     d. Move to the next unchecked task.

4. **Handle blockers**
   - If a task is unclear → ask for clarification before proceeding.
   - If a task reveals the plan needs updating → suggest editing the plan, then continue.
   - If an error blocks progress → report it and wait for guidance.

5. **Wrap up**
   - When all tasks are checked: "Plan complete. `.plans/<name>.md` is fully checked off."
   - If paused mid-plan: "Paused after task N. Resume anytime with `/execute-plan <name>`."

## Guardrails

- Update the plan file immediately after completing each task. Do not batch checkbox updates.
- Keep changes scoped to the current task. Don't drift into future tasks.
- If the user interrupts or changes direction, stop and confirm before continuing.
- Never edit the plan's goal/context without asking, but feel free to append to Notes.
