# cb-spec

Analyze a feature specification, user story, PRD, or requirements description for gaps, conflicts, ambiguities, and missing edge cases — before any planning or development starts. One-shot, read-only.

**Usage:** paste or describe the spec inline, or point at a file: `cb-spec src/docs/invite-system.md`

---

## Phase 1: Read context

Use MEMORY.md and session context from `cb-load` — prior decisions and constraints are already in context; re-read only if `cb-load` has not run this session. If pointing at a file, read it fully. Scan relevant parts of the codebase to understand what already exists that this spec might affect.

---

## Phase 2: Analyze across five dimensions

**Completeness** — user flows or states not described? (empty states, error states, edge inputs, concurrent users) All actors and permissions defined? Expected output for every action specified? Implicit assumptions that should be made explicit?

**Conflicts** — contradicts existing behaviour, API contracts, or prior decisions? Internal contradictions within the spec itself? Conflicts with existing data models, permissions, or business rules?

**Ambiguities** — where could two reasonable engineers read this differently? Terms used inconsistently? Quantities, limits, or thresholds left vague when they need to be precise?

**Missing edge cases** — empty input, null values, max values, malformed data? Dependency unavailable? Failure modes? Concurrent or race condition scenarios?

**Scope risks** — implicit requirements that expand scope significantly? Dependencies on things not yet built? Could this spec be misread to justify scope creep?

---

## Phase 3: Report

```
Spec Analysis Report
Scope: [spec or feature name]

GAPS
  ⚠ [what's not defined and why it matters]

CONFLICTS
  ⚠ [what conflicts and with what]

AMBIGUITIES
  ⚠ [what's unclear and what the options are]

MISSING EDGE CASES
  ⚠ [scenario not handled and why it matters]

SCOPE RISKS
  ⚠ [implicit requirement or dependency that could expand scope]

CLARIFYING QUESTIONS
  Before building, get answers to:
  1. [question — what decision it unlocks]
  2. [question]

VERDICT
  ✓ Spec is solid — ready for cb-plan
  ⚠ Spec needs clarification — resolve the above before planning
  ✗ Spec has gaps or conflicts that would produce wrong behaviour if built as written
```

After the report: "Resolve the above, then run `cb-plan` to produce the implementation plan."
