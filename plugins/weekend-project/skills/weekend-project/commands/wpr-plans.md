# Command: wpr-plans

Show the plan queue. Read-only.

---

## 1. Reconcile first

Before displaying anything, run the reconciliation in `references/plan-schema.md`: `session.yaml → current_plan` is authoritative, folder placement is a derived view. If anything moved, say so in one line above the table.

## 2. Read

Glob `plans/*/plan-*.json` across all four folders. Read each plan's `id`, `title`, `status`, `depends_on`, `prs[].status`, and its entry in `budget.json`.

Never trust a stored path — always resolve a plan by globbing its ID.

## 3. Render

```
Plans — [project name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ plan-001  MVP                        6/6 PRs   506k / 730k
  ▶ plan-002  Billing and subscriptions  2/3 PRs   180k / 310k   ← current
    plan-003  Admin and reporting        0/4 PRs        ~250k    needs plan-002
    plan-004  Mobile responsive pass     0/2 PRs        ~140k
  ⏸ plan-005  Offline mode                                       deferred

  Total: 686k spent · ~700k estimated remaining

Next: PR-003 of plan-002 — "Invoice list and cancel flow"
```

Markers: `✓` done · `▶` active · (blank) pending · `⏸` deferred.

Order: `done/` by ID, then `active/`, then `pending/` by ID, then `deferred/` by ID. A pending plan whose `depends_on` is unmet shows what it is waiting for.

If a deferred plan has a `deferred_reason`, show it under the table rather than crowding the row:

```
plan-005 deferred — "waiting on the design system rewrite; would need redoing after"
```

## 4. Nothing queued

If `pending/` and `deferred/` are both empty and a plan is active:

```
plan-002 is running. Nothing queued behind it.
Add one with `wpr-plan-add` — it won't interrupt the current build.
```

If everything is in `done/`:

```
All plans complete — [N] plans, [N] PRs merged to develop-ai.

  wpr-plan-add   queue the next batch
  wpr-review     work through known-issues.md
```

---

## Also regenerate roadmap.md

`roadmap.md` at the project root is the committed, readable version of this view — the same content as the table above, plus each plan's `done_when`. Regenerate it whenever a plan is created, started, completed or deferred, so the file in the repo always matches the queue on disk.
