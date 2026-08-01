# cb-validate-data

Post-operation data integrity audit. Run after any data operation — migration, import, bulk update, transform, or seed. One-shot, read-only — no changes.

**Usage:** `cb-validate-data` (infers from context) or explicit: `cb-validate-data users table after subscription_tier migration`

---

## Checks

**Counts** — do row counts match expectations (before vs after)? Any rows unexpectedly inserted, deleted, or duplicated?

**Integrity** — foreign keys intact? No orphaned records? Unique constraints valid? Required fields populated, no unexpected NULLs?

**Correctness** — spot-check a sample of records: do values match what the operation should have produced? Are computed/derived fields correct? Does output shape match expected schema?

**Boundaries** — records at edges (first, last, max value, empty strings) look correct? Known edge cases in the operation handled correctly?

---

## Output format

```
Data Validation Report
Operation: [what was validated]

COUNTS      ✓ / ✗  [description and numbers]
INTEGRITY   ✓ / ✗  [foreign keys, constraints, nulls]
CORRECTNESS ✓ / ✗  [spot-check results — N records sampled]
BOUNDARIES  ✓ / ✗  [edge case results]

VERDICT
  ✓ Data looks correct
  ✗ Issues found — [summary of what's wrong and whether to fix-forward or roll back]
```

One-shot — after the report, resume normal behavior.
