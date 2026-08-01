# cb-feedback

Log a correction so the agent doesn't repeat the same mistake next session. Reads recent context, drafts a correction rule, shows it for review, then logs on confirmation.

**Usage:**
- `cb-feedback` — infer from recent messages, ask for one-liner to confirm
- `cb-feedback <description>` — use description as the basis, enrich with message context

---

## Phase 1: Draft the correction

Read the last 5–10 messages for context. Ask the user one question:

```
What should I have done differently?
(One line is enough — I'll use it to write the correction rule.)
```

If the user already provided a description in the command (e.g. `cb-feedback you kept adding unrelated files`), skip the question and use that directly.

---

## Phase 2: Show draft — wait for approval

Using the user's description + message context, draft the correction:

```
Correction draft
─────────────────────────────────────────
Don't:  [what the agent did wrong — specific behaviour]
Do:     [correct behaviour — what should have happened]
Why:    [brief context — what task or pattern triggered this]
─────────────────────────────────────────
Edit this or reply "log it" to save.
```

Wait. If the user edits any field, update the draft and show it again. Only proceed to Phase 3 when the user confirms ("log it", "yes", "looks good", or similar).

---

## Phase 3: Log to feedback.md

Append to `0-cowork/memory/feedback.md` (create if missing):

```markdown
# Agent Corrections
<!-- Read this file before starting work. These are confirmed correction rules. -->

## [YYYY-MM-DD] — [3-5 word label summarising the mistake]
Don't:  [exact text from confirmed draft]
Do:     [exact text from confirmed draft]
Why:    [exact text from confirmed draft]
```

If the file already exists, append only the new `## [date]` block — never overwrite existing entries.

---

## Phase 4: Verify MEMORY.md pointer

Read `MEMORY.md`. Check if it contains a reference to `feedback.md` or agent corrections.

**Reference found** — nothing to do.

**Reference missing** — append this block to MEMORY.md:

```markdown
## Agent Corrections
Refer to `0-cowork/memory/feedback.md` before starting work.
This file contains confirmed correction rules from past sessions — read it and apply them.
```

Report: `✓ Pointer added to MEMORY.md` or `✓ Pointer already exists — no change`.

---

## Phase 5: Confirm

```
✓ Feedback logged
  File:    0-cowork/memory/feedback.md
  Entry:   [date] — [label]
  MEMORY.md pointer: ✓ exists / ✓ added

Agent will read this at next session start under "Watch out for".
```

One-shot — after confirmation, resume normal behavior.
