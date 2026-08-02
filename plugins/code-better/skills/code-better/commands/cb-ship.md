# cb-ship

Read `commands/_shared-rules.md` if not already loaded this session.

End-to-end ship command. Validates the current state of the branch, raises a PR, and merges to the development branch. Chains naturally after `cb-fix` but works standalone when the branch is already in a shippable state.

One-shot — returns to normal behavior after completing or failing.

---

## Phase 1: Pre-flight checks

Before touching git, confirm the workspace is clean enough to ship.

**1a — Confirm target branch:**

Check git config and remote to determine the development branch:
- Run `git remote show origin` and look for the HEAD branch
- Common names to check: `develop`, `development`, `dev`, `staging`, `main`, `master`
- If ambiguous, ask the user: "Which branch should I merge into — develop or main?"

Do not guess. Do not default silently to main if a develop branch exists.

**1b — Check working tree:**

Run `git status`. If there are unstaged or uncommitted changes, stop:

> Uncommitted changes found. Commit or stash them before running cb-ship.
> [list the files]

**1c — Run cb-verify gate:**

Run lint → typecheck → build → tests (from `_shared-rules.md`). Show raw output.

**cb-verify:** ✓ lint · ✓ types · ✓ build · ✓ tests

If any stage fails: stop here. Do not proceed until the gate passes. Suggest `cb-fix` if a test is failing.

**1d — Run E2E tests (if configured):**

Same detection logic as cb-fix Phase 6 Step 2. Check for Playwright, Cypress, WDIO, or Nightwatch.

If found, run them now. Show raw output.

**E2E:** ✓ [N passed] / ✗ [N failed] / – not configured

If E2E tests fail: stop and report. Ask:
> E2E tests are failing. Fix them before merging, or proceed anyway? (proceeding is only appropriate if these failures are pre-existing and unrelated to this branch)

Do not auto-proceed on E2E failure — require an explicit yes.

---

## Phase 2: Production readiness scan

Run `cb-prod` scoped to this branch's changed files:

Run `git diff --name-only $(git merge-base HEAD origin/<target-branch>)..HEAD` to get the file list, then audit those files against the production readiness checklist from `_shared-rules.md`.

If any ⛔ critical findings: stop. Do not create a PR until critical issues are resolved.

If ⚠ moderate findings: report them and ask:
> [N] moderate issues found. Resolve before raising the PR, or proceed and flag them in the PR description?

If · minor only or clean: proceed automatically.

---

## Phase 3: PR description

Generate the PR description from the branch diff. Do not ask the user to write it — draft it and confirm.

Gather context:
- `git log $(git merge-base HEAD origin/<target-branch>)..HEAD --oneline` — commit list
- `git diff $(git merge-base HEAD origin/<target-branch>)..HEAD --stat` — changed files summary
- Session context: the fix description, root cause, and test results from cb-fix (if available)

Draft the PR description in this format:

---
## What changed
[2–4 sentences: what the fix does, not how. Describe the user-visible or system-level outcome.]

## Root cause
[One line — what was broken and why. Omit if this is a feature, not a fix.]

## Testing
- Unit/integration: [passed N / not configured]
- E2E: [passed N / not configured]
- Manual: [describe the specific scenario tested to confirm the fix]

## Notes
[Any follow-up items flagged during cb-fix, known limitations, or pre-existing failures in E2E]
---

Show the draft to the user and ask: "PR description looks good? (yes to proceed / edit inline)"

Wait for confirmation before creating the PR.

---

## Phase 4: Raise the PR

Check for `gh` CLI:
- Run `which gh` — if not found, fall back to instructions: "gh CLI not found. Create the PR manually at: [git remote get-url origin converted to browser URL]"
- If found, check auth: `gh auth status` — if not authenticated, stop and say so.

Create the PR:

```
gh pr create \
  --base <target-branch> \
  --title "<branch name converted to sentence — strip prefixes like fix/, feat/, chore/>" \
  --body "<PR description from Phase 3>"
```

Show the PR URL. If creation fails, show the raw error and stop.

---

## Phase 5: CI wait (if configured)

Check if the repo has CI configured:
- Look for `.github/workflows/` with push or PR triggers
- Look for `.circleci/`, `.travis.yml`, `Jenkinsfile`, `bitbucket-pipelines.yml`

If CI is found:
- Run `gh pr checks --watch` to stream CI status
- Wait for CI to complete before proceeding to merge
- If CI fails: stop. Show which checks failed. Do not merge. Suggest fixing and re-running `cb-ship`.

If no CI is detected: proceed directly to Phase 6 and note it in the summary.

---

## Phase 6: Merge

After CI passes (or if no CI), merge the PR:

```
gh pr merge --squash --delete-branch
```

Squash by default — one clean commit per fix. If the user has specified a different merge strategy (merge commit or rebase) earlier in the session or in `CLAUDE.md`, use that instead.

`--delete-branch` removes the source branch after merge. If the branch should be kept, the user must say so before this phase.

Confirm merge:

**Merged:** [PR URL]
**Into:** [target-branch]
**Strategy:** squash
**Branch deleted:** yes / no

---

## Phase 7: Summary

**Ship Summary**

- **Branch:** [branch name]
- **Target:** [target branch]
- **cb-verify:** [passed / failed]
- **E2E:** [passed N / failed N / not configured]
- **Production readiness:** [clean / N moderate flagged in PR]
- **CI:** [passed / not configured]
- **PR:** [URL]
- **Merged:** yes / no
- **Follow-up:** [anything flagged during the run that needs attention]

---

## Auto-exit

When `cb-ship` activates, automatically exit: `cb-workflow`, `cb-explore`, `cb-brainstorm`, `cb-plan`, `cb-feature`. Announce: `✦ cb-ship on — exited: [list]`
