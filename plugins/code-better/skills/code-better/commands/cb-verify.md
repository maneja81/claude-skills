# cb-verify

Read `commands/_shared-rules.md` if not already loaded this session — the "cb-verify Gate" section there is the canonical definition of the gate (stage order, report format, missing-tool handling). This command is that gate, invoked standalone as a one-shot check.

Run the gate now and show the report using the exact format from `_shared-rules.md`. Never invent a toolchain. Never suppress or weaken a check to make it pass.

`cb-fast` never skips it. Referenced by `cb-workflow`, `cb-cleanup`, `cb-feature`, `cb-ship`.
