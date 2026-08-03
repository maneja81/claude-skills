### `cb-workflow`

**Before anything else:** if `0-cowork/memory/feedback.md` exists and has not been read this session, read it now and apply all correction rules silently. These are logged mistakes — do not repeat them.

Execute like a senior engineer who trusts nothing they haven't seen with their own eyes. During execution the dangerous failure is not a bad plan — it is claiming a step worked without proving it. So nothing is "done" until the evidence says so.

**Default stance:** you do not get to assert that something passed, built, ran, or works. You show the command and its output, and let that speak. No output, no ✓.

---

**Entry check — before the first step**

- **Arrived from an approved `cb-plan` plan?** Review the plan critically before executing — even approved plans can have gaps. Scan for: unclear instructions, missing dependencies, steps that assume something that wasn't confirmed, or anything that would block execution. If you find concerns, raise them with the user before touching any code. If the plan is clear, proceed — discovery is done, do not re-investigate from scratch. Follow the plan's steps, `Touches`, and `Blast radius` as written.
- **Invoked directly, no approved plan?** Do a quick discovery pass before the first step that touches code: read the files you are about to change and their direct callers, and confirm what already exists so you reuse it rather than recreate it. You cannot honour "match conventions / reuse / don't break things" if you never looked. Keep this pass tight — the change surface and its direct dependents, nothing more.
- **Branch check:** never start implementation on the main or master branch without explicit user confirmation. If the current branch is main/master, stop and ask: "This is the main branch — should I create a feature branch before starting?"

---

**The per-step loop**

Break the task into a numbered step plan. **Never execute all steps at once — this is a hard rule, not skipped by `cb-fast`.** Each step follows this exact sequence before moving to the next:

1. **Show** — present the next step: what it is, what it touches, what it will change
2. **Discuss / seek approval** — wait for explicit confirmation before touching any code. If the user says "go" or equivalent, proceed. If they have questions or want changes, resolve them first.
3. **Execute** — implement the step only after approval
4. **Run `cb-verify`** — lint → typecheck → build → tests. Show raw output. Fix any failures before proceeding — do not move to the next step with a broken build or failing tests.
5. **Run `cb-prod`** — production readiness check on the changed code. Show findings. Fix any Critical issues before proceeding. Flag Moderate issues in the step summary.
6. **Repeat** for the next step — do not begin step N+1 until step N has passed both cb-verify and cb-prod.

If the user explicitly says "run all steps without asking" or equivalent, you may batch execution — but `cb-verify` and `cb-prod` still run after each step. Failures in either still stop progression.

**Step 2/5: [name]** — [what you'll do]

Depends on this: [callers/consumers of any shared code this step touches — from the plan, or a quick check]

...work...

Side-effect check: [what else changed as a result — callers verified, types updated, routes wired, validators matched — or "no shared code touched"]

Validation: [the exact command you ran]
  [raw output — the real thing, trimmed if huge but never fabricated or summarised into "looks good"]

✓ Done. [what that output actually confirms]. Next: Step 3 — [name].

If executing an approved plan, update the plan's status tracker (`[ ]` → `[✓]`) as each step completes.

**Task registration (Cowork):** before executing the first step, call `TaskCreate` to register every step as a task. Call `TaskUpdate` → `in_progress` when starting a step, `completed` when it is validated. If `TaskCreate`/`TaskUpdate` are unavailable (non-Cowork environments), the `[ ]` → `[✓]` tracker serves the same purpose — same validation rules apply.

**On failure:** stop immediately. Show the real error — the actual output, not a paraphrase. You may make **one** retry, and you must announce it ("retrying with X"). If it still fails, report what failed and why, propose a fix, and wait for guidance. Never retry silently, never proceed on a failed step, never mark a failed step ✓.

**Stop and ask — do not guess — in any of these situations:**
- A dependency is missing or unavailable
- An instruction in the plan is unclear or ambiguous
- The plan has a critical gap that prevents starting a step
- cb-verify or cb-prod fails repeatedly after one retry
- The approach turns out to be fundamentally different from what the plan described

Ask for clarification rather than guessing. A wrong guess compounds — a clarifying question costs one message.

**When asking for help after repeated failures, always include:**
- What was attempted (each approach tried, in order)
- The exact error from the last attempt (raw output, not paraphrased)
- What alternatives exist and why each was ruled out

This gives the user enough context to unblock without needing to re-read the whole session.

---

**Hard rules**

**No unverified success — evidence or it didn't happen.** No "✓ tests pass", "build succeeds", "it works now", or "validated" without the command and its raw output in the reply. If you cannot produce output, the step is not done — say so and stop, do not assume.

**No invention mid-flight.** If a step needs something the plan didn't account for, check for an existing one first. If it's a genuine deviation, flag it and get a nod before building it.

All other hard rules (no over-engineering, follow existing project, don't break existing behaviour, production-ready only, stay in scope) are defined in `commands/_shared-rules.md` — already loaded at the start of this command.

---

**Interaction with `cb-fast`**

`cb-fast` drops the status bar and the per-step "shall I proceed?" pauses. It does **not** drop the evidence gate or the failure-stop. Under `cb-fast + cb-workflow`: still show validation output (tersely — command + key result line is enough), still stop on failure. Speed removes ceremony, never proof.

---

**After all steps complete — run Pre-Done Gate before cleanup**

Before moving to cleanup, run the Pre-Done Gate from `commands/_shared-rules.md`:
- Diff review — re-read every changed line against the requirement
- Side-effect check — confirm all callers, types, routes, validators are consistent
- Integration path trace — trace the primary user journey end-to-end through the code
- Common failure modes — null/empty/auth/async/config checks
- cb-verify — lint → typecheck → build → tests with raw output
- Requirement check — re-read the original ask and confirm it matches exactly

Do not proceed to cleanup until all six pass. If any fail, fix first and re-run the gate.

---

**After Pre-Done Gate passes — run live app check**

Boot the app and confirm it works in a real process before cleanup. Run automatically — do not ask for permission.

**Step 1 — detect start command:**

Check in this order:
- `package.json` scripts: `dev`, `start`, `serve` (prefer `dev` for local validation)
- `Makefile`: look for a `dev`, `run`, or `start` target
- `Procfile`: use the `web:` entry
- Framework defaults: `next dev`, `vite`, `python manage.py runserver`, `go run .`, `rails s`, `cargo run`, `mix phx.server`

If no start command can be detected, skip this block and note: "Live check skipped — could not detect a start command."

**Step 2 — boot the app:**

Start the process in the background. Tail its stdout/stderr until one of:
- A "listening on port", "ready", "started", or "running at" message appears → confirmed up
- 15 seconds pass with no such message → assume failed, show the last 20 lines of output and stop

Show the confirmed port and URL.

**Step 3 — smoke check (always run):**

Hit the root URL and up to 3 key routes (infer from the codebase — routes file, nav links, or sitemap):

```
GET http://localhost:<port>/          → expect 2xx
GET http://localhost:<port>/<route1>  → expect 2xx
```

Show the status code for each. Any 5xx or connection refused = live check failed — report and stop.

**Step 4 — visual check (if Playwright is available):**

Check for `@playwright/test` in `package.json` or `playwright.config.*` in the project root.

If found:
1. Open each smoke-checked URL in a real browser via Playwright
2. Take a screenshot of each page — save to `0-cowork/screenshots/` with a timestamped filename
3. Read the browser console for errors and failed network requests (4xx/5xx)

Report:

**Live check:**
- ✓ Booted on port [N]
- ✓/✗ [route] — [status code]
- 📸 Screenshot: `0-cowork/screenshots/[filename]`
- ⚠ Console errors: [list] / ✓ none
- ⚠ Failed requests: [list] / ✓ none

If no Playwright: mark visual check as `– not configured` and proceed.

**Step 5 — tear down:**

Kill the dev server process cleanly after the check completes.

If the live check finds errors (5xx, console errors, failed requests): stop before cleanup, report findings, and ask whether to fix them now or proceed anyway.

---

**After live check passes — auto-run cleanup and prod audit**

Run these automatically in order — do not ask for permission:

1. Run `cb-cleanup` (read `commands/cb-cleanup.md`). Complete the full cleanup flow before proceeding.
2. Run `cb-prod` (read `commands/cb-prod.md`). Complete the full production readiness audit.

After both complete, show the optional follow-up prompt:
```
─────────────────────────────────────────
Optional next steps:

  cb-review-flow   → trace end-to-end impact on dependents
  cb-validate-data → verify data landed correctly  [show only if data ops were involved]
─────────────────────────────────────────
```

**Auto-remember — append to `MEMORY.md`** (create if missing) and to `0-cowork/memory/session_logs.md` (create if missing):

```
## [date] — [task name]

**Worked on:** [what was built or changed — one sentence]
**Decisions made:** [non-obvious choices and why]
**Files changed:** [key files]
**Validation:** [cb-verify result — pass / fail / not run]
**Open items:** [anything unresolved, flagged but not fixed, deferred]
**Watch out for:** [risks, known issues, or things the next session should know]
```

Keep each field brief. Never overwrite existing entries — append only.

---