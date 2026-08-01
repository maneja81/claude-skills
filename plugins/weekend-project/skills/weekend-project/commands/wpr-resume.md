# Command: wpr-resume

Resume a paused or interrupted build from the last saved checkpoint.

## Steps

### 1. Read session state

Read `$PROJECT_ROOT/.claude/weekend-project/session.yaml` — the absolute path, not a relative one, in case the shell is inside a worktree. If it doesn't exist or `phase` is null: tell the user there's nothing to resume and offer `wpr-start`.

If a legacy `plan.json` exists and `plans/` does not, run the migration in `references/plan-schema.md` first.

### 1b. Reconcile the plan folders

`session.yaml → current_plan` is authoritative; folder placement is a derived view. Apply the reconciliation rules in `references/plan-schema.md`:

- `current_plan` not in `active/` → move it there
- A stray file in `active/` → return it to `pending/`
- `current_plan` names an ID with no file anywhere → stop and escalate

Report in one line only if something moved.

If `phase: complete` and `current_plan` is null, this is a plan boundary rather than an interrupted build: read `plans/pending/`, pick the next plan whose `depends_on` is satisfied, re-validate it for staleness, and ask before starting it. Do not silently begin a new plan.

### 2. Load memory

Read all files in `.claude/weekend-project/memory/`. Read last 20 entries from `decisions.jsonl`. This is mandatory — do not skip it even if context seems fresh.

### 3. Verify git state

```bash
git status
git branch --show-current
```

Confirm the working tree is clean and on the right branch. If there are uncommitted changes from a prior interrupted run:

```
Found uncommitted changes on [branch]:
  [list of changed files]

Options:
  1. Commit them with message "wip: resuming from interrupted session"
  2. Stash them and start fresh from last commit
  3. Discard them and start the current step over

What would you like to do?
```

Wait for user input before proceeding.

### 4. Resume from exact state

Based on `session.yaml → round_state`:

| State | Resume action |
|---|---|
| `dev-building` | Re-read PR plan + memory, continue Sr. Developer work from last commit |
| `qa-reviewing` | Re-spawn Sr. QA agent for current round |
| `fix-in-progress` | Re-read QA report for current round, continue fix round |
| `merge-gate` | Re-run merge gate (`phases/06-merge-gate.md`) |
| `merged` | Advance to next PR (run post-merge steps if not completed) |
| `escalated` | Surface the escalation issue to user, wait for instruction |

### 5. Announce resumption

```
Resuming build — [project name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Memory loaded: [N] patterns · [N] decisions · [N] QA learnings

Continuing from: PR-[N] · [branch] · [state]
Last checkpoint: [timestamp]

[Brief description of what will happen next]
```

Then continue execution without further prompting.

---

## Context reset recovery

If Claude's context was fully reset (no memory of the project at all), the session.yaml is the source of truth. The resume flow rebuilds full context from:

1. `session.yaml` — where we are, including `current_plan`
2. The active plan, found by globbing `plans/*/[current_plan]-*.json` — what we're building
3. `config.yaml` — project specifics
4. `memory/` — all accumulated knowledge
5. `pr-logs/[current-branch]/` — this PR's history
6. `decisions.jsonl` (last 20) — recent decisions

This is enough to resume any state without human context.
