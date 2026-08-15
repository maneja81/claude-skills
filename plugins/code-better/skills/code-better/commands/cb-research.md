# cb-research

Read `commands/_shared-rules.md` if not already loaded this session.

Deep, uncapped research on a specific ask. No file limit, no "pattern is clear, stop here" — the goal is a research report thorough enough that nothing downstream (a plan, a fix, a feature) misses an edge case or breaks existing functionality because something wasn't checked. One-shot, read-only. Produces a persisted report; does not plan, does not write code.

Sits alongside `cb-spec` / `cb-impact` / `cb-estimate` as pre-work — it does not auto-chain into `cb-plan`. The user decides when to move forward.

**Usage:**
- `cb-research <ask>` — e.g. `cb-research add tenant isolation to the billing module`
- `cb-research <ask> --path <folder>` — scope the sweep to a specific area

**Difference from other commands:**
- `cb-explore` maps a whole project generically, capped at 10 files. `cb-research` is ask-driven and uncapped.
- `cb-plan` Phase 1 discovery is capped at 10 files and stops once the pattern is clear. `cb-research` is the version with no cap, for asks where missing something would be costly.
- `cb-agents` Phase 1 is this same rigor already spent — if you're about to run `cb-agents`, running `cb-research` first is redundant. Use `cb-research` standalone when you want the report without committing to the full pipeline (intake, approval gate, workflow agent, review agents).

---

## Step 0: Scope check

Restate the ask in one sentence to confirm understanding. If it spans multiple clearly independent subsystems (e.g. "research auth, billing, and reporting changes"), say so and ask whether to research them separately — one `cb-research` run per subsystem produces a cleaner report than one run trying to cover all of them.

If a `--path` was given, scope to it. Otherwise infer the likely codebase area(s) from the ask and confirm before starting if it's not obvious.

---

## Step 1: Decide single-pass or fan-out

Default to a single linear pass. Only fan out into parallel research agents when the ask genuinely spans 2 or more distinct, loosely-coupled areas of the codebase (e.g. "add audit logging to billing, auth, and the admin API" — three separate modules, not three files in one module). If unsure, default to single-pass — fan-out adds coordination overhead that isn't worth it for a single-area ask.

**Single-pass:** proceed to Step 2 directly.

**Fan-out:** spawn one research agent per area, all in one message (parallel). Each agent follows Steps 2–7 below scoped to its assigned area, using the exact prompt template in `commands/cb-agents.md` under "Research Agent prompt" (reuse it verbatim — do not fork a second copy of this prompt to maintain). After all agents complete, merge their reports using the same merge procedure `cb-agents` uses after its Phase 1 (combine Files Read / Searches Run without dedup, merge Current State under area headings, consolidate Call Chain entries, merge Conventions flagging contradictions, merge Reuse Audit, dedup Open Questions, combine "must not invent" sections). Then continue to Step 8 with the merged report.

---

## Step 2: Load memory first

Read `MEMORY.md`, `0-cowork/memory/feedback.md`, and `0-cowork/memory/known-issues.md` if it exists. Read `0-cowork/index.md` to see what knowledge files exist, then read only the ones relevant to this ask (do not scan all of `0-cowork/memory/`). Extract: prior decisions relevant to this area, known pitfalls, conventions already documented, anything already logged as a known issue that overlaps with this ask.

Skip re-reading `feedback.md`/`MEMORY.md` if `cb-load` already ran this session and loaded them — use what's already in context.

---

## Step 3: Map the terrain, then search before reading

Do not open files by guessing. First:
- List the relevant directory tree (2–3 levels) to see what exists
- Grep for entry points into this area (routes, exports, CLI commands, event handlers)
- Grep for the key symbols, functions, types, or error messages central to the ask
- Grep for how similar problems are already solved elsewhere in the codebase

Build a ranked list of files to read from the search results — highest signal first. This step does not count against anything; it's how the read list gets built, not a substitute for reading.

---

## Step 4: Read everything in the change surface — no cap

Unlike `cb-explore` and `cb-plan`'s discovery, there is no file limit and no early stop once "the pattern is clear." Read:

- **Every file directly in the change surface** — in full, not excerpted
- **Every direct caller and dependent** of anything that will change — in full if central, first 80 lines + targeted grep of the relevant section if it's a large peripheral file
- **Every test file covering this area** — to know what's already verified and what isn't
- **2–3 sibling files** outside the change surface, purely to confirm conventions (naming, error handling, module boundaries)

If a file is genuinely enormous (1000+ lines) and only tangential, read enough to confirm it's tangential, then note what was skipped and why — never skip silently. "This file is out of scope because X" is fine. Silence is not.

There is no target file count for this command. Stop reading only when you can trace the full flow end-to-end from evidence you've actually read, not before.

---

## Step 5: Trace the full call chain and blast radius

For every function, type, route, or schema the ask touches:
- Who calls it — every caller, at least 2 levels deep, not just direct callers
- What it calls — dependencies, services, DB queries, external APIs
- What data flows through it — request/response shape, DB schema, contracts
- What currently depends on its exact current behavior (not just "is called by," but "would break if the behavior changed")

This is the section that answers "what will break" — treat it as the most important output of this command. Be exhaustive here even if other sections are lighter.

---

## Step 6: Edge cases — checked against real code, not listed generically

For the actual code read in Step 4, check each of these explicitly and state what the code actually does — not what it should do:

- Null / undefined / missing input — handled, or will it throw?
- Empty array / zero rows / empty string — degrades gracefully or breaks?
- Max values, large payloads, pagination boundaries
- Concurrent access / race conditions — any unguarded shared state?
- Auth / permission boundaries — who can currently reach this, and does the ask change that?
- Async errors — are they awaited and propagated, or can they be silently swallowed?
- Missing env/config — would this break in a fresh environment?
- Any edge case already flagged in `known-issues.md` that overlaps this area

Report each as: `[edge case] — [file:line] — [what the code actually does today]`. If genuinely not applicable, say so briefly rather than omitting the row.

---

## Step 7: Reuse audit and conventions

**Reuse audit** — for every capability the ask will require, document the search performed and its result: reuse existing / extend existing / create new, with the reasoning. "I didn't look" is never valid — show the search.

**Conventions observed** — naming, error handling pattern, how new functionality is normally added in this codebase, test conventions, import/module style. Pull this from the sibling files read in Step 4, not from assumption.

---

## Step 8: Report

Save to `0-cowork/memory/research/{YYYY-MM-DD}-{slug}.md` (create the folder if missing) and show the full report in the reply. Render as plain markdown, not a code block.

```
Research Report — [ask, one line]
Scope: [path or inferred area(s)]
Mode: single-pass / fan-out ([N] agents merged)

── MEMORY & PRIOR CONTEXT ───────────────────────────────
Prior decisions relevant to this ask: [from MEMORY.md — quote, don't paraphrase]
Known pitfalls: [from feedback.md]
Overlapping known issues: [from known-issues.md, with KI-N reference, or "none found"]

── FILES READ ───────────────────────────────────────────
[file path : line range — every file actually opened, no omissions, no cap]

── SEARCHES RUN ─────────────────────────────────────────
[what was grepped/searched → what was found or "nothing found"]

── CURRENT STATE ────────────────────────────────────────
Entry point(s): [where this is triggered]
Core logic: [the real flow, file:line references throughout]
Data flow: [what goes in, what comes out, what gets persisted]
Exit points: [what this returns/emits and who receives it]

── CALL CHAIN & BLAST RADIUS ────────────────────────────
Callers (2+ levels deep): [caller — file:line]
Dependencies: [what this calls — file:line]
Schema / types / contracts involved: [file:line]
If this changes, these break: [dependent — exact reason — file:line]

── EDGE CASES CHECKED ───────────────────────────────────
[edge case] — [file:line] — [what the code actually does today]
... (every row from Step 6)

── WHAT WILL BREAK IF THIS IS BUILT NAIVELY ─────────────
[Ranked by severity — ⛔/⚠/· from _shared-rules.md. Each entry: existing behavior — why the naive approach breaks it — file:line.]

── CONVENTIONS OBSERVED ─────────────────────────────────
Naming & structure: [...]
Error handling pattern: [...]
How new code is normally added: [...]
Test conventions: [...]

── REUSE AUDIT ──────────────────────────────────────────
Need: [capability] — Searched: [what/where] — Found: [existing code, file:line, or "nothing found"] — Decision: reuse/extend/create new — because [reason]

── TEST COVERAGE TODAY ──────────────────────────────────
[What's already tested in this area, what isn't — file:line to test files]

── OPEN QUESTIONS ───────────────────────────────────────
[Anything genuinely ambiguous that must be resolved before planning. Specific, not vague — "unclear how X works" is not useful; "src/billing/service.ts:88 calls createInvoice with tenant_id always undefined — bug or intentional?" is.]

── WHAT MUST NOT BE INVENTED ────────────────────────────
[Every gap where a plan might be tempted to assume instead of verify. Be explicit — "X was not found; do not assume it exists or behaves any particular way."]
```

---

## Step 9: Summary and next step

```
cb-research complete
  Ask: [one line]
  Files read: [N] (no cap applied)
  Blast radius: [N] callers/dependents traced
  Edge cases checked: [N]
  Breakage risks found: [N] ⛔ / [N] ⚠ / [N] ·
  Open questions: [N]
  Saved to: 0-cowork/memory/research/[filename].md

Next: cb-plan will use this report as grounding for discovery — or resolve the open questions above first if any remain.
```

If open questions exist, list them plainly before the summary and suggest resolving them now rather than letting `cb-plan` inherit them unresolved.

---

## Hard rules

- No file cap, no early stop on "pattern is clear" — this command exists specifically because other research steps have caps and this one shouldn't.
- Every claim about the codebase traces to a file actually read or a search actually run this session. Mark `UNKNOWN` rather than infer.
- Never skip a file silently — if something is out of reach or genuinely out of scope, say so explicitly (see Step 4).
- The "What will break if built naively" and "What must not be invented" sections are mandatory, never omitted for brevity.
- This command does not write a plan and does not touch code. If asked to also plan, suggest running `cb-plan` next — it will read the saved report from Step 8 as grounding.

---

## Auto-enable / Auto-exit

On activation, auto-enable `cb-read-only` and `cb-thorough` (same as `cb-explore`/`cb-debug`). Auto-exit `cb-workflow`, `cb-feature`, `cb-fix`, `cb-brainstorm`. Announce: `✦ cb-research on — enabled: cb-read-only, cb-thorough — exited: [list]`
