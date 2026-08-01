# cb-mark-pending

Parks an in-progress or blocked item from the current session into a structured file under `0-cowork/plans/pending/`. Creates a self-contained handoff document so the next session can resume without re-investigating from scratch.

**Usage:**
- `cb-mark-pending` — park the current task
- `cb-mark-pending authentication flow` — park a specific named item from this session

One item per run. For multiple items, run the command once per item.

---

## Step 1: Identify the item

If a name or description was provided in the command, use that. If not, ask: "Which specific item from this session should I park? Give me a short name or description."

Do not guess or infer — the user must confirm what is being parked.

---

## Step 2: Gather session context (silent)

Pull from session memory — do not re-read files already in context:

- What was the original task or goal?
- What commands ran this session (cb-plan, cb-workflow, cb-fix, etc.)?
- Which files were read or changed?
- What decisions were made and why?
- What was confirmed from the codebase (evidence gathered)?
- What was the last action taken before parking?
- What's left to do?
- What is unknown or unresolved?
- What needs to be tested or verified on resume?

---

## Step 3: Generate filename

Format: `YYYY-MM-DD-{slug}.md`

Slug rules: lowercase, hyphens only, max 6 words, derived from the item name. Examples:
- "google sheets upload integration" → `2026-07-09-google-sheets-upload-integration.md`
- "fix null pointer in roster controller" → `2026-07-09-fix-null-pointer-roster-controller.md`
- "auth token refresh investigation" → `2026-07-09-auth-token-refresh-investigation.md`

---

## Step 4: Write the pending file

Create `0-cowork/plans/pending/{filename}.md`. Create the folder path if it doesn't exist.

File structure (render as plain markdown):

---

# [Item name]

**Status:** Pending
**Parked:** [date and time]
**Session commands used:** [e.g. cb-plan, cb-workflow — steps 1–3 complete]
**Resume with:** [suggested command — e.g. `cb-workflow` to continue execution, `cb-fix` to apply confirmed fix, `cb-plan` to re-plan after new findings]

---

## What This Is

[Original goal and problem — enough for someone cold to understand it immediately.]

---

## Current State

**Done:**
- [Completed step or finding — file:line where relevant]

**Not done:**
- [What still needs to happen]

**Blocked by:** [blocker, or "Nothing — paused intentionally"]

---

## Research Gathered

**Files read:**
- `[file:line-range]` — [what it confirmed]

**Key findings:**
- [Finding — file:line]

**Decisions made:**
- [Decision] — because [reason]

**Reuse identified:**
- [Existing code] — `[file:line]`

If nothing researched: "No codebase research this session — start with discovery."

---

## What Needs to Happen Next

1. [Step — specific action, file to edit, function to change]
2. [...]

---

## Open Questions

- [Question] — [what it blocks]

Omit if none.

---

## Things to Test on Resume

- [ ] [Scenario — what to do and expected result]

Include: happy path, one edge case, one regression check.

---

## Relevant Files

| File | Why relevant |
|---|---|
| `[path]` | [what matters here] |

---

## Risks and Watch-outs

- [Risk] — [what to watch for]

Omit if none.

---

## Step 5: Append to session log

Append a one-line entry to `0-cowork/memory/session_logs.md`:

`[date] — PENDING: [item name] → 0-cowork/plans/pending/[filename].md`

---

## Step 6: Confirm

Report (plain markdown):

**Parked:** [item name]
**File:** `0-cowork/plans/pending/[filename].md`
**Resume with:** `[suggested command]`

To resume: open the file, read the "What Needs to Happen Next" section, then run the suggested command.
