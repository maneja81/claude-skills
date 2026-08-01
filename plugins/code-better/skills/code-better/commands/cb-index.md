# cb-index

Builds a structured index of the `0-cowork/` directory, then saves a shell script to regenerate it in one command any time.

Run this when setting up a new project or after the folder structure changes significantly.
The index is consumed by `cb-load` at session start — keeping it current means the agent always has an accurate map.

---

## Step 1 — Locate folder

Check for:
- `0-cowork/` — must exist (create it if missing)

---

## Step 2 — Scan and build index

Run this shell command to gather the raw structure:

```bash
# 0-cowork full tree (depth 4, show files)
find 0-cowork -maxdepth 4 | sort
```

For each file found in `0-cowork/`, classify it:

| Pattern | Classification |
|---|---|
| `MEMORY.md` | Session memory |
| `0-cowork/memory/session_logs.md` | Session history log |
| `0-cowork/memory/feedback.md` | Agent correction rules |
| `0-cowork/memory/known-issues.md` | Deferred issues tracker |
| `0-cowork/memory/*.md` | Knowledge / notes file |
| `0-cowork/agents/*/outputs/` | Agent pipeline run |
| `0-cowork/agents/*/outputs/final-report.md` | Pipeline final report |
| `0-cowork/agents/*/outputs/plan.md` | Approved plan |
| `0-cowork/plans/active/` | Plans in progress |
| `0-cowork/plans/pending/` | Parked items |
| `0-cowork/plans/done/` | Completed plans |
| `0-cowork/scripts/` | Utility scripts |
| `CLAUDE.md` | Project conventions |
| `.cb-modes` | Active mode state |

---

## Step 3 — Write index file

Save to `0-cowork/index.md`:

```markdown
# 0-cowork Index
Generated: {YYYY-MM-DD HH:MM}
Regenerate: bash 0-cowork/scripts/update-index.sh

---

## Memory & Context Files

| File | Purpose |
|---|---|
| MEMORY.md | Session memory — decisions, open items, watch-outs |
| 0-cowork/memory/session_logs.md | Full session history log |
| 0-cowork/memory/feedback.md | Agent correction rules (logged mistakes) |
| 0-cowork/memory/known-issues.md | Deferred issues tracker |
| 0-cowork/memory/{other files} | {description inferred from filename} |

---

## Agent Pipeline Runs

| Folder | Task | Date | Verdict |
|---|---|---|---|
| 0-cowork/agents/{slug}/ | {task name from final-report.md if exists, else slug} | {date from slug} | {verdict from final-report.md if exists, else "in progress"} |

(If no agent runs exist yet: "No pipeline runs yet.")

---

## Plans

| File | Status |
|---|---|
| 0-cowork/plans/active/{file} | Active |
| 0-cowork/plans/pending/{file} | Pending |
| 0-cowork/plans/done/{file} | Done |

---

## Scripts

| Script | What it does |
|---|---|
| 0-cowork/scripts/update-index.sh | Regenerates this index file |

---

## Quick Stats
  Memory entries:   {count of ## headings in MEMORY.md}
  Feedback rules:   {count of rules in feedback.md}
  Pipeline runs:    {count of folders under 0-cowork/agents/}
  Known issues:     {count in known-issues.md}
```

---

## Step 4 — Save the regeneration script

Save to `0-cowork/scripts/update-index.sh`:

```bash
#!/bin/bash
# update-index.sh — regenerates 0-cowork/index.md
# Run from the project root: bash 0-cowork/scripts/update-index.sh

set -e

INDEX="0-cowork/index.md"
GENERATED=$(date "+%Y-%m-%d %H:%M")

echo "# 0-cowork Index" > "$INDEX"
echo "Generated: $GENERATED" >> "$INDEX"
echo "Regenerate: bash 0-cowork/scripts/update-index.sh" >> "$INDEX"
echo "" >> "$INDEX"
echo "---" >> "$INDEX"
echo "" >> "$INDEX"

# --- Memory files ---
echo "## Memory & Context Files" >> "$INDEX"
echo "" >> "$INDEX"
echo "| File | Exists |" >> "$INDEX"
echo "|---|---|" >> "$INDEX"
for f in "MEMORY.md" "0-cowork/memory/session_logs.md" "0-cowork/memory/feedback.md" "0-cowork/memory/known-issues.md"; do
  if [ -f "$f" ]; then
    echo "| $f | ✓ |" >> "$INDEX"
  else
    echo "| $f | – missing |" >> "$INDEX"
  fi
done
find 0-cowork/memory -maxdepth 1 -name "*.md" \
  ! -name "session_logs.md" ! -name "feedback.md" ! -name "known-issues.md" 2>/dev/null | sort | while read f; do
  echo "| $f | ✓ |" >> "$INDEX"
done
echo "" >> "$INDEX"

# --- Agent runs ---
echo "## Agent Pipeline Runs" >> "$INDEX"
echo "" >> "$INDEX"
if [ -d "0-cowork/agents" ] && [ "$(ls -A 0-cowork/agents 2>/dev/null)" ]; then
  echo "| Folder | Date |" >> "$INDEX"
  echo "|---|---|" >> "$INDEX"
  for d in 0-cowork/agents/*/; do
    slug=$(basename "$d")
    date_part=$(echo "$slug" | grep -oE "^[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "unknown")
    echo "| $d | $date_part |" >> "$INDEX"
  done
else
  echo "_No pipeline runs yet._" >> "$INDEX"
fi
echo "" >> "$INDEX"

echo "---" >> "$INDEX"
echo "_Index updated by update-index.sh_" >> "$INDEX"

echo "✓ Index written to $INDEX"
```

Make the script executable:
```bash
chmod +x 0-cowork/scripts/update-index.sh
```

---

## Step 5 — Confirm

```
✓ Index built → 0-cowork/index.md
  Memory files:   {N}
  Agent runs:     {N}
  Known issues:   {N found / none}

Script saved → 0-cowork/scripts/update-index.sh
Run any time to refresh: bash 0-cowork/scripts/update-index.sh
```

---

## When to re-run

- After a `cb-agents` pipeline run completes (new folder appears)
- When `cb-load` reports the index is missing or stale (older than 7 days)
- After running `cb-tidy` (folder structure changed)
