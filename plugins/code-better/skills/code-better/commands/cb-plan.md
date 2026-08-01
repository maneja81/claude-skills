### `cb-plan`

**Before anything else:** if `0-cowork/memory/feedback.md` exists and has not been read this session, read it now and apply all correction rules silently. These are logged mistakes — do not repeat them.

Plan like a principal engineer who is skeptical of new code and assumes the solution already exists in the codebase until proven otherwise. A plan is not written from assumptions — it is written from evidence gathered *this session*.

**Default stance:** the codebase is the source of truth, not your priors. If you have not read it this session, you do not know it — go read it or mark it `UNKNOWN`. Never describe current behavior, conventions, or existing code from memory or inference.

This command runs in two gated phases. You may not begin Phase 2 until Phase 1 is complete and shown to the user.

---

**Scope check — before anything else**

If the task spans multiple independent subsystems (e.g. "add auth, billing, and reporting"), stop before discovery:

> This looks like multiple independent pieces. Each should have its own plan — one per subsystem, each producing working, testable software on its own. Should we split before planning, or is there a reason they must ship together?

Wait for confirmation. If the task is appropriately scoped, proceed.

---

**Phase 1 — Discovery (mandatory, evidence-gated)**

Use MEMORY.md context from the session load (`cb-load`) — prior decisions, architecture choices, and conventions are already in context. Re-read MEMORY.md only if `cb-load` has not run this session. Do not scan all files under `0-cowork/memory/`; use the session index to identify and read only the specific knowledge files relevant to this change. Then investigate the actual code the change will touch.

Keep discovery targeted — read the files in the change surface, their direct dependents, and 1–2 sibling files to sample conventions. Do not crawl the whole repo. Do not read a file past the point where the pattern is clear.

**Scope limit:** if you have opened more than 10 files and still don't have a clear picture of what to change, stop discovery. Do not guess. Tell the user: "Discovery exceeded 10 files without a clear picture. Can you point me to the specific area or file to focus on?" Wait for direction before continuing.

Produce this discovery report *before* any plan. **Render as plain markdown — not in a code block.**

---

**Discovery**

**Read**
- [actual files opened this session, with line ranges — e.g. src/auth/session.ts:1-80]
- (not "reviewed the auth code" — name the files or it didn't happen)

**Searched**
- [what you grepped/searched for and the result — e.g. "searched for existing date formatter → found src/utils/date.ts:formatISO"]
- e.g. "searched for a retry helper → nothing found"

**Current state**
- How it works today: [the real flow, pointing at specific files/functions]
- Entry points / triggers: [where this is called from]

**Conventions observed** (from sibling files)
- Naming & structure: [...]
- Error handling style: [...]
- Folder placement & import style: [...]
- Test pattern: [...]

**Reuse audit** (one entry per thing you are tempted to create new)
- Need: [capability the task requires] — Existing: [what already does this, or "searched X, Y — found nothing"] — Decision: reuse / extend / create new — because [reason]

---

**Hard rule — no invention:** every statement about the current codebase in the plan must trace back to an entry under `Read` or `Searched`. If you catch yourself asserting something you did not verify this session, stop and go verify it, or mark it `UNKNOWN` and flag it.

**Hard rule — reuse before create:** you may not plan to create a new function, file, utility, type, or component without a Reuse audit entry showing you looked for an existing one first. "I didn't find one" is only valid if you actually searched — show the search.

**Pre-plan self-check** — do not proceed to Phase 2 until every box is yes (render as plain markdown):

- [ ] I read the actual files this change touches (not guessed from names)
- [ ] I traced who depends on what I'm about to change
- [ ] I sampled a sibling file and know the conventions to follow
- [ ] I searched for existing code before proposing anything new
- [ ] I know what this change makes redundant
If any box is "no," go back to discovery. Do not write the plan yet.

---

**File structure map — before writing steps**

Before defining steps, map every file this plan will create or modify. This locks in decomposition decisions before task planning starts.

| File | Create / Modify | Responsibility |
|---|---|---|
| `exact/path/to/file` | Create / Modify | One clear responsibility — what this file owns |

Rules:
- Each file has one clear responsibility. If you can't state it in one sentence, the boundary needs work.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If a file you're modifying has grown unwieldy, a split can be included in the plan — but only if it's required for the task, not as a cleanup opportunity.

This map informs the steps below. Each step's `Touches` should trace back to a row in this table.

---

**Phase 2 — The plan**

Produce a full step-by-step plan in workflow format with a status tracker. Stop and wait for explicit go-ahead before executing a single step.

**Plan: [task name]**

**Done when:** [one observable condition that confirms the whole feature is complete — e.g. "user can log in with email/password and session persists across refresh" or "all N endpoints return correct responses and existing tests pass"]

Follows conventions: [the specific conventions from Discovery this plan adheres to]
Reuses: [existing code/utilities this plan builds on instead of recreating]

- [ ] **Step 1: [name]** — [what will be done and why]
  - Touches: [specific files, functions, or systems]
  - Current behavior here: [how this bit works today — from Discovery, not invented]
  - Blast radius: [what depends on this — callers, types, contracts, schema, consumers — traced]
  - Edge cases: [boundary conditions, empty/null/large/concurrent]
  - Error handling: [how failures are caught and surfaced]
  - Breaking changes: [any API, schema, or contract change; migration needed?]
  - Verify: [exact check that will confirm this step is done — command to run, output to expect, or behavior to observe]

- [ ] **Step 2: [name]** — ...

- [ ] **Step N: [name]** — ...

**Removes / obsoletes:** [dead code, old code paths, now-unused functions or config this change makes redundant — planned for removal, not left behind]

**Risks & dependencies:** [anything that could block the work or ripple into other parts of the system]

**Rollback:** [how to undo this if something goes wrong]

---

**Plan Validation** — complete this before asking for approval. If any section reveals a gap, fix the plan first.

**1. Requirement coverage**
Re-read the original ask word by word. For each requirement or constraint stated, identify the step that covers it. List unmapped items explicitly.

| Requirement | Covered by step | Gap? |
|---|---|---|
| [requirement from the ask] | Step N / Not covered | Yes / No |

If any row is "Not covered" — add a step or explain why it's out of scope. Do not leave gaps silent.

**2. Existing codebase impact — consolidated**
Roll up the blast radius from all steps into one view. Everything currently working that this plan touches.

| What exists today | Step that touches it | Risk if it breaks |
|---|---|---|
| [existing function / route / type / table / component] | Step N | Low / Medium / High |

Flag any High-risk row explicitly: "⚠ [what] — needs extra care at Step N because [reason]."

**3. Plan-level edge cases**
Scenarios not covered by any individual step's edge cases — system-level boundary conditions, multi-step interactions, or state that spans the change.

- [Scenario] — [which step handles it, or "not handled — add to Step N"]

If no plan-level edge cases exist beyond what's in the steps, write: "All edge cases handled at step level — none span multiple steps."

**4. Gap check**
Is there anything the ask requires — explicitly or implicitly — that has no step covering it?

- [Gap or "No gaps found — all requirements are covered"]

For implied requirements (standard platform behavior, error states, permissions, data consistency) that aren't in the AC but must ship: call them out here and confirm they're in a step.

**5. No placeholders — scan every step for these failures and fix before presenting:**
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases" — without specifying what and where
- "Write tests for the above" — without actual test structure or assertions
- "Similar to Step N" — repeat the specifics, the engineer may read steps out of order
- References to a function, type, or file not defined in any step of this plan

If any are found, fix them inline. Do not present the plan with placeholders.

**6. Cross-step consistency — verify naming is coherent across all steps:**
Do function names, type names, method signatures, and file paths referenced in later steps match exactly what was defined in earlier steps? A function named `refreshToken()` in Step 2 but `renewToken()` in Step 5 is a plan bug that causes execution failures.

Scan forward-references in each step and confirm the name matches its definition. Fix any mismatches before presenting.

---

Waiting for go-ahead. Reply "cb-workflow" (or go / yes / proceed) to execute in workflow mode, or give feedback to adjust the plan.

Hard rules (no over-engineering, no invention without a reuse audit, follow existing project, production-ready) are defined in `commands/_shared-rules.md` — already loaded. Apply them to all plan steps.

---

**On approval — auto-switch to execution**

When the user replies "cb-workflow" (or equivalent approval — go / yes / proceed / lgtm):
- If the approval includes changes ("cb-workflow but fix step 3 first"), apply the changes to the plan, re-show the affected steps, and confirm before executing.
- Otherwise: switch out of `cb-plan` and into `cb-workflow` mode. Confirm: "✦ Plan approved. Switching to workflow mode."
- Execute the plan step by step under `cb-workflow` rules: one step at a time, validate each before proceeding (show the actual command and its raw output as evidence — never claim a step passed without showing it), and update the status tracker (`[ ]` → `[✓]`) as steps complete.

Note: the Phase 2 approval gate is a *correctness* gate, not ceremony. It is not skipped by `cb-fast`.