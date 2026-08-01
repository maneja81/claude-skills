# Command: wpr-review

Work through open decisions and known issues interactively with the user. This is the primary way to resolve blockers and triage deferred issues.

## Steps

### 1. Read both files

Read `open-decisions.md` and `known-issues.md` from the project root.

### 2. Present summary

```
Review session — [project name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Open decisions requiring your input: [N]
AI assumptions to confirm:          [N]
Known issues (deferred):            [N]

I'll work through these in order. Open decisions first — some may be blocking PRs.
```

### 3. Open decisions — Pending Your Input

For each item under `## Pending Your Input` in `open-decisions.md`:

Present one at a time:

```
OD-[N] — Blocks PR-[N]
─────────────────────────────────────
[Question]

Context: [why this decision matters, what it affects]
Options: [A, B, C — with brief tradeoffs]
My recommendation: [which option and why, if there's a clear best choice]

Your choice:
```

Wait for the user's answer. Record it in `open-decisions.md` under `## Resolved`. Update `decisions.jsonl` with the decision and rationale. If the decision unblocks a PR, note that.

### 4. AI assumptions — for confirmation

For each item under `## AI Assumptions`:

Present concisely:

```
AS-[N] — [assumption summary]
PR: [branch]
I assumed: [what was assumed]
Because: [rationale]

Is this correct, or should I revisit it?
```

If the user says it's wrong: create a note to revisit the affected PR. Append to `open-decisions.md` under `## Pending Revisit`.

### 5. Known issues triage

For each item in `known-issues.md` under `## Active`:

Present:

```
KI-[N] — [severity] — [title]
From: [branch]
Description: [details]

Options:
  1. Fix now — I'll add this to the backlog PR
  2. Defer to a future build cycle
  3. Won't fix — explain why in known-issues.md
```

Handle the response and update `known-issues.md` accordingly.

### 6. Completion

After working through all items:

```
Review complete.
  Decisions resolved: [N]
  Issues triaged: [N]
  Assumptions confirmed: [N]
  Items deferred: [N]

[If any blocking decisions were resolved]:
  PR-[N] is now unblocked. Resume execution? (yes / no)
```

If execution is active and a blocking decision was just resolved, offer to continue with `wpr-resume`.
