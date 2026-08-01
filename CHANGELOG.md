# Changelog

Both plugins are versioned independently and tagged `<plugin-name>--v<version>`.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## weekend-project 1.0.0 — 2026-08-01

First public release.

### Added

- Intake interview producing `config.yaml`, and a generated `CLAUDE.md` for the target project.
- Planning protocol: evidence-gated discovery where every claim about the codebase traces to a file actually opened, a reuse audit before anything new is proposed, and a validation pass covering requirement coverage, consolidated blast radius, plan-level edge cases and cross-PR naming consistency.
- Plan queue — `plans/pending`, `active`, `done`, `deferred`. A project is a sequence of plans rather than a single batch. `wpr-plan-add` queues one without interrupting a running build; `wpr-plans` shows the queue; `roadmap.md` renders it at the project root.
- Per-PR execution loop: isolated git worktree, test-first commits, an independent QA review against the plan's acceptance criteria, up to three fix rounds, a merge gate, and `--no-ff` merge to `develop-ai`.
- Sr. Developer and Sr. QA roles as separate agents, with a mandatory edge-case checklist covering empty input, maximum length, zero results, concurrency, auth expiry, network failure, malformed JSON, injection, XSS and oversized payloads.
- Project memory reloaded before every PR, plus an append-only `decisions.jsonl` recording each non-obvious choice with its rationale and rejected alternatives.
- Per-plan token budgeting, with a warning when a plan passes 80% of its own estimate before its final PR.
- Resumption from `session.yaml` after a pause or a context reset, including reconciliation of the plan folders.
- Migration for projects created before the plan queue existed: an existing `plan.json` becomes `plan-001`.
- Guardrails — writes confined to the project root, pushes restricted to `develop-ai` and `wpr/*`, a secret scan before every commit, and a hard stop when a PR reaches round four with unresolved blockers.

### Notes

The per-PR loop is the part exercised by the run documented in `HOW-IT-WORKS.md`. The plan queue and the worktree state handling are new in this release and have not yet been run end to end.

---

## code-better 1.0.0 — 2026-08-01

First public release.

### Added

- 40 behavioural mode commands, session-persistent and stackable, with a status bar showing what is active.
- Fixed precedence: safety modes beat action modes, and `cb-fast` never skips a verify gate, a plan approval or an irreversible-action confirmation.
- Phase awareness — commands enable and exit incompatible modes on start, and the one transition that grants write access asks for confirmation first.
- Positional invocation: a command activates only as the leading token of a message, so referring to one in conversation does not trigger it.
- Lazy loading — 32 command files read only when their command runs; the simple modifiers are defined inline.
- Session start with a setup check and a memory briefing, and `cb-setup` to generate the supporting files from codebase analysis.
