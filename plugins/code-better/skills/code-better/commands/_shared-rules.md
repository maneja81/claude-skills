# Shared Rules — code-better

Referenced by all heavy commands. Read once per session when first needed.

---

## Output Formatting — Global Rule

**Never wrap command output in code blocks.** Plan steps, discovery reports, task trackers, phase outputs, checklists, structured analysis, and status updates must all render as plain markdown — headers, bold text, bullet lists, numbered lists, tables. Code blocks are for code and shell commands only. This applies to every command in the skill without exception.

---

## Output Language — AI Patterns to Avoid

Every command output must sound like a senior engineer wrote it, not a language model. Actively avoid these patterns:

**Filler phrases — delete entirely:**
- "It's important to note that" / "It's worth mentioning"
- "In order to" → use "to"
- "At the end of the day" / "That being said" / "Moving forward" / "In terms of"

**Overused words — use simpler alternatives:**
- "comprehensive" → "full" or "complete"
- "leverage" / "utilize" → "use"
- "facilitate" → "help" or "enable"
- "ensure" → "make sure"
- "robust" → "solid" or "reliable"
- "seamless" → skip it
- "optimal" → "best"
- "enhance" → "improve"
- "streamline" → "simplify"

**Hedging — be direct instead:**
- "I think maybe we could consider..." → state the opinion
- "It would seem that..." → state the fact
- "Perhaps it might be worth..." → suggest directly

**Transition padding — drop or use "also":**
- "Furthermore" / "Additionally" / "Moreover" / "In conclusion"

**Meta-commentary — delete and just say the thing:**
- "This approach works by..." → describe what it does
- "The benefit of this is..." → state the benefit
- "What this means is..." → just say it

---

## Engineering Hard Rules

These apply to every command that writes code. Non-negotiable.

**No over-engineering — climb the ladder first**
Before writing any code, run this sequence and stop at the first rung that solves the problem:

1. **Does this need to exist at all?** Speculative need → skip it and say so. (YAGNI)
2. **Already in this codebase?** A helper, util, type, or pattern that lives nearby → reuse it. Look before writing; re-implementing what's a few files over is the most common over-engineering.
3. **Stdlib / language built-in does it?** Use it.
4. **Native platform feature covers it?** CSS over JS, DB constraint over app code, `<input type="date">` over a picker library.
5. **An already-installed dependency solves it?** Use it. Never add a new dependency for what a few lines can do.
6. **Can it be one line?** One line.
7. **Only then:** write the minimum code that works.

Two rungs would work → take the higher one. The ladder runs *after* you understand the problem — read the task and trace the real flow first, then climb. If complexity is genuinely warranted past rung 7, call it out explicitly and let the user decide.

**Follow the existing project**
Before writing any code, check how the project already does it. Match existing folder structure, file naming conventions, import style, and patterns. Reuse existing utilities and components — never create a new one if something equivalent already exists. If unsure, read 1–2 nearby files first and match what you see.

**Don't break existing behaviour**
Before completing any step, verify nothing already working is affected. Check callers of any function changed, types modified, or contracts updated. If a step changes shared code, explicitly state what else depends on it and confirm it still works.

**Production-ready code only**
Every step produces code that is ready to ship. No TODOs, no debug logs, no hardcoded values, no swallowed exceptions, no missing error handling. If a step can't be completed to production quality, say so and wait for guidance rather than shipping half-done work.

**Never self-report validation results**
Any "✓ validated", "tests passed", or debug "Result" must show the actual command run and its raw output. Never report a result that was not directly observed — if a check could not be run, say so explicitly rather than assuming it would pass.

---

## Git & GitHub Write Operations — Pre-Approval Required

Applies to any command that can touch git or GitHub state: `cb-ship` today, and any future command that pushes, commits, merges, or opens/merges a PR.

**Always pre-approved, no need to ask:** `git status`, `git diff`, `git log`, `git branch` (listing), `git merge-base`, `gh pr checks` (watching status), and any other read-only git/gh command.

**Never pre-approved — requires an explicit upfront choice before the command runs any of these:** `git commit`, `git push`, `git merge`, `git checkout -b` / branch creation, `git branch -d`, `gh pr create`, `gh pr merge`, or anything else that changes git history, remote state, or GitHub state.

Before a command reaches its first write operation, ask the user once:

> This will need to [commit / push / open a PR / merge / delete a branch — name the specific actions this run requires]. Should I handle these myself, or will you take care of them and just want the [validation / draft / diff] from me?

If the user wants to handle it themselves: run everything up to the point right before the first write operation, hand off what was produced (PR description, branch name, diff, validation results), and stop — do not execute any write.

If the user wants the agent to handle it: proceed, but this pre-approval covers the *category* of action stated upfront, not a blanket yes for the rest of the session — a genuinely irreversible step within that category (see below) still gets its own specific confirmation before it runs.

---

## Irreversible Actions — Always Confirm Before Proceeding

Applies in `cb-careful` mode and referenced by `cb-workflow`, `cb-fix`, `cb-feature`:

- Database migrations or schema changes
- Force pushes or git history rewrites
- Production deploys
- Deleting files or branches
- API calls with side effects (sending emails, charging payments, posting to external services)
- Bulk data updates without a dry-run
- Dropping tables, columns, or indexes
- Revoking permissions or access tokens

**Preferred approach:** where a dry-run mechanism exists (`--dry-run`, `terraform plan`, migration preview, `git push --dry-run`), run it first and show output as the confirmation — a real preview beats a yes/no question.

---

## Severity Levels

Used in reports produced by `cb-prod`, `cb-review-flow`, `cb-enhance`, `cb-spec`, `cb-impact`, `cb-audit`:

| Level | Symbol | Meaning |
|---|---|---|
| Critical | ⛔ | Data loss, security hole, silent failure in production, broken deploy |
| Moderate | ⚠ | Edge case gaps, missing error handling, test coverage holes, stale dependents |
| Minor | · | Style inconsistencies, dead imports, hardcoded minor values, naming |

---

## Production Readiness Checklist

Used by `cb-prod`, `cb-audit`, `cb-cleanup`, `cb-workflow` post-validation, `cb-feature` Phase 5:

**Security**
- No secrets, tokens, API keys hardcoded
- Input validated and sanitised at every boundary
- Auth/permission checks on all new routes and data access
- No SQL or command injection risks

**Reliability**
- No swallowed exceptions (`catch {}`, bare `except:`, `.catch(() => {})` with no logging)
- Error handling on all external calls (HTTP, DB, queue, file I/O)
- Timeouts and retry logic where dependencies could be slow or unavailable
- Async errors awaited and propagated correctly

**Config hygiene**
- No hardcoded URLs, ports, limits, or feature flags — use env/config
- No environment-specific logic leaking into shared code
- Config validated on load — missing required keys fail loudly

**Observability**
- Critical paths (auth, payments, data writes) have structured logging
- Errors visible in production — not swallowed or dev-only
- No debug leftovers (`console.log`, `print`, `debugger`, commented-out blocks)

**Dead weight**
- No unused imports, dead variables, or unreachable code
- No untracked TODO/FIXME comments

---

## cb-verify Gate

Referenced by `cb-workflow`, `cb-cleanup`, `cb-feature`. Run in this order:

1. **Lint** — eslint, ruff, golangci-lint, etc.
2. **Typecheck** — tsc --noEmit, mypy, etc.
3. **Build** — if the project has a build step
4. **Tests** — jest, vitest, pytest, go test, etc.

Report format (plain markdown — not a code block):

**cb-verify:** ✓ lint · ✓ types · ✓ build · ✗ tests (2 failed)
- ✗ [test name] — [one-line reason]

If a stage's tooling doesn't exist, mark it `–` and move on. Never invent a toolchain. Never suppress or skip a check to make it pass.
---

## Pre-Done Gate

Run this before declaring any task, step, or command complete. Every box must pass — if any fail, fix before reporting done.

**1. Diff review — re-read every changed line**
For each file changed this session, re-read the actual diff. For each change ask: does this line do exactly what the requirement says? Not "is it correct code" — does it solve the specific thing asked?

**2. Side-effect check — what else needed to change?**
For every function, type, schema, route, or contract you changed:
- Grep for all call sites — did any callers break?
- Check the type file / interface — did the shape change propagate?
- Check the route registration / export — is it actually wired up?
- Check related validators, mappers, or serializers — do they match?

If you changed X and Y depends on X, Y must be verified. List what you checked.

**3. Integration path trace — follow the actual user journey**
Pick the primary action a user will take that exercises this change. Trace it step by step from the entry point (HTTP request / UI action / job trigger) through to the output (response / DB write / UI state). At each hop, confirm the code actually connects — not "it should work" but "I read the code and it does."

Call out any hop you could not verify and why.

**4. Common failure modes — check each explicitly**
- Null / undefined / empty input — is it handled or will it throw?
- Empty array / zero rows — does the code degrade gracefully?
- Auth / permissions — is access correctly gated on new routes or data?
- Async errors — are all awaits covered and errors propagated?
- Missing env / config — would this break in a fresh environment?

**5. cb-verify — run the gate**
Run lint → typecheck → build → tests. Show raw output. If any stage fails, fix before proceeding.

**6. Requirement check — read the original ask one more time**
Re-read the user's original request or the plan step. Does what you built actually match it? Not "close enough" — exactly.

Only after all six pass: report done.
