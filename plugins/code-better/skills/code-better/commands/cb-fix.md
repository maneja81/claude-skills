# cb-fix

Read `commands/_shared-rules.md` if not already loaded this session.

Implement a production-ready fix for a confirmed bug. Chains from `cb-debug` — reads confirmed root cause from session context. Also works standalone when the cause is already known.

---

## Phase 1: Scope the fix

- Read the confirmed root cause (from `cb-debug` output or user description)
- Identify the minimal change required — what specifically must change and why
- List every file that must be touched; explicitly flag any shared utilities used elsewhere
- If multiple approaches exist, state the tradeoff and recommend one — only ask the user to choose if the tradeoff is genuinely a judgment call they need to make

---

## Phase 2: Implement

Apply `cb-workflow` discipline throughout:
- One step at a time, validate before proceeding
- Production-ready only — all hard rules from `_shared-rules.md` apply
- Follow existing project conventions — naming, structure, error handling style
- Don't touch anything outside the confirmed fix scope — flag separately at the end

---

## Phase 3: Validate the fix

Stricter than normal step validation:

**Reproduce after fix — mandatory.** Trigger the exact scenario that caused the original bug. Show that it no longer fails. This is not optional — "the fix looks correct" is not validation.

- Describe the specific reproduction step taken and its result
- Confirm the root cause is specifically gone — not just that tests pass. Explain *why* the bug can no longer occur given the change made.
- Check one adjacent path that was not changed — confirm it still behaves correctly.
- Run the Pre-Done Gate from `commands/_shared-rules.md`: diff review, side-effect check, integration trace, failure modes, cb-verify, requirement check.
- If no tests covered this bug path, note it: "No test existed for this case — worth adding."

---

## Phase 4: Recurrence check

Search the codebase for the same bug pattern:
```
Recurrence check: [pattern searched]
  ✓ No other instances found
  ⚠ Same pattern found in: [file:line] — [description]
```

If recurrences found, ask whether to fix them now or flag for follow-up — don't silently fix inline.

---

## Phase 5: Regression check

Check callers and dependents of anything changed:
- Still passing the right arguments?
- Handle any new error cases introduced by the fix?
- Any tests now passing for the wrong reasons?

---

## Phase 6: Summary

**Fix Summary** (render as plain markdown)

- **Root cause:** [one line]
- **Fix:** [what changed and why it resolves the cause]
- **Reproduced after fix:** [yes — [what was tested and what happened]]
- **Files changed:** [list]
- **Tests:** [passed / fixed N / no coverage — worth adding]
- **Recurrences:** [none / N found — action taken]
- **Regression check:** [clean / concerns]
- **Pre-Done Gate:** [passed / [what failed and how it was fixed]]

**Flagged for follow-up:** [anything noticed but intentionally left out of scope]

Run `cb-cleanup` before raising the PR.

---

## Auto-exit

When `cb-fix` activates, automatically exit: `cb-debug`, `cb-explore`, `cb-brainstorm`. Announce: `✦ cb-fix on — exited: [list]`
