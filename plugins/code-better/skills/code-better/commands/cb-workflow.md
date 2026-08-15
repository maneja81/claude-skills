### `cb-workflow`

**Before anything else:** if `0-cowork/memory/feedback.md` exists and has not been read this session, read it now and apply all correction rules silently. These are logged mistakes — do not repeat them.

Execute like a senior engineer who trusts nothing they haven't seen with their own eyes. During execution the dangerous failure is not a bad plan — it is claiming a step worked without proving it. So nothing is "done" until the evidence says so.

**Default stance:** you do not get to assert that something passed, built, ran, or works. You show the command and its output, and let that speak. No output, no ✓.

---

**Step 0 — Execution style (ask before the first step)**

Before entry checks or planning steps, ask the user how they want execution to run:

> How should I run this?
> 1. **Step by step** — show each step, wait for your go-ahead before executing it, then validate before moving on.
> 2. **Run all steps** — execute the full plan end to end, running `cb-verify` and `cb-prod` after every step regardless, and give you one completed status report at the end (stopping early only on a failure).

Wait for the answer before proceeding. If the user already stated a preference in the same message that invoked `cb-workflow` (e.g. "cb-workflow, run all steps without asking"), skip the question and use that preference directly — confirm it in one line instead: "✦ Running all steps, one status report at the end."

This choice governs the per-step loop below. It does not change what still always runs: `cb-verify` and `cb-prod` after every step, the failure-stop rule, and the Pre-Done Gate before cleanup — none of that is skippable under either style.

**Also ask, same message:** whether to checkpoint progress with a local commit after each validated step, so a later failure can be rolled back without losing already-validated work.

> Also — want me to make a local commit after each step passes validation (so a failure later doesn't cost you already-working progress)? This is a git write, so it needs your go-ahead per the Git & GitHub Write Operations policy — I won't push or touch any remote, just local checkpoint commits.

If yes: after a step passes `cb-verify` and `cb-prod` (Step 4/5 below), run `git add` on exactly the files that step touched and commit with a message naming the step (e.g. `wip: step 2 — [step name]`). If a step later fails, these checkpoints are what gets rolled back to rather than losing the whole run. If no: skip this — no local commits, same as current behavior.

---

**Entry check — before the first step**

- **Arrived from an approved `cb-plan` plan?** Review the plan critically before executing — even approved plans can have gaps. Scan for: unclear instructions, missing dependencies, steps that assume something that wasn't confirmed, or anything that would block execution. If you find concerns, raise them with the user before touching any code. If the plan is clear, proceed — discovery is done, do not re-investigate from scratch. Follow the plan's steps, `Touches`, and `Blast radius` as written.
- **Invoked directly, no approved plan?** Do a quick discovery pass before the first step that touches code: read the files you are about to change and their direct callers, and confirm what already exists so you reuse it rather than recreate it. You cannot honour "match conventions / reuse / don't break things" if you never looked. Keep this pass tight — the change surface and its direct dependents, nothing more.
- **Branch check:** never start implementation on the main or master branch without explicit user confirmation. If the current branch is main/master, stop and ask: "This is the main branch — should I create a feature branch before starting?"

---

**The per-step loop**

Break the task into a numbered step plan. Each step follows this exact sequence before moving to the next:

1. **Show** — present the next step: what it is, what it touches, what it will change
2. **Discuss / seek approval** — under "step by step" (Step 0), wait for explicit confirmation before touching any code; if the user has questions or wants changes, resolve them first. Under "run all steps," skip the wait and proceed straight to execution.
3. **Execute** — implement the step (after approval under "step by step"; directly under "run all steps")
4. **Scope guard** — run `git diff --stat` (or the project's equivalent) and compare the actual changed files against the step's declared scope (its `Touches` line, or what was shown in step 1). Any file changed that wasn't declared — an auto-formatter touching unrelated files, an IDE-wide reformat, scope creep mid-step — gets flagged and confirmed before continuing: "This step also touched [file] — expected? (y/n, or I'll revert it)." Never silently let an undeclared file ride along.
5. **Run `cb-verify`** — lint → typecheck → build → tests. Show raw output. Fix any failures before proceeding — do not move to the next step with a broken build or failing tests. Runs after every step under both styles — never skipped.
6. **Run `cb-prod`** — production readiness check on the changed code. Show findings. Fix any Critical issues before proceeding. Flag Moderate issues in the step summary. Runs after every step under both styles — never skipped.
7. **Adjacent-path spot-check** — pick one path that calls or sits next to what this step changed but wasn't supposed to change, and actually exercise or read it to confirm it still behaves the same (a quick manual check, a targeted test run, or reading the call site if it's not testable). Don't rely solely on the compiler/test suite catching it — state what was checked and what was confirmed. If nothing adjacent exists to check (e.g. a brand-new isolated file), say so explicitly rather than skipping silently.
8. **Checkpoint commit (only if approved in Step 0)** — `git add` the files this step touched (and only those) and commit locally with a message naming the step.
9. **Repeat** for the next step — do not begin step N+1 until step N has passed both cb-verify and cb-prod.

**"Step by step" style:** never execute all steps at once — this is a hard rule, not skipped by `cb-fast`. Wait for approval before each step.

**"Run all steps" style:** execute the full plan without pausing for per-step approval — but `cb-verify` and `cb-prod` still run after each step, and a failure in either still stops progression immediately (see "On failure" below). At the end, produce one completed-status report covering every step, its validation result, and anything flagged along the way — not just a final "done."

**Step 2/5: [name]** — [what you'll do]

Depends on this: [callers/consumers of any shared code this step touches — from the plan, or a quick check]

...work...

Scope guard: [files actually changed vs. declared scope — match / flagged + resolution]

Side-effect check: [what else changed as a result — callers verified, types updated, routes wired, validators matched — or "no shared code touched"]

Validation: [the exact command you ran]
  [raw output — the real thing, trimmed if huge but never fabricated or summarised into "looks good"]

Adjacent-path check: [what nearby/related path was spot-checked and what confirmed it's unaffected — or "nothing adjacent exists to check"]

Checkpoint: [committed locally as "wip: step N — [name]" / not enabled this run]

✓ Done. [what that output actually confirms]. Next: Step 3 — [name].

If executing an approved plan, update the plan's status tracker (`[ ]` → `[✓]`) as each step completes.

**Task registration (Cowork):** before executing the first step, call `TaskCreate` to register every step as a task. Call `TaskUpdate` → `in_progress` when starting a step, `completed` when it is validated. If `TaskCreate`/`TaskUpdate` are unavailable (non-Cowork environments), the `[ ]` → `[✓]` tracker serves the same purpose — same validation rules apply.

**On failure:** stop immediately. Show the real error — the actual output, not a paraphrase. You may make **one** retry, and you must announce it ("retrying with X"). If it still fails, report what failed and why, propose a fix, and wait for guidance. Never retry silently, never proceed on a failed step, never mark a failed step ✓. If checkpoint commits are enabled, mention that the last validated checkpoint (step N) is intact and offer to reset to it if the failed step's partial changes should be discarded — do not reset without asking, this is itself a git write.

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

**After Pre-Done Gate passes — auto-run cleanup and prod audit**

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