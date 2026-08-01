# cb-remember

Two modes: **save** (default) and **cleanup**.

---

## Default mode — save

1. Check if `MEMORY.md` exists in the project root. If not, create it.
2. Identify what's worth saving: decisions made, architecture choices, conventions, open questions, important file paths.
3. If a topic is large enough, create `0-cowork/memory/{topic}.md` and reference it from `MEMORY.md`.
4. Append only — never overwrite or delete existing entries.
5. Cap each session entry in `MEMORY.md` to 5 bullet points max. If more context exists, split into a topic file.

`MEMORY.md` format:
```markdown
# Memory

## Session [date]
- [decision or context worth keeping]
- See `0-cowork/memory/architecture.md` for full notes

## References
- `0-cowork/memory/architecture.md` — system architecture decisions
- `0-cowork/memory/conventions.md` — code style and naming
```

**Also append to `0-cowork/memory/session_logs.md`** (create if missing):
```markdown
## [date] — [task or topic name]

**Worked on:** [what was built, debugged, or researched]
**Decisions made:**
- [decision and brief reasoning]
**Files changed:** [key files touched]
**Open items:** [anything unresolved or to revisit]
**Watch out for:** [risks, known gotchas]
```

After saving, confirm what was written.

---

## Cleanup mode — `cb-remember cleanup`

Read and consolidate memory files. Never change anything without showing a confirmation diff first.

**Step 1: Read all memory**
- `MEMORY.md`
- `0-cowork/memory/session_logs.md`
- All topic files under `0-cowork/memory/`

**Step 2: Flag candidates for removal**
- **Redundant** — same fact recorded multiple times
- **Superseded** — earlier decision overridden by a later one (keep latest)
- **Resolved** — open questions answered in a later session
- **Stale** — references to files or systems that no longer exist

Always keep: active architectural decisions, conventions still in use, unresolved open items, entries marked ⭐, most recent entry per topic.

**Step 3: Show confirmation diff**
```
Memory Cleanup — Confirmation Required

REMOVE:
  session_logs.md: [date] entry — superseded by [later date]
  MEMORY.md: "Open: should we use Zod?" — resolved [date]

KEEP:
  All architecture decisions
  All active conventions
  [N] session log entries with unique content

[N] entries would be removed. [N] would be kept.
Confirm cleanup? (yes to proceed, no to cancel)
```

**Step 4: Apply only on confirmation.**
After cleanup confirm: "Cleanup complete. Removed [N] entries. All key decisions preserved."
