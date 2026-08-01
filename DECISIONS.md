# Decisions

Non-obvious choices in this repository, with the alternatives that were rejected. Recorded because each of these looks arbitrary from the outside, and each is the kind of thing a later change could undo by accident.

The skills themselves require a decision log with rationale and rejected alternatives. This applies the same rule to the repository.

---

## `weekend-project` does not depend on `code-better`

**Decision.** `weekend-project` carries its own exploration protocol, verify gate and merge gate. It declares no plugin dependency, reads no file belonging to another skill, and works identically whether or not `code-better` is installed.

**Why.** An earlier draft delegated a dozen steps to `code-better` by reading its command files from a hardcoded path. That never worked. Installed as a plugin, a skill runs from the plugin cache, so the path resolves to nothing — and three of the four supported install methods have no dependency resolution at all. Declaring the dependency would have installed the other skill successfully while leaving every file read broken, which is worse than not declaring it, because the failure looks like it should work.

**Rejected.**

- *Declare `dependencies: ["code-better"]`.* Guarantees installation, not readability. Also forces a forty-command mode system onto anyone who wants only the builder, and blocks disabling that skill while the builder is enabled.
- *Vendor the command files into `weekend-project`.* About 1,100 lines duplicated into a skill whose design principle is loading only what a step needs.
- *Symlink between plugins.* Supported within a marketplace and dereferenced into the cache — but skipped entirely for local-path installs, and left dangling by a plain `cp -R`. Two of four install paths break.
- *Install the other skill into the target project when missing.* Requires shipping a full copy inside the builder, and silently adds a second skill with session-persistent modes to someone's project in the middle of an unattended build.

---

## Plans are referenced by ID, never by path

**Decision.** `session.yaml` stores `current_plan: plan-002`. The file is located by globbing `plans/*/plan-002-*.json`. No path is ever stored.

**Why.** Plans move between `pending/`, `active/`, `done/` and `deferred/` as their status changes. Storing a path means every move is a two-step operation — move the file, update the pointer — that can be interrupted halfway, leaving the two disagreeing. Resumption after an interruption is the feature the whole skill rests on, so it cannot be the thing that breaks.

With ID references, `session.yaml` is the single authority and folder placement is a derived view. `wpr-resume` reconciles: a plan named as current but sitting in `pending/` is moved, a stray file in `active/` is returned. A half-finished move self-heals instead of orphaning work.

**Rejected.**

- *Status as a field in the file, one flat directory.* Loses the property that `ls plans/pending/` answers "what is queued" without opening anything.
- *Status in both the folder and a field, folder authoritative.* Two mutable sources for one fact. They drift.

---

## Execution stops at every plan boundary

**Decision.** When a plan's PRs are all merged, execution stops, reports what the plan cost against its estimate, and asks before starting the next one. `auto_continue: true` opts out.

**Why.** The reason to split a large project into several plans is budget control. Chaining them automatically spends the whole budget in one unattended run and removes the control that motivated the split. The boundary is also the natural review point: there is merged, working software on `develop-ai`, and looking at it before building on top of it is cheaper than discovering a wrong assumption three plans later.

**Rejected.**

- *Always continue automatically.* Contradicts the reason plans exist.
- *Always stop, no opt-out.* Some projects genuinely want the full unattended chain, and refusing that is paternalistic.

---

## Skill state lives only in the main working tree

**Decision.** Every read and write of `.claude/weekend-project/` uses an absolute path under the project root, even when the shell is inside a build worktree. A `wpr/*` branch may never stage a path under that directory, and the merge gate blocks the merge if one appears.

**Why.** Each PR builds in its own `git worktree`, which contains a full copy of every tracked file — including a snapshot of the state directory as it stood when the branch was created. A relative write from inside the worktree therefore lands in that stale snapshot: the decision log, memory update or budget change is written to the wrong file, committed into the PR branch, and destroyed when the worktree is removed. Nothing errors.

The rule has a second benefit. Because PR branches never touch state, merging one can never conflict on a state file — which is what makes it safe to commit all of it.

**Rejected.**

- *Gitignore the state directory entirely.* Plan files must be in the repository for a worktree created from `develop-ai` to contain them, and the decision log and memory are the record of why the codebase looks the way it does.
- *Let PR branches carry their own state changes.* Guarantees merge conflicts on every state file, and makes the stale snapshot authoritative on merge.

---

## Plans are generated, never hand-written

**Decision.** Every plan goes through the planning protocol: evidence-gated discovery, a reuse audit, and a validation pass. There is no supported way to drop a hand-authored plan file into `plans/pending/` and expect it to run.

**Why.** The review loop works because acceptance criteria are independently verifiable. "Returns 422 with a field-level error array" drives a QA pass; "validation works" drives nothing. Hand-written plans reliably produce the second kind. Accepting them would mean either executing weak criteria or building a validator that rejects most of what a human writes — and the second is just the planning protocol with worse ergonomics.

The reuse audit matters more with every plan that merges: it is what stops the fifth plan rebuilding what the second one shipped.

**Rejected.**

- *Accept hand-written plans, validate on load.* Two code paths, and the failure is discovered after the user has already written the file.
- *Accept them and harden criteria automatically.* That is generating the plan, with the user's draft as an input — which the interview already supports.

---

## Both skills live in one marketplace repository

**Decision.** One repository, one `marketplace.json`, two independently versioned plugins under `plugins/`. Releases are tagged `<plugin-name>--v<version>`.

**Why.** Users add one marketplace and install either or both. The tag convention exists precisely so a single repository can host multiple plugins on separate version lines, so independence costs nothing. Two repositories would mean two marketplaces to add, and two sets of scaffolding to keep in step.

**Rejected.**

- *A repository per skill.* More standalone identity, more friction for anyone who wants both, duplicated infrastructure.
- *One plugin containing both skills.* Forces both on everyone and couples their version lines.

---

## `main` is the default branch

**Decision.** `main` is the default and holds released work. Development happens on `develop`. Feature branches squash into `develop`; `develop` merges into `main` with a merge commit.

**Why.** Adding a marketplace without an explicit ref fetches the **default branch**. If the default were the development branch, every installer would receive work in progress. The default branch of a distribution repository is a published artefact, not a workspace.

**Rejected.**

- *Development branch as default.* Ships unfinished work to everyone who installs.
- *A single branch.* No place for work that is not ready to be installed.
