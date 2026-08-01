# Phase 03 — UI Mockups (Frontend Projects Only)

Skip this phase entirely if `config.yaml → stack.is_frontend = false`.

Before writing a single line of production code, get visual alignment with the user. Catching design issues now costs nothing. Catching them in round-2 QA costs a full review cycle.

This phase uses `design-taste-frontend` skill principles. Read that skill before generating any mockup.

---

## Atomic design breakdown

Before generating screen mockups, define the design system atoms. This becomes the shared language for the entire build.

Generate `ui-mockups/design-system.html` — a single self-contained HTML file showing:

1. **Typography scale** — display, h1–h4, body, small, mono, label
2. **Colour tokens** — background, surface, border, text-primary, text-secondary, accent, accent-hover, destructive, success
3. **Spacing scale** — 4px base, show 4/8/12/16/24/32/48/64/96
4. **Border radius** — the single radius scale chosen for this project
5. **Component atoms** — Button (all states: default, hover, active, disabled, loading), Input (default, focus, error, disabled), Badge, Tag
6. **Motion tokens** — easing curves, duration values

Apply `design-taste-frontend` Pre-Flight Check to the design system before presenting it.

Present `design-system.html` to the user. Ask: "Does this design direction feel right? Any changes to fonts, colours, or radius before I build the screens?"

Wait for approval. Update any changes. Then proceed to screen mockups.

---

## Screen mockups

Identify the major screens from the active plan. Typically 3-5 screens (home, core feature, auth, dashboard, settings). Do not generate mockups for every screen — focus on the ones that define the visual language.

For each major screen, generate **2-3 variant HTML files**:
- `ui-mockups/[screen]-v1.html`
- `ui-mockups/[screen]-v2.html`
- `ui-mockups/[screen]-v3.html` (if needed)

### Variant rules

Variants must differ meaningfully — different layout family, different hero paradigm, different density. Not colour swaps.

Use the vocabulary from `design-taste-frontend` Section 10:
- V1: Standard/safe (appropriate for the design direction)
- V2: More expressive (higher DESIGN_VARIANCE)
- V3: Experimental (only if brief supports it)

Each HTML file is:
- Completely self-contained (inline CSS + JS, no external deps)
- Uses the approved design system tokens from `design-system.html`
- Mobile-responsive (declare collapse explicitly)
- Passes the design-taste-frontend Pre-Flight Check

### What each mockup includes

For each screen variant, use real content — not lorem ipsum. Derive content from the project description in `config.yaml`. If the project is a restaurant booking app, write actual restaurant copy. The QA agent will visually validate the implementation against these mockups — vague placeholder content makes that impossible.

---

## User approval flow

Present variants to the user:

```
UI Mockups ready — [N] screens, [M] variants each.

Open these files in your browser to review:
  Home:       ui-mockups/home-v1.html · v2.html · v3.html
  Dashboard:  ui-mockups/dashboard-v1.html · v2.html
  Auth:       ui-mockups/auth-v1.html · v2.html

Pick a variant per screen (or mix elements: "home v2 but with v1's nav").
Run `wpr-mockups` to record your choices.
```

Record approvals in `ui-mockups/approval.yaml`:

```yaml
approved:
  home: v2
  dashboard: v1
  auth: v1
mix_notes:
  home: "use v1 navigation component, v2 for everything else"
approved_by_user: true
approved_at: "ISO-timestamp"
```

Do not proceed to execution until `approved_by_user: true`.

---

## Component translation

Once mockups are approved, break each organism from each approved screen into the framework components that will be built in the design PR.

Based on `config.yaml → stack.framework`:

**React / Next.js:**
```
Hero organism → src/components/Hero.tsx
Navigation organism → src/components/Navigation.tsx
FeatureGrid organism → src/components/FeatureGrid.tsx
Footer organism → src/components/Footer.tsx
Shared atoms → src/components/ui/ (Button, Input, Card, Badge, etc.)
```

**Angular:**
```
Hero → src/app/components/hero/hero.component.ts + .html + .spec.ts
Navigation → src/app/components/navigation/...
Shared → src/app/shared/ui/
```

**Vue:**
```
Hero → src/components/Hero.vue
Navigation → src/components/Navigation.vue
Shared → src/components/ui/
```

Write the component breakdown to `ui-mockups/components.yaml`. This becomes the scope definition for the design system PR (`wpr/design/design-system`) and the layout PR (`wpr/design/layout`).

The Sr. Developer uses the approved HTML mockup as a pixel-accurate implementation spec. The Sr. QA agent takes a Playwright screenshot of the implemented component and diffs it against the mockup HTML rendered in a headless browser.

---

## Completion

Once approval is recorded and components are mapped:
- Update `session.yaml → phase: execution`
- Proceed to `phases/04-execution.md`
