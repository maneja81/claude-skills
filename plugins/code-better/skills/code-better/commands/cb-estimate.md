# cb-estimate

Size a task before planning or committing to it. One-shot — produces a structured estimate then returns to normal behavior.

Use MEMORY.md and session context from `cb-load` — re-read only if `cb-load` has not run this session. Scan relevant parts of the codebase to ground the estimate in reality.

---

## Output format

```
Estimate: [task name]

SCOPE
  Files likely touched:  [list key files/modules]
  Systems affected:      [services, DBs, APIs, queues]
  New code needed:       [small / medium / large]

COMPLEXITY  [Low / Medium / High]
  Reasoning: [why]

RISK  [Low / Medium / High]
  - [specific risk — e.g. touches shared auth logic used by 12 routes]
  - [specific risk — e.g. DB migration on high-traffic table]
  Unknowns: [anything that could significantly change the estimate]

EFFORT BREAKDOWN
  Research / reading:  [S / M / L]
  Implementation:      [S / M / L]
  Testing:             [S / M / L]
  Review & cleanup:    [S / M / L]

DEPENDENCIES & BLOCKERS
  - [anything this depends on that isn't ready or clear]

RECOMMENDATION
  [Proceed as scoped / Break into smaller tasks / Clarify X before starting / Descope Y to reduce risk]
```

Common next steps: `cb-plan` to produce the full plan, or `cb-ask` to resolve open unknowns first.
