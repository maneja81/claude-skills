# cb-cleanup

Read `commands/_shared-rules.md` if not already loaded this session.

Pre-PR cleanup workflow. Run all steps sequentially without waiting between them unless a judgment call is needed.

**Goal**: leave the codebase in a state where the PR will be approved without pushback.

---

## Step 1/6: Baseline verify
Run the `cb-verify` gate (from `_shared-rules.md`) before touching anything. Record the baseline — any pre-existing failures are not yours to fix (flag them, don't hide them).

## Step 2/6: Dead code & files
- Remove unused variables, functions, imports, and files introduced as part of this work
- Flag (but don't delete) anything that looks orphaned but might be used elsewhere — ask before removing

## Step 3/6: Debug cleanup
- Remove `console.log`, `print`, `debugger`, and other debug statements — these are always safe to delete
- Remove temp/test files not meant for production
- **Commented-out code blocks: flag, don't auto-delete.** Commented code is sometimes intentional (examples, rollback fallbacks, feature flags). For each block found, show it and ask: "Intentional or safe to remove?" Only delete after confirmation.

## Step 4/6: Code style & conventions
- Check naming conventions, formatting, and structure against the existing codebase — match what exists, don't introduce new patterns
- Fix deviations: variable names, file structure, folder placement, export style

## Step 5/6: Production readiness
Use the production readiness checklist from `_shared-rules.md`. Fix obvious items directly (missing import cleanup, clear unused variable). Reserve "flag, don't fix" for genuinely judgment-call items.

## Step 6/6: Re-verify & summary
Run `cb-verify` again. Compare to baseline.

```
✓ Cleanup complete

Baseline:  [cb-verify result before cleanup]
After:     [cb-verify result after cleanup]
Removed:   [dead code / files removed]
Fixed:     [style or convention issues corrected]
Flagged:   [anything left for the user to decide]
Prod:      [pass / any concerns]
```

---

## Auto-exit

When `cb-cleanup` activates, automatically exit: `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan`. Announce: `✦ cb-cleanup on — exited: [list]`
