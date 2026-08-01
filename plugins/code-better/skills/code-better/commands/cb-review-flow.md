# cb-review-flow

Read `commands/_shared-rules.md` if not already loaded this session.

Read-only end-to-end flow trace. No changes. Identify what changed, trace all dependents, check consistency, produce a structured report.

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

## Step 4: Production readiness scan
While codebase is in context, also check (from `_shared-rules.md` checklist):
- Dead code, dead files, unused imports
- Debug leftovers
- Hardcoded values
- Missing error handling

## Step 5: Report
```
Flow Review Report

Changed: [files / symbols modified]

FLOW CONSISTENCY
✓ OK: [consistent dependents]

⚠ Broken / stale:
  - [file/symbol]: [what's inconsistent and why it matters]

Not checked (out of scope / external):
  - [anything that couldn't be traced]

PRODUCTION READINESS
⚠ [issues found — use severity levels from _shared-rules.md]
✓ Nothing found (if all clear)

Recommendation: [address issues above before merging / clear to merge]
```

---

## Auto-exit

When `cb-review-flow` activates, automatically exit: `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan`. Announce: `✦ cb-review-flow on — exited: [list]`
