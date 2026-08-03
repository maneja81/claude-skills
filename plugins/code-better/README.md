# Code Better

> This is a personal side project — built evenings and weekends, around a full-time job.
> No support, no roadmap commitments, no guarantees.

**Behavioural modes for Claude Code. Say how you want to work once, and it sticks.**

Most of the friction in working with a coding agent isn't what it knows — it's what mode it's in. You wanted it to look, and it started editing. You wanted the smallest possible fix, and it refactored three files. You wanted it to slow down on the migration, and it ran it.

`code-better` gives you 42 one-word commands that set that behaviour explicitly, hold it for the session, and stack.

```
cb-read-only look at my auth code
```

> ✦ cb-read-only mode on
> `[modes: cb-read-only]`

It reads. It doesn't write. It stays that way until you say otherwise — and if you ask for an edit while read-only is active, it produces a diff for review instead of silently obeying the more recent instruction.

```
cb-workflow cb-careful run the database migration
```

Two modes at once: step-by-step execution, validating each step, flagging assumptions and asking before anything irreversible.

---

## Install

Part of the [maneja81-skills](https://github.com/maneja81/claude-skills) marketplace.

```
/plugin marketplace add maneja81/claude-skills
/plugin install code-better@maneja81-skills
/reload-plugins
```

Or install it as a plain skill — see the [repository README](../../README.md#installation) for the script, manual-copy and claude.ai upload paths.

---

## How it works

Three properties do most of the work:

**Session-persistent.** A mode stays active until `cb-reset`. You set it once, not on every message. Active modes are shown in a status bar on every reply: `[modes: cb-read-only · cb-workflow]`

**Stackable.** Modes combine. `cb-workflow cb-careful`, `cb-plan cb-thorough`, `cb-fix cb-minimal`.

**Safety wins.** The precedence rules are fixed and not up for negotiation mid-session:

- `cb-read-only` and `cb-careful` beat any command that writes files
- `cb-fast` compresses output — it never bypasses a verify gate, a plan approval, or an irreversible-action confirmation
- `cb-fast` + `cb-careful` gives you one-line confirmations (`⚠ This deletes the table — confirm?`), not zero confirmations
- With `cb-read-only` active, a write command runs report-only: it describes the change and writes a diff to scratch, and announces that it did so

Modes live in memory for the session — no state file, so two sessions on the same project never interfere. If context compacts and the modes are lost, it asks you once which ones to restore rather than silently reverting to default behaviour.

**Invocation is positional.** A command only activates as the leading token of your message. *"should I use cb-fast here?"* and *"what does cb-cleanup do?"* are references, not invocations — they won't trigger anything.

---

## Commands

### Pre-work

| Command | |
|---|---|
| `cb-spec` | Analyse a spec or requirements for gaps and conflicts |
| `cb-impact` | Map the blast radius of a proposed change |
| `cb-estimate` | Size a task: complexity, risk, effort breakdown |
| `cb-explore` | Build a knowledge map of a project folder |

### Research and planning

| Command | |
|---|---|
| `cb-brainstorm` | Explore options grounded in the codebase before picking one |
| `cb-plan` | Full step-by-step plan, then wait for your go-ahead |
| `cb-ask` | Ask every clarifying question upfront, before starting |
| `cb-debate` | Adversarial review — PRO vs CON agents, 5 evidence-gated rounds, verdict of ADOPT / REJECT / MERGE |

### Execution

| Command | |
|---|---|
| `cb-workflow` | Step-by-step execution, validating each step |
| `cb-feature` | End-to-end feature: spec → impact → brainstorm → plan → execute → cleanup → review |
| `cb-poc` | Proof-of-concept: speed over polish, production rules relaxed |

### Debugging and fixing

| Command | |
|---|---|
| `cb-debug` | Reproduce → hypothesis → test → confirm, *before* fixing |
| `cb-fix` | Implement a confirmed fix: minimal scope, recurrence check, regression guard |

### Review and validation

| Command | |
|---|---|
| `cb-cleanup` | Pre-PR sweep: baseline verify, dead code, conventions, prod readiness, re-verify |
| `cb-review-flow` | Trace an end-to-end flow's impact, read-only |
| `cb-pr-review` | Full PR/diff review: correctness, edge cases, tests, conventions, prod readiness |
| `cb-prod` | Production readiness audit: security, reliability, config, observability |
| `cb-audit` | Full-app sweep for bugs, gaps, edge cases, dead code — logs to `known-issues.md` |
| `cb-verify` | Lint + typecheck + build + tests, in one gate |
| `cb-validate-data` | Post-data-operation audit: counts, integrity, correctness |

### Behavioural modifiers — stack with anything

| Command | |
|---|---|
| `cb-read-only` | No file edits without explicit approval |
| `cb-careful` | Flag assumptions, prefer dry-runs, confirm irreversible actions |
| `cb-thorough` | Read everything fully, miss nothing, prepend a reading log |
| `cb-fast` | Skip ceremony, execute directly (never skips `cb-verify`) |
| `cb-minimal` | Smallest change that works, no scope creep |
| `cb-explain` | Narrate every action in plain language |

### Session and memory

| Command | |
|---|---|
| `cb-load` | Load memory, feedback rules and index into a session briefing |
| `cb-remember` | Save context to `MEMORY.md` + session logs |
| `cb-feedback` | Log a correction rule so the same mistake isn't repeated |
| `cb-context` | Dump current session state and context health |
| `cb-index` | Build an index of `0-cowork/`, and save the regeneration script |
| `cb-mark-pending` | Park an in-progress item for later |
| `cb-tidy` | Organise `0-cowork/`: archive stale files, extract known issues |
| `cb-refresh` | Reload skill instructions and clear all active modes |

### Everything else

| Command | |
|---|---|
| `cb-agents` | Multi-agent pipeline: intake → research → plan → [approval] → workflow → review |
| `cb-enhance` | Deep review of an existing feature + severity-ranked enhancement plan |
| `cb-scope` | Restate understanding and in/out of scope, then wait for confirmation |
| `cb-rubber-duck` | Listen mode — ask questions, don't jump to solutions |
| `cb-setup` | Generate `CLAUDE.md`, `MEMORY.md` and `0-cowork/memory/` from codebase analysis |
| `cb-help` | Show the full menu |
| `cb-reset` | Clear all modes — or `cb-reset <mode>` to drop just one |

`cb-summarize` is an alias for `cb-scope`.

---

## Phase awareness

Some combinations don't make sense, so commands adjust the stack when they start and tell you what changed in one line:

```
✦ cb-plan on — enabled: cb-read-only, cb-thorough
✦ cb-workflow on — exited: cb-plan, cb-read-only, cb-thorough
```

Planning and exploration turn *on* read-only and thorough, because that's what those phases need. Execution commands turn them off — and that one transition asks for confirmation first, since it's the moment the agent gains write access:

```
✦ cb-workflow on — exiting cb-read-only (switching to execution mode). Confirm?
```

`cb-explain`, `cb-minimal` and `cb-ask` never auto-exit. They're preferences about how you like to be worked with, not phases.

---

## Session start

Typing `/code-better` on its own runs a setup check, loads your project memory, and asks what you're working on:

```
Setup Status
  CLAUDE.md          ✓ found
  MEMORY.md          ✓ found
  0-cowork/memory/   ✓ found
  Agent corrections  ✓ active (feedback.md found)
  Active modes       none
```

If anything is missing, it offers to run `cb-setup`, which analyses the codebase and generates all of it.

Typing a command *with* a task — `cb-read-only check my auth code` — skips the ceremony and goes straight to work.

### The `0-cowork/` convention

The memory commands (`cb-load`, `cb-remember`, `cb-index`, `cb-tidy`, `cb-mark-pending`) read and write a `0-cowork/` directory alongside `CLAUDE.md` and `MEMORY.md`. `cb-setup` creates it. If you don't want that structure, the mode commands all work without it — only the session and memory group depends on it.

---

## Structure

```
skills/code-better/
  SKILL.md              routing, mode state, precedence, auto-exit/enable rules
  commands/             35 command files, loaded only when the command is invoked
    _shared-rules.md    engineering hard rules, severity levels, irreversible-action list
```

The simple modifiers (`cb-read-only`, `cb-minimal`, `cb-careful`, `cb-fast`, `cb-explain`, `cb-scope`, `cb-rubber-duck`, `cb-reset`) are defined inline in `SKILL.md` — no file read needed. Everything heavier is lazy-loaded, so the skill costs very little context until a command actually runs.

---

## Limitations

- **Modes don't survive compaction reliably.** They're in-memory by design. After a compaction the skill asks which modes to restore rather than guessing — but it has to notice first, which usually means you referencing one.
- **Precedence is fixed.** Safety beats speed, always. If you want a genuinely unguarded fast path, this isn't it.
- **`0-cowork/` is opinionated.** The session and memory commands assume that layout. The rest of the skill doesn't care.
- **It's instructions, not enforcement.** These are behavioural rules the model follows, not sandbox permissions. For hard guarantees about what an agent can touch, use Claude Code's permission settings.

---

## License

[MIT](LICENSE) © Mohit Aneja
