# Token Estimates Reference

Use these ranges to estimate a plan's `prs[].estimated_tokens` during the planning phase. Ranges are based on typical complexity. Round up when uncertain.

---

## By PR type

| PR type | Low | Mid | High | Notes |
|---|---|---|---|---|
| Project scaffold + CI | 60k | 80k | 100k | Higher if complex monorepo or multi-env CI |
| Auth system | 100k | 150k | 220k | Higher with OAuth, MFA, or complex role system |
| Database setup (schema + migrations + seed) | 60k | 90k | 130k | Higher for complex relations |
| Core API (CRUD + validation + error handling) | 80k | 120k | 180k | Per resource group |
| Design system (atoms + molecules) | 80k | 120k | 160k | Higher for complex animation or a11y |
| Layout + navigation | 50k | 80k | 120k | Higher for complex responsive behavior |
| Feature screen (UI + API integration) | 100k | 150k | 200k | Per major screen |
| External service integration | 60k | 100k | 160k | Depends on SDK quality |
| E2E test suite | 60k | 80k | 120k | Higher for large flow coverage |
| Performance optimisation | 40k | 70k | 100k | Hard to predict — use high end |
| Accessibility audit + fixes | 30k | 50k | 80k | |
| QA backlog cleanup | 30k | 50k | 80k | Depends on deferred issue count |

## Overhead multipliers

| Overhead type | Multiplier |
|---|---|
| QA rounds + fixes (per PR) | +35% on top of dev estimate |
| Memory load per PR | +5k flat |
| UI mockup phase | +60k flat (frontend projects) |
| Buffer | +15% on total |

## Example calculation

Project: Next.js SaaS, 6 PRs

| PR | Dev est. | + QA (35%) | Total |
|---|---|---|---|
| PR-001: Scaffold | 80k | 28k | 108k |
| PR-002: Auth | 150k | 52k | 202k |
| PR-003: Design system | 120k | 42k | 162k |
| PR-004: Dashboard | 150k | 52k | 202k |
| PR-005: Email integration | 100k | 35k | 135k |
| PR-006: QA backlog | 50k | 17k | 67k |
| Memory loads (6 × 5k) | — | — | 30k |
| UI mockup phase | — | — | 60k |
| **Subtotal** | | | **966k** |
| **Buffer (15%)** | | | **145k** |
| **Total estimate** | | | **~1.1M tokens** |

Show this as ~1.1M to the user, not the exact figure.

## When to flag large estimates

If the total estimate exceeds 500k: suggest breaking into an MVP phase (core functionality only, ~3-4 PRs) and an enhancement phase (remaining features). Present the split to the user before committing to the full plan.

If any single PR is estimated above 250k: it is too large. Split it into two PRs with independent acceptance criteria.
