# cb-audit

Read `commands/_shared-rules.md` if not already loaded this session.

Full-app audit — read-only. Sweeps the whole codebase (not just a diff) for bugs, gaps, edge cases, dead code, and repo-wide design decay, then writes every finding to `0-cowork/memory/known-issues.md` as a status-tracked entry. Unlike `cb-prod` / `cb-review-flow` / `cb-pr-review` (all scoped to a diff or a single change), `cb-audit` is the full-project sweep — and unlike those, it persists what it finds so work can be picked up across sessions.

**This command owns whole-repo-scale findings that a diff-scoped review structurally cannot see** — duplicate logic that lives in two files nobody is currently touching, or a god-object that grew slowly over many unrelated PRs. `cb-pr-review` catches DRY/SOLID issues introduced *in a single diff*; `cb-audit` catches the ones that only become visible when the whole codebase is in view at once.

**Usage:**
- `cb-audit` — full codebase
- `cb-audit <path>` — scoped to a folder or file set

One-shot. No fixes — this command only finds and logs.

---

## Step 1: Determine scope

If a path is given, use it. Otherwise scope to the whole project, excluding: `node_modules`, `.git`, build output (`dist`, `build`, `.next`, etc.), lockfiles, and anything in `.gitignore`.

For a large codebase, work module by module (directory by directory) rather than trying to hold everything in context at once. Say so if the scope is large enough to require this.

---

## Step 2: Sweep

Check each of the following. Use the severity levels from `_shared-rules.md` (⛔ critical / ⚠ moderate / · minor).

**Bugs & correctness**
- Logic that doesn't match its own naming, comments, or docs
- Off-by-one errors, incorrect comparisons, wrong operator precedence
- Type mismatches not caught by the compiler (dynamic languages) or suppressed with `any`/`# type: ignore`

**Edge cases & gaps**
- Null / undefined / empty-input handling missing
- Unhandled empty array / zero-row / zero-state cases
- Race conditions, unguarded concurrent access
- Missing auth/permission checks on routes or data access
- Unawaited or unpropagated async errors

**Dead code**
- Unused exports, functions, variables, imports, files
- Unreachable branches (conditions that can never be true, code after unconditional return)
- Commented-out code blocks left in place

**Repo-wide design decay** *(whole-repo scope — this is unique to this command, not covered by diff-scoped reviews)*
- **Cross-file DRY** — the same logic (not just similar-looking code — the same actual behaviour) implemented independently in two or more files that were never part of the same diff. Grep for likely duplicates (similar function names, similar string literals, similar validation/transform patterns) before concluding something is unique.
- **Architecture-level SOLID violations** — files or classes that have accumulated multiple unrelated responsibilities over time (god objects/god files — flag by size + import fan-in/fan-out, not by a fixed line count); circular dependencies between modules; a low-level module that has come to depend on a high-level one.
- These require holding more than one file in view at once — note explicitly which files were compared to reach each finding.

**Production readiness**
Run the full checklist from `_shared-rules.md` (security, reliability, config hygiene, observability, dead weight) across the scoped area, not just changed files.

Do not fix anything found — record it and move to the next item.

---

## Step 3: Deduplicate against existing known issues

Read `0-cowork/memory/known-issues.md` if it exists. Skip any finding that's already logged with a matching file/description (same root cause, not just same file) — note it as "already tracked (KI-N)" instead of creating a duplicate.

---

## Step 4: Write findings to known-issues.md

If `0-cowork/memory/known-issues.md` does not exist, create it:

```markdown
# Known Issues

Deferred bugs, gaps, and follow-up items. Updated by cb-audit, cb-tidy, and cb-workflow.
Resolve items by editing Status — never delete entries.

Status values: Open · In Progress · Fixed · Won't Fix · Deferred

---
```

For each new finding, assign the next sequential ID (`KI-N`, continuing from the highest existing ID — start at `KI-1` if the file is new) and append:

```markdown
### KI-[N] — [short issue title]

**Severity:** ⛔ Critical / ⚠ Moderate / · Minor
**Category:** Bug / Edge case / Dead code / Design decay (DRY/SOLID) / Production readiness
**Status:** Open
**Found:** [date] via cb-audit
**Location:** `[file:line]`
**Description:** [what's wrong — one to three sentences, enough to understand it cold]
**Impact:** [what breaks or is missing if this isn't fixed]
**Suggested fix:** [one line, or "Needs investigation"]
```

Never overwrite or renumber existing entries. Append only.

---

## Step 5: Report

```
Audit Report
Scope: [path or "full codebase"]

FINDINGS THIS RUN
  ⛔ [N critical]  ⚠ [N moderate]  · [N minor]
  Already tracked (skipped as duplicate): [N]

New entries: KI-[N] through KI-[M] → 0-cowork/memory/known-issues.md

BY CATEGORY
  Bugs:                  [N]
  Edge cases / gaps:     [N]
  Dead code:             [N]
  Design decay (DRY/SOLID): [N]
  Production readiness:  [N]

NEXT STEPS
  cb-fix KI-[N]      — implement a fix for one item (root cause confirmed from the entry)
  cb-cleanup         — clear dead code / debug leftovers across the branch
  cb-prod            — re-check production readiness after fixes land
  cb-ship            — validate, raise PR, merge once items are resolved

Triage: edit Status in known-issues.md directly (Open → In Progress / Fixed / Won't Fix / Deferred) as items are worked.
```

If nothing found: say so explicitly — don't manufacture issues. Still note how many pre-existing entries in `known-issues.md` remain `Open`.

---

## Auto-exit

When `cb-audit` activates, automatically exit: `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan`. Announce: `✦ cb-audit — exited: [list]`
