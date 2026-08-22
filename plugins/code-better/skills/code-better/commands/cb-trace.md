# cb-trace

Read-only end-to-end trace of how one existing feature currently works, start to finish. Builds full context before any change is made. No edits.

**Usage:** `cb-trace <feature or flow description>` — e.g. `cb-trace how password reset works`. If no target given, ask first.

**This command owns "how does X work today" — not "what changed" (`cb-review-flow`) or "map the whole codebase" (`cb-explore`).** Use it before touching unfamiliar code: bug investigation, an extension to an existing feature, or a handoff with no prior context.

---

## Step 1: Locate the entry point

Use MEMORY.md / session context from `cb-load` if already loaded this session — don't re-scan what's already known.

Find where the flow starts: a route, UI event handler, CLI command, cron job, queue consumer, or webhook. Grep for the feature's name, related strings, or known UI labels/API paths to anchor the search rather than browsing folders.

**Ambiguity gate:** if the grep finds nothing, stop and ask for a more specific term or a file/route hint — don't guess. If it finds multiple plausible, unrelated entry points (e.g. the term matches two unrelated features, or both a web and a mobile handler), list them and ask which one before tracing. Don't proceed on a guess.

## Step 2: Walk the flow hop by hop

Follow the feature through every layer it touches, in order:

- **Entry** — route/handler/trigger that kicks it off
- **Validation / auth** — what gates the request before it does anything
- **Business logic** — services, use-cases, core functions that do the work
- **Data layer** — queries, mutations, schema, cache reads/writes
- **External calls** — other services, APIs, queues, third-party integrations
- **Response / side effects** — what's returned, rendered, emitted, or triggered downstream (events, notifications, jobs)

At each hop, confirm the code actually connects to the next one — don't assume from naming. Note the exact file:line for each hop.

**Hard limits:** never read more than 15 files total for the trace. Don't open a file just to confirm it's not relevant — grep first. Skip test files, generated files, lock files, migrations unless the migration defines current schema shape. If a hop fans out to many branches (e.g. multiple handler types), trace the primary/most common path fully and note the others as unexplored branches rather than reading all of them.

**Under `cb-thorough`:** the file cap and single-path rule both lift — read every file needed to fully resolve a hop, and trace all branches at a fan-out point, not just the primary one, noting each fully.

## Step 3: Note state and edge cases

While walking the flow, capture without deep-diving:
- Where state changes (DB writes, cache invalidation, external side effects)
- Conditional branches that alter the flow (feature flags, permission checks, input variants)
- Existing error handling — what's handled vs. silently swallowed vs. unhandled
- Tests covering this flow, if easily located (don't hunt exhaustively)

## Step 4: Report

```
Trace: [feature/flow name]

FLOW
1. [file:line] — [entry point, what triggers it]
2. [file:line] — [next hop, what it does]
...
N. [file:line] — [terminal point: response/render/side effect]

STATE CHANGES
- [what gets written/mutated, where]

BRANCHES / VARIANTS
- [conditional paths noted but not fully traced]

EDGE CASES & ERROR HANDLING
- [what's handled, what's not]

TESTS
- [files covering this flow, or "none found"]

OPEN QUESTIONS
- [anything ambiguous or needing human confirmation]
```

If the target maps onto an existing `0-cowork/memory/projects/{project-name}.md` entry from `cb-explore`, offer to append a "Traced Flows" section there rather than leaving the trace only in chat output.

## Step 5: Next step

Based on why the trace was requested, offer the next command rather than just stopping:
- Investigating a bug → "Want me to run `cb-debug` from here?"
- Extending or changing this flow → "Want me to run `cb-brainstorm` or `cb-plan` from here?"
- Pure context-gathering with no immediate change → nothing to offer, stop after the report.

---

## Auto-exit

When `cb-trace` activates, automatically exit: `cb-workflow`, `cb-feature`, `cb-fix`, `cb-brainstorm`. Announce: `✦ cb-trace on — exited: [list]`

Never exit: `cb-careful`, `cb-thorough`, `cb-explain`, `cb-read-only`, `cb-ask`. These persist across all phases.
