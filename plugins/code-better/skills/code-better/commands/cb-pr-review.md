# cb-pr-review

Read `commands/_shared-rules.md` if not already loaded this session.

Code review focused on correctness, intent, coverage, design principles, and production readiness — scoped strictly to the diff. Read-only — no fixes. One-shot.

**This command owns code quality on changed files.** For whether the change breaks something downstream, use `cb-review-flow` instead — that command owns blast-radius/integration, not quality. Don't duplicate that work here; if you spot a broken dependent while reviewing, note it once under Correctness and move on rather than tracing the full call chain.

**Usage:**
- `cb-pr-review` — reviews unstaged + staged changes (`git diff HEAD`)
- `cb-pr-review <branch>` — reviews diff against a branch (`git diff main...HEAD`)
- `cb-pr-review <file(s)>` — reviews specific files

---

## Phase 1: Context

Use MEMORY.md and `CLAUDE.md` context from the session load — conventions, prior decisions, and architecture are already in context. Re-read only if `cb-load` has not run this session. Do not scan all files under `0-cowork/memory/`; use the session index to identify relevant knowledge files and read only those if needed for this review.

Detect the change scope:
- If no target given: run `git diff HEAD` to get all staged + unstaged changes
- If branch given: run `git diff <branch>...HEAD`
- If files given: read those files directly

If git is not available or the diff is empty, say so and stop.

---

## Phase 2: Detect test framework

Check for the presence of a test framework before attempting any coverage assessment:

- Python: look for `pytest`, `unittest` in `pyproject.toml`, `setup.cfg`, `requirements*.txt`, or a `tests/` directory
- JS/TS: look for `jest`, `vitest`, `mocha` in `package.json`
- Go: check for `_test.go` files
- Other: check for a `tests/` or `spec/` directory

Result: **found** (name the framework) or **not found** (mark test coverage as N/A throughout).

---

## Phase 3: Review across five dimensions

**1. Correctness**
Does the code do what it claims? Trace the logic for the happy path and at least two edge cases. Flag anywhere the implementation diverges from the stated intent.

**2. Edge cases & error handling**
What inputs or states could break this? Is every error path handled explicitly? No swallowed exceptions, no silent failures. Check boundary conditions: empty input, null/None, max values, concurrent access if relevant.

**3. Test coverage** *(skip entirely if no test framework found — mark N/A)*
Are the changed behaviours covered by tests? For new functions: is there at least one test for the happy path and one for a failure case? For bug fixes: is there a test that would have caught the original bug? Flag untested paths by name.

**4. Conventions & consistency**
Does this match existing naming, structure, error handling, and import style in the codebase? Any patterns introduced here that don't exist elsewhere? Check against `CLAUDE.md` conventions if present.

**5. Code quality & design principles** *(diff-scoped — this dimension is unique to this command)*
Apply these directly to the changed files, not the whole codebase:

- **DRY** — is any logic in this diff duplicated within the diff itself, or does it re-implement something that already exists elsewhere in the codebase? Grep for a likely existing equivalent before flagging "no existing version found" as a pass.
- **SOLID, applied practically:**
  - Single responsibility — does each changed function/class do one thing? Flag functions doing input validation + business logic + persistence in one block.
  - Coupling & abstraction leaks — does this change reach across a layer boundary it shouldn't (e.g. a controller doing raw DB queries, a UI component embedding business rules)?
  - Dependency direction — does the change make a lower-level module depend on a higher-level one, inverting the existing architecture?
- **Complexity & readability** — function/file length, nesting depth, and naming judged against what's normal elsewhere in this codebase (not an abstract standard). Flag anything a reviewer would need to ask "why" about out loud.
- **Cite the file:line for every finding** — a principle violation without a location is not actionable.

**6. Production readiness**
Apply the production readiness checklist from `_shared-rules.md`. Focus on: secrets/credentials, hardcoded values, debug logging left in, dead code, missing input validation at boundaries.

---

## Review comment style

Comments must sound like a senior engineer wrote them — direct, specific, no hedging.

- **Point to the issue directly** — reference `file:line`, name the function or variable. "this can be nil" beats "there may be a potential null reference issue in this area of the code."
- **Question design decisions bluntly** — "is this necessary?", "why do we need this?", "does this mean we always depend on X being available?"
- **Suggest alternatives with the actual code** — don't say "consider a different approach"; show it.
- **State opinions as opinions** — "I don't think this is the right place for this" not "it might perhaps be worth considering whether..."
- **Skip pleasantries** — no "great approach here but...", no "this is a minor nit but...", no "just a thought". State the finding.

Apply the AI language rules from `_shared-rules.md` — no "leverage", "ensure", "comprehensive", filler phrases, or meta-commentary.

---

## Phase 4: Report

```
PR Review
Scope: [files / branch / diff reviewed]
Test framework: [name] / N/A — not detected

CORRECTNESS
  ⛔/⚠/· [file:line] [description — what's wrong and why]

EDGE CASES & ERROR HANDLING
  ⛔/⚠/· [file:line] [description]

TEST COVERAGE              [skip block entirely if N/A]
  ⛔/⚠/· [missing test — which behaviour is uncovered]

CONVENTIONS
  ⚠/· [file:line] [description]

CODE QUALITY & DESIGN PRINCIPLES
  ⛔/⚠/· [file:line] [DRY / SOLID / complexity — description]

PRODUCTION READINESS
  ⛔/⚠/· [file:line] [description]

VERDICT
  ✓ Good to merge
  ⚠ Merge with minor fixes — [list]
  ✗ Do not merge — [N critical issues must be resolved first]

SUGGESTED NEXT STEPS
  [cb-fix <issue> — for bugs]
  [cb-cleanup — for conventions/dead code]
  [cb-prod — for full production readiness sweep if needed]
```

Omit any section that has no findings. If everything is clean, say so explicitly — don't manufacture issues.

---

## Auto-exit

When `cb-pr-review` activates, automatically exit: `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan`. Announce: `✦ cb-pr-review — exited: [list]`
