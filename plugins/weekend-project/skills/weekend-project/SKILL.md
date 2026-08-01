---
name: weekend-project
description: >
  Autonomous end-to-end project builder. Intercepts short project requests ("I want to build a website", "help me create an app") and runs a structured intake interview, generates a PR-by-PR execution plan with token budget estimate, presents UI mockups for approval on frontend projects, then executes the full build using Sr. Developer and Sr. QA Analyst agent roles — TDD, SOLID, DRY, TypeScript strict, Playwright UI validation — looping review/fix rounds until production-ready, then merging each PR to `develop-ai`. User approves the plan once, then steps away. Use when: `weekend-project`, `wpr-start`, `wpr-status`, `wpr-plan`, `wpr-resume`, `wpr-review`, `wpr-budget`, `wpr-plans`, `wpr-plan-add`, `wpr-mockups`, `wpr-pause`, `wpr-abort`, or any message that is a short project brief ("I want to create...", "help me build...", "I need an app that...").
---

# Weekend Project — Autonomous Project Builder

## Command routing table

| Command | Action |
|---|---|
| `weekend-project` | First-run setup → interview → plan → execute |
| `wpr-start` | Same as above — alias |
| `wpr-status` | Load and display current state from session.yaml |
| `wpr-plan` | Read `commands/wpr-plan.md` |
| `wpr-plans` | Read `commands/wpr-plans.md` — show the plan queue |
| `wpr-plan-add` | Read `commands/wpr-plan-add.md` — queue a new plan for later |
| `wpr-resume` | Read `commands/wpr-resume.md` |
| `wpr-review` | Read `commands/wpr-review.md` |
| `wpr-budget` | Read `commands/wpr-budget.md` |
| `wpr-mockups` | Record the user's chosen UI variants to `ui-mockups/approval.yaml` (see `phases/03-ui-mockups.md`) |
| `wpr-pause` | Freeze execution, save session.yaml, confirm to user |
| `wpr-abort` | Save state, summarize what's done, stop all agents |
| `wpr-feedback` | Append user feedback to `.claude/weekend-project/memory/feedback.md` |
| `wpr-remember` | Manually save something to `.claude/weekend-project/memory/` |
| `wpr-reset-pr` | Abandon current PR branch, mark PR as todo, resume from it |
| `wpr-skip` | Push current minor issue to backlog, continue execution |

## Command recognition

Activate on `weekend-project` or `wpr-*` as the leading token of a message. All valid forms:
- `weekend-project I want to build a SaaS for restaurants`
- `wpr-start`
- `wpr-status`

A `wpr-*` name appearing mid-sentence is a reference, not an invocation. Do not activate.

Short project briefs with no explicit `wpr-*` command (e.g. "I want to create a website for my business") should also trigger `weekend-project` — recognise the intent and start the intake flow.

---

## Environment detection (run before anything else)

Detect the runtime environment and set `ENV` in memory for this session:

**Claude Code (local):**
- Direct terminal access
- Git and gh CLI available natively
- Full autonomous execution — no warnings needed

**Cowork (cloud):**
- Terminal access via device bridge
- Slower file operations; context resets more likely
- Show this warning once at startup, then proceed:

```
⚠  Running in Cowork cloud mode.
   Long builds are more reliable in Claude Code (local terminal).
   Proceeding in cloud mode — make sure your project folder is connected.
   If execution stalls mid-PR, run `wpr-resume` to continue from last checkpoint.
```

Then verify the connected folder before proceeding. If no folder is connected, stop and ask the user to connect their project folder in the desktop app.

---

## First-run detection

Check for `.claude/weekend-project/session.yaml` in the project root.

- **Not found → fresh project.** Run full setup (Step A below).
- **Found, but `plan.json` exists and `plans/` does not → migrate.** Run the migration in `references/plan-schema.md`, then continue with the result.
- **Found, phase = complete → current plan is done.** Check `plans/pending/`:
  - Plans queued → show the next one and offer to start it (`wpr-resume`), or `wpr-plans` for the whole queue.
  - Nothing queued → tell the user, offer `wpr-plan-add` to queue the next batch or `wpr-review` for `known-issues.md`.
- **Found, any other phase → resumption.** Run `wpr-resume` flow (read `commands/wpr-resume.md`).

---

## Step A — Fresh project setup

Run all steps in order. Do not skip steps on user impatience — each is a guardrail.

### A1: Permission checks

Run these in parallel:

```bash
gh auth status
git config user.name
git config user.email
git rev-parse --is-inside-work-tree
```

If any fail:
- `gh auth status` fails → run `gh auth login` interactively. Do not proceed until authenticated.
- git config missing → set `git config user.name` and `git config user.email` interactively.
- Not inside a git repo → `git init`, then `git remote add origin` if the user wants GitHub integration.

### A2: Create folder structure

```bash
mkdir -p .claude/weekend-project/{memory,ui-mockups,pr-logs,playwright}
mkdir -p .claude/weekend-project/plans/{pending,active,done,deferred}
```

Create empty memory files:
```
.claude/weekend-project/memory/patterns.md
.claude/weekend-project/memory/decisions.md
.claude/weekend-project/memory/qa-learnings.md
.claude/weekend-project/memory/user-preferences.md
.claude/weekend-project/memory/feedback.md
```

Add to `.gitignore` (append, do not overwrite):
```
.wpr-worktrees/
.claude/weekend-project/pr-logs/
.claude/weekend-project/playwright/
.claude/weekend-project/ui-mockups/*.html
```

`.wpr-worktrees/` must be ignored before the first worktree is created. It lives inside the repo, and an unignored worktree gets picked up by `git add -A` and committed into a PR.

Everything else under `.claude/weekend-project/` — `plans/`, `config.yaml`, `session.yaml`, `budget.json`, `decisions.jsonl`, `memory/` — **is committed**. It is the project's record of intent and accumulated knowledge, and plan files must be in the repository for a worktree created from `develop-ai` to contain them.

Create user-facing files at project root if they don't exist:
```
known-issues.md   (from template in references/known-issues-template.md)
open-decisions.md (from template in references/open-decisions-template.md)
```

Initialize session:
```yaml
# .claude/weekend-project/session.yaml
phase: interview
current_plan: null          # plan ID, e.g. plan-002 — authoritative, never a path
current_pr: null
current_pr_branch: null
current_round: 0
round_state: null
memory_loaded: false
env: claude-code            # or cowork
auto_continue: false        # true = start the next pending plan without asking
last_checkpoint: null
```

### A3: Run interview

Read `phases/01-interview.md` and run the intake questionnaire.
Save answers to `.claude/weekend-project/config.yaml` after each section (resume-safe).

### A4: Generate CLAUDE.md

After interview completes, generate or merge a `CLAUDE.md` at the project root.
If `CLAUDE.md` already exists, append a `## Weekend Project` section — do not overwrite existing content.

Template:
```markdown
## Weekend Project

**AI Branch:** develop-ai (all AI work merges here — never touch main)
**AI Branch Prefix:** wpr/ (feature, chore, bugfix)
**Skill:** weekend-project
**Config:** .claude/weekend-project/config.yaml
**Plan:** .claude/weekend-project/plans/

### Standards
- TDD: tests before implementation
- TypeScript strict, no `any`
- SOLID + DRY enforced
- All decisions logged to .claude/weekend-project/decisions.jsonl

### Commands
wpr-status · wpr-plan · wpr-review · wpr-budget · wpr-pause · wpr-resume

### Files to check
- known-issues.md — deferred issues from QA rounds
- open-decisions.md — pending decisions that may block PRs
```

### A5: Create develop-ai branch

```bash
git checkout -b develop-ai
git push -u origin develop-ai
```

If `develop-ai` already exists remotely, check it out instead. Never force-push.

### A6: Advance to planning

Update `session.yaml → phase: planning`.
Read `phases/02-planning.md` and generate the PR plan.

---

## Reference files

This skill is self-contained. Everything it needs is under its own directory — never read from another skill's installed location, and never assume another skill is present.

| Reference | Used for |
|---|---|
| `references/planning-protocol.md` | How every plan is produced — discovery, reuse audit, validation |
| `references/plan-schema.md` | Plan file schema, the four folders, reconciliation, staleness, migration |
| `references/explore-protocol.md` | Reading a codebase before writing to it — token limits and layered approach |
| `references/verify-gate.md` | Lint · typecheck · build · test, run after every step and every fix |
| `references/merge-gate-checklist.md` | The production gate before a merge |
| `references/tdd-patterns.md` | Test-first patterns by layer |
| `references/playwright-templates.md` | E2E and accessibility test scaffolding |
| `references/token-estimates.md` | Per-PR-type sizing for the budget |

Load a reference when the step that needs it begins, not upfront.

**Optional:** if the user also has the `code-better` skill installed, its `cb-*` commands cover the same ground interactively (`cb-explore`, `cb-verify`, `cb-prod`, `cb-pr-review`). Use them if the user invokes them. Never require them, and never route through them by default.

---

## Memory protocol

**Before starting any PR or task:**
1. Read all 5 files in `.claude/weekend-project/memory/`
2. Read `.claude/weekend-project/decisions.jsonl` (last 20 entries)
3. Announce: "Memory loaded — [N] patterns, [N] decisions, [N] QA learnings"

**After completing any PR:**
1. Append new patterns, decisions, QA findings to the relevant memory files
2. Log the completion to `decisions.jsonl`
3. Update `session.yaml → last_checkpoint`

**On user `wpr-feedback`:**
Append the feedback verbatim to `memory/feedback.md` with timestamp. Acknowledge and note how it will affect future PRs in the current build.

---

## Decision logging

Every non-obvious technical decision must be logged to `decisions.jsonl` (append-only, one JSON per line):

```json
{
  "id": "d-001",
  "ts": "2026-07-31T10:23:00Z",
  "pr": "wpr/feature/auth",
  "agent": "sr-developer",
  "decision": "Used RS256 for JWT signing instead of HS256",
  "rationale": "RS256 allows public key verification without exposing the secret — better for multi-service architectures",
  "alternatives": ["HS256", "session-based auth"],
  "standard": "OWASP JWT Cheat Sheet"
}
```

"Non-obvious" means: a choice between two or more valid approaches, a deviation from a default, or any assumption made in the absence of explicit user instruction.

---

## Guardrails (enforced on every agent, every turn)

1. All file writes must be inside `config.yaml → project_root`. Refuse and escalate any operation targeting a path outside it.
2. Git push is only permitted to branches starting with `wpr/` or equal to `develop-ai`.
3. Never push to `main`, `master`, `develop`, or any branch not prefixed `wpr/`.
4. Before every commit: scan staged files for secrets (API keys, tokens, `.env` values). Block commit if found.
5. Agents read any file in the project for context but write only to files within their current PR scope.
6. Round limit: if a PR reaches round 4 with unresolved `blocker` or `major` issues, stop, notify user, wait for instruction.
7. **State lives in the main working tree, never in a worktree.** See below — this one breaks silently.

---

## State path rule

Skill state lives at `<project_root>/.claude/weekend-project/`. During execution the Sr. Developer works inside a worktree at `<project_root>/.wpr-worktrees/<branch>/`, which contains its own copy of every tracked file — including a snapshot of `.claude/weekend-project/` as it stood when the branch was created.

**Always read and write skill state through the absolute `project_root` path.** A relative `.claude/weekend-project/...` from inside a worktree resolves to the stale snapshot, so a decision logged there is written to the wrong file, committed into the PR, and lost on worktree removal.

```bash
# correct — from anywhere, including inside a worktree
$PROJECT_ROOT/.claude/weekend-project/decisions.jsonl

# wrong when the shell is inside .wpr-worktrees/<branch>/
.claude/weekend-project/decisions.jsonl
```

This applies to `session.yaml`, `plans/`, `budget.json`, `decisions.jsonl`, `memory/`, `pr-logs/` and `roadmap.md` — every write, in every phase.

**A `wpr/*` branch must never stage a path under `.claude/weekend-project/`.** Add this to the pre-commit check alongside the secret scan: if any staged path matches, unstage it, write it to the main tree instead, and continue. The merge gate independently re-checks this (`phases/06-merge-gate.md`).

Because PR branches never touch state, merging them into `develop-ai` can never conflict on a state file. State is committed to `develop-ai` directly, in its own `chore(wpr): ...` commit after each merge.

---

## Phase file map

| Phase | File |
|---|---|
| Interview | `phases/01-interview.md` |
| Planning | `phases/02-planning.md` |
| UI Mockups (frontend only) | `phases/03-ui-mockups.md` |
| Execution loop | `phases/04-execution.md` |
| QA review round | `phases/05-review-round.md` |
| Merge gate | `phases/06-merge-gate.md` |

Load a phase file only when entering that phase. Do not load all upfront.

---

## Token budget tracking

`.claude/weekend-project/budget.json` is keyed by plan — see `references/plan-schema.md` for the shape.

Update the current plan's `actual` and `by_pr` after each PR completes. Warn when a plan's `actual` exceeds 80% of that plan's estimate before its final PR — per plan, not per project, so one overrun cannot hide inside a large total.

At a plan boundary, show what the finished plan cost against its estimate before starting the next one. That comparison is the whole reason for splitting a large project into plans.
