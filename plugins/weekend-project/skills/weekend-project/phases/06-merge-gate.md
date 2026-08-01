# Phase 06 — Merge Gate

Run after QA verdict is `pass`. This is the final production gate before merging to `develop-ai`.

The full checklist is in `references/merge-gate-checklist.md` — the automated commands below are the blocking subset, and the manual inspection items in that file are equally required.

---

## Pre-merge checks

Run all checks. Log results to `pr-logs/[branch]/merge-gate.json`.

### 1. Test suite
```bash
pnpm test --run
```
Must pass with zero failures and zero skipped tests. If any tests are skipped, block the merge and flag as `blocker`.

### 2. Type check
```bash
pnpm typecheck
```
Zero errors. Zero warnings suppressed with `// @ts-ignore` or `// @ts-expect-error` without a documented justification comment.

### 3. Lint
```bash
pnpm lint
```
Zero errors. Warnings allowed only if they existed before this PR (check `git diff` scope).

### 4. Build
```bash
pnpm build
```
Must succeed. Build warnings about bundle size are logged but do not block merge (unless size exceeds project-defined threshold).

### 5. Secret scan
```bash
git diff develop-ai...[branch] -- . | grep -iE "(api_key|secret|token|password|credential|private_key)" 
```
Any match that is not a test fixture or a reference to an env variable name blocks the merge.

### 6. Diff scope check
```bash
git diff --stat develop-ai...[branch]
```
Verify the diff is scoped to this PR's stated purpose. Changes to files outside the PR scope are flagged. The Sr. Developer must explain any out-of-scope file changes before the merge proceeds.

**Hard block — no skill state in a PR diff:**
```bash
git diff --name-only develop-ai...[branch] | grep -E '^\.claude/weekend-project/|^\.wpr-worktrees/'
```
Any match blocks the merge. It means an agent wrote state through a relative path from inside the worktree (see the State path rule in `SKILL.md`). Fix by removing those paths from the branch, re-applying the change to the main working tree, and re-running the gate — do not merge and clean up afterwards, because the merge is what makes the stale copy authoritative.

### 7. Commit hygiene
All commits in the branch follow conventional commits format:
- `feat(scope): description`
- `fix(scope): description`
- `chore(scope): description`
- `test(scope): description`
- `docs(scope): description`

Commits with messages like "fix" or "wip" or "asdf" block the merge.

### 8. PR description
Before merging, generate and log the PR description (for the GitHub PR record):

```markdown
## [PR Title]

### What
[1-3 sentences on what this PR does]

### Why
[Why this is needed — what problem it solves]

### Changes
- [file or area]: [what changed]
- [file or area]: [what changed]

### Testing
- Unit tests: [N] new tests
- E2E tests: [N] new tests (if applicable)
- Manual testing: [what was verified]

### Decisions logged
[List of decision IDs from decisions.jsonl for this PR]
```

### 9. Acceptance criteria confirmation
Re-verify all acceptance criteria from the active plan pass. This is a final sanity check — QA already verified these, but the merge gate double-checks before committing.

---

## Merge gate log format

Write to `pr-logs/[branch]/merge-gate.json`:

```json
{
  "branch": "wpr/feature/auth",
  "gate_run_at": "ISO-timestamp",
  "checks": {
    "tests": "pass",
    "typecheck": "pass",
    "lint": "pass",
    "build": "pass",
    "secret_scan": "pass",
    "diff_scope": "pass",
    "commit_hygiene": "pass",
    "acceptance_criteria": "pass"
  },
  "result": "pass"
}
```

If any check fails: `result: fail`. Do not merge. Return to the Sr. Developer with the specific failure.

---

## Merge

If all checks pass:

```bash
cd [project_root]
git checkout develop-ai
git pull origin develop-ai
git merge --no-ff [branch] -m "chore: merge [branch] into develop-ai"
git push origin develop-ai
```

`--no-ff` is required — always create a merge commit so the PR boundary is visible in the git log.

After push, confirm the remote accepted the push. If there's a conflict (another merge happened between the branch creation and now): rebase the branch onto the latest `develop-ai`, re-run the merge gate, then merge.

---

## Post-merge cleanup

```bash
git branch -d [branch]
git worktree remove .wpr-worktrees/[branch-name] --force
```

Push branch deletion to remote:
```bash
git push origin --delete [branch]
```

---

## Update user-facing files

### known-issues.md
Append any `minor` issues from `qa-report.json` that were deferred:

```markdown
| KI-[N] | minor | [branch] | [bug title] | [date] |
```

### open-decisions.md
If the Sr. Developer made any assumptions during this PR that weren't previously logged, add them to `## AI Assumptions`. Move any `## Pending Your Input` items that were resolved during this PR to `## Resolved`.

---

## Trigger memory save

After merge and file updates, save learnings:

1. Read the full PR: what patterns were established, what bugs were found and fixed, what decisions were made.
2. Append to `memory/patterns.md` — any reusable code patterns created in this PR.
3. Append to `memory/qa-learnings.md` — bug patterns the QA agent found (so future PRs avoid them).
4. Append to `memory/decisions.md` — key architectural decisions with rationale.

Format each memory entry with context so future agents can use it without needing to read the full PR log:

```markdown
## [Pattern/Decision name] — from [branch] ([date])
[2-3 sentences explaining what was established and why]
Example: `[code snippet or file reference]`
```

Return to `phases/04-execution.md` Step 8 to advance to the next PR.
