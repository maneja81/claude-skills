# cb-load

Loads all persistent context — memory, correction rules, and project index — so the
agent is fully briefed before the first task of the session. Fast, silent, and
structured. Produces a compact briefing the agent keeps active for the session.

Run automatically by `/code-better` session start. Also run standalone at the top of
any session when you want the agent fully primed without going through the full
`/code-better` flow.

---

## Step 1 — Load files (in this order)

Read each file if it exists. Note missing files but do not block — continue loading
what is available. **Total file reads in this step: 4 maximum** (feedback, MEMORY,
session_logs, index). Do not read additional files unless the user explicitly asks.

1. **`0-cowork/memory/feedback.md`** — agent correction rules
   Read every rule. Apply all of them silently for the rest of the session.
   These are logged past mistakes — treat them as hard constraints, not suggestions.
   **Guard:** if feedback.md was already read in Step 1 of the `/code-better` session
   start (i.e. this is the integrated load, not a standalone `cb-load` call), skip
   this read — rules are already active. Only read it once per session.

2. **`MEMORY.md`** — session memory
   Read fully. Extract: decisions made, open items, watch-outs, files changed in
   recent sessions.

3. **`0-cowork/memory/session_logs.md`** — session history
   **Read the last 80 lines only** (use tail offset — do not load the full file).
   session_logs.md is append-only and can be very long. Extract the last 3 entries
   from those 80 lines.

4. **`0-cowork/index.md`** — project index
   Read fully. Extract: what projects exist, what agent runs exist, what memory files
   are present.
   If missing: note "Index not found — run `cb-index` to generate it."
   If last-modified date is older than 7 days: note "⚠ Index may be stale — consider
   running `cb-index` to refresh."

**Do not read any other files in `0-cowork/memory/`** during session load. The index
already lists what files are there. If the user needs content from a specific knowledge
file (e.g. architecture.md), read it on demand when relevant to the task.

---

## Step 2 — Produce session briefing

Output a compact briefing. Keep it scannable — no walls of text.

```
Session Briefing
────────────────────────────────────────────────

CORRECTIONS ACTIVE  ({N} rules from feedback.md)
  ⚑ {rule 1 — one line}
  ⚑ {rule 2}
  ...
  (If none: "None — feedback.md not found or empty")

RECENT WORK  (from session_logs.md — last 3 entries)
  {date} — {task name}
    Worked on: {one line}
    Open items: {if any}
    Watch out for: {if any}

KEY DECISIONS  (from MEMORY.md — skip resolved/stale, only what affects next task)
  · {non-obvious decision still relevant — one line}
  · {decision}

OPEN ITEMS  (from MEMORY.md + session_logs.md)
  ⚠ {unresolved item — file or area — one line}
  (If none: "None flagged")

PROJECT INDEX
  Projects:    {count} — {comma-separated project folder names}
  Agent runs:  {count} — {most recent slug if any}
  Index file:  ✓ current  /  ⚠ stale ({date})  /  ✗ missing

ACTIVE MODES  (from .cb-modes)
  {mode} · {mode}  /  none
  (If any write-mode command is active alongside cb-read-only, show it as "(report-only)")

────────────────────────────────────────────────
Ready. What would you like to work on?
```

---

## Step 3 — Stay loaded for the session

All rules from feedback.md remain active for the entire session — not just the
current response. If context is compacted, re-read feedback.md before the next
task (it is small and fast to load).

The briefing is shown once. Do not repeat it unless the user asks (`cb-load` again
re-runs the full flow and shows a fresh briefing).

---

## Integration with `/code-better` session start

`/code-better` calls `cb-load` automatically as part of Step 2. The briefing above
replaces the old memory-only summary — it covers correction rules, recent work,
key decisions, open items, and project index in one pass.

**Token budget for the integrated load (SKILL.md Step 1 + cb-load Step 2 combined):**
- Files read: feedback.md + MEMORY.md + last 80 lines of session_logs.md + index.md = 4 files max
- No additional memory files unless user requests them
- Help menu: not shown; replaced with the single line "Type `cb-help` to see all 44 commands."

If `/code-better` fast-path is triggered (user opens with a command + task), `cb-load`
still runs silently (feedback rules applied, index noted) but the briefing block is
suppressed — the agent goes straight to the task.
