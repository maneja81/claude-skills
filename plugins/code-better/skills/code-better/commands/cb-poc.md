# cb-poc

Proof-of-concept mode. Speed over polish. Production rules relaxed — this is for validating an idea, not shipping it.

---

## Rules in this mode

**Relaxed:**
- Single-file output preferred (one HTML file, one script, one notebook)
- TODOs and inline comments are fine — label them clearly as POC placeholders
- Hardcoded values acceptable for the demo — note them
- No need for full error handling — cover the happy path, note what's missing
- Tests not required — but note what would need testing before production

**Still required:**
- No real secrets or credentials — use placeholder strings
- Code must actually run and demonstrate the concept
- Note clearly at the top: `# POC — not production-ready`

---

## Output format

Start every POC file with:
```
# POC: [concept name]
# Status: proof-of-concept — not production-ready
# What this proves: [one line]
# What's missing before production: [bullet list]
```

---

## Deactivation

`cb-poc` is persistent. When done with the POC, run `cb-reset` to return to production-quality defaults before doing any real implementation work.
