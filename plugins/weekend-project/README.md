# Weekend Project

> This is a personal side project — built evenings and weekends, around a full-time job.
> No support, no roadmap commitments, no guarantees.

**An agent skill that turns a one-line brief into a sequence of reviewed, merged pull requests.**

You describe what you want. It interviews you, plans the build as a series of small PRs with explicit acceptance criteria, shows you a token estimate, and — once you approve — builds each PR test-first, reviews its own work as an adversarial QA engineer, fixes what it finds, runs a production gate, and merges to `develop-ai`.

You approve once. Then you step away.

```
weekend-project
      │
      ├─ 1. Environment + first-run detection
      ├─ 2. Intake interview        → config.yaml
      ├─ 3. Planning                → plan.json + budget.json   ◀── you approve here
      ├─ 4. UI mockups (frontend)   → ui-mockups/               ◀── and here
      │
      └─ 5. Execution loop, once per PR:
              worktree → Sr. Developer (TDD) → Sr. QA → fix rounds → merge gate → merge
                                                  ▲             │
                                                  └─────────────┘
                                                   up to 3 rounds
```

**[HOW-IT-WORKS.md](HOW-IT-WORKS.md)** — a walkthrough of a real run (React + Express + Postgres todo app), including what the QA pass actually caught and what it cost.

---

## Why a separate QA role

The interesting part isn't that an agent can write code. It's that a second agent, given explicit acceptance criteria and told to try to break the work, finds things a green test suite does not. From the live run in [HOW-IT-WORKS.md](HOW-IT-WORKS.md):

| PR | Found | Why the tests missed it |
|---|---|---|
| 001 | Two Vite instances in one app — `apps/web` pinned v6 while its plugins deduped to hoisted v7 | The build passed. Only `npm ls vite` showed it |
| 003 | `rejects.toThrow()` would pass on *any* error, including a connection failure | Tests were green; they just weren't asserting the constraint |
| 004 | `npm run db:migrate` failed from the host — the exact command the README tells you to run | The suite sets its own `DATABASE_URL` |
| 004 | A corrupted template literal broke typecheck and build | `seed.ts` isn't imported by any test, so the suite stayed green |
| 005 | `import.meta.env.VITE_API_URL` was `any`, silently defeating strict mode | Types aren't runtime behaviour |

The recurring lesson, which the skill records to its own memory and reloads before every subsequent PR: **a green test suite is not a green build.**

---

## Requirements

| | |
|---|---|
| **Agent** | [Claude Code](https://claude.com/claude-code) (recommended), Claude Desktop, or claude.ai. See [other agents](#using-it-with-other-ai-agents). |
| **Git** | Required. The skill uses `git worktree`, so git ≥ 2.5. |
| **GitHub CLI** | `gh`, authenticated — optional but recommended. Without it, the skill runs local-only. |
| **Node / package manager** | Whatever your project needs. Defaults assume `pnpm` unless you say otherwise in the interview. |
| **Token budget** | Real builds cost real tokens. The live run was ~506k output tokens for 5 merged PRs. See [Cost](#cost). |
| **Playwright MCP** | Optional. Enables browser-level UI validation during the build. See [Optional integrations](#optional-integrations). |

---

## Installation

### Option A — Plugin marketplace (recommended for Claude Code)

One command, and updates are a single `/plugin update` later.

```
/plugin marketplace add maneja81/claude-skills
/plugin install weekend-project@maneja81-skills
/reload-plugins
```

Installed as a plugin, the skill is namespaced — invoke it with `/weekend-project:weekend-project`, or just describe your project and let Claude route to it.

### Option B — Install script

```bash
curl -fsSL https://raw.githubusercontent.com/maneja81/claude-skills/main/install.sh | bash weekend-project
```

Or from a clone, which also lets you install it into a single project:

```bash
git clone https://github.com/maneja81/claude-skills.git
cd claude-skills

./install.sh weekend-project              # personal:  ~/.claude/skills/weekend-project
./install.sh --project weekend-project    # project:   ./.claude/skills/weekend-project
./install.sh --uninstall weekend-project  # remove a personal install
```

An existing install is moved aside to `weekend-project.backup-<timestamp>` rather than overwritten.

### Option C — Manual copy

The skill is plain markdown. Copy the directory to wherever your agent looks for skills.

```bash
git clone https://github.com/maneja81/claude-skills.git
SRC=claude-skills/plugins/weekend-project/skills/weekend-project

# Personal — available in all your projects
cp -R "$SRC" ~/.claude/skills/

# Project — available in this repo only, and committable so your team gets it
mkdir -p .claude/skills
cp -R "$SRC" .claude/skills/
```

The directory name **must** stay `weekend-project` — for personal and project skills, the directory name is the command name.

| Scope | Path |
|---|---|
| Personal | `~/.claude/skills/weekend-project/SKILL.md` |
| Project | `.claude/skills/weekend-project/SKILL.md` |
| Plugin | installed and namespaced automatically by Option A |

### Option D — Claude Desktop / claude.ai

Download [`bundles/weekend-project.zip`](../../bundles/weekend-project.zip) from this repo, then in Claude go to **Settings → Capabilities → Skills** (or **Customize → Skills**), click **+ → Create skill → Upload a skill**, and select the zip.

The archive contains a single `weekend-project/` folder with `SKILL.md` inside — the folder name has to match the skill name or the upload is rejected. To rebuild it after editing the skill:

```bash
cd plugins/weekend-project/skills && zip -r ../../../bundles/weekend-project.zip weekend-project -x '*.DS_Store'
```

> Uploaded skills are private to your account. On Team or Enterprise, use the org provisioning flow to share one across the organisation.

### Verify the install

Restart Claude Code (personal and project skills are hot-reloaded, but a new top-level skills directory needs a restart), then:

```
/help          # weekend-project should be listed
weekend-project
```

If it doesn't appear, check that `SKILL.md` sits directly inside the `weekend-project/` directory — not one level deeper.

---

## Quick start

```bash
mkdir my-app && cd my-app
claude
```

Then, in the session:

```
weekend-project
```

An empty directory is fine — the skill runs `git init`, creates its folder structure, and initialises a session.

**1. Answer the interview.** Give it one line and it derives the rest:

> a simple todo app in reactjs, postgres using docker, container names simple-todo-test

It asks only what it genuinely cannot infer — typically app shape, GitHub setup, and design direction. Everything else becomes a logged assumption in `open-decisions.md` rather than a question.

**2. Approve the plan.** You get a PR table, a token estimate, and the list of assumptions it made on your behalf:

```
PR   Branch                      Scope                              Blocked by
001  wpr/chore/scaffold          npm monorepo, TS strict, tooling   —
002  wpr/chore/docker            Compose: web / api / db            001
003  wpr/feature/db-schema       Drizzle schema, migrations, seed   002
004  wpr/feature/todos-api       CRUD REST API, validation          003
005  wpr/feature/todo-ui         Todo list, optimistic updates      004
006  wpr/feature/e2e-a11y        Playwright E2E + axe               005
```

**3. Pick your mockups** (frontend projects only). It generates a design system plus 2–3 self-contained HTML variants per major screen. You pick per screen, or mix: *"home v2 but with v1's nav."*

**4. Step away.** Check in whenever you like:

```
wpr-status     where it is now
wpr-budget     tokens spent vs estimated
wpr-pause      freeze at the next safe point
wpr-resume     continue from the last checkpoint
```

---

## Commands

| Command | What it does |
|---|---|
| `weekend-project` | Start: setup → interview → plan → execute |
| `wpr-start` | Alias for `weekend-project` |
| `wpr-status` | Current phase, PR, round, and what's next |
| `wpr-plan` | Show or revise the current PR plan |
| `wpr-plans` | Show the plan queue — done, active, pending, deferred |
| `wpr-plan-add` | Queue another plan for later, without interrupting the current build |
| `wpr-mockups` | Record your chosen UI variants |
| `wpr-review` | Work through deferred issues in `known-issues.md` |
| `wpr-budget` | Token estimate vs actual, per PR |
| `wpr-pause` | Freeze at the next safe point, push work so nothing is lost |
| `wpr-resume` | Continue from the last checkpoint (also after a context reset) |
| `wpr-abort` | Save state, summarise what's done, stop |
| `wpr-feedback` | Log feedback that shapes the remaining PRs |
| `wpr-remember` | Save something to project memory by hand |
| `wpr-reset-pr` | Abandon the current PR branch and rebuild it |
| `wpr-skip` | Push the current minor issue to the backlog and continue |

A short project brief with no command — *"I want to build a booking site for my studio"* — starts the same flow.

---

## What it writes to your project

```
.claude/weekend-project/
  session.yaml        current plan, phase, PR and round — the resume point
  config.yaml         interview answers
  plans/
    done/             plans whose PRs have all merged
    active/           the plan being executed (0 or 1)
    pending/          queued, not started
    deferred/         shelved, each with a reason
  budget.json         token estimate vs actual, per plan and per PR
  decisions.jsonl     append-only log of every non-obvious technical choice
  memory/             patterns, decisions, qa-learnings, preferences, feedback
  pr-logs/<branch>/   qa-report.json, merge-gate.json, merge-summary.json
  ui-mockups/         design system + screen variants + approval.yaml

roadmap.md            the plan queue, rendered — at the project root
known-issues.md       deferred minor issues, at the project root where you'll see them
open-decisions.md     assumptions it made on your behalf, and anything blocking a PR
CLAUDE.md             generated project conventions (appended if one already exists)
```

`session.yaml` is the important one. Every phase transition rewrites it, which is what makes `wpr-resume` work after a context reset or a pause days later.

`.wpr-worktrees/`, `pr-logs/`, `playwright/` and generated mockup HTML are added to `.gitignore` automatically. Everything else — plans, config, decision log, memory — is committed. It's the record of why the codebase looks the way it does, and plan files have to be in the repository for a build worktree to contain them.

---

## More than one plan

A project is a queue of plans, not a single shot. A plan is a batch of PRs that ships something coherent on its own.

```
wpr-plan-add     queue another plan — doesn't interrupt the running build
wpr-plans        see the queue
```

```
Plans — simple-todo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ plan-001  MVP                        6/6 PRs   506k / 730k
  ▶ plan-002  Billing and subscriptions  2/3 PRs   180k / 310k   ← current
    plan-003  Admin and reporting        0/4 PRs        ~250k    needs plan-002
  ⏸ plan-005  Offline mode                                       deferred
```

This exists because the honest answer to a 900k-token estimate is "don't run that in one go." Planning now splits large projects into an MVP plan plus follow-ons, ships the MVP, and leaves the rest queued.

**It stops at each plan boundary and asks.** Auto-chaining would defeat the point of splitting for budget control, and the boundary is the natural review point — there's merged code on `develop-ai` worth looking at before building on top of it. Set `auto_continue: true` in `session.yaml` if you'd rather it ran straight through.

**Plans aren't hand-written.** Every plan goes through the same [planning protocol](skills/weekend-project/references/planning-protocol.md) — evidence-gated discovery where every claim about the codebase traces to a file you actually opened, a reuse audit before anything new is proposed, and a validation pass that rejects acceptance criteria like *"add appropriate error handling."* A plan that hasn't been through it hasn't been planned.

**Queued plans go stale, and it knows.** A plan written four PRs ago was written against a codebase that no longer exists. Before executing one, it re-runs discovery and the reuse audit against current `develop-ai` and shows you the delta — *"`packages/utils/paginate.ts` now exists, built in plan-002/pr-004 → scope reduced to wiring it in."* If the drift is bad enough that the PR boundaries stop making sense, it says so rather than executing something that no longer fits.

Follow-up plans need about three questions instead of a full interview — the stack, standards and design direction are already in `config.yaml`.

---

## Inside one PR

Every PR runs the same loop:

**Load memory.** Reads `memory/*.md` and the last 20 `decisions.jsonl` entries before writing any code. This is how PR-004 in the live run knew, without being told, that `packages/types` must stay dependency-free and that relative imports in `apps/api` need `.js` extensions — both discovered during PR-001.

**Isolate.** `git worktree add .wpr-worktrees/<branch> -b wpr/feature/<name>`. Each PR builds in its own working tree, so a failed PR leaves `develop-ai` untouched.

**Build test-first.** Tests are committed *before* implementation, in separate commits, so TDD is verifiable in `git log` rather than merely claimed:

```
3beb732 test(api): add supertest coverage for every todos endpoint
faf26a1 feat(api): add todos CRUD router, error middleware and cors
```

**Review against the criteria.** The QA role checks each acceptance criterion and records evidence, not a verdict. Criteria are written to be independently verifiable — *"returns 422 with a field-level error array"*, not *"validation works"*. It also works a mandatory edge-case checklist: empty input, max length, zero results, concurrent mutations, expired auth, network failure, malformed JSON, injection, XSS, oversized payloads.

**Fix and re-review.** Blockers and majors are fixed in severity order, one commit per bug, then reviewed again — up to 3 rounds. Minors can be deferred to `known-issues.md`. A PR reaching round 4 with unresolved blockers stops and waits for you.

**Merge gate.** Tests, typecheck, lint, build, secret scan, diff-scope check and commit hygiene, plus manual checks (no `any`, no stray `console`, no leaked stack traces, no `.only`/`.skip`). Any automated failure blocks the merge.

**Merge and record.** `--no-ff` into `develop-ai`, worktree removed, memory updated, budget updated, `session.yaml` advanced.

---

## Guardrails

- **Writes are confined** to `config.yaml → project_root`. Anything outside it is escalated to you rather than done. In the live run this stopped the build twice — once when `pnpm` was missing (installing it meant touching `/opt/homebrew`) and once at a browser binary download. That's the intended behaviour: a machine-level install is your decision, not the agent's.
- **Pushes only to `develop-ai` or `wpr/*`.** Never `main`, `master`, or `develop`. Never force-push.
- **Secret scan on staged files** before every commit. A match blocks the commit.
- **Round limit.** Round 4 with unresolved blockers stops and waits.
- **Nothing merges to your main branch.** Reviewing and merging `develop-ai` → `main` stays yours.

---

## Cost

This is the part to read before starting a large project.

The live run cost roughly **506k output tokens for 5 merged PRs** against a 730k estimate (69% of estimate), including QA rounds and fixes. Rough shape per PR:

```
scaffold        ~88k     API + validation + tests   ~118k
docker          ~62k     UI + optimistic updates    ~142k
schema + repo   ~96k
```

Planning produces an estimate before you commit, using a per-PR-type sizing table plus +35% for QA rounds, +60k for the mockup phase, and a 15% buffer. `budget.json` tracks estimate against actual per PR, and the skill warns you if actual crosses 80% of the estimate before the final PR.

If an estimate exceeds ~500k tokens, it will suggest splitting the project into an MVP batch and an enhancement batch rather than running one long build. Take that suggestion — shorter builds resume more reliably.

---

## Optional integrations

None of these are required. The skill degrades gracefully without them.

**[Playwright MCP](https://github.com/microsoft/playwright-mcp)** — lets the agent drive a real browser while building: open the running app, click through it, read the accessibility tree, screenshot. This is what turns *"the component tests pass"* into *"the assembled app works."*

```bash
claude mcp add playwright npx @playwright/mcp@latest
```

Restart Claude Code and confirm with `/mcp`. Use it alongside a committed `@playwright/test` suite — MCP to see the UI while building, specs as the regression net.

> Playwright MCP downloads a browser binary on first use. To keep it inside the project, set `PLAYWRIGHT_BROWSERS_PATH` to a gitignored directory before launching.

**[`code-better`](../code-better/)** — its sibling in this repo. `weekend-project` carries its own [exploration protocol](skills/weekend-project/references/explore-protocol.md), [verify gate](skills/weekend-project/references/verify-gate.md) and [merge gate](skills/weekend-project/references/merge-gate-checklist.md), so it never requires code-better and never reads from it. What code-better adds is the same discipline **on demand, for you** — `cb-read-only` while you inspect what the build produced, `cb-pr-review` on the `develop-ai` diff before you merge it to `main`, `cb-careful` when you take the wheel back.

```
/plugin install code-better@maneja81-skills
```

**`design-taste-frontend`** — if installed, the mockup phase applies its design vocabulary and pre-flight check. Without it, mockups are generated from the design direction you chose in the interview.

---

## Using it with other AI agents

`SKILL.md` follows the [Agent Skills](https://agentskills.io) open standard — it is plain markdown with YAML frontmatter and no Claude-specific syntax. Any agent that can read local files can run this workflow.

For agents that read an `AGENTS.md` (Codex CLI, Cursor, Gemini CLI, opencode, Amp, and others), vendor the skill into the repo and point at it:

```bash
mkdir -p .agent-skills
cp -R plugins/weekend-project/skills/weekend-project .agent-skills/
```

```markdown
<!-- AGENTS.md -->
## Weekend Project workflow

When I ask you to build a project end-to-end, or say `weekend-project` or any
`wpr-*` command, read `.agent-skills/weekend-project/SKILL.md` and follow it.
Load the phase, role and reference files it names only when you reach that phase.
```

What the workflow actually depends on, so you can judge the fit:

| Capability | Used for | If missing |
|---|---|---|
| Read local files on demand | Loading phase/role files only when needed | Inline the phase files; costs far more context |
| Shell execution | git, worktrees, tests, typecheck, build | The workflow doesn't function — this is the hard requirement |
| Git worktrees | PR isolation | Substitute plain branches; a failed PR is messier to unwind |
| Subagents / separate roles | Sr. Developer and Sr. QA as distinct reviewers | Run the QA pass as a separate, fresh session — the value is in the independent read, not the mechanism |
| Long-running autonomy | Multi-hour unattended builds | Use `wpr-pause` / `wpr-resume` and drive it in shorter sessions |

The `wpr-*` commands are recognised from the routing table in `SKILL.md`, so they work as plain typed text in any agent — no slash-command support needed.

---

## Repository layout

```
plugins/weekend-project/
  .claude-plugin/plugin.json   plugin manifest
  skills/weekend-project/
    SKILL.md                   entry point: routing, guardrails, memory protocol
    phases/                    01-interview → 06-merge-gate, loaded on demand
    roles/                     sr-developer.md, sr-qa.md
    commands/                  wpr-status, wpr-plan, wpr-plans, wpr-plan-add,
                               wpr-review, wpr-budget, wpr-resume
    references/                planning-protocol, plan-schema, explore-protocol,
                               verify-gate, merge-gate-checklist, tdd-patterns,
                               playwright-templates, token-estimates, and templates
  README.md · HOW-IT-WORKS.md · LICENSE
```

This plugin lives in the [claude-skills](https://github.com/maneja81/claude-skills) marketplace repo alongside [code-better](../code-better/). The bundle for Claude Desktop / claude.ai is at [`bundles/weekend-project.zip`](../../bundles/weekend-project.zip), and the installer at [`install.sh`](../../install.sh) handles both skills.

`SKILL.md` stays small on purpose — phase files load only when the run enters that phase, so the skill costs almost nothing in context until it's actually working.

---

## Updating

```
/plugin update weekend-project@maneja81-skills     # plugin install
./install.sh weekend-project                       # script install — backs up the old copy
```

## Uninstalling

```
/plugin uninstall weekend-project@maneja81-skills
./install.sh --uninstall weekend-project
rm -rf ~/.claude/skills/weekend-project            # manual install
```

Removing the skill leaves your project untouched: the code, branches, `develop-ai` history, `known-issues.md` and `open-decisions.md` all stay.

---

## Limitations

Worth knowing before you rely on it:

- **Autonomy has a ceiling.** Long builds hit context resets. `session.yaml` and `wpr-resume` are the mitigation, not a guarantee — expect to type `wpr-resume` a few times on a large project. Splitting into several plans helps more than anything else.
- **Escalations pause the build.** Anything needing a machine-level install or a write outside the project root stops and waits for you. Convenient if you're watching, slow if you left for the evening.
- **The estimate is an estimate.** Sizing comes from a per-PR-type table, not from your codebase. Complex or unusual work overruns it.
- **Defaults are opinionated.** TypeScript strict, TDD, SOLID/DRY, conventional commits, `pnpm`. You can override each in the interview, but the workflow is built around them.
- **QA is thorough, not omniscient.** It catches build/type/integration issues that tests miss. It does not replace a human review of product decisions, or a real security audit.

---

## Contributing

[Discussions](https://github.com/maneja81/claude-skills/discussions) is the place — especially for real run reports. If you build something with it, the useful thing to share is what the QA pass caught and what it missed.

When changing the skill, edit `plugins/weekend-project/skills/weekend-project/` (the source of truth) and rebuild the bundle:

```bash
cd plugins/weekend-project/skills && zip -r ../../../bundles/weekend-project.zip weekend-project -x '*.DS_Store'
```

Keep `SKILL.md` lean. New procedural detail belongs in a phase or reference file that loads on demand, not in the always-resident entry point.

---

## License

[MIT](LICENSE) © Mohit Aneja
