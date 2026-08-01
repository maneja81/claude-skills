# Command: wpr-status

Show the current state of the weekend project build without modifying anything.

## Steps

1. Read `.claude/weekend-project/session.yaml`
2. Read the active plan — glob `$PROJECT_ROOT/.claude/weekend-project/plans/*/[current_plan]-*.json`
3. Read `.claude/weekend-project/budget.json`
4. Count entries in `known-issues.md` (minor deferred issues)
5. Count entries in `open-decisions.md` pending input

Render:

```
Weekend Project — [project name from config.yaml]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase:         [interview | planning | ui-mockups | execution | complete]
Current PR:    PR-[N] · [branch] · [title]
Round:         [N] / 3
State:         [dev-building | qa-reviewing | fix-in-progress | merge-gate | merged]
Last saved:    [last_checkpoint from session.yaml]

Progress:      [████████░░] [N] of [total] PRs merged

Budget:
  Estimated:   ~[X]k tokens (with 15% buffer)
  Spent:       ~[Y]k tokens ([Z]%)
  Remaining:   ~[R]k tokens

Open items:
  Known issues:     [N] deferred (see known-issues.md)
  Open decisions:   [N] pending your input (see open-decisions.md)
  Backlog PR:       [scheduled / not needed]

Next step: [one sentence on what happens next]

Run `wpr-resume` to continue · `wpr-plan` to see the full plan · `wpr-review` to work through open items
```

If `session.yaml` does not exist: tell the user no project is active and offer `wpr-start`.
