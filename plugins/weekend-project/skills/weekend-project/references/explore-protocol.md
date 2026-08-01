# Exploration Protocol

Read before writing code in any PR, and before planning against an existing codebase. Read-only. The goal is a working mental model at the lowest token cost that still gets the details right.

Never assume file locations, import paths, existing utilities, or naming conventions. Read first, then act.

---

## Hard limits

These exist because exploration is the easiest place to burn a PR's entire token budget.

- Never read more than **10 files** in Layers 2–4.
- Never read a file larger than **~300 lines** in full — read the first 60 (imports and signatures) to understand its shape, then decide if the rest is worth it.
- If a folder has more than **20 files**, list it — do not open it.
- Skip test files, generated files, lock files and build output unless they are the subject of the PR.
- Never follow into `node_modules/`, `vendor/`, or `dist/`.

---

## Layer 1 — Layout (always run)

List the root directory one level deep, then expand key folders one more level.

Read the manifests: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `docker-compose.yml`, and `CLAUDE.md` if present.

For a project already under way, prefer what memory already knows: `.claude/weekend-project/memory/` and `decisions.jsonl` were written by earlier PRs specifically so this layer stays cheap. Re-read source only where memory is silent or stale.

## Layer 1.5 — Targeted grep (before opening anything)

Locate files instead of guessing at them. Grep does not count toward the 10-file limit.

- Entry points: `app =`, `router =`, `server.listen`, `if __name__`, `func main`
- Route definitions: `@app.`, `@router.`, `.get(`, `.post(`, `Route(`
- Core modules: the most-imported internal paths
- Auth and middleware: `middleware`, `authenticate`, `requireAuth`, `JWT`, `token`

Use the results to build a ranked list. Read highest-signal first.

## Layer 2 — Entry points

From the manifests and grep results, identify where the app starts and where requests arrive. Read those files only. Note the top-level architectural boundaries.

## Layer 3 — Patterns (1–2 files per area)

Read one representative file per major area, chosen from grep results rather than directory order. Extract naming conventions, error-handling style, auth pattern, data flow. **Stop reading as soon as the pattern is clear** — a third example teaches nothing the second didn't.

## Layer 4 — External boundaries (scan only)

What does this call out to? Scan imports and config for databases, queues, third-party APIs. Do not follow into their source.

---

## Record what you learned

Append to `.claude/weekend-project/memory/patterns.md` — anything a later PR would otherwise rediscover:

```markdown
## [Area] — from [branch] ([date])
[2-3 sentences: the convention, and why it is the way it is]
Example: `[file reference]`
```

This is the mechanism that lets PR-004 know what PR-001 established without re-reading the repo. Conventions that surprised you are the highest-value entries — if it surprised you, it will surprise the next agent too.

Anything ambiguous that a human should settle goes to `open-decisions.md`, not into an assumption.

---

## Report

```
Explored: [scope]
Files read: [N] of 10

Stack: [one line]
Entry points: [comma-separated]
Conventions noted: [count] → memory/patterns.md

[Anything worth flagging in 1-2 sentences]
```
