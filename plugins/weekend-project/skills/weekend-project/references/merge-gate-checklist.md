# Merge Gate Checklist

The production gate. Run twice per PR: by the Sr. Developer before handing to QA, and again in `phases/06-merge-gate.md` before the merge itself.

Run all items. Log results in `pr-logs/[branch]/merge-gate.json`.

---

## Automated checks (run as commands)

```bash
# 1. Tests
pnpm test --run
# Expected: 0 failures, 0 skipped

# 2. Type check
pnpm typecheck
# Expected: 0 errors

# 3. Lint
pnpm lint
# Expected: 0 errors (warnings reviewed but don't block)

# 4. Build
pnpm build
# Expected: exits 0

# 5. Secret scan
git diff develop-ai...[branch] | grep -iE "(api_key|secret|token|password|credential|private_key|bearer)" | grep -v ".env.example" | grep -v "test"
# Expected: 0 matches (any match reviewed)

# 6. Bundle size check (if Next.js)
# Compare .next/analyze output if bundle analysis is set up
```

---

## Manual checks (verify by inspection)

### Code quality
- [ ] No `any` types without justified comment
- [ ] No `@ts-ignore` or `@ts-expect-error` without justification comment
- [ ] No `console.log` statements (except deliberate logging with a logger utility)
- [ ] No TODO comments without a linked `open-decisions.md` entry
- [ ] No dead code (unreachable branches, unused exports)
- [ ] No commented-out code blocks

### Error handling
- [ ] All async functions have try/catch or `.catch()`
- [ ] No empty catch blocks `catch (e) {}`
- [ ] API routes return structured error responses (not raw error objects or stack traces)
- [ ] User-facing errors show helpful messages, not technical details

### Security
- [ ] No environment variables hardcoded (even test values use `process.env`)
- [ ] SQL/database queries use parameterised inputs
- [ ] User inputs are sanitised before use in file paths, URLs, or queries
- [ ] No sensitive data logged

### Tests
- [ ] New functionality has corresponding tests
- [ ] Error paths are tested (not just happy paths)
- [ ] No `.skip` or `.only` in committed test files
- [ ] Test descriptions are readable prose

### Git hygiene
- [ ] All commits follow conventional commit format
- [ ] No "wip", "fix", "asdf", or empty commit messages
- [ ] Diff is scoped to this PR's stated purpose (no unrelated file changes)

### Documentation
- [ ] README updated if new setup steps or env vars are required
- [ ] New env vars added to `.env.example` (never to `.env`)

---

## Result

If all items pass: proceed to merge in `phases/06-merge-gate.md`.

If any item fails: return to Sr. Developer with the specific failure. Do not merge a PR that fails any automated check or any `critical` manual check.

Items marked as warnings (bundle size, lint warnings) are logged but do not block merge.
