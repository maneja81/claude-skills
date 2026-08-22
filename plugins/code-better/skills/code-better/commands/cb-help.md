# cb-help

Show the command reference. No setup checks, no memory briefing.

```
code-better — Behavioral Mode Shortcuts

HOW TO USE
  Type the command + your task: cb-read-only look at my auth code
  Modes stay active all session. Stack multiple: cb-workflow cb-careful run the DB migration
  To exit all: cb-reset

PRE-WORK (run before planning)
  cb-spec         — analyze a spec or requirements for gaps and conflicts
  cb-impact       — map blast radius of a proposed change
  cb-estimate     — size a task: complexity, risk, effort breakdown
  cb-explore      — build a knowledge map of a project folder
  cb-research     — uncapped deep research on a specific ask: blast radius, edge cases, what will break
  cb-trace        — read-only end-to-end trace of how an existing feature works today, hop by hop

RESEARCH & PLANNING
  cb-brainstorm   — explore options grounded in codebase before picking a solution
  cb-plan         — full step-by-step plan, wait for go-ahead
  cb-ask          — ask all clarifying questions upfront before starting
  cb-debate       — adversarial review: PRO vs CON agents, 5 evidence-gated rounds, orchestrator verdict (ADOPT / REJECT / MERGE)

EXECUTION
  cb-workflow     — step-by-step execution, validate each step
  cb-feature      — end-to-end feature: spec? → impact? → brainstorm → plan → execute → cleanup → review
  cb-poc          — proof-of-concept mode: speed over polish, production rules relaxed

DEBUGGING & FIXING
  cb-debug        — reproduce → hypothesis → test → confirm before fixing
  cb-fix          — implement confirmed fix: minimal scope, recurrence check, regression guard, unit + E2E tests

REVIEW & VALIDATION
  cb-cleanup      — pre-PR: baseline verify, dead code, conventions, prod readiness, re-verify
  cb-review-flow  — blast-radius/integration only: trace dependents, contract drift, read-only (not code quality)
  cb-pr-review    — diff code-quality review: correctness, edge cases, tests, conventions, DRY/SOLID, prod readiness
  cb-prod         — production readiness audit: security, reliability, config, observability
  cb-audit        — full-repo sweep: bugs, gaps, dead code, cross-file DRY/SOLID decay — logs to known-issues.md
  cb-verify       — lint + typecheck + build + tests in one gate
  cb-validate-data — post-data-operation audit: counts, integrity, correctness
  cb-ship         — validate → raise PR → wait for CI → merge to development branch

BEHAVIORAL MODIFIERS (stack with anything)
  cb-read-only    — no file edits without approval
  cb-careful      — flag assumptions, prefer dry-runs, confirm irreversible actions
  cb-thorough     — read everything fully, miss nothing, prepend reading log
  cb-fast         — skip ceremony, execute directly (never skips cb-verify)
  cb-minimal      — smallest possible change, no scope creep
  cb-explain      — narrate every action in plain language

MULTI-AGENT
  cb-agents       — full multi-agent pipeline: intake → research → plan → [approval] → workflow → review

SESSION
  cb-index        — build index of 0-cowork/, save regeneration script
  cb-load         — load memory, feedback rules, and index into a session briefing
  cb-mark-pending — park an in-progress item to 0-cowork/plans/pending/
  cb-tidy         — organise 0-cowork/: archive stale files, extract known issues, restructure
  cb-refresh      — reload skill instructions and clear all active modes

UTILITIES
  cb-enhance      — deep review of existing feature + severity-ranked enhancement plan
  cb-remember     — save context to MEMORY.md + session_logs.md (one-shot)
  cb-feedback     — log a correction rule so the mistake isn't repeated (one-shot)
  cb-context      — dump current session state + context health (one-shot)
  cb-scope        — restate understanding + in/out of scope, wait for confirmation (alias: cb-summarize)
  cb-rubber-duck  — listen mode, ask questions, don't jump to solutions
  cb-setup        — generate CLAUDE.md, MEMORY.md, 0-cowork/memory/ from codebase analysis
  cb-help         — show this menu
  cb-reset        — clear all active modes
```
