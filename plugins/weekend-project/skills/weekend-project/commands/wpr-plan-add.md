# Command: wpr-plan-add

Queue a new plan for later. Does not start execution and does not touch the running build.

Usage: `wpr-plan-add` or `wpr-plan-add billing and subscriptions`

---

## 1. Preconditions

Requires an initialised project (`.claude/weekend-project/config.yaml` exists). If it doesn't, this is a first run — route to `weekend-project` instead.

Safe to run at any time, including mid-build: it only writes a new file into `plans/pending/` and regenerates `roadmap.md`. If a build is in progress, say so and confirm the new plan is meant for afterwards, not now.

---

## 2. The short interview

This is the payoff of having planned once already. `config.yaml` holds the stack, infrastructure, standards and design direction — do not ask any of it again.

Ask only what a follow-up plan genuinely needs:

```
What should this plan deliver?
(2-3 sentences — what changes for the user when it's done)
```

```
Does it depend on anything not yet merged?
(Name a pending plan, or "no")
```

Then, only if the answer is ambiguous from the description:

```
Anything new in the stack for this?
(New service, new dependency, new external integration — or "no")
```

Three questions maximum. If the user gave a description in the command itself and it's clear, the second may be the only one you need to ask.

Log any new stack answer to `open-decisions.md` as an assumption, exactly as the interview would.

---

## 3. Plan it properly

Follow `references/planning-protocol.md` in full — the scope check, Phase 1 discovery, the reuse audit, Phase 2, and plan validation. A queued plan gets the same rigour as the first one.

Discovery here is cheaper than it was for plan-001 and should look different: read `memory/`, `decisions.jsonl` and `plans/done/` first. Most of the codebase knowledge is already recorded by the PRs that have merged. Go to the source only where memory is silent or where this plan touches code no previous plan did.

**The reuse audit is the point of this command.** A plan queued against a codebase that four PRs have already changed is the exact situation where something gets rebuilt. Every "create new" needs a search behind it.

---

## 4. Write it

Per `references/plan-schema.md`:

- Next ID is `max(all IDs across all four folders) + 1` — including `done/` and `deferred/`
- Write to `plans/pending/plan-<NNN>-<slug>.json` with `status: pending`
- Set `depends_on` from the second interview answer
- Add its estimate to `budget.json → plans.plan-<NNN>`
- Regenerate `roadmap.md`

Do not modify `session.yaml`. The queued plan is not active.

---

## 5. Confirm

```
Queued plan-003 — Admin and reporting

  4 PRs · ~250k tokens estimated
  Depends on: plan-002 (billing)

  plans/pending/plan-003-admin-reporting.json

Run it with `wpr-resume` once plan-002 is done, or `wpr-plans` to see the queue.
```

If a build is currently running, add: "Current build is unaffected — plan-002 continues."

---

## Deferring and removing

`wpr-plan-add --defer <id>` moves a plan from `pending/` to `deferred/` and requires a reason, written to `deferred_reason`. A shelved plan with no reason is an unanswerable question later.

To bring one back, move it to `pending/` and clear `deferred_reason`. Re-validate it first — see the staleness section of `references/plan-schema.md`.

Plans are not deleted. A plan that will never happen belongs in `deferred/` with a reason, where it documents a decision. If the user insists on deletion, confirm once and note it in `decisions.jsonl`.
