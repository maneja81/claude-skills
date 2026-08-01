# How It Works

`weekend-project` turns a one-line project brief into a sequence of reviewed,
merged pull requests. You approve a plan once; the skill then builds each PR,
reviews its own work against explicit acceptance criteria, fixes what it finds,
and merges to `develop-ai`.

This document explains the mechanism, using a real run — a React + Express +
Postgres todo app — as the worked example. For installation and commands, see
the [README](README.md).

---

## The pipeline

```
weekend-project
      │
      ├─ 1. Environment + first-run detection
      ├─ 2. Intake interview        → config.yaml
      ├─ 3. Planning                → plan.json + budget.json     ◀── you approve here
      ├─ 4. UI mockups (frontend)   → ui-mockups/                 ◀── and here
      │
      └─ 5. Execution loop, once per PR:
              worktree → Sr. Developer (TDD) → Sr. QA → fix rounds → merge gate → merge
                                                  ▲             │
                                                  └─────────────┘
                                                   up to 3 rounds
```

Steps 2–4 are the conversation: you answer the interview, approve the plan, and
pick your mockups. Everything after step 4 runs unattended until it finishes or
hits an escalation.

---

## What it writes to disk

```
.claude/weekend-project/
  session.yaml        current phase, PR and round — the resume point
  config.yaml         interview answers
  plan.json           the PRs, each with acceptance criteria
  budget.json         token estimate vs actual, per PR
  decisions.jsonl     append-only log of every non-obvious technical choice
  memory/             patterns, decisions, qa-learnings, preferences, feedback
                      — reloaded before every PR
  pr-logs/<branch>/   qa-report.json, merge-gate.json, merge-summary.json
  ui-mockups/         design system, screen variants, approval.yaml

known-issues.md       deferred issues, at the project root where you'll see them
open-decisions.md     assumptions the skill made on your behalf
CLAUDE.md             generated conventions for the project
```

`session.yaml` is the important one. Every phase transition rewrites it, so
`wpr-resume` can pick up mid-build after a context reset.

---

## Trying it with a todo app

### 1. Start

```bash
mkdir simple-todo && cd simple-todo
claude
```

```
weekend-project
```

An empty directory is fine — the skill runs `git init`, creates the folder
structure, and initialises `session.yaml`.

### 2. Answer the interview

Give it one line and it derives the rest:

> a simple todo app in reactjs, postgres using docker, container names simple-todo-test

It asks only what it genuinely cannot infer. In the example run that was three
questions: app shape (Vite SPA + Express API vs Next.js fullstack), GitHub
(new repo vs local-only), and design direction. Everything else became a
logged assumption in `open-decisions.md` — Drizzle over Prisma, no auth,
Tailwind v4, ports 3000/4000/5432.

### 3. Approve the plan

You get a PR table, a token estimate, and a list of assumptions:

```
PR   Branch                      Scope                              Blocked by
001  wpr/chore/scaffold          npm monorepo, TS strict, tooling   —
002  wpr/chore/docker            Compose: web / api / db            001
003  wpr/feature/db-schema       Drizzle schema, migrations, seed   002
004  wpr/feature/todos-api       CRUD REST API, validation          003
005  wpr/feature/todo-ui         Todo list, optimistic updates      004
006  wpr/feature/e2e-a11y        Playwright E2E + axe               005
```

Approve it and step away.

### 4. Watch (or don't)

```
wpr-status     where it is now
wpr-budget     tokens spent vs estimated
wpr-pause      freeze at the next safe point
wpr-resume     continue from the last checkpoint
```

---

## Inside one PR

Each PR runs the same loop. Using PR-004 (the REST API) as the example:

**Load memory.** Reads `memory/*.md` and the last 20 `decisions.jsonl` entries
before writing any code. This is how PR-004 knew, without being told, that
`packages/types` must stay dependency-free and that relative imports in
`apps/api` need `.js` extensions — both discovered during PR-001.

**Isolate.** `git worktree add .wpr-worktrees/api -b wpr/feature/todos-api`.
Each PR builds in its own working tree, so a failed PR leaves `develop-ai`
untouched.

**Build test-first.** Tests are committed before implementation, in separate
commits, so TDD is verifiable in `git log` rather than merely claimed:

```
3beb732 test(api): add supertest coverage for every todos endpoint
faf26a1 feat(api): add todos CRUD router, error middleware and cors
```

**Review against the criteria.** The QA pass checks each acceptance criterion
and records evidence, not a verdict. Criteria are written to be independently
verifiable — "returns 422 with a field-level error array", not "validation
works".

**Fix and re-review.** Blockers and majors are fixed in severity order, then
reviewed again, up to 3 rounds. Minors can be deferred to `known-issues.md`.

**Merge gate.** Tests, typecheck, lint, format, build, secret scan, plus manual
checks (no `any`, no stray `console`, no leaked stack traces, diff scoped to
the PR's purpose). Any automated failure blocks the merge.

**Merge and record.** `--no-ff` into `develop-ai`, worktree removed, memory
updated, budget updated, `session.yaml` advanced.

### What the review actually catches

From the example run, the QA pass is only worth having because it finds things
the test suite does not:

| PR | Found | Why tests missed it |
|---|---|---|
| 001 | Two Vite instances in one app — `apps/web` pinned v6 while its plugins deduped to hoisted v7 | The build passed. Only `npm ls vite` showed it |
| 003 | `rejects.toThrow()` would pass on *any* error, including a connection failure | Tests were green; they just weren't asserting the constraint |
| 004 | `npm run db:migrate` failed from the host — the exact command the README tells you to run | The suite sets its own `DATABASE_URL` |
| 004 | A corrupted template literal broke typecheck and build | `seed.ts` isn't imported by any test, so the suite stayed green |
| 005 | `import.meta.env.VITE_API_URL` was `any`, silently defeating strict mode | Types aren't runtime behaviour |

The recurring lesson, recorded in `memory/qa-learnings.md`: **a green test suite
is not a green build.** The gate runs typecheck, lint, build and a clean
`npm ci` precisely because each has caught something the tests could not.

---

## Completing PR-006 with Playwright MCP

PR-006 adds browser-level tests. Two options — an MCP server lets Claude drive
a browser interactively during the build; `@playwright/test` gives you a
committed suite. Use both: MCP to see the UI while building, specs as the
regression net.

### Add the MCP server

Outside the session:

```bash
claude mcp add playwright npx @playwright/mcp@latest
```

Then restart Claude Code and confirm with `/mcp`. The skill can now open the
running app, click through it, read the accessibility tree, and screenshot —
which is what turns "the component tests pass" into "the assembled app works".

> Playwright MCP downloads a browser binary on first use. If you'd rather keep
> it inside the project, set `PLAYWRIGHT_BROWSERS_PATH` to a gitignored
> directory before launching.

### Then run the PR

```
wpr-resume
```

It picks up at `pr-006` from `session.yaml` and builds against these criteria:

- Suite runs green against `docker compose up` with a clean database
- Covers create → complete → edit → delete → reload-and-persist
- Simulates an API 500 and asserts the UI shows an error state
- `axe-core` reports zero critical or serious violations, light and dark
- Passes 3 consecutive runs with no flakes and no arbitrary sleeps
- One documented command runs it all from cold start

The last two matter most. A flaky E2E suite is worse than none, so the criteria
forbid `sleep` and require repeat runs — the skill uses web-first assertions
and resets state through the API between tests rather than waiting.

---

## Guardrails

- Writes are confined to `config.yaml → project_root`; anything outside is
  escalated to you. This is why the run stopped twice — once when `pnpm` was
  missing (Node 26 removed corepack, so installing it meant touching
  `/opt/homebrew`) and once at the Chromium download.
- Pushes only to `develop-ai` or `wpr/*`. Never `main`, `master`, or `develop`.
- Staged files are scanned for secrets before every commit.
- A PR reaching round 4 with unresolved blockers stops and waits for you.

The escalations are the point. The skill defaults to finishing autonomously,
but a machine-level install is your decision, not its own — so it asks and
waits rather than assuming.

---

## Cost

The example run cost roughly 506k output tokens for 5 merged PRs against a
730k estimate — 69%, including QA rounds and fixes. Rough shape per PR:

```
scaffold        ~88k     API + validation + tests   ~118k
docker          ~62k     UI + optimistic updates    ~142k
schema + repo   ~96k
```

`budget.json` tracks estimate against actual per PR, and the skill warns if
actual passes 80% of the estimate before the final PR.
