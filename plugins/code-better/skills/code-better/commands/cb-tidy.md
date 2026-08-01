# cb-tidy

Organise the `0-cowork/` folder: validate files, extract context from anything worth keeping, archive stale items, and restructure into a clean layout. Safe by default — never deletes, only archives.

Run this when `0-cowork/` has accumulated cruft: stale plans, loose research files, old scratch notes, or duplicated knowledge files.

---

## Folder target structure

After tidy, `0-cowork/` should look like this:

```
0-cowork/
  memory/
    MEMORY.md               ← project memory (never touched by cb-tidy)
    feedback.md             ← correction log (never touched by cb-tidy)
    session_logs.md         ← session history (never touched by cb-tidy)
    known-issues.md         ← deferred issues tracker (created/updated here)
    [knowledge files]       ← topic-specific .md files
  plans/
    active/                 ← plans being executed now
    pending/                ← parked items from cb-mark-pending
    done/                   ← completed plans
  scratch/                  ← temporary working files (volatile, safe to archive)
  archive/
    YYYY-MM/                ← archived items by month
```

Protected files — **never move, archive, or modify these**:
- `0-cowork/memory/MEMORY.md`
- `0-cowork/memory/feedback.md`
- `0-cowork/memory/session_logs.md`

---

## Phase 1: Scan

List every file in `0-cowork/` recursively. Build a flat inventory:

| File | Last modified | Size | Location |
|---|---|---|---|
| `[path]` | [date] | [bytes] | [current folder] |

Also detect:
- Files in the root of `0-cowork/` that belong in subfolders
- Files in `plans/` without a subfolder (active/pending/done)
- Duplicate or near-duplicate files (same base name in different folders)
- Missing target folders (memory/, plans/active|pending|done/, scratch/, archive/)

Report total: `N files across M folders`

---

## Phase 2: Categorise

Classify each file. Read the file if its classification isn't obvious from name and location.

| File | Category | Reason |
|---|---|---|
| `[path]` | Keep / Archive / Known-issue | [one-line reason] |

**Categories:**

**Keep** — active knowledge or plans that are still useful:
- A plan still in progress or recently completed (within 30 days)
- A knowledge file actively referenced in MEMORY.md
- Any file that contains a decision, finding, or constraint not captured elsewhere

**Archive** — no longer needed but must not be deleted:
- Completed plans older than 30 days with no open items
- Scratch files or drafts that were superseded
- Research that was incorporated into a knowledge file or MEMORY.md
- Session outputs from finished work
- Duplicate files where one is clearly the more current version

**Known-issue** — deferred bugs, limitations, or follow-up work:
- Any file or section that describes a known problem without a resolution
- TODO or open question sections from completed plans
- Items explicitly marked "deferred", "future", or "not in scope" with a reason

**Hard rule:** when in doubt, archive. Do not delete. Do not merge content without explicit user confirmation.

---

## Phase 3: Present findings

Show the user the categorisation before touching anything.

**Tidy Plan — 0-cowork/**

**Keep in place** (N files)
- `[file]` — [one-line reason]

**Move to correct subfolder** (N files)
- `[file]` → `[target path]` — [reason]

**Archive** (N files)
- `[file]` → `archive/YYYY-MM/[filename]` — [reason]

**Known issues to extract** (N items)
- `[file or section]` — [short description of the issue]

**Folders to create** (if any)
- `[path]`

**Protected files — not touched**
- `0-cowork/memory/MEMORY.md`
- `0-cowork/memory/feedback.md`
- `0-cowork/memory/session_logs.md`

---

Stop here and confirm:

> Ready: archive N files, move M files, [create/update] known-issues.md with N items. Nothing deleted. Proceed?

Wait for explicit confirmation before Phase 4.

---

## Phase 4: Extract known issues

Before archiving anything, extract deferred issues from files marked "Known-issue" in Phase 2.

For each issue found, prepare an entry:

```
### [Short issue title]

**Source:** `[file path]` — [date found or last-modified date of the file]
**Status:** Deferred
**Description:** [what the problem is — one to three sentences, enough to understand it cold]
**Impact:** [what breaks or is missing if this isn't fixed — or "Unknown"]
**Blocked by / Deferred because:** [reason it wasn't addressed]
**Reproduce:** [how to trigger it — or "Not documented"]
**Suggested fix:** [if one was noted — or "Not documented"]
**Related files:** [relevant file paths — or "None noted"]
```

If `0-cowork/memory/known-issues.md` does not exist, create it:

```markdown
# Known Issues

Deferred bugs, gaps, and follow-up items. Updated by cb-tidy and cb-workflow.
Add new items manually or via cb-tidy. Resolve items by editing Status to "Resolved" and adding a resolution note — never delete entries.

---
```

Append all extracted entries. Never overwrite existing entries.

---

## Phase 5: Archive and reorganise

Execute the plan from Phase 3. For each action:

**Archive:** move `[source]` → `0-cowork/archive/YYYY-MM/[filename]`
- Create `archive/YYYY-MM/` if it doesn't exist
- Use the current month for YYYY-MM
- If a file with the same name already exists in the archive folder, append `-2`, `-3`, etc.

**Move:** move `[source]` → `[target subfolder]`
- Create target folder if it doesn't exist

**Create folders:** create any missing target folders

After each file action, confirm it completed (check the file exists at the new path).

---

## Phase 6: Update session log

Append to `0-cowork/memory/session_logs.md`:

`[date] — TIDY: archived N files, moved M files, extracted K known issues → known-issues.md`

---

## Phase 7: Report

**Tidy complete**

**Archived:** N files → `0-cowork/archive/YYYY-MM/`
**Moved:** M files to correct subfolders
**Known issues:** K extracted → `0-cowork/memory/known-issues.md` (N total)
**Folders created:** [list or none]
**Protected:** MEMORY.md, feedback.md, session_logs.md untouched

---

## Hard rules

- Never delete any file. Archive only.
- Never modify protected files: MEMORY.md, feedback.md, session_logs.md.
- Never merge file content without user confirmation.
- Never move an active plan (files under `plans/active/`) without explicit user confirmation.
- If a file's category is ambiguous after reading it, default to Keep and flag it in the Phase 3 report.
- Always confirm the Phase 3 plan before executing Phase 4+.
