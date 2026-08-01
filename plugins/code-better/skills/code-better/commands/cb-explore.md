# cb-explore

Explore a project folder, build a structured knowledge map, save to `0-cowork/memory/projects/{project-name}.md`. One-shot, read-only.

**Usage:** `cb-explore <folder-path>` — if no path given, ask first.

---

## Phase 1: Check for graphify data
Look for: `.graphify/` directory, `graphify.json`, `codebase-graph.json`, or any file/folder with "graph" in the name at root level.

- **Found** — use as primary source. Skip or minimise manual directory walking.
- **Not found** — proceed to Phase 2.

---

## Phase 2: Layered exploration (token-efficient)

**Hard limits:** never read more than 10 files total in Layers 2–4. Never read a file larger than ~300 lines in full. If a folder has more than 20 files, list it — do not open. Skip test files, generated files, lock files, build output.

**Layer 1 — Layout (always run)**
List root directory (1 level, then expand key folders 1 more level). Read config files: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `docker-compose.yml`. Read `CLAUDE.md` if present. Use MEMORY.md and session context from `cb-load` rather than re-reading — re-read only if `cb-load` has not run this session. Do not scan all files under `0-cowork/memory/`; the index lists what's there.

**Layer 1.5 — Targeted grep (run before deciding what to read)**
Before opening any source file, use grep/glob to locate the right files rather than guessing:
- Find entry points: grep for `app =`, `router =`, `server.listen`, `if __name__`, `func main`
- Find route definitions: grep for `@app.`, `@router.`, `.get(`, `.post(`, `Route(`
- Find key imports: grep for the most-imported internal modules to identify core dependencies
- Find auth/middleware: grep for `middleware`, `authenticate`, `require_auth`, `JWT`, `token`

Use results to build a ranked file list — read the highest-signal files first. This grep step does not count toward the 10-file read limit.

**Layer 2 — Entry points**
From config + grep results, identify main entry files: server bootstrap, router, CLI entrypoint. Read those only. Identify top-level architectural boundaries.

**Layer 3 — Patterns (spot-check, 1–2 files per area)**
Read one representative file per major area — chosen from grep results, not directory order. Extract: naming conventions, error handling style, auth pattern, data flow. Stop reading once the pattern is clear. For files > 300 lines, read only the first 60 lines (imports + function signatures) to understand shape before deciding whether a full read is worth the tokens.

**Layer 4 — External boundaries (scan only)**
What external services are called? Scan imports and config — do not follow into node_modules or vendor.

---

## Phase 3: Save to memory

Write or update `0-cowork/memory/projects/{project-name}.md`:

```markdown
# [Project Name]
Last explored: [date]
Graphify data: found at [path] / not found

## Stack
[Runtime, framework, language, build tool, key libraries]

## Folder Structure
[Key directories — not exhaustive, just enough to navigate]

## Entry Points
[Where requests come in, where the app starts]

## Conventions
[Naming, error handling, auth, import style]

## External Boundaries
[APIs, queues, databases, third-party services]

## Files Worth Knowing
[2–5 files that most unlock understanding]

## Needs Deeper Exploration
[Folders too large to read — flag for future sessions]

## Open Questions
[Anything ambiguous needing human clarification]
```

If an entry exists, update in place — don't append a duplicate.

---

## Phase 4: Report

```
Explored: [folder path]
Graphify: found / not found
Files read: [N]

Stack: [one line]
Key entry points: [comma-separated]
Saved to: 0-cowork/memory/projects/[name].md

[1–2 sentences on anything notable or worth flagging]
```
