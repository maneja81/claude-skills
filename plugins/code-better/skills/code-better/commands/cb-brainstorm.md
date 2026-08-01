# cb-brainstorm

---

## Behavior

Explore the problem space before committing to a solution. Read memory and codebase context first, surface multiple options with tradeoffs, give a lean, then stop.

**Hard gate:** Do not suggest implementation or write any code during brainstorm. The output of cb-brainstorm feeds into cb-plan — never directly into cb-workflow or execution.

**No request is too simple to skip:** the rationalization "this is quick, I'll just do it" is exactly where unexamined assumptions cause the most wasted work. Even a two-minute brainstorm catches them. Run it.

---

## Steps

**1. Read context + scope check**
Use MEMORY.md context from the session load (`cb-load`) — prior decisions, conventions, and anything already ruled out are already in context. Re-read MEMORY.md only if `cb-load` has not run this session. Do not scan all files under `0-cowork/memory/` — the session index lists what's there; read specific knowledge files only if directly relevant. Then gather just enough codebase context to be grounded.

Before exploring options, assess scope: if the request describes multiple independent subsystems (e.g. "build a platform with auth, billing, reporting, and notifications"), flag it immediately:

> This looks like multiple independent pieces. Before brainstorming any one part, let's decompose — what are the sub-projects, how do they relate, and which should we tackle first?

Help the user decompose, then brainstorm only the first piece. Each sub-project gets its own brainstorm → cb-plan → execution cycle.

**2. Explore options**
Think out loud. Surface multiple angles, approaches, and tradeoffs. Prioritise breadth over depth in the first pass. Minimum 3 options. Actively look for reuse — what already exists in the codebase that could solve part of this?

Apply YAGNI ruthlessly: remove speculative features from every proposed option. If it's not confirmed needed now, it doesn't appear in the option. Flag it as a future consideration at most.

**3. Give a lean**
State a preferred direction with reasoning — lead with the recommendation, don't bury it. Hold it loosely and flag over-engineering risks in each option.

**Context:** [what was read from memory + codebase]

**Options:**

**A. [approach]** — [tradeoffs, reuse potential, over-engineering risk]

**B. [approach]** — [tradeoffs, reuse potential, over-engineering risk]

**C. [approach]** — [tradeoffs, reuse potential, over-engineering risk]

**Lean:** [recommended option first, and why — specific reasoning, not just "it's simpler"]

**4. Exit condition**
Once 3+ options are surfaced, stop expanding. Ask:

> Want me to go deeper on one of these, run cb-estimate to size the work, or move to cb-plan?

Do not keep generating options unprompted.

---

## Auto-exit

When `cb-brainstorm` activates, exit: nothing. It's a research phase — compatible with all modifiers.

When `cb-plan` or `cb-workflow` activates after brainstorm, `cb-brainstorm` auto-exits (handled by those commands).
