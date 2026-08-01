# Verify Gate

The check that runs after every implementation step and after every individual bug fix. Cheap, fast, and run often — this is not the merge gate.

Detect the project's toolchain and run in this order:

1. **Lint** — eslint, biome, ruff, golangci-lint
2. **Typecheck** — `tsc --noEmit`, mypy
3. **Build** — if the project has a build step
4. **Tests** — vitest, jest, pytest, `go test`

Report as plain markdown, not a code block:

**verify:** ✓ lint · ✓ types · ✓ build · ✗ tests (2 failed)
- ✗ [test name] — [one-line reason]

---

## Rules

- If a stage doesn't exist in this project, mark it `–` and move on. **Never invent a toolchain.**
- **Never suppress or weaken a check to make it pass.** Not `--no-verify`, not `// @ts-ignore`, not `.skip`, not loosening a lint rule. If a check is wrong, that's a finding to raise, not a line to edit.
- Run this after **each** fix during a fix round — never batch several fixes and verify once at the end. A batched verify tells you something broke but not which change did it.
- A failing verify blocks progress to the next concern. Fix it before moving on.

The commands here are the same ones the merge gate runs, plus more. Passing this does not mean a PR is mergeable — see `06-merge-gate.md` for what else has to hold.
