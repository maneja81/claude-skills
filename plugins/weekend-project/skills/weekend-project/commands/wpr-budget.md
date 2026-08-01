# Command: wpr-budget

Show token usage breakdown and remaining budget.

## Steps

1. Read `.claude/weekend-project/budget.json`
2. Read the active plan — glob `$PROJECT_ROOT/.claude/weekend-project/plans/*/[current_plan]-*.json` (for PR list)
3. Read `.claude/weekend-project/session.yaml` (for current progress)

Render:

```
Token Budget — [project name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Estimate (with 15% buffer): ~[X]k tokens
Spent to date:              ~[Y]k tokens ([Z]%)
Remaining:                  ~[R]k tokens

By PR:
  PR-001 wpr/chore/scaffold         est. 80k  ·  actual 74k   ✓
  PR-002 wpr/feature/auth           est. 140k ·  actual 163k  ✓  (+16%)
  PR-003 wpr/design/design-system   est. 120k ·  in progress
  PR-004 wpr/feature/dashboard      est. 160k ·  pending
  PR-005 wpr/chore/qa-backlog       est. 40k  ·  pending
  ──────────────────────────────────────────────────────
  Total estimated remaining: ~320k tokens

[If actual > 80% of estimate_with_buffer]:
⚠  Spending is tracking above estimate. Remaining [N] PRs estimated at [X]k.
   Current plan headroom: [Y]k. Consider reviewing the remaining PRs for scope reduction.

[If on track]:
✓  Spending is within estimate.
```

If user asks "how much has PR-[N] cost?" — show the PR breakdown for that PR including dev build, QA rounds, and fix rounds separately (if tracked).
