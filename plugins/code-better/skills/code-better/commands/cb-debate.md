# cb-debate

Adversarial multi-agent review. Two independent agents read the codebase and build opposing cases — one FOR, one AGAINST your query. They debate for up to 5 rounds with evidence-gated rebuttals, then the orchestrator synthesizes a final verdict.

**Use for:** architectural decisions, technology choices, refactoring approaches, "should we do X?", disputed implementation strategies, build-vs-buy questions.

**Not worth the cost for:** clear-cut questions, style preferences, anything with an obvious answer from a quick read. The pre-check gate will catch these.

**Usage:**
- `cb-debate <question>` — debate with auto-detected project repos
- `cb-debate <question> --path <codebase-path>` — specify a root path explicitly

---

## Step 0: Pre-check — is this worth a debate?

Before spawning any agents, the orchestrator evaluates the question. This is mandatory — it protects cost.

**Assess all three:**
1. Is there a genuine tradeoff where reasonable engineers could disagree based on the codebase?
2. Does the answer depend on codebase-specific evidence that isn't obvious without reading it?
3. Is the decision consequential enough to justify two full codebase reads plus up to 5 debate rounds?

**If the answer to any of the three is no** — do not run the debate. Respond directly:

> This question doesn't need a debate — [one-line reasoning]. [Direct answer or recommendation].

**If all three are yes**, show this before proceeding:

> **cb-debate starting.** Two agents will independently read the codebase and build opposing cases, then debate for up to 5 evidence-gated rounds. Token cost is high — this is appropriate for the question.
>
> Question: [restate the question precisely, as the orchestrator understands it]
>
> Proceeding...

If the question is ambiguous, restate it precisely and confirm with the user before spawning agents.

---

## Step 1: Codebase load

Check for `CLAUDE.md` and `0-cowork/` to confirm a project is loaded. If neither exists, ask the user to confirm the working directory before proceeding.

If no codebase is found and the question requires codebase evidence:

> cb-debate needs access to the codebase for this question. Connect a folder in Cowork or pass `--path <root>`.

Wait for the user to connect or provide a path. Do not proceed without it.

If the question is purely architectural or conceptual (no codebase scan required), note this explicitly and skip to Step 2.

Show what was found:
> Codebase: [detected root] — [key project folders found]

---

## Step 2: Independent research — spawn two agents

Spawn Agent A and Agent B simultaneously. They do not share findings at this stage — each reads the codebase independently and builds their case from scratch.

---

### Agent A — PRO

Read the codebase. Your task: build the strongest honest case FOR the query.

Your job is not to be right — it is to find every piece of evidence, pattern, precedent, and reasoning that supports the affirmative position. Do not strawman the CON position. Do not hide risks — acknowledging them honestly makes the PRO case stronger, not weaker.

Cite every file, pattern, and line you rely on. Uncited claims do not count as evidence.

**Produce:**

**PRO — Core claim:** [one sentence stating the FOR position precisely]

**Evidence from codebase:**
- [file / pattern / line] — [why this supports the PRO case]
- [repeat for each piece of evidence]

**Strongest argument:** [the single most compelling reason to adopt this — grounded in evidence]

**Risks acknowledged from PRO side:** [real risks you see even as the PRO agent — do not minimise]

---

### Agent B — CON

Read the codebase. Your task: build the strongest honest case AGAINST the query.

Your job is not to be right — it is to find every piece of evidence, counter-pattern, risk, and cost that argues against the affirmative position. Do not strawman the PRO position. Do not hide merits — acknowledging them honestly makes the CON case stronger, not weaker.

Cite every file, pattern, and line you rely on. Uncited claims do not count as evidence.

**Produce:**

**CON — Core claim:** [one sentence stating the AGAINST position precisely]

**Evidence from codebase:**
- [file / pattern / line] — [why this supports the CON case]
- [repeat for each piece of evidence]

**Strongest argument:** [the single most compelling reason to reject this — grounded in evidence]

**Merits acknowledged from CON side:** [real merits you see even as the CON agent — do not minimise]

---

## Step 3: Debate loop — max 5 rounds

### Evidence gate (hard rule — enforced every round from round 2 onward)

Each rebuttal must introduce at least one new piece of codebase evidence — a file, pattern, dependency, or behaviour **not cited in any prior round**. A rebuttal that only restates prior arguments without new evidence is flagged immediately by the orchestrator:

> ⚠ [Agent A / Agent B] Round [N] rebuttal contains no new codebase evidence. Going deeper before continuing.

The flagged agent must find new evidence before the round proceeds. This is one attempt. If a second attempt also produces no new evidence:

> [Agent A / Agent B] has exhausted its codebase evidence after [N] rounds.

That agent's case is closed. The other agent gets one final rebuttal, then the orchestrator synthesizes.

### Early stop conditions

The orchestrator closes the debate before round 5 if any of these are true:

- Both agents have exhausted new evidence in the same round
- The remaining disagreement is purely subjective (style, convention, preference with no codebase impact) — note it and stop
- One agent concedes a material point that resolves the core question — note the concession and stop
- The debate has converged: both agents are essentially agreeing on the same implementation with different framing

Announce early stop:
> Debate closed after [N] rounds — [specific reason].

### Round format

**Round [N]**

**PRO rebuttal:**
- New evidence: [file / pattern / line not cited before]
- Argument: [what this evidence adds or changes in the PRO case]
- Addresses CON's [specific point from previous round]: [direct response]

**CON rebuttal:**
- New evidence: [file / pattern / line not cited before]
- Argument: [what this evidence adds or changes in the CON case]
- Addresses PRO's [specific point from previous round]: [direct response]

---

## Step 4: Orchestrator synthesis

After the debate closes, the orchestrator evaluates both cases. Do not pick based on confidence, eloquence, or volume of arguments. Evaluate on these criteria in order:

1. **Evidence quality** — which case cited more concrete, specific, verifiable codebase evidence? Vague references ("the codebase uses this pattern") lose to specific ones ("UserController.cs line 84 uses X and callers would need to change").
2. **Correctness** — which case is factually accurate about how the codebase currently works? Any factual error in a case weakens it regardless of the argument's logic.
3. **Risk surface** — which risks raised by CON are real and concrete vs. speculative? A speculative risk does not outweigh a confirmed one.
4. **Pattern alignment** — which direction aligns with the existing project's established conventions, naming, structure, and architecture?
5. **Reversibility** — how hard is it to undo if the chosen direction is wrong? Prefer the more reversible option when evidence is close.

Show the synthesis reasoning before the verdict — one paragraph per criterion, noting which case was stronger on each point and why.

---

## Step 5: Final verdict

One of three verdicts — no other options.

---

### ADOPT

**Verdict: ADOPT**

[2–3 sentences on why PRO won — specific criteria from Step 4 that decided it]

**With these conditions:** [CON's valid caveats that must be honoured in implementation — do not omit even in an ADOPT verdict. If CON raised no valid points, say so explicitly.]

**Watch out for:** [the strongest CON risk that remains real even with conditions applied]

---

### REJECT

**Verdict: REJECT**

[2–3 sentences on why CON won — specific criteria from Step 4 that decided it]

**What to do instead:** [if the debate surfaced an alternative direction, name it. Do not just say no without offering a path forward.]

**PRO's valid point:** [the strongest PRO argument that deserves acknowledgment — do not ignore it even in a REJECT verdict]

---

### MERGE

**Verdict: MERGE**

[2–3 sentences on why neither case fully won — the evidence supports a hybrid]

**Adopt from PRO:** [specific elements, patterns, or components to take from the FOR case]

**Adopt from CON:** [specific constraints, guardrails, or caveats to honour from the AGAINST case]

**Implementation path:** [concrete description of how to combine them — not abstract, actionable]

---

### When both cases are weak

If both cases produced thin evidence, speculative reasoning, or failed the evidence gate repeatedly:

> **Verdict: INCONCLUSIVE**
>
> Neither case produced sufficient codebase evidence to decide confidently. Recommend a focused spike: [specific thing to investigate — file, pattern, or behaviour that would resolve the question]. Re-run cb-debate after the spike.

---

## Hard rules

- **Pre-check is mandatory.** Never skip Step 0. A debate that shouldn't have run wastes the cost and dilutes trust in the command.
- **Evidence gate is non-negotiable.** Every claim from round 2 onward must trace to a specific file or pattern. The orchestrator enforces this actively — not passively.
- **The losing side's strongest point must appear in the verdict.** A verdict that ignores the best counter-argument is a preference, not a verdict.
- **Orchestrator picks on evidence, not confidence.** An agent that argues loudly with thin evidence loses to an agent that argues quietly with strong evidence.
- **MERGE is not a cop-out.** Only use MERGE when the evidence genuinely supports elements from both cases. If one case clearly won, say so.
- **No emojis** except the ⚠ evidence-gate flag.
- **Output is plain markdown** — no code blocks wrapping structured output, no tables for the verdict itself. Headers, bold, and bullets only.
