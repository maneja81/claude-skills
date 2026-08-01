# cb-context

Produce a concise summary of current session state:
- Files read or modified
- Key decisions made
- Open questions or blockers
- Active modes (from memory)
- **Context health:** fresh / mid-session / long (consider `cb-remember` + restart if long)

Most-recent-first. Cap each section to 5 items, note "+N earlier" if more.

One-shot — after the dump, resume normal behavior.
