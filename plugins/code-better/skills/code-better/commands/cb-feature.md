# cb-feature

Read `commands/_shared-rules.md` if not already loaded this session.

End-to-end workflow for building a new feature. Chains: understand → (spec?) → (impact?) → brainstorm → (estimate?) → plan → execute → cleanup → review. `cb-careful` is active throughout.

---

## Phase 1: UNDERSTAND

Use MEMORY.md context from the session load (`cb-load`) — decisions, conventions, and prior work are already in context. Re-read MEMORY.md only if `cb-load` has not run this session. Do not scan all files under `0-cowork/memory/`; the session index lists what's there — read specific knowledge files only if directly relevant to this feature. Scan codebase structure: existing patterns, utilities, folder conventions, naming style, anything that might already solve part of the problem.

Then apply `cb-ask` behavior — ask all clarifying questions in one structured block:
```
Scope
  - What exactly should this feature do?
  - What should it NOT do?

Output & contracts
  - Any specific UX, API contract, or data shape expected?

Existing codebase
  - Are there existing components/functions this should reuse or extend?

Constraints
  - Any known constraints (performance, backwards compatibility, permissions, data volume)?
```

If a written spec is provided, offer: "Want me to run `cb-spec` to validate it for gaps before we brainstorm?"

Wait for answers. If vague or partial, proceed but state which assumptions you're filling in.

If the feature touches shared or sensitive code, offer: "Want me to run `cb-impact` to map the blast radius before planning?"

---

## Phase 2: BRAINSTORM *(cb-brainstorm rules)*

Surface 2–3 approaches grounded in existing codebase patterns. Actively look for reuse. Flag over-engineering risks in each option. Give a lean with reasoning.

Wait for user to confirm direction before Phase 3.

---

## Phase 2.5: ESTIMATE *(optional)*

After brainstorm direction is confirmed, offer: "Want a `cb-estimate` before we plan? It'll size complexity, risk, and effort across the agreed approach." If yes, run `cb-estimate`. If no, proceed to Phase 3.

---

## Phase 3: PLAN *(cb-plan + cb-careful rules)*

Use session memory context — re-read MEMORY.md only if context has been compacted. Produce a full step-by-step plan with status tracker. Each step must include: details, edge cases, error handling, breaking changes. Hard rules from `_shared-rules.md` apply.

Wait for "cb-workflow" to proceed to Phase 4.

---

## Phase 4: EXECUTE *(cb-workflow rules)*

One step at a time. Validate via `cb-verify` before proceeding. Register all steps as tasks via `TaskCreate` before starting. Update task status as steps complete. No scope creep. Ask before any irreversible action. Update status tracker `[ ]` → `[✓]`.

---

## Phase 4.5: PRE-DONE GATE

Before cleanup, run the Pre-Done Gate from `commands/_shared-rules.md`:

1. **Diff review** — re-read every changed line against the original feature requirement
2. **Side-effect check** — confirm all callers, types, routes, validators, exports are consistent with the changes
3. **Integration path trace** — trace the full user journey for this feature end-to-end: from the UI action or API call, through controllers, services, DB, and back to the response or rendered state. At each hop confirm the code actually connects.
4. **Common failure modes** — null/empty/auth/async/config checks
5. **cb-verify** — lint → typecheck → build → tests with raw output
6. **Requirement check** — re-read the original feature ask and confirm every part of it is delivered

Do not proceed to Phase 5 until all six pass. Fix any failures first.

---

## Phase 5: CLEANUP *(cb-cleanup rules)*

Run the full cleanup workflow: baseline verify, dead code, debug cleanup, conventions check, production readiness, re-verify.

---

## Phase 6: REVIEW *(cb-review-flow rules)*

Trace end-to-end flow, check all dependents at 2+ levels, produce the full report. Don't declare done until the report is clean.

---

## Auto-exit

When `cb-feature` activates, automatically exit: `cb-explore`, `cb-brainstorm`, `cb-plan`, `cb-rubber-duck`, `cb-scope`, `cb-workflow`. Announce in one line: `✦ cb-feature on — exited: [list]`

Never exit: `cb-careful`, `cb-thorough`, `cb-explain`, `cb-fast`, `cb-minimal`, `cb-ask`, `cb-read-only`. These persist across all phases.
