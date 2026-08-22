---
name: code-better
description: >
  Activates behavioral mode shortcuts when the user types slash commands at the
  start of a message or on their own. ALWAYS use this skill when you see any of
  these at the start of a user message: /code-better, /cb-read-only, /cb-workflow,
  /cb-brainstorm, /cb-plan, /cb-minimal, /cb-explain, /cb-debug, /cb-fix,
  /cb-rubber-duck, /cb-scope, /cb-summarize, /cb-careful, /cb-fast, /cb-context,
  /cb-remember, /cb-reset, /cb-cleanup, /cb-review-flow, /cb-feature, /cb-help,
  /cb-enhance, /cb-prod, /cb-explore, /cb-thorough, /cb-ask, /cb-verify,
  /cb-estimate, /cb-validate-data, /cb-setup, /cb-spec, /cb-impact, /cb-poc,
  /cb-pr-review, /cb-feedback, /cb-mark-pending, /cb-refresh, /cb-agents,
  /cb-index, /cb-load, /cb-debate, /cb-tidy, /cb-ship, /cb-audit, /cb-research, /cb-trace, or bare names without the slash.
  44 commands total. Session-persistent and stackable — once set, stay active
  until cb-reset. Never ignore these commands even if they appear alongside
  other instructions.
---

# code-better — Behavioral Mode Shortcuts

## How this skill is organised

The SKILL.md file (this file) handles routing, mode management, and session start.
Commands are lazy-loaded from the `commands/` folder when first invoked — they are
not read upfront. Only load a command file when that command is actually activated.

Command → file mapping:

| Command | File |
|---|---|
| `cb-workflow` | `commands/cb-workflow.md` |
| `cb-brainstorm` | `commands/cb-brainstorm.md` |
| `cb-plan` | `commands/cb-plan.md` |
| `cb-fix` | `commands/cb-fix.md` |
| `cb-cleanup` | `commands/cb-cleanup.md` |
| `cb-review-flow` | `commands/cb-review-flow.md` |
| `cb-pr-review` | `commands/cb-pr-review.md` |
| `cb-prod` | `commands/cb-prod.md` |
| `cb-audit` | `commands/cb-audit.md` |
| `cb-feature` | `commands/cb-feature.md` |
| `cb-poc` | `commands/cb-poc.md` |
| `cb-enhance` | `commands/cb-enhance.md` |
| `cb-spec` | `commands/cb-spec.md` |
| `cb-impact` | `commands/cb-impact.md` |
| `cb-estimate` | `commands/cb-estimate.md` |
| `cb-validate-data` | `commands/cb-validate-data.md` |
| `cb-explore` | `commands/cb-explore.md` |
| `cb-trace` | `commands/cb-trace.md` |
| `cb-research` | `commands/cb-research.md` |
| `cb-debate` | `commands/cb-debate.md` |
| `cb-debug` | `commands/cb-debug.md` |
| `cb-thorough` | `commands/cb-thorough.md` |
| `cb-ask` | `commands/cb-ask.md` |
| `cb-context` | `commands/cb-context.md` |
| `cb-verify` | `commands/cb-verify.md` |
| `cb-agents` | `commands/cb-agents.md` |
| `cb-index` | `commands/cb-index.md` |
| `cb-load` | `commands/cb-load.md` |
| `cb-mark-pending` | `commands/cb-mark-pending.md` |
| `cb-tidy` | `commands/cb-tidy.md` |
| `cb-remember` | `commands/cb-remember.md` |
| `cb-feedback` | `commands/cb-feedback.md` |
| `cb-setup` | `commands/cb-setup.md` |
| `cb-refresh` | `commands/cb-refresh.md` |
| `cb-help` | `commands/cb-help.md` |
| `cb-ship` | `commands/cb-ship.md` |

Shared rules (engineering hard rules, severity levels, production checklist, irreversible-action list): `commands/_shared-rules.md`

All other commands are defined inline below — no extra reads needed.

---

## Subagent stop

If you were dispatched as a subagent inside a `cb-agents` pipeline, skip the session start flow entirely — no cb-load, no setup checks, no mode confirmation prompt. Go directly to the assigned task. Session state is managed by the orchestrator, not by each subagent.

---

## Command recognition

Commands use the `cb-` prefix. All valid activation forms:
- `/code-better cb-read-only look at my auth code`
- `cb-read-only look at my auth code`
- `/cb-read-only look at my auth code`

**Invocation vs reference — critical distinction:** only activate when a command name is the **leading directive token** of the message (possibly preceded only by `/code-better`). A command name appearing mid-sentence, in a question, or in quoted text is a *reference*, not an invocation — do not activate.

Examples that must NOT activate:
- "should I use cb-fast here?"
- "what does cb-cleanup do?"
- "we discussed cb-read-only earlier"
- "let's not use cb-workflow for this"

**Input normalisation:** commands are lowercase with hyphens. `CB-Fast`, `cb_fast`, and `cbfast` are not recognised — do not activate on these forms.

**Red flags — rationalizations that mean STOP and use the right command:**

| Thought | Reality |
|---|---|
| "This is just a quick fix" | That's cb-fix. Activate it — quick fixes become scope creep without it. |
| "Let me explore the codebase first" | That IS cb-explore. Activate it before starting. |
| "I know what needs to be done" | That's not a plan. Run cb-plan — knowing isn't the same as a verified, approved plan. |
| "I'll just start, it's straightforward" | cb-workflow exists for this. Use it. |
| "I'll figure out the approach as I go" | That's cb-brainstorm. Run it before committing to a direction. |
| "The command files are already loaded" | Skills evolve mid-session. Run cb-refresh if updates were applied this session. |
| "This doesn't need cb-prod, it's a small change" | Small changes break prod too. Run cb-prod after every step. |
| "I'll clean up later" | Later never comes. cb-cleanup is part of the workflow, not optional. |

**Unknown `cb-*` command:** if the user types a `cb-` prefixed word that isn't in the canonical list, respond: "Unknown command — did you mean [closest match]? Type `cb-help` to see all commands."

**Canonical command names:** `cb-read-only`, `cb-workflow`, `cb-brainstorm`, `cb-plan`, `cb-minimal`, `cb-explain`, `cb-debug`, `cb-fix`, `cb-rubber-duck`, `cb-scope`, `cb-careful`, `cb-fast`, `cb-context`, `cb-remember`, `cb-verify`, `cb-reset`, `cb-cleanup`, `cb-review-flow`, `cb-feature`, `cb-help`, `cb-enhance`, `cb-prod`, `cb-explore`, `cb-thorough`, `cb-ask`, `cb-estimate`, `cb-validate-data`, `cb-setup`, `cb-spec`, `cb-impact`, `cb-poc`, `cb-pr-review`, `cb-feedback`, `cb-mark-pending`, `cb-refresh`, `cb-agents`, `cb-index`, `cb-load`, `cb-debate`, `cb-tidy`, `cb-ship`, `cb-audit`, `cb-research`, `cb-trace`.

**Alias:** `cb-summarize` → `cb-scope` (merged; both trigger the same behavior).

---

## Mode persistence — in-memory only

Modes are tracked in-memory for the current session only. No file is written. This means:
- Multiple sessions on the same project never interfere with each other
- If context compacts, active modes may be lost — see the compaction recovery rule below

**Migration:** if a `.cb-modes` file exists in the project, delete it silently on first encounter and do not recreate it.

Rules:
1. **On activation** of any persistent mode, hold it in memory for this session. If `cb-read-only` is active and a write-mode command is invoked (`cb-workflow`, `cb-feature`, `cb-fix`, `cb-cleanup`, `cb-poc`, `cb-enhance`, `cb-remember`, `cb-feedback`, `cb-mark-pending`): run it report-only for this invocation only. Do not clear `cb-read-only` unless the user explicitly switches modes (auto-exit confirmation still applies).
2. **One-shot commands** (`cb-context`, `cb-scope`, `cb-remember`, `cb-reset`, `cb-verify`, `cb-prod`, `cb-estimate`, `cb-validate-data`, `cb-fix`, `cb-spec`, `cb-impact`, `cb-setup`, `cb-cleanup`, `cb-review-flow`, `cb-audit`, `cb-research`, `cb-trace`) are never persisted — they run and return to prior state.
3. **`cb-reset`** clears all in-memory modes.
4. **Compaction recovery:** if mid-session you have no memory of any active modes but the user references one, ask once: "It looks like I may have lost track of active modes after context compaction. Which modes should be active? I'll re-enable them now."

**Session start — mode confirmation:** at the start of every session, if no modes are in memory, include this prompt in the briefing:

> Any modes to activate for this session? (e.g. cb-careful, cb-read-only, cb-workflow — or skip if starting fresh)

---

## Mode behavior

- **Session-persistent**: once activated, stays active until `cb-reset`
- **Stackable**: multiple modes active at once (e.g. `cb-workflow cb-careful`)
- **Announced**: confirm activation at top of reply (e.g. "✦ cb-read-only mode on")
- **Phase-aware**: certain commands auto-exit incompatible modes (see Auto-exit Rules below)

Status bar — show at start of every response while modes are active:
`[modes: cb-read-only · cb-workflow]`

If `cb-read-only` is active and a write-mode command is running report-only:
`[modes: cb-read-only · cb-workflow (report-only)]`

**Proactive memory:** after a major decision or completed workflow phase, offer once per session: "Worth saving to memory? (`cb-remember`)"

**Non-negotiable:** `cb-fast` never skips `cb-verify` gates, plan approval, or irreversible-action confirmations. `cb-fast` suppresses the status bar — all active modes remain in effect.

**Stacking precedence:**

1. **Safety modes beat action modes.** `cb-read-only` and `cb-careful` always win over any command that writes files.
2. **Speed modes never override safety or correctness.** `cb-fast` compresses output — it does not bypass `cb-read-only`, `cb-careful`, `cb-verify`, or plan approval.
3. **Whenever `cb-read-only` is active alongside a write-mode command** — downgrade to report-only: describe changes, produce a diff to `0-cowork/scratch/`, make no actual edits. Announce: "✦ cb-read-only active — running [command] in report-only mode."
4. **`cb-fast` + `cb-careful` together:** compress to one-line confirmations ("⚠ This deletes the table — confirm?") but never skip them.

---

## Auto-exit rules

When a command starts, automatically exit incompatible modes. Announce in one line: `✦ cb-workflow on — exited: cb-plan, cb-read-only, cb-thorough`

**Special case — auto-exiting `cb-read-only`:** when an execution command (cb-workflow, cb-feature, cb-fix, cb-poc, cb-enhance) auto-exits cb-read-only, announce and confirm: "✦ cb-workflow on — exiting cb-read-only (switching to execution mode). Confirm?" This is the one auto-exit that requires confirmation.

| Command started | Auto-exits |
|---|---|
| `cb-plan` | `cb-workflow`, `cb-feature`, `cb-fix`, `cb-poc`, `cb-enhance`, `cb-explore`, `cb-brainstorm`, `cb-rubber-duck` |
| `cb-explore` | `cb-workflow`, `cb-feature`, `cb-fix`, `cb-brainstorm` |
| `cb-research` | `cb-workflow`, `cb-feature`, `cb-fix`, `cb-brainstorm` |
| `cb-trace` | `cb-workflow`, `cb-feature`, `cb-fix`, `cb-brainstorm` |
| `cb-debug` | `cb-workflow`, `cb-feature`, `cb-fix` |
| `cb-scope` / `cb-spec` / `cb-impact` / `cb-review-flow` / `cb-pr-review` | `cb-workflow`, `cb-feature`, `cb-fix` |
| `cb-workflow` | `cb-read-only`, `cb-plan`, `cb-thorough`, `cb-explore`, `cb-debug`, `cb-brainstorm`, `cb-rubber-duck` |
| `cb-feature` | `cb-read-only`, `cb-plan`, `cb-thorough`, `cb-explore`, `cb-debug`, `cb-brainstorm`, `cb-rubber-duck`, `cb-workflow` |
| `cb-fix` | `cb-read-only`, `cb-plan`, `cb-thorough`, `cb-explore`, `cb-debug`, `cb-brainstorm` |
| `cb-poc` | `cb-read-only`, `cb-careful` |
| `cb-enhance` | `cb-read-only`, `cb-plan` |
| `cb-brainstorm` | `cb-workflow`, `cb-feature`, `cb-fix` |
| `cb-rubber-duck` | `cb-workflow`, `cb-feature` |
| `cb-cleanup` | `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan` |
| `cb-prod` | `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan` |
| `cb-audit` | `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan` |
| `cb-fast` | `cb-thorough`, `cb-careful` |
| `cb-thorough` | `cb-fast` |

Note: one-shot commands (`cb-cleanup`, `cb-review-flow`, `cb-prod`, `cb-scope`, `cb-spec`, `cb-impact`, `cb-audit`, `cb-research`, `cb-trace`) still trigger their auto-exit rules on invocation.

**Never auto-exit** — always-on modifiers that survive phase changes:
`cb-explain`, `cb-minimal`, `cb-ask`

---

## Auto-enable rules

When a command starts, automatically enable matching modes. Announce in the same line as exits: `✦ cb-plan on — enabled: cb-read-only, cb-thorough`

Only enable if not already active.

| Command started | Auto-enables |
|---|---|
| `cb-plan` | `cb-read-only`, `cb-thorough` |
| `cb-explore` | `cb-read-only`, `cb-thorough` |
| `cb-research` | `cb-read-only`, `cb-thorough` |
| `cb-trace` | `cb-read-only`, `cb-thorough` |
| `cb-debug` | `cb-read-only`, `cb-thorough` |
| `cb-scope` / `cb-spec` / `cb-impact` / `cb-review-flow` / `cb-pr-review` / `cb-audit` | `cb-read-only` |
| `cb-workflow` | `cb-careful` |
| `cb-feature` | `cb-careful` |
| `cb-fix` | `cb-careful` |
| `cb-enhance` | `cb-careful` |

---

## Session start — `/code-better` or no recognised command

**Fast-path:** If the opening message contains a specific command **and** a task (e.g. `cb-read-only check my auth code`), skip Steps 2–3. Do Step 1 silently, run `cb-load` silently, then execute the command. Use the full flow only when `/code-better` is typed alone or no recognized command is present.

Run all steps in order without asking first.

**Step 1: Setup check (silent read)**

Check all three:
1. **CLAUDE.md** — exists and non-empty?
2. **MEMORY.md** — exists? (blank is fine)
3. **0-cowork/memory/** — folder exists?

If a legacy `.cb-modes` file exists, delete it silently.

Note whether `0-cowork/memory/feedback.md` exists — **do NOT read it here**; `cb-load` reads it in Step 2.

Show status block:
```
Setup Status
  CLAUDE.md          ✓ found  /  ✗ missing  /  ⚠ found but empty
  MEMORY.md          ✓ found  /  ✗ missing
  0-cowork/memory/   ✓ found  /  ✗ missing
  Agent corrections  ✓ active (feedback.md found)  /  – none
  Active modes       [modes in memory this session]  /  none
```

**Step 1b: Setup offer (only if anything is missing)**

```
Some setup items are missing. Run cb-setup to fix this automatically?
It will: analyze the codebase → generate CLAUDE.md → create MEMORY.md → create 0-cowork/memory/
```
Wait for response. If yes, run `cb-setup`, then continue.

**Step 2: Context load (always run)**

Run `cb-load` (read `commands/cb-load.md`). Reads feedback.md, MEMORY.md, session_logs.md (last 80 lines), and 0-cowork/index.md in one pass — produces a structured briefing.

**Step 3: Ask what to work on**

End with:
```
What would you like to work on this session?
Type `cb-help` to see all 44 commands.
```

---

## `cb-help`

Read `commands/cb-help.md` and render the menu. No setup checks, no memory briefing.

---

## Inline commands

### `cb-read-only`
Never create, edit, delete, or move files without explicit user approval in that message.

Read files and run read-only shell commands freely. **Exception:** may write to `0-cowork/scratch/` or `/tmp` to generate diff/patch files for review. If a real file change is needed, describe it and ask: "OK to apply?"

**Shell command safety:** commands that look passive can mutate state — `npm install`, `git stash`, `git checkout`, `git clean`, `pip install`, `docker pull` all have side effects. If a shell command's side effects are unclear, treat it as a write: describe what it would do and ask before running.

---

### `cb-minimal`
Make the smallest change that satisfies the request. No abstractions "for future flexibility." If you notice something worth fixing separately, mention it at the end — don't do it.

Scope boundary: only touch the function/component directly responsible for the requested behavior.

**Workaround disclosure:** if the minimal fix is a workaround rather than a root-cause fix, say so and name the root cause in one line.

---

### `cb-explain`
Narrate what you're doing as you go. Before each tool call: one sentence on why. After: one sentence on what it produced.

For repetitive actions in a sequence, narrate the first instance fully, then compress: "...same for [list]"

---

### `cb-rubber-duck`
Listen mode. Ask one focused question at a time. Only suggest a solution when explicitly asked or after the full problem is talked through.

After 3 questions, if the user seems stuck: "Want me to switch to cb-brainstorm and suggest directions, or keep working through it together?"

---

### `cb-scope` (alias: `cb-summarize`)
Before starting, restate understanding in 2–4 sentences, then explicitly state in/out of scope. Wait for confirmation before proceeding.

Format (plain markdown, not a code block):

**Understanding:** [2–4 sentences]
**In scope:** [list]
**Out of scope:** [list]
**Assumptions:** [any]

---

### `cb-careful`
Flag every assumption. Before any irreversible action, call it out and ask for confirmation. The irreversible-actions list is in `commands/_shared-rules.md`.

**Prefer dry-runs:** where available (`--dry-run`, `terraform plan`, migration preview), run it first.

---

### `cb-fast`
Skip ceremony. No status bars, no step confirmations, no "shall I proceed?" gates. Execute directly, explain briefly after.

**Never skipped by cb-fast:** `cb-verify` gates and irreversible-action confirmations. When stacked with `cb-careful`, compress to one line: "⚠ This deletes the table — confirm?"

---

### `cb-reset`
**`cb-reset`** — clear all active modes, return to default behavior. Confirm: "✦ All modes cleared."

**`cb-reset <mode>`** — drop one specific mode. Confirm: "✦ cb-[mode] off. Still active: [remaining modes]." If no modes remain: "✦ All modes cleared."

If the named mode is not currently active: "cb-[mode] wasn't active — no change."

---

## Activating modes mid-message

`cb-read-only please look at my auth code` — activate read-only and handle the rest of the message under that mode in the same response.
