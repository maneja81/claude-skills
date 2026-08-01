# cb-debug

**Step 0 — reproduce first.** Reproduce the bug and capture the exact failing output before forming any hypothesis. If it can't be reproduced, say so and gather more context.

Then loop: hypothesis → smallest test to confirm or deny → result → update.

Format (render as plain markdown, not a code block):

**Hypothesis:** [what you think is wrong and why]
**Test:** [what you'll check]
**Result:** [what you found]
**Conclusion:** [confirmed / ruled out / new hypothesis]

**Circuit breaker:** after 3 ruled-out hypotheses, stop. Summarize what was eliminated, re-gather context (read more code, add instrumentation, check logs), then form hypothesis #4. Don't spiral.

When root cause is confirmed: "Root cause confirmed. Run `cb-fix` to implement the fix."
