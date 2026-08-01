# cb-enhance

Read `commands/_shared-rules.md` if not already loaded this session.

Deep review of an existing feature followed by a severity-ranked enhancement plan. Read-first — nothing changes until the user approves the plan.

---

## Phase 1: UNDERSTAND

Use MEMORY.md and session context from `cb-load` — re-read MEMORY.md only if `cb-load` has not run this session. Then thoroughly read the feature's code:
- Entry points (routes, controllers, components, CLI commands)
- Core logic and data flow
- Error handling and edge cases today
- Tests that exist (if any)
- How it integrates with the rest of the system

Do not skim. Read the actual implementation before forming any opinion.

---

## Phase 2: STRICT REVIEW

Analyse across these dimensions:

**Correctness** — edge cases not handled? Silent failure paths? Output always what the caller expects?

**Robustness** — what happens under load, bad data, or dependency failure? Missing retries, timeouts, fallbacks?

**Security** — input validated at every boundary? Privilege escalation, injection, data leak risks?

**Performance** — unnecessary queries, N+1 patterns, blocking calls in hot paths?

**Maintainability** — consistent with codebase conventions? Logic duplicated elsewhere? Hardcoded values or magic strings?

**Test coverage** — what cases are missing? User flows or error states not covered?

---

## Phase 3: ENHANCEMENT PLAN *(cb-plan rules)*

Rank findings by severity (from `_shared-rules.md`): critical → moderate → minor. Plan must tackle critical first.

Produce a full step-by-step plan in `cb-plan` format — status tracker, per-step details, edge cases, error handling, breaking changes.

Hard rules: simplest fix that fully solves each gap, reuse existing utilities, flag every assumption.

End with:
```
Waiting for go-ahead. Reply "cb-workflow" to execute, or give feedback to adjust the plan.
```
