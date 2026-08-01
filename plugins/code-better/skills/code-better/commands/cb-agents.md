# cb-agents

Multi-agent pipeline for non-trivial feature work. Manages scoped agents in
sequence with a mandatory human approval gate between planning and execution.

```
[Intake]      Asks 4 questions, creates task folder
     ↓
[Phase 1]     Research Agent(s)  →  0-cowork/agents/{slug}/outputs/research/
     ↓         ← THE MOST IMPORTANT PHASE. If research is thin, everything downstream fails.
[Phase 2a]    Plan Agent         →  0-cowork/agents/{slug}/outputs/plan.md
     ↓
[HUMAN GATE]  Present plan — wait for approval before proceeding
     ↓
[Phase 2b]    Workflow Agent     →  0-cowork/agents/{slug}/outputs/workflow-report.md
     ↓
[Phase 3]     Review Agent A (cb-pr-review)  ──┐  spawned in one message (parallel)
              Review Agent B (cb-review-flow) ─┘
     ↓
[Synthesis]   Final report  →  0-cowork/agents/{slug}/outputs/final-report.md
```

---

## Step 0 — Intake (always first, no agents yet)

Ask the user these questions in ONE message before doing anything else:

```
cb-agents — need a few details before starting:

1. What's the task? (ticket, spec, or description — the more specific, the better)
2. Which codebase areas are in scope? (e.g. "billing module", "whole repo")
3. Output folder name? (optional — leave blank to auto-generate)
4. Anything agents must know upfront? (prior decisions, files to avoid, constraints)
```

Wait for answers. Do not spawn any agent before this.

---

## Step 1 — Setup

Using the intake answers:

1. Derive a task slug: lowercase, hyphens, max 5 words from the task description.
   e.g. "Add tenant isolation to billing" → `add-tenant-billing`

2. Create the task folder structure:
   ```
   0-cowork/agents/{YYYY-MM-DD}-{slug}/outputs/
   0-cowork/agents/{YYYY-MM-DD}-{slug}/outputs/research/
   ```

3. Confirm to the user:
   ```
   ✦ cb-agents
   Task folder: 0-cowork/agents/2026-07-05-add-tenant-billing/outputs/
   Starting Phase 1 — Research.
   ```

All downstream agent prompts use this root path. Agents write only to their
assigned path — never anywhere else.

---

## Step 2 — Phase 1: Research Agents

> **This is the most critical phase of the entire pipeline.**
> The plan agent can only plan what research reveals. The workflow agent can only
> build what the plan describes. The review agents can only validate what was built.
> If research is shallow, guessed, or incomplete — every downstream phase fails.
> Research agents have ONE job: give the plan agent everything it needs to write
> a plan grounded entirely in real code, not assumptions.

Decide how many research agents to spawn based on scoped areas:
- 1 area → 1 agent
- 2–3 distinct areas → spawn all in ONE message (parallel)
- More than 3 areas → group into 3 agents max, each covering related areas

**Research Agent prompt** (customise per agent — fill in {AREA}, {OUTPUT_PATH}, {TASK_DESCRIPTION}, {INTAKE_NOTES}):

---

> **Your role:** You are the research foundation of a multi-agent pipeline.
> The plan agent, workflow agent, and review agents all depend entirely on what
> you produce. If you guess, invent, or skip something — the plan will be wrong,
> the code will be wrong, and the review will miss it. Your output is the only
> source of truth about the codebase that downstream agents will ever see.
>
> **Your job:** Deep, focused discovery of the real codebase — no plans, no
> solutions, no code. Only evidence.
>
> **Task context:** {TASK_DESCRIPTION}
> **Codebase area:** {AREA}
> **Known constraints / prior decisions:** {INTAKE_NOTES}
>
> ---
>
> **Discovery process — follow in order:**
>
> **1. Load memory**
> Read MEMORY.md and 0-cowork/memory/feedback.md. Read 0-cowork/index.md to get a
> map of what knowledge files exist — then read only the specific knowledge files
> relevant to your assigned area (do not scan all files under 0-cowork/memory/).
> Extract: prior decisions relevant to this area, known pitfalls, conventions already
> documented, anything marked "watch out for". These are facts — treat them as such.
>
> **2. Map the terrain**
> Run: `find . -maxdepth 3 -type f -name "*.ts" -o -name "*.js" -o -name "*.py"` (adapt to project language)
> Do not read files yet. Build a mental map: what exists, where, what the naming
> patterns suggest. Identify candidate files for deeper reading.
>
> **3. Targeted search before reading**
> Before opening any file, grep to locate exactly what matters:
> - Entry points: where is this area of code called from?
> - Key symbols: functions, classes, types, constants central to this area
> - Related patterns: how does the rest of the codebase solve similar problems?
> - If it's a bug: grep for the error message, the failing function, the affected data path
> - If it's a feature: grep for where similar features are implemented to sample the pattern
>
> Build a ranked list of files to read — highest signal first.
>
> **4. Deep file reading**
> Read files from your ranked list. For each file:
> - Read fully if it's central to the change (not just the function — the whole file,
>   so you understand context, imports, callers, and the shape of the module)
> - For large files (300+ lines): read the full file if this is the core change surface;
>   read first 80 lines + grep for the relevant section if it's a dependency or caller
> - Hard limit: 15 files maximum. If you're at 15 and still unclear, stop and flag it —
>   do not guess, do not continue reading hoping it becomes clear.
>
> **5. Trace the full call chain**
> For any function or system the task touches, trace:
> - Who calls it (callers, routes, event triggers, cron jobs)
> - What it calls (dependencies, services, DB queries, external APIs)
> - What data it reads and writes (schema, types, contracts)
> - What would break if it changed (dependents, consumers, downstream side effects)
>
> This blast radius information is what the plan agent needs most. Do not skip it.
>
> **6. Conventions deep-dive**
> Read 2–3 sibling files (same module, similar purpose) that are NOT part of the
> change surface — purely to understand how this project does things. Extract:
> - Naming conventions (functions, files, variables, types)
> - Error handling patterns (try/catch shape, error types, how errors surface to callers)
> - How new functionality is added (where it goes, what it extends, what it registers with)
> - Test file conventions (naming, structure, what gets mocked, what gets tested)
> - Import style and module boundaries
>
> **7. Reuse audit**
> For every capability the task will need to create, search first:
> - Is there an existing utility, helper, hook, service, or function that already does this?
> - Is there something close that could be extended rather than replaced?
> - Document what you searched and what you found (or didn't find). "I didn't look" is not valid.
>
> ---
>
> **Report format — save to {OUTPUT_PATH}:**
>
>     Research Report — {AREA}
>     Task: {TASK_DESCRIPTION}
>
>     ── MEMORY & PRIOR CONTEXT ───────────────────────────────
>     Prior decisions relevant to this area:
>       [from MEMORY.md / session_logs.md — quote directly, don't paraphrase]
>     Known pitfalls / watch-outs:
>       [anything flagged previously that applies here]
>
>     ── FILES READ ───────────────────────────────────────────
>     [file path : line range read — e.g. src/billing/service.ts:1-180]
>     [file path : line range read]
>     ... (every file actually opened, no omissions)
>
>     ── SEARCHES RUN ─────────────────────────────────────────
>     [what you grepped / searched for → what was found or "nothing found"]
>     e.g. grep "createInvoice" → found in src/billing/service.ts:42, src/api/billing.ts:88
>     e.g. grep "tenantId" → not found anywhere in billing module
>
>     ── CURRENT STATE ────────────────────────────────────────
>     How this area works today (full flow, not a summary):
>       Entry point: [where this is triggered — route, event, cron, import]
>       Core logic:  [what actually happens — step by step, file:line references]
>       Data flow:   [what data goes in, what comes out, what gets written where]
>       Exit points: [what this returns or emits, and who receives it]
>
>     ── CALL CHAIN & BLAST RADIUS ────────────────────────────
>     Callers (who calls what we're changing):
>       [caller name — file:line]
>     Dependencies (what we're changing calls):
>       [dependency name — file:line]
>     Schema / types involved:
>       [type/table/contract — file:line]
>     If this changes, these break:
>       [dependent — why it breaks — file:line]
>
>     ── CONVENTIONS OBSERVED ─────────────────────────────────
>     (from sibling files outside the change surface)
>     Naming & structure:        [...]
>     Error handling pattern:    [...]
>     How new code is added:     [...]
>     Test conventions:          [...]
>     Import & module style:     [...]
>
>     ── REUSE AUDIT ──────────────────────────────────────────
>     [For each capability the task needs:]
>     Need: [what the task requires]
>       Searched: [what you looked for and where]
>       Found:    [existing code that does this — file:line] OR "nothing found"
>       Decision: reuse [name] / extend [name] / create new — because [reason]
>
>     ── OPEN QUESTIONS ───────────────────────────────────────
>     [Anything genuinely ambiguous that the plan agent must resolve before planning.
>      Be specific — "unclear how X works" is not useful. "src/billing/service.ts:88
>      calls createInvoice but the tenant_id param is always undefined — is this a
>      bug or intentional?" is useful.]
>
>     ── WHAT THE PLAN AGENT MUST NOT INVENT ──────────────────
>     [List any gaps in your research where the plan agent might be tempted to fill
>      in from assumptions. Be explicit: "I could not find X — the plan must not
>      assume X exists or works in any particular way."]
>
> ---
>
> **Hard rules:**
> - Every statement about the codebase must trace to a file you read or a search you ran.
>   If you haven't verified it this session, mark it UNKNOWN — never state it as fact.
> - Never describe "how something probably works" — only how it actually works, per the code.
> - Never suggest solutions, architectures, or approaches. That is the plan agent's job.
> - The "What the plan agent must not invent" section is mandatory — leave nothing implicit.
>
> Return message: "Research complete → {OUTPUT_PATH} ({N} files read, {N} open questions)"

---

After all research agents complete:
- If multiple agents ran, read all outputs and merge into `research/merged.md`:
  - Combine all FILES READ, SEARCHES RUN sections (no deduplication — keep everything)
  - Merge CURRENT STATE sections under area headings
  - Consolidate CALL CHAIN entries (cross-area dependencies are especially important)
  - Merge CONVENTIONS OBSERVED (flag any contradictions between areas)
  - Merge REUSE AUDIT entries
  - Consolidate OPEN QUESTIONS — remove duplicates, keep all unique ones
  - Combine "What the plan agent must not invent" sections

Show the user a summary and **resolve every open question before proceeding**:

```
Phase 1 complete
  Files read:       {N} across {N} agents
  Open questions:   {N} (listed below)
  Gaps flagged:     {N} things the plan agent must not invent
```

**All open questions must be resolved before the plan agent starts. No exceptions.**

Present every open question to the user in one numbered list:

```
Before I hand this to the plan agent, I need answers to these open questions
found during research. The plan cannot be written without them.

1. [question from research — be specific, include file:line context]
2. [question]
...

Please answer each one. I'll update the research notes and then start planning.
```

Wait for the user's answers. Do not spawn the plan agent until every question has
a response. Once answered:
1. Append the answers to `research/merged.md` under a new section:
   ```
   ── OPEN QUESTIONS — RESOLVED ────────────────────────────────
   Q1: [question]
   A:  [user's answer]
   ...
   ```
2. Remove the answered items from the "What the plan agent must not invent" section
   if they are now resolved.
3. Confirm to the user:
   ```
   All open questions resolved. Starting Phase 2 — Planning.
   ```

Only then switch modes and spawn the plan agent:

```
✦ cb-agents — phase transition
  Exited:  cb-explore · cb-brainstorm · cb-rubber-duck (research phase complete)
  Entered: cb-plan

All context is in the research report. Planning from evidence only.
```

Write `cb-plan` to `.cb-modes` (remove `cb-explore`, `cb-brainstorm`, `cb-rubber-duck` if present).

---

## Step 3 — Phase 2a: Plan Agent

Spawn ONE plan agent:

> You are a principal engineer writing an implementation plan.
> The research is complete. Read it at:
>   0-cowork/agents/{slug}/outputs/research/merged.md
>   (or agent-1.md if only one research agent ran)
>
> This research report is your ONLY source of truth about the codebase.
> Do not re-investigate. Do not assume anything not stated in the report.
> If something is marked UNKNOWN or listed under "What the plan agent must not
> invent" — flag it in the plan rather than filling it in.
>
> Task context: {TASK_DESCRIPTION}
> Constraints: {INTAKE_NOTES}
>
> Produce a full plan in cb-plan Phase 2 format:
>
>     Plan: {TASK_NAME}
>
>     Follows conventions: [from research Conventions section — be specific]
>     Reuses: [from research Reuse audit — name the exact files/functions]
>
>     [ ] Step 1: [name] — [what and why]
>           Touches: [specific files:functions from research FILES READ]
>           Current behavior here: [from research CURRENT STATE — quote it]
>           Blast radius: [from research CALL CHAIN — name every dependent]
>           Edge cases: [boundaries, nulls, concurrency, missing data]
>           Error handling: [how failures surface — match existing pattern from research]
>           Breaking changes: [API/schema/contract changes; migration needed?]
>
>     [ ] Step N: ...
>
>     Removes / obsoletes: [dead code this change makes redundant]
>     Risks & dependencies: [anything that could block or ripple — from research open questions]
>     Rollback: [how to undo if something goes wrong]
>     Unresolved: [anything marked UNKNOWN in research that affects this plan]
>
> Hard rules:
> - Every Touches and Current behavior entry must cite research report line/section.
> - No new file, function, or utility without a matching reuse audit entry showing
>   you looked for an existing one and didn't find it.
> - No over-engineering. Simplest solution that fully solves the problem.
> - If the research flagged something as "must not invent" — do not invent it.
>   Flag it as a risk or blocker instead.
>
> Save to: 0-cowork/agents/{slug}/outputs/plan.md
> Return: "Plan ready → 0-cowork/agents/{slug}/outputs/plan.md"

---

## Step 4 — Human Gate (mandatory, non-skippable)

Read the plan file. Present it to the user in full.

Then show:

```
─────────────────────────────────────────────────────────
Plan ready. Review the steps above.

  go / cb-workflow / yes   → proceed to execution
  [feedback]               → I'll update the plan and show it again
  cancel                   → stop the pipeline
─────────────────────────────────────────────────────────
```

Do not spawn any agent until the user explicitly approves.

If the user requests changes: send the current plan + requested edits back to
the plan agent, get the updated plan, re-show it, wait for approval again.

---

## Step 5 — Phase 2b: Workflow Agent

Only spawn after explicit user approval. Switch modes immediately on approval:

```
✦ cb-agents — phase transition
  Exited:  cb-plan
  Entered: cb-workflow

Executing approved plan. Evidence gate active — no output, no ✓.
cb-cleanup and cb-prod will run automatically after all steps complete.
```

Update `.cb-modes`: remove `cb-plan`, write `cb-workflow`.

> You are a senior engineer executing an approved plan under cb-workflow discipline.
>
> Read the approved plan at: 0-cowork/agents/{slug}/outputs/plan.md
> Read the research at: 0-cowork/agents/{slug}/outputs/research/merged.md
>
> Execute the plan exactly — do not deviate, do not add steps, do not re-investigate
> what is already in the research report.
>
> Evidence gate (non-negotiable):
> - No output = no ✓. Every step must show the actual command run and its raw output.
> - One step at a time. Do not proceed until the current step is validated.
> - On failure: stop immediately, show the real error, announce any retry.
>   Never mark a failed step ✓. Never retry silently. Never proceed on a failure.
>
> Hard rules: read and apply `commands/_shared-rules.md` (already loaded). Key additions specific to this pipeline: no deviation from the approved plan without flagging; use the research Call Chain section to check callers before modifying shared code; treat research Conventions as the ground truth for naming and patterns.
>
> Step format:
>
>     Step N/T: [name] — [what you'll do]
>       Depends on: [callers from research call chain]
>       ...work...
>       Validation: [exact command run]
>         [raw output]
>       ✓ Done. [what the output confirms]. Next: Step N+1 — [name].
>
> Update [ ] → [✓] in plan.md as each step completes.
>
> After all steps:
> 1. Run cb-cleanup (read commands/cb-cleanup.md) — full 6-step flow.
> 2. Run cb-prod (read commands/cb-prod.md) — full audit.
> 3. Save report to: 0-cowork/agents/{slug}/outputs/workflow-report.md
>
>     ## Workflow Report — {TASK_NAME}
>     **Steps completed:** N/N
>     **Files changed:** [list]
>     **Validation per step:** [pass/fail]
>     **Cleanup result:** [summary]
>     **Prod audit verdict:** [ready / issues found]
>     **Flagged for review:** [things review agents should pay attention to]
>     **Open items:** [deferred, out of scope, or blocked]
>
> Return: "Workflow complete → 0-cowork/agents/{slug}/outputs/workflow-report.md"

Wait for the workflow agent. Read workflow-report.md.

Announce workflow completion and mode exit:

```
✦ cb-agents — phase transition
  Exited:  cb-workflow
  Entered: review phase (cb-pr-review + cb-review-flow — parallel)

Workflow complete. cb-cleanup and cb-prod ran as part of workflow.
```

Update `.cb-modes`: remove `cb-workflow`.

**If prod audit verdict is "issues found (critical)":** stop. Surface the critical
issues to the user. Do not proceed to review until they are resolved or explicitly
accepted by the user.

---

## Step 6 — Phase 3: Review Agents (parallel)

Spawn BOTH agents in ONE message:

**Review Agent A — PR Review:**
> Run a full PR review on the current git diff (git diff HEAD).
> Read for context:
>   - MEMORY.md and CLAUDE.md (project conventions)
>   - 0-cowork/agents/{slug}/outputs/plan.md (intent)
>   - 0-cowork/agents/{slug}/outputs/workflow-report.md (what was flagged)
>
> Review across 5 dimensions:
>   1. Correctness — does it do what the plan intended?
>   2. Edge cases & error handling — are boundaries covered?
>   3. Test coverage — if a test framework exists, are new paths tested?
>   4. Conventions — matches existing project patterns from research?
>   5. Production readiness — no debug leftovers, secrets, missing error handling?
>
> Verdict: "good to merge" / "merge with fixes" / "do not merge"
> Save to: 0-cowork/agents/{slug}/outputs/pr-review.md
> Return: "PR review complete → 0-cowork/agents/{slug}/outputs/pr-review.md"

**Review Agent B — Flow Review:**
> Trace the end-to-end flow through the files listed in workflow-report.md.
> Read for context:
>   - 0-cowork/agents/{slug}/outputs/research/merged.md (original state + call chain)
>   - 0-cowork/agents/{slug}/outputs/plan.md (intended blast radius)
>
> Check:
>   - Are all callers and dependents from the research call chain still intact?
>   - Are types, contracts, and schema still consistent end-to-end?
>   - Any production blockers in the data flow the PR review won't catch?
>   - Integration surfaces, async paths, side effects?
>
> Save to: 0-cowork/agents/{slug}/outputs/review-flow.md
> Return: "Flow review complete → 0-cowork/agents/{slug}/outputs/review-flow.md"

Wait for both. Read both output files.

---

## Step 7 — Synthesis

Produce the final report at 0-cowork/agents/{slug}/outputs/final-report.md:

```
Pipeline Report: {TASK_NAME}
Run: {YYYY-MM-DD} | Folder: 0-cowork/agents/{slug}/outputs/

PHASE 1 — RESEARCH     ✓   {N} files read · {N} agents · {N} open questions
PHASE 2a — PLAN        ✓   {N} steps · approved by user
PHASE 2b — WORKFLOW    ✓/✗  {N}/{N} steps passed · cleanup: {result} · prod: {verdict}
PHASE 3 — PR REVIEW    ✓/✗  {verdict}
PHASE 3 — FLOW REVIEW  ✓/✗  {key finding}

OVERALL VERDICT
  [ready to ship / merge with fixes (list) / blocked — reason]

OPEN ITEMS
  [anything flagged across all phases needing follow-up]

FILES
  Research:     0-cowork/agents/{slug}/outputs/research/merged.md
  Plan:         0-cowork/agents/{slug}/outputs/plan.md
  Workflow:     0-cowork/agents/{slug}/outputs/workflow-report.md
  PR Review:    0-cowork/agents/{slug}/outputs/pr-review.md
  Flow Review:  0-cowork/agents/{slug}/outputs/review-flow.md
```

Append to MEMORY.md and 0-cowork/memory/session_logs.md:

```
## {date} — {task name}
**Worked on:** {one sentence}
**Decisions made:** {non-obvious choices from plan}
**Files changed:** {from workflow report}
**Validation:** {workflow verdict}
**Open items:** {deferred items}
**Watch out for:** {risks flagged by review agents}
**Pipeline outputs:** 0-cowork/agents/{slug}/outputs/
```

---

## When NOT to use this

For tasks touching ≤ 3 files or with a known fix, use `cb-plan → cb-workflow` directly.
This pipeline earns its keep for multi-system features, client-facing work, or any
task where research being wrong would cost more than the time to do it right.
