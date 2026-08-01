# Phase 01 — Intake Interview

Run a structured interview to capture everything needed to generate an accurate plan and CLAUDE.md. Save answers to `.claude/weekend-project/config.yaml` after each section so the interview can resume if context resets.

Ask one section at a time. Wait for answers before moving to the next section. Do not dump all questions at once.

---

## Section 1: Project basics

```
What are we building?
(e.g. "SaaS web app", "REST API", "desktop app", "mobile app", "marketing website", "internal tool")
```

```
Describe it in 2-3 sentences — what does it do, who uses it?
```

```
What's the project folder path on your machine?
(e.g. /Users/you/Projects/my-app — this must already exist as a git repo, or I'll init one)
```

Save to config.yaml:
```yaml
project_type: ~
description: ~
project_root: ~
```

---

## Section 2: GitHub

```
GitHub repo URL? (existing or "create new")
```

```
What's your main branch called? (default: main)
```

AI will work on `develop-ai` and branch with `wpr/` prefix. Confirm this with the user in one line before moving on.

Save:
```yaml
github_repo: ~
main_branch: main
ai_branch: develop-ai
branch_prefix: wpr/
```

---

## Section 3: Tech stack

Ask in a single grouped question to avoid over-interviewing:

```
Tech stack — fill in what you know, skip what you don't and I'll suggest defaults:

  Language/framework: (e.g. Next.js 15, React 19, Angular 18, plain Node.js, Python/FastAPI)
  CSS/styling: (e.g. Tailwind v4, CSS Modules, styled-components)
  Testing: (e.g. Vitest, Jest, Playwright, Cypress — or "you choose")
  Package manager: (npm / pnpm / yarn — default: pnpm)
```

For any blank, apply the current industry default for the chosen framework. Log each default as an assumption in `open-decisions.md`.

Save:
```yaml
stack:
  framework: ~
  language: typescript  # always TS unless user explicitly says otherwise
  css: ~
  testing: ~
  package_manager: pnpm
  is_frontend: ~  # derived: true if framework has UI output
  is_fullstack: ~
```

---

## Section 4: Database and infrastructure

Only ask if the project type suggests it (skip for pure marketing sites):

```
Database? (PostgreSQL / MySQL / SQLite / MongoDB / none — or "you choose")
ORM? (Drizzle / Prisma / TypeORM / none)
Auth? (NextAuth / Clerk / custom JWT / none)
File storage? (S3 / Cloudflare R2 / local / none)
Email? (Resend / SendGrid / Postmark / none)
Deployment target? (Vercel / Railway / Fly.io / Docker / self-hosted / TBD)
```

Skip any that clearly don't apply. Log all "you choose" items as open decisions.

Save:
```yaml
infra:
  database: ~
  orm: ~
  auth: ~
  storage: ~
  email: ~
  deploy: ~
```

---

## Section 5: Docker / local dev

```
Local dev setup:
  Docker Compose? (yes / no)
  Any services to containerise? (DB, Redis, mail server, etc.)
  Dev server port? (default: 3000)
```

Save:
```yaml
local_dev:
  docker: false
  services: []
  port: 3000
```

---

## Section 6: Standards confirmation

Present the non-negotiable defaults. User can override any:

```
I'll build with these standards — override anything you want to change:

  ✓ TypeScript strict mode (no `any`)
  ✓ TDD — tests written before implementation
  ✓ SOLID + DRY principles
  ✓ ESLint + Prettier enforced on commit (Husky)
  ✓ Conventional commits
  ✓ Playwright for UI/E2E tests (frontend projects)
  ✓ All decisions logged to .claude/weekend-project/decisions.jsonl
```

Save any overrides:
```yaml
standards:
  typescript_strict: true
  tdd: true
  solid_dry: true
  lint_on_commit: true
  conventional_commits: true
  playwright: true  # set false if user declines
  decision_log: true
```

---

## Section 7: UI direction (frontend projects only)

Skip if `is_frontend: false`.

```
Design direction — pick the closest or describe your own:
  A) Clean / minimal (Linear, Vercel style)
  B) Premium consumer (Apple-adjacent, high craft)
  C) Bold / expressive (agency, Awwwards energy)
  D) Corporate / trust-first (enterprise SaaS, B2B)
  E) Describe it yourself
```

```
Any brand assets? (logo URL, brand colors, existing style guide)
Dark mode? (yes / no / system default)
```

Save:
```yaml
ui:
  design_direction: ~
  brand_assets: ~
  dark_mode: system
```

---

## Interview completion

Once all sections are complete:

1. Write the complete `config.yaml` with all captured values.
2. Show the user a clean summary of what was captured — one compact block, not a wall of YAML.
3. Ask: "Anything to change before I generate the plan?"
4. On confirmation, update `session.yaml → phase: planning` and proceed to `phases/02-planning.md`.

---

## Resume protocol

If `config.yaml` already exists with partial data (interview was interrupted):
- Read what's already saved
- Skip completed sections
- Continue from the first unanswered section
- Tell the user: "Resuming interview from Section [N]..."
