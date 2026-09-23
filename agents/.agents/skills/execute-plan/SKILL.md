---
name: execute-plan
description: Implement or resume tasks from a .plans/<name>.md file, verifying each task before marking it done.
---

# Execute Plan

Work from the plan file as the source of truth. A checked box means the outcome was verified, not merely that code was written. Follow the repo's instructions and git policy.

## Process

1. **Select and orient.** Use the named `.plans/<name>.md`; otherwise list `.plans/*.md` and ask which one. If none exists, suggest `prepare-plan`. Read the entire plan, repo instructions, and working-tree status before changing code. Summarize the goal, completed tasks, next unblocked task, and any existing changes that might overlap. On resumption, trust the file and the diff over memory.
2. **Choose a task.** Work on an unchecked task whose stated dependencies are done; when dependencies are unstated, follow list order. Read its surrounding context and relevant code. If the plan is a legacy one-line list or its check is vague, make the task's observable outcome and verification check explicit in the plan before working; ask only if the goal requires a decision the user has not made. Independent tasks with disjoint files may be delegated, but one owner updates the plan and verifies their results.
3. **Implement and verify.** Announce the task, make the smallest change that meets its outcome, and follow the repo's test/format rules. Use `tdd` at agreed test seams where it fits. Run the task's focused check, read its output, and compare with the expected result; reproduce manual checks rather than guessing. A failed check means the task is still open: diagnose, fix, and rerun it.
4. **Record immediately.** Once the outcome is verified, mark only that task `[x]` and append one brief line under `## Notes` recording the check and result (or a manual observation). Do this after each task, not as a batch. If verification is unavailable, leave `[ ]` and record what remains to check so another session can resume.
5. **Adapt deliberately.** If code reveals a wrong task or command, make the smallest correction consistent with the Goal, record `Ruling: <change> — <reason>` in Notes, and continue. Ask before changing the Goal or scope. Stop for destructive/irreversible actions, security-sensitive choices, external side effects such as pushing or publishing, or a plan so unclear every path is a guess; otherwise resolve ordinary errors yourself.
6. **Close out.** Run the repo's final build/test checks and review the full diff against the Goal and repo rules; use an independent reviewer for substantial changes if available. Fix material findings, then report verified tasks, checks run, rulings, and anything still unchecked. Declare the plan complete only when every required task and final check passed; clearly distinguish optional tasks that remain open.

## Guardrails

- Preserve already completed checkboxes and unrelated working-tree changes.
- Keep edits scoped to the task; record discoveries for later tasks in Notes instead of silently doing them now.
- Never auto-commit when repo instructions prohibit it.
