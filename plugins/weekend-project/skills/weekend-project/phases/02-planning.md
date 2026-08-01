# Phase 02 — Planning

Generate a PR-by-PR execution plan. This phase is read-only and thorough — no code is written here, and no files are created outside `.claude/weekend-project/`.

**Follow `references/planning-protocol.md`.** It defines the evidence-gated discovery, the reuse audit, and the plan validation that every plan must pass — the first one and the seventh. This file supplies the wpr-specific parts: PR types, the standard sequence, budget, and how the plan is presented.

Plans are never hand-written. A plan that has not been through the protocol has not been planned.

---

## Load context first

Before planning:
1. Read `.claude/weekend-project/config.yaml`
2. Read `.claude/weekend-project/memory/` (all 5 files) and the last 20 `decisions.jsonl` entries
3. Read `CLAUDE.md` if it exists (project conventions)
4. Read `plans/done/` — what has already shipped is the strongest input to what comes next, and the reuse audit depends on it
5. If the project folder has existing code, follow `references/explore-protocol.md` to understand the current state before adding to it

---

## Planning principles

- Single responsibility per PR. One concern, one branch, one reviewable unit.
- Prefer smaller PRs (~150-200 lines of production code) over large ones.
- PRs that set up foundations (scaffold, config, CI, design system) come first and block all others.
- Every PR must have explicit acceptance criteria — these drive the QA agent's review.
- If two valid architectural approaches exist, argue both sides against the actual requirements before choosing — state the strongest case for each, then what decides it. Pick one and log the rationale to `decisions.jsonl`. A decision recorded without its rejected alternative is not a decision, it's a preference.
- For greenfield choices where the right answer isn't obvious, generate options grounded in the stack and constraints from `config.yaml` rather than in general best practice, then choose.

---

## PR types

| Type | Branch prefix | When to use |
|---|---|---|
| chore | `wpr/chore/` | Scaffold, CI, config, tooling, deps |
| feature | `wpr/feature/` | New functionality |
| bugfix | `wpr/bugfix/` | Fixing issues found in QA |
| design | `wpr/design/` | UI components, design system |
| cleanup | `wpr/chore/qa-backlog` | Deferred minor issues — always last |

---

## Standard PR sequence (adapt to project type)

These are the typical layers. Not all projects need all layers.

```
Layer 0: Foundation
  PR-001: Project scaffold — init, config files, CI, git hooks, env setup
  PR-002: CI/CD pipeline — GitHub Actions (lint, typecheck, test, build)

Layer 1: Infrastructure
  PR-003: Database setup — schema, migrations, seed data
  PR-004: Auth system — sessions/JWT, middleware, protected routes
  PR-005: Core API routes — base CRUD, error handling, validation

Layer 2: Frontend (if applicable)
  PR-006: Design system — tokens, base components (Button, Input, Card, Typography)
  PR-007: Layout — navigation, page shell, routing
  PR-008: [Feature screens] — one PR per major screen/flow

Layer 3: Integration
  PR-009: External services — email, storage, payments, etc.
  PR-010: End-to-end tests — Playwright test suite

Layer 4: Polish
  PR-011: Performance — lazy loading, caching, image optimisation
  PR-012: Accessibility audit — WCAG AA pass
  PR-013: chore/qa-backlog — deferred minor issues
```

Adapt this to the actual project. A marketing website skips Layers 1-3. A pure API skips Layer 2. A simple CRUD app might collapse Layers 1-2 into 2-3 PRs.

---

## Where the plan is written

Write to `.claude/weekend-project/plans/pending/plan-<NNN>-<slug>.json`, using the full schema and numbering rules in `references/plan-schema.md`. The first plan of a project is `plan-001`.

Then regenerate `roadmap.md` at the project root.

The structure below shows the PR shape; `references/plan-schema.md` is authoritative for the plan-level fields (`done_when`, `depends_on`, `removes`, `risks`, `rollback`, `status`).

```json
{
  "project": "project-name",
  "created": "ISO-timestamp",
  "ai_branch": "develop-ai",
  "is_frontend": true,
  "ui_mockup_phase": true,
  "total_prs": 10,
  "prs": [
    {
      "id": "pr-001",
      "title": "Project scaffold",
      "type": "chore",
      "branch": "wpr/chore/scaffold",
      "scope": "Init Next.js 15 + TypeScript strict + Tailwind v4 + ESLint + Prettier + Husky + Vitest",
      "acceptance_criteria": [
        "pnpm install succeeds with no peer warnings",
        "pnpm dev starts on port 3000",
        "pnpm typecheck passes",
        "pnpm lint passes",
        "pnpm test passes (smoke test)",
        "Husky pre-commit hook runs lint and typecheck"
      ],
      "blocked_by": [],
      "estimated_tokens": 80000,
      "is_frontend_pr": false,
      "playwright_required": false
    }
  ]
}
```

Every PR must have `acceptance_criteria` — minimum 3, maximum 8. These are the QA agent's review checklist. Vague criteria ("it works") are not allowed. Each criterion must be independently verifiable.

---

## Token budget

After generating the plan, calculate the budget using `references/token-estimates.md` as the sizing guide.

Formula:
```
base = sum of estimated_tokens per PR
review_overhead = base * 0.35   (QA rounds, fixes, memory loads)
ui_mockup_phase = 60000         (if is_frontend)
buffer = (base + review_overhead + ui_mockup_phase) * 0.15
total = base + review_overhead + ui_mockup_phase + buffer
```

Write to `budget.json`. Show the user:

```
Token estimate: ~[total] tokens (includes 15% buffer)

Breakdown:
  Development:  ~[base]k
  QA rounds:    ~[review]k
  UI mockups:   ~[ui]k  (if applicable)
  Buffer (15%): ~[buffer]k

Check your Claude plan supports this before stepping away.
Actual usage tracked in .claude/weekend-project/budget.json
```

If the estimate exceeds 500k tokens, split it into multiple plans rather than one long build — an MVP plan of 3–4 PRs that ships something usable, then follow-on plans for the rest. Create the first plan now and queue the others with `wpr-plan-add`. Say plainly why:

```
Estimated ~980k tokens across 11 PRs. That's a long unattended run, and a
budget overrun in PR-9 wastes everything before it.

Splitting into:
  plan-001  MVP — auth, core CRUD, one screen        ~420k   4 PRs
  plan-002  Billing and subscriptions                ~310k   3 PRs
  plan-003  Admin, reporting, polish                 ~250k   4 PRs

plan-001 ships something you can actually use. Approve it now, and the
other two sit in plans/pending/ until you run them.
```

---

## Open decisions

Any "you choose" from the interview, or any architectural choice where the user's preference was not explicit, must be logged in `open-decisions.md` under `## AI Assumptions`.

If a choice would significantly affect the architecture (auth strategy, DB schema design, API shape), log it under `## Pending Your Input` and flag the PR that is blocked by it.

---

## Plan presentation

Present the plan to the user as a clean table:

```
Weekend Project Plan — [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PR  Branch                        Scope                      Blocked by
──────────────────────────────────────────────────────────────────────
001 wpr/chore/scaffold             Project init + CI          —
002 wpr/feature/auth               Auth system (JWT + Clerk)  001
003 wpr/design/design-system       Base UI components         001
004 wpr/feature/dashboard          Dashboard screen           002, 003
...

Total: [N] PRs · ~[X]k tokens · Est. [Y] hours autonomous build time

Open decisions requiring your input: [N]  (see open-decisions.md)
UI mockup approval required before execution: yes/no
```

Ask: "Any changes to the plan before I proceed?" Wait for confirmation.

On confirmation:
- Move the plan file from `plans/pending/` to `plans/active/`, set its `status: active`
- Set `session.yaml → current_plan: plan-<NNN>`
- Update `session.yaml → phase: ui-mockups` (if frontend) or `phase: execution`
- Regenerate `roadmap.md`
- If frontend: proceed to `phases/03-ui-mockups.md`
- If not: proceed to `phases/04-execution.md`

If the user was queuing a plan for later rather than starting it now (`wpr-plan-add`), stop here: the plan stays in `plans/pending/`, `session.yaml` is untouched, and no execution begins.
