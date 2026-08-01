# Plan Files — Schema and Lifecycle

A project is a queue of plans. Each plan is a batch of PRs that ships something coherent on its own.

```
.claude/weekend-project/plans/
  pending/    queued, not started
  active/     the one being executed (0 or 1 file)
  done/       all PRs merged
  deferred/   shelved, with a reason
```

All four are committed. Plan files are the project's record of intent, and a worktree created from `develop-ai` only contains them if they are in the repository.

---

## The one invariant

**`session.yaml` is authoritative. Folder placement is a derived view.**

Plans are referenced by **ID**, never by path. `session.yaml` holds `current_plan: plan-002`; the file is found by globbing `plans/*/plan-002-*.json`. Nothing stores a path, so a half-completed move can never orphan a plan.

`wpr-resume` reconciles on every run:

- `session.yaml → current_plan` names a plan not in `active/` → move it there, say so
- A file sits in `active/` that isn't `current_plan` → move it back to `pending/`, say so
- More than one file in `active/` → keep `current_plan`, return the rest to `pending/`
- `current_plan` names an ID with no matching file anywhere → stop and escalate; do not invent a plan

Reconciliation is silent housekeeping unless something moved, in which case report it in one line.

---

## Identity and numbering

IDs are `plan-NNN`, zero-padded, globally unique, never reused. The next ID is `max(all existing IDs across all four folders) + 1` — including `done/` and `deferred/`, so a completed plan's number is never handed out again.

The filename is `plan-NNN-<slug>.json`. The slug is cosmetic; the ID is identity. Renaming the slug is safe, changing the number is not.

---

## Schema

```json
{
  "id": "plan-002",
  "title": "Billing and subscriptions",
  "created": "ISO-timestamp",
  "status": "pending",
  "depends_on": ["plan-001"],
  "done_when": "A user can subscribe, see an invoice, and cancel — verified end to end against Stripe test mode",
  "ai_branch": "develop-ai",
  "is_frontend": true,
  "ui_mockup_phase": false,
  "estimated_tokens": 420000,
  "removes": ["the hardcoded PLAN_LIMITS map in apps/api/src/limits.ts"],
  "risks": ["Stripe webhook signature verification needs a public URL in dev"],
  "rollback": "Revert the merge commits; no destructive migrations in this plan",
  "deferred_reason": null,
  "prs": [
    {
      "id": "pr-001",
      "title": "Stripe client and webhook receiver",
      "type": "feature",
      "branch": "wpr/feature/stripe-webhooks",
      "scope": "Stripe SDK wiring, signed webhook endpoint, event persistence",
      "acceptance_criteria": [
        "POST /api/webhooks/stripe returns 400 on an invalid signature",
        "A valid checkout.session.completed event writes one row to billing_events",
        "Replaying the same event id is a no-op — no duplicate row"
      ],
      "touches": ["apps/api/src/billing/stripe.ts", "apps/api/src/routes/webhooks.ts"],
      "current_behaviour": "No billing code exists; limits are a hardcoded map in limits.ts",
      "blast_radius": ["apps/api/src/limits.ts consumers", "the users table (new FK)"],
      "edge_cases": ["duplicate event id", "clock skew on signature", "oversized payload"],
      "breaking_changes": "none",
      "verify": "pnpm test --filter api billing → 7 passing",
      "blocked_by": [],
      "estimated_tokens": 120000,
      "is_frontend_pr": false,
      "playwright_required": false,
      "status": "todo"
    }
  ]
}
```

`status` on a plan is `pending` · `active` · `done` · `deferred`, and must agree with its folder. On any disagreement the folder is corrected to match `session.yaml`, and `status` is rewritten to match the folder.

`status` on a PR is `todo` · `in-progress` · `merged` · `abandoned`.

`deferred_reason` is required when a plan is in `deferred/` and null everywhere else. "Shelved without a reason" becomes "why is this here?" three months later.

---

## Staleness

A plan written before other plans merged was written against a codebase that no longer exists.

Before executing any plan that was not created in this session, re-run Phase 1 discovery from `references/planning-protocol.md` against the current `develop-ai`, and specifically re-run the **reuse audit**. Report the delta:

```
plan-003 was planned 4 PRs ago. Re-checked against current develop-ai:

  PR-002 "add pagination helper" — packages/utils/paginate.ts now exists (built in plan-002/pr-004)
      → scope reduced to wiring it into the admin list
  PR-004 — unchanged
  PR-005 — acceptance criterion 3 referenced getUser(), now getUserById()
      → criterion updated

Proceed with the revised plan?
```

If the delta is large enough that PR boundaries no longer make sense, say so and offer to replan rather than executing something that no longer fits.

---

## Budget

`budget.json` is keyed by plan:

```json
{
  "plans": {
    "plan-001": { "estimate": 730000, "actual": 506000, "by_pr": { "pr-001": 88000 } },
    "plan-002": { "estimate": 420000, "actual": 0, "by_pr": {} }
  },
  "project_total": { "estimate": 1150000, "actual": 506000 }
}
```

Warn when a plan's actual crosses 80% of its own estimate before its final PR — per plan, not per project, so one overrun doesn't hide inside a large total.

---

## Migration from single-plan projects

A project created before plans existed has `plan.json` and no `plans/`. On first run of any command, if `plan.json` exists and `plans/` does not:

1. Create the four folders
2. Move `plan.json` → `plans/<folder>/plan-001-<slug>.json`, choosing the folder from `session.yaml → phase`: `complete` → `done/`, anything else → `active/`
3. Add `id`, `status`, `depends_on: []`, `deferred_reason: null`; leave every PR untouched
4. Rewrite `budget.json` into the keyed form under `plan-001`
5. Set `session.yaml → current_plan`
6. Generate `roadmap.md`
7. Tell the user in one line: "Migrated to multi-plan layout — existing work is now plan-001."

Never delete `plan.json` in the same commit as the migration. Leave it for one plan cycle so a rollback is possible, then remove it.
