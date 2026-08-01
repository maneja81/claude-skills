# Command: wpr-plan

Show the full PR plan. Optionally edit it.

## Steps

1. Read the active plan — glob `$PROJECT_ROOT/.claude/weekend-project/plans/*/[current_plan]-*.json`
2. Read `session.yaml` to know which PRs are done

Render the plan as a table:

```
PR Plan — [project name]
━━━━━━━━━━━━━━━━━━━━━━━━

  #    Status    Branch                         Scope                           Blocked by    Est.
  ─────────────────────────────────────────────────────────────────────────────────────────────────
  001  ✓ merged  wpr/chore/scaffold             Project init + CI               —             80k
  002  ✓ merged  wpr/feature/auth               Auth system (JWT + Clerk)       001           140k
  003  → current wpr/design/design-system       Base UI components              001           120k
  004  ○ pending wpr/feature/dashboard          Dashboard screen                002, 003      160k
  005  ○ pending wpr/chore/qa-backlog           Deferred minor issues           all           40k
  ─────────────────────────────────────────────────────────────────────────────────────────────────
  Total: 5 PRs · ~540k tokens estimated

Legend: ✓ merged · → current · ○ pending · ✗ escalated
```

Then ask: "Want to edit the plan? Options:
  - Add a PR (`wpr-plan add`)
  - Remove a PR (`wpr-plan remove PR-[N]`)
  - Edit a PR's scope or acceptance criteria (`wpr-plan edit PR-[N]`)
  - Reorder PRs (`wpr-plan reorder`)
  - No changes needed"

If the user edits the plan:
- Apply changes to the active plan file
- Recalculate budget and update `budget.json`
- If reordering affects a current or completed PR, warn before applying
- Show the updated plan for confirmation

Plan edits are only allowed before a PR has started. Editing a PR that is `current` or `merged` requires explicit user confirmation with a clear warning about the impact.
