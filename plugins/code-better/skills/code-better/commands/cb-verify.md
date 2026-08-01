# cb-verify

One-shot quality gate. Detect and run in order:
1. **Lint** (eslint, ruff, golangci-lint, etc.)
2. **Typecheck** (tsc --noEmit, mypy, etc.)
3. **Build** (if the project has a build step)
4. **Tests** (jest, vitest, pytest, go test, etc.)

Report (render as plain markdown, not a code block):

**cb-verify:** ✓ lint · ✓ types · ✓ build · ✗ tests (2 failed)
- ✗ [test name] — [one-line reason]

If a stage doesn't exist, mark `–` and move on — never invent a toolchain. Never suppress or weaken a check to make it pass. Referenced by `cb-workflow`, `cb-cleanup`, `cb-feature`. `cb-fast` never skips it.
