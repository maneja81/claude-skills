# Planning Protocol

How every plan is produced — the first one and the seventh. Plans are never hand-written: a plan that has not been through this protocol has not been planned.

Plan like a principal engineer who is sceptical of new code and assumes the solution already exists in the codebase until proven otherwise. A plan is written from evidence gathered *this session*, not from assumptions.

**Default stance:** the codebase is the source of truth, not your priors. If you have not read it this session, you do not know it — go read it, or mark it `UNKNOWN` and flag it.

Two gated phases. Do not begin Phase 2 until Phase 1 is complete and shown to the user.

---

## Scope check — before anything else

If the request spans multiple independent subsystems ("add auth, billing and reporting"), stop before discovery:

> This looks like multiple independent pieces. Each should be its own plan — one per subsystem, each producing working, testable software on its own. Should I split these into separate plans, or is there a reason they must ship together?

Wait for confirmation. If they split, create the first plan now and queue the rest with `wpr-plan-add` — do not plan them all in one pass.

---

## Phase 1 — Discovery (mandatory, evidence-gated)

Read `memory/` and the last 20 `decisions.jsonl` entries first — for any plan after the first, most of what you need is already there, written by the PRs that have already merged. Then investigate the actual code the change will touch, following `references/explore-protocol.md`.

Keep discovery targeted: the files in the change surface, their direct dependents, and 1–2 siblings to sample conventions.

**Scope limit:** if you have opened more than 10 files and still don't have a clear picture, stop. Do not guess. Ask the user to point you at the specific area.

Produce this report before any plan. Render as plain markdown, not a code block.

**Discovery**

**Read**
- [files actually opened this session, with line ranges — `apps/api/src/todos.ts:1-80`]
- Not "reviewed the API code" — name the files or it didn't happen

**Searched**
- [what you grepped for and what came back — "searched for an existing date formatter → found `packages/utils/date.ts:formatISO`"]
- ["searched for a retry helper → nothing found"]

**Current state**
- How it works today, pointing at specific files and functions
- Entry points and triggers

**Conventions observed** (from sibling files)
- Naming and structure · error handling · folder placement and imports · test pattern

**Reuse audit** — one entry per thing you are tempted to create new
- Need: [capability] — Existing: [what already does this, or "searched X, Y — found nothing"] — Decision: reuse / extend / create new — because [reason]

---

**Hard rule — no invention.** Every statement about the codebase must trace to an entry under *Read* or *Searched*. If you catch yourself asserting something unverified, go verify it or mark it `UNKNOWN`.

**Hard rule — reuse before create.** No plan may create a new function, file, utility, type or component without a Reuse audit entry showing you looked first. "I didn't find one" is only valid if you actually searched — show the search.

This rule is what keeps plan-005 from rebuilding what plan-002 already shipped. It matters more with every plan that merges.

**Pre-plan self-check** — every box must be yes before Phase 2:

- [ ] I read the files this change touches, rather than inferring from their names
- [ ] I traced who depends on what I am about to change
- [ ] I sampled a sibling file and know the conventions to follow
- [ ] I searched for existing code before proposing anything new
- [ ] I know what this change makes redundant

---

## Phase 2 — The plan

### File structure map — before defining PRs

Map every file the plan will create or modify. This locks in decomposition before PR boundaries are drawn.

| File | Create / Modify | Responsibility |
|---|---|---|
| `exact/path` | Create / Modify | One sentence. If you can't state it in one sentence, the boundary needs work |

Files that change together belong together. Split by responsibility, not by technical layer.

### PR decomposition

Apply the principles and PR types in `phases/02-planning.md`. Each PR must produce working, reviewable software on its own, and each carries:

- **Scope** — one concern, one branch
- **Acceptance criteria** — 3 to 8, each independently verifiable. These become the QA agent's checklist
- **Touches** — files, traced back to a row in the file structure map
- **Current behaviour here** — from Discovery, not invented
- **Blast radius** — callers, types, contracts, schema, consumers
- **Edge cases** — empty, null, maximum, concurrent
- **Breaking changes** — API, schema or contract changes, and any migration needed
- **Verify** — the exact command to run and the output to expect

Also record, once per plan:

- **Done when** — one observable condition confirming the whole plan is complete
- **Removes / obsoletes** — dead code and paths this plan makes redundant, planned for removal rather than left behind
- **Risks and dependencies**
- **Rollback** — how to undo this if it goes wrong

---

## Plan validation

Complete before presenting. If any section reveals a gap, fix the plan first.

**1. Requirement coverage.** Re-read the original ask word by word. Map each requirement to the PR that covers it.

| Requirement | Covered by | Gap? |
|---|---|---|
| [from the ask] | PR-00N / not covered | yes / no |

Any "not covered" row gets a PR or an explicit out-of-scope note. No silent gaps.

**2. Existing codebase impact.** Roll the blast radius up into one view.

| What exists today | PR that touches it | Risk if it breaks |
|---|---|---|

Flag every high-risk row: "⚠ [what] — needs extra care in PR-00N because [reason]."

**3. Plan-level edge cases.** Scenarios no single PR owns — system-level boundaries, multi-PR interactions, state spanning the change. If none: "All edge cases handled at PR level — none span multiple PRs."

**4. Gap check.** Anything the ask requires implicitly — error states, permissions, data consistency, standard platform behaviour — that has no PR covering it.

**5. No placeholders.** Scan every acceptance criterion and reject:
- "TBD", "TODO", "implement later"
- "add appropriate error handling", "add validation", "handle edge cases" — without saying what and where
- "write tests for the above" — without the actual assertions
- "similar to PR-00N" — repeat the specifics
- references to a function, type or file defined in no PR of this plan

**6. Cross-PR consistency.** Do function names, type names, signatures and paths referenced in later PRs match exactly what earlier PRs define? `refreshToken()` in PR-002 and `renewToken()` in PR-005 is a planning bug that surfaces as an execution failure.

---

## Output

Write the validated plan to `.claude/weekend-project/plans/pending/plan-<NNN>-<slug>.json` using the schema in `references/plan-schema.md`, then regenerate `roadmap.md`.

Present the PR table and wait for explicit approval. The approval gate is a correctness gate, not ceremony.
