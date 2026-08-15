# cb-review-flow

Read `commands/_shared-rules.md` if not already loaded this session.

Read-only end-to-end integration trace. No changes. Identify what changed, trace every dependent across the whole codebase, check consistency and contract drift, produce a structured report.

**This command owns blast-radius/integration — not code quality.** It answers "does everything downstream still work," not "is this code well-written." For DRY/SOLID/complexity/conventions on the changed files themselves, use `cb-pr-review` instead. Don't re-review code quality here even if something looks off — note it as "flag for cb-pr-review" at most and keep tracing.

---

## Step 1: Identify the change surface
- What was changed: functions, types, schemas, API contracts, config, constants, or business logic
- List changed files/symbols as the starting point

## Step 2: Trace dependents
- Find all callers, importers, consumers, and references across the whole codebase
- Look for: function calls, type usages, shared utilities, API clients, DB queries, UI components, tests, config references
- Go at least 2 levels deep. Stop past 2 levels only if clearly out of scope (different service/repo with no shared deploy)

## Step 3: Check consistency
For each dependent:
- Still passing the right arguments / expecting the right return shape?
- Handles new error cases or edge cases introduced by the change?
- Any hardcoded assumptions (magic strings, expected values, response shapes) now stale?
- Related tests still testing the right thing, or passing for the wrong reasons?

## Step 4: Schema, contract & boundary drift
- **Schema/contract drift** — if a type, DB schema, or API contract changed, check every serializer, mapper, validator, and consumer against the new shape. Flag any place still assuming the old shape.
- **Cross-module/cross-service boundaries** — if the change crosses a module, package, or service boundary (e.g. a shared library, an internal API, an event payload), check the boundary contract itself, not just the immediate caller. Note any consumer outside this repo that can't be traced directly (flag as "not checked — external").

## Step 5: Report
```
Flow Review Report

Changed: [files / symbols modified]

FLOW CONSISTENCY
✓ OK: [consistent dependents]

⚠ Broken / stale:
  - [file/symbol]: [what's inconsistent and why it matters]

SCHEMA / CONTRACT DRIFT
✓ OK: [consumers still matching the current shape]
⚠ Drift found: [file:line — old shape assumed, why it breaks]

BOUNDARY CHECKS
[cross-module/cross-service boundaries touched, and their status]

Not checked (out of scope / external):
  - [anything that couldn't be traced]

Recommendation: [address issues above before merging / clear to merge]
```

---

## Auto-exit

When `cb-review-flow` activates, automatically exit: `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan`. Announce: `✦ cb-review-flow on — exited: [list]`
