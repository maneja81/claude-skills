# cb-prod

Read `commands/_shared-rules.md` if not already loaded this session.

Standalone production readiness audit. Read-only — no fixes. Scope is whatever the user points at; default to recently changed files.

**Determining scope when not specified:** run `git diff --name-only HEAD` (staged + unstaged) and `git status --short` to identify changed files. Audit those. If git is not available or the repo has no commits, ask the user to specify which files to audit.

Use the full production readiness checklist from `_shared-rules.md`. Use severity levels from `_shared-rules.md`.

---

## Output format

```
Production Readiness Report
Scope: [files / feature / PR audited]

CRITICAL
  ⛔ [file:line] [description — why it's a production risk]

MODERATE
  ⚠ [file:line] [description]

MINOR
  · [file:line] [description]

VERDICT
  ✓ Ready to ship
  ✗ Not ready — [N critical, N moderate must be resolved]
```

Omit empty categories. If everything is clean, say so explicitly.

One-shot — after the report, resume normal behavior.

---

## Auto-exit

When `cb-prod` activates, automatically exit: `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan`. Announce: `✦ cb-prod — exited: [list]`
