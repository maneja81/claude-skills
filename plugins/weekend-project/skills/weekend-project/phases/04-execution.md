# Phase 04 — Execution Loop

Execute the active plan sequentially. One PR at a time. Each PR fully completes (review clean, merged to `develop-ai`) before the next begins.

---

## Pre-execution checklist

Before starting the first PR, confirm:
- [ ] `develop-ai` branch exists and is pushed to remote
- [ ] the active plan is confirmed by the user
- [ ] `ui-mockups/approval.yaml` exists (frontend projects only)
- [ ] `budget.json` estimate acknowledged by user
- [ ] `open-decisions.md` has no items under `## Pending Your Input` that block PR-001

If any block is found: surface it, resolve it, then proceed.

---

## PR execution loop

For each PR in the active plan (in order, respecting `blocked_by`):

### Step 1: Load context

Update `session.yaml`:
```yaml
current_pr: pr-001
current_pr_branch: wpr/chore/scaffold
current_round: 0
round_state: dev-building
```

Run memory load:
1. Read all `.claude/weekend-project/memory/` files
2. Read last 20 entries from `decisions.jsonl`
3. Read `open-decisions.md` — check if any item blocks this PR. If yes, surface to user and wait.
4. Announce: "Starting PR-[N]: [title]. Memory loaded."

### Step 2: Create worktree and branch

Before the first worktree of the project is created, confirm `.wpr-worktrees/` is in `.gitignore`. If it isn't, add it and commit that first.

```bash
cd $PROJECT_ROOT
git worktree add .wpr-worktrees/[branch-name] -b [branch-name]
cd .wpr-worktrees/[branch-name]
```

The Sr. Developer agent works exclusively inside this worktree — **for source code only**. Skill state (`session.yaml`, `plans/`, `decisions.jsonl`, `memory/`, `budget.json`, `pr-logs/`) is read and written through `$PROJECT_ROOT/.claude/weekend-project/`, never through a relative path from inside the worktree. See the State path rule in `SKILL.md`.

All file operations stay inside the project root — never outside.

### Step 3: Sr. Developer builds the PR

Spawn the Sr. Developer agent with:
- Role file: `roles/sr-developer.md`
- PR plan: the specific PR object from the active plan
- Memory: all memory files (pre-loaded)
- Approved mockups: `ui-mockups/` (if frontend PR)
- Component map: `ui-mockups/components.yaml` (if design PR)
- References: `references/explore-protocol.md`, `references/verify-gate.md`, `references/tdd-patterns.md`, `references/merge-gate-checklist.md`

The Sr. Developer follows this sequence:
1. **Explore** — read the existing codebase before touching anything, per `references/explore-protocol.md`
2. **Scope** — restate the PR scope and acceptance criteria; log anything ambiguous to `open-decisions.md`
3. Write failing tests first (TDD)
4. Implement to make tests pass
5. **Verify** — `references/verify-gate.md`: lint, typecheck, build, tests
6. Before any irreversible operation (migrations, file deletes, data backfills): state what it will do, prefer a dry-run where one exists, and confirm before running it
7. Log all non-obvious decisions to `decisions.jsonl`
8. **Production gate** — `references/merge-gate-checklist.md` before handing to QA

If the production gate fails: fix before handing over. Do not submit a PR that fails it.

Update `session.yaml → round_state: qa-reviewing`.

### Step 4: QA review round

Spawn the Sr. QA Analyst agent with:
- Role file: `roles/sr-qa.md`
- PR plan: the specific PR object (acceptance criteria)
- Round number: current round
- Prior round reports: if round > 1, include `pr-logs/[branch]/round-[N-1]/qa-report.json`
- Playwright config: `.claude/weekend-project/playwright/wpr.config.ts`
- Approved mockups: for visual diff (frontend PRs)
- References: `phases/05-review-round.md` (review dimensions), `references/verify-gate.md`, `references/playwright-templates.md`

QA agent writes structured report to:
`pr-logs/[branch]/round-[round]/qa-report.json`

Update `session.yaml → round_state: fix-in-progress` (if issues found) or `merge-gate` (if clean).

### Step 5: Fix round (if issues found)

Read `qa-report.json`. Process each `blocker` and `major` issue.

Spawn the Sr. Developer agent again with:
- Role file: `roles/sr-developer.md`
- QA report: the structured bug list for this round
- References: `references/verify-gate.md`
- Instruction: fix issues in severity order (blockers first). Reproduce each bug before fixing it. Apply the smallest fix that resolves it — no refactoring, no improving adjacent code. One fix per commit. Verify after each fix before moving to the next.

Save fix response to `pr-logs/[branch]/round-[round]/dev-response.json`.

Increment round counter. If `round > 3` and unresolved blockers/majors remain: stop, notify user, wait for instruction. Do not loop further.

Go back to Step 4.

### Step 6: Merge gate

Read `phases/06-merge-gate.md`. Run full merge gate before merging.

### Step 7: Post-merge

After successful merge to `develop-ai`:

1. Clean up worktree:
   ```bash
   git worktree remove .wpr-worktrees/[branch-name]
   ```

2. Update memory:
   - Append patterns discovered to `memory/patterns.md`
   - Append decisions made to `memory/decisions.md`
   - Append QA findings to `memory/qa-learnings.md`

3. Update `pr-logs/[branch]/merge-summary.json`:
   ```json
   {
     "branch": "wpr/chore/scaffold",
     "merged_at": "ISO-timestamp",
     "rounds": 2,
     "bugs_found": 4,
     "bugs_fixed": 4,
     "minor_deferred": 1,
     "tokens_actual": 84000
   }
   ```

4. Update `budget.json → by_pr.[id] = actual_tokens`

5. Update `session.yaml` → advance to next PR or `phase: complete`

6. If minor issues were deferred, append to `known-issues.md`.

7. **Commit the updated state to `develop-ai`.** All of the above wrote to the main working tree, not the PR branch, so it is still uncommitted:

   ```bash
   cd $PROJECT_ROOT
   git checkout develop-ai
   git add .claude/weekend-project/ known-issues.md open-decisions.md roadmap.md
   git commit -m "chore(wpr): record state after [branch]"
   git push origin develop-ai
   ```

   This keeps the state commit separate from the PR merge commit, so `git log` reads as an alternating sequence of work and record. It also guarantees the next worktree — created from `develop-ai` — contains the current plans.

   If nothing is staged, skip the commit rather than creating an empty one.

8. Tell the user: "PR-[N] merged ✓ — [brief outcome]. Starting PR-[N+1]: [title]."

### Step 8: Next PR

Go to Step 1 with the next PR. Repeat until all PRs are merged.

---

## Plan completion

When every PR in the active plan is merged (excluding the backlog PR):

1. Check `known-issues.md` — if there are deferred items, create a `wpr/chore/qa-backlog` PR and add it to the end of this plan.
2. Move the plan file from `plans/active/` to `plans/done/`, set `status: done`.
3. Clear `session.yaml → current_plan`, set `phase: complete`.
4. Regenerate `roadmap.md` and commit the state (Step 7 above).
5. Present the summary:

```
plan-002 complete ✓  — Billing and subscriptions

  PRs merged: 3
  Tokens: ~294k / 310k estimated
  Deferred issues: 2 (see known-issues.md)

Done when: "A user can subscribe, see an invoice, and cancel" — verified in PR-003.
```

### Then check the queue

Read `plans/pending/`, respecting `depends_on`:

**A plan is ready to run** — stop and ask, unless `session.yaml → auto_continue` is true:

```
Next up: plan-003 — Admin and reporting  (4 PRs, ~250k estimated)

  Spent so far: 800k across 2 plans
  This plan:    ~250k

Start it now, or leave it queued? (`wpr-resume` starts it later)
```

Stopping here is deliberate. Splitting a project into plans is a budget-control decision, and auto-chaining would defeat it. The boundary is also the natural review point — there is merged code on `develop-ai` worth looking at before building on top of it.

Before starting the next plan, re-validate it for staleness per `references/plan-schema.md` — it was planned against a codebase that has since changed.

**Plans queued but blocked** by an unmet `depends_on` — say which, and what would unblock them.

**Nothing queued:**

```
All plans complete ✓

  Plans: [N] · PRs merged: [N] · Tokens: ~[X]k

Your `develop-ai` branch is ready to review and merge to [main_branch].

  wpr-plan-add   queue the next batch
  wpr-review     work through known-issues.md
```

---

## Pause / Resume handling

If `wpr-pause` is received at any point:
- Complete the current atomic operation (finish the current file write or git command)
- Save `session.yaml` with exact state
- Push current branch to remote so no work is lost: `git push -u origin [branch]`
- Confirm: "Paused after [state]. Run `wpr-resume` to continue."

If context resets mid-execution:
- On next message, detect incomplete `session.yaml`
- Run `wpr-resume` automatically
- Read `commands/wpr-resume.md`
