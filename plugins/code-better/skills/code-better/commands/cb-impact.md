# cb-impact

Map the blast radius of a proposed change before any code is written. One-shot, read-only — no changes, no plan, just a clear picture of what would be affected.

**Usage:** `cb-impact add tenant isolation to the billing module`

---

## Phase 1: Understand the proposed change

Use MEMORY.md and session context from `cb-load` — prior decisions and constraints are already in context; re-read only if `cb-load` has not run this session. Clarify the exact change: what would be added, modified, removed, or restructured. If ambiguous, ask one focused question before proceeding.

---

## Phase 2: Map the blast radius

**Direct impact — what must change**
Files, functions, types, schemas, API contracts directly modified. Database changes: new columns, changed types, migrations. API changes: new endpoints, modified shapes, versioning implications.

**Indirect impact — what breaks or needs updating**
All callers, importers, and consumers — traced at least 2 levels deep. Tests that cover the changed behaviour. Config, environment variables, or infrastructure needing change. Documentation or external contracts affected.

**Cross-cutting concerns**
- Auth/permissions: does this change who can do what?
- Data integrity: any existing records in invalid state after this change?
- Performance: new queries, network calls, or computation on hot paths?
- Backwards compatibility: breaks any existing clients, integrations, or stored data?

---

## Phase 3: Report

```
Impact Report
Proposed change: [one-line description]

DIRECT IMPACT
  Files modified:   [list]
  Schema changes:   [tables, columns, types]
  API changes:      [endpoints, contracts, versioning]

INDIRECT IMPACT
  Callers affected: [files/functions calling changed code]
  Tests affected:   [tests covering changed behaviour]
  Config/infra:     [env vars, deployment, infrastructure]

CROSS-CUTTING RISKS
  ⚠ Auth/permissions:   [any change to access control]
  ⚠ Data integrity:     [existing data that would be invalid]
  ⚠ Performance:        [hot paths affected]
  ⚠ Backwards compat:   [breaking changes to clients or integrations]

BLAST RADIUS SUMMARY
  Complexity: Low / Medium / High
  Risk:       Low / Medium / High
  Reasoning:  [why]

UNKNOWNS
  [anything that couldn't be determined without more context]

RECOMMENDATION
  [Proceed as proposed / Narrow scope / Resolve unknowns first / Consider alternative]
```

After the report: "Run `cb-estimate` to size the effort, or `cb-plan` to produce the implementation plan."
