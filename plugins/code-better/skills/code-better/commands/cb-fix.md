# cb-fix

Read `commands/_shared-rules.md` if not already loaded this session. Also read `CLAUDE.md` if it exists and has not been read this session — it contains project-specific coding conventions, architecture decisions, and instructions that govern all work in this repo.

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

Recurrence check: [pattern searched]
  ✓ No other instances found
  ⚠ Same pattern found in: [file:line] — [description]

If recurrences found, ask whether to fix them now or flag for follow-up — don't silently fix inline.

---

## Phase 5: Regression check

Check callers and dependents of anything changed:
- Still passing the right arguments?
- Handle any new error cases introduced by the fix?
- Any tests now passing for the wrong reasons?

---

## Phase 6: Test suite

Run the full test suite. Show raw output — never self-report results.

**Step 1 — detect and run unit/integration tests:**

Check for the project's test runner in this order:
- `package.json` → scripts.test (jest, vitest, mocha, etc.)
- `pyproject.toml` / `setup.cfg` / `pytest.ini` → pytest
- `go.mod` → go test ./...
- `Makefile` → look for a `test` target
- `Rakefile` / `.rspec` → rspec

Run what's found. If nothing is found, say so — do not invent a command.

Report format:

**Tests:** ✓ [N passed] / ✗ [N failed] / – not found
- ✗ [test name] — [failure reason, one line]

If any tests fail: stop here, report the failure, and do not proceed to Phase 7 or suggest cb-ship until fixed.

**Step 2 — detect and run E2E tests with Playwright (if available):**

Check for Playwright:
- `package.json` dependencies or devDependencies contains `@playwright/test` or `playwright`
- `playwright.config.ts` / `playwright.config.js` exists in the project root

If Playwright is found:
1. Check if the app needs to be running first — look for a `webServer` config in `playwright.config.*`. If present, Playwright will start it automatically; note this in output.
2. Run: `npx playwright test` (or `yarn playwright test` / `pnpm playwright test` — match what the project uses)
3. Show raw output including browser, test names, pass/fail counts, and any screenshots or trace paths on failure.

If Playwright is not found, check for other E2E runners:
- `cypress.config.*` → `npx cypress run`
- `wdio.conf.*` → `npx wdio`
- `nightwatch.conf.*` → `npx nightwatch`

Run whichever is found. If none found, mark E2E as `– not configured`.

Report format:

**E2E:** ✓ [N passed] / ✗ [N failed] / – not configured
- ✗ [test name] — [failure reason, one line]
- 📸 Screenshot / trace saved at: [path] (if available)

If any E2E tests fail: stop, report, and do not proceed to Phase 7 until addressed. Ask whether to fix the E2E failures now or skip E2E and proceed anyway (only appropriate when E2E failures are pre-existing and unrelated to this fix).

---

## Phase 7: Summary

**Fix Summary** (render as plain markdown)

- **Root cause:** [one line]
- **Fix:** [what changed and why it resolves the cause]
- **Reproduced after fix:** [yes — what was tested and what happened]
- **Files changed:** [list]
- **Unit/integration tests:** [passed N / failed N — details]
- **E2E tests:** [passed N / failed N / not configured]
- **Recurrences:** [none / N found — action taken]
- **Regression check:** [clean / concerns]
- **Pre-Done Gate:** [passed / what failed and how it was fixed]

**Flagged for follow-up:** [anything noticed but intentionally left out of scope]

Ready to ship? Run `cb-ship` to validate, raise a PR, and merge to development.

---

## Auto-exit

When `cb-fix` activates, automatically exit: `cb-debug`, `cb-explore`, `cb-brainstorm`. Announce: `✦ cb-fix on — exited: [list]`
