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

## code-better 1.3.0 — 2026-08-22

### Added

- `cb-trace` — read-only, end-to-end trace of how one existing feature works today, hop by hop (entry → auth/validation → business logic → data layer → external calls → response/side effects), citing file:line at each hop. Distinct from `cb-explore` (whole-project structural map) and `cb-review-flow` (diff-scoped "what changed" trace): `cb-trace` builds full context on an already-existing feature before any change is planned or made, for unfamiliar-code investigation, bug triage, or extending a feature with no prior context. Notes state changes, branches not fully walked, existing error handling, and known tests; optionally appends a "Traced Flows" section to the project's `cb-explore` memory entry.

---

## code-better 1.2.0 — 2026-08-15

### Added

- `cb-research` — uncapped, ask-driven deep research. No file cap and no "pattern is clear, stop here" early exit (unlike `cb-explore` and `cb-plan`'s discovery phase). Traces the full call chain and blast radius, checks explicit edge cases against the real code, audits reuse, and produces a dedicated "what will break if this is built naively" section, plus an "open questions" and "what must not be invented" gate before any plan is written. Saves to `0-cowork/memory/research/{date}-{slug}.md`. Supports optional parallel fan-out (reusing `cb-agents`' research-agent prompt) when an ask spans multiple distinct codebase areas.
- `cb-workflow` — a Step 0 that asks upfront whether to run step-by-step (pause for approval each step) or run all steps and report completion status at the end; either way `cb-verify` and `cb-prod` still run after every step and a failure still stops progression. Also asks, in the same message, whether to checkpoint each validated step with a local commit, so a later failure can roll back without losing already-working progress.
- `cb-workflow` — a per-step scope guard (diffs actual changed files against the step's declared scope and flags anything undeclared) and a per-step adjacent-path regression spot-check, so a step's side effects are caught immediately rather than only at the final Pre-Done Gate.
- A Git & GitHub Write Operations policy in `_shared-rules.md`: reads (`status`, `diff`, `log`, `gh pr checks`) are always pre-approved; any write (commit, push, merge, branch create/delete, `gh pr create`/`merge`) requires an explicit upfront choice — handle it, or hand back the diff/draft and let the user do it themselves. `cb-ship` now asks this before Phase 1, and asks again with the specific merge details right before Phase 6's actual merge.

### Changed

- `cb-pr-review` now owns diff-scoped code quality as a distinct dimension: DRY (duplicated logic in the diff, or re-implementing something that already exists), SOLID applied practically (single responsibility, coupling/abstraction leaks, dependency direction), and complexity/readability — each finding cited to a file:line.
- `cb-review-flow` dropped the production-readiness step it duplicated from `cb-prod`/`cb-pr-review`, and now owns pure blast-radius/integration: dependents, plus schema/contract drift and cross-module/cross-service boundary checks. It explicitly defers code-quality findings to `cb-pr-review` instead of reviewing them itself.
- `cb-audit` now also sweeps for repo-wide design decay that a diff-scoped review structurally cannot see: cross-file DRY (the same logic duplicated across files that were never part of the same diff) and architecture-level SOLID violations (god files, circular dependencies).
- `cb-verify` no longer duplicates the gate procedure — it now points at the canonical definition in `_shared-rules.md` and adds only the one-shot invocation framing.
- `cb-agents`' Phase 3 review-agent prompts updated to match the sharpened `cb-pr-review` / `cb-review-flow` split, with an explicit non-overlap instruction for each.
- `cb-help` — added the `cb-summarize` alias to the `cb-scope` line, so it's discoverable from the menu itself.

---

## code-better 1.1.0 — 2026-08-03

### Added

- `cb-audit` — a full-app, read-only sweep for bugs, edge cases, dead code and production readiness. Unlike `cb-prod` / `cb-review-flow` / `cb-pr-review`, which are scoped to a diff or a single change, `cb-audit` covers the whole codebase and persists what it finds to `0-cowork/memory/known-issues.md` as status-tracked entries, so items can be worked through one at a time with `cb-fix` → `cb-cleanup` → `cb-prod` → `cb-ship` across sessions.

### Changed

- `cb-tidy`'s known-issues extraction now uses the same ID/severity/category schema as `cb-audit`, so both commands write compatible entries into the same file.

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
