# cb-refresh

Reloads the skill instructions and clears all active modes. Use mid-session when skill files have been updated and you want the new behavior to take effect without starting a new session.

**What it does:**
1. Re-reads `SKILL.md` — picks up any changes to inline commands, mode rules, routing table, stacking precedence, auto-exit rules
2. Re-reads any heavy command files already loaded this session — picks up changes to cb-plan, cb-workflow, cb-fix, etc.
3. Clears all active modes and deletes `.cb-modes` — fresh slate so updated rules apply cleanly
4. Runs `cb-load` — re-primes session context (feedback rules, memory, session log, index)

---

## Step 1: Snapshot active state (silent)

Before clearing anything, note:
- Which modes are currently active (from `.cb-modes`)
- Which command files were read this session (from session memory)

---

## Step 2: Re-read SKILL.md

Read `SKILL.md` in full. Apply all updated definitions immediately:
- Inline command behavior (cb-read-only, cb-careful, cb-fast, cb-debug, cb-scope, etc.)
- Mode persistence rules and write-time conflict checks
- Stacking precedence and auto-exit rules
- Routing table (for any renamed or added commands)
- Canonical command list

---

## Step 3: Re-read loaded command files

Re-read each heavy command file that was already loaded this session. If session memory does not track which files were loaded, re-read the files referenced in the routing table that are most likely to have been used (cb-plan, cb-workflow, cb-fix, cb-feature, _shared-rules).

---

## Step 4: Clear all active modes

Delete `.cb-modes`. All modes are now inactive. Do not re-adopt any modes from the previous state — the user will re-activate what they need with the updated skill in effect.

---

## Step 5: Run cb-load

Run the full `cb-load` flow (read `commands/cb-load.md`). Produce the standard session briefing so context is fully re-primed.

---

## Step 6: Confirm

After the `cb-load` briefing, add this block:

**cb-refresh complete**

- SKILL.md — re-read ✓
- Command files refreshed — [list of files re-read, or "none tracked this session — refreshed likely candidates"]
- Active modes cleared — [list of modes that were active, now cleared] / none were active
- Session context — re-loaded via cb-load ✓

Updated skill instructions are now active. Re-activate any modes you need.
