# Playwright Templates

Templates for the Sr. QA Analyst to generate test files. Adapt to the specific PR scope.

Config file generated once during project setup:

```typescript
// .claude/weekend-project/playwright/wpr.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: '.claude/weekend-project/playwright',
  fullyParallel: false,  // sequential — we test one PR at a time
  retries: 1,
  reporter: [['json', { outputFile: '.claude/weekend-project/playwright/results.json' }]],
  use: {
    baseURL: 'http://localhost:3000',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['iPhone 13'] } },
  ],
  webServer: {
    command: 'pnpm dev',
    url: 'http://localhost:3000',
    reuseExistingServer: true,
    timeout: 30000,
  },
  snapshotDir: '.claude/weekend-project/playwright/snapshots',
})
```

---

## Template: Auth flow

```typescript
import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

test.describe('Auth — [PR title]', () => {
  test('sign up with valid email and password', async ({ page }) => {
    await page.goto('/auth/signup')
    await page.getByLabel('Email').fill('test@example.com')
    await page.getByLabel('Password').fill('SecurePass123!')
    await page.getByRole('button', { name: /sign up/i }).click()
    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText(/welcome/i)).toBeVisible()
  })

  test('login with invalid credentials returns error', async ({ page }) => {
    await page.goto('/auth/login')
    await page.getByLabel('Email').fill('test@example.com')
    await page.getByLabel('Password').fill('wrongpassword')
    await page.getByRole('button', { name: /log in/i }).click()
    await expect(page.getByRole('alert')).toContainText(/invalid/i)
    await expect(page).toHaveURL('/auth/login')  // stayed on login page
  })

  test('protected route redirects unauthenticated user', async ({ page }) => {
    await page.goto('/dashboard')
    await expect(page).toHaveURL(/\/auth\/login/)
  })

  test('accessibility — login page', async ({ page }) => {
    await page.goto('/auth/login')
    const results = await new AxeBuilder({ page }).analyze()
    expect(results.violations).toEqual([])
  })

  test('visual — login page', async ({ page }) => {
    await page.goto('/auth/login')
    await expect(page).toHaveScreenshot('login.png', { threshold: 0.05 })
  })

  test('mobile — login page', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 })
    await page.goto('/auth/login')
    await expect(page).toHaveScreenshot('login-mobile.png', { threshold: 0.05 })
  })
})
```

---

## Template: API endpoint

```typescript
import { test, expect } from '@playwright/test'

test.describe('API — [resource] CRUD', () => {
  let authToken: string
  let createdId: string

  test.beforeAll(async ({ request }) => {
    const res = await request.post('/api/auth/login', {
      data: { email: 'test@example.com', password: 'SecurePass123!' }
    })
    const body = await res.json()
    authToken = body.token
  })

  test('GET /api/[resource] returns empty array for new user', async ({ request }) => {
    const res = await request.get('/api/[resource]', {
      headers: { Authorization: `Bearer ${authToken}` }
    })
    expect(res.status()).toBe(200)
    const body = await res.json()
    expect(Array.isArray(body.data)).toBe(true)
    expect(body.data).toHaveLength(0)
  })

  test('POST /api/[resource] creates a record', async ({ request }) => {
    const res = await request.post('/api/[resource]', {
      headers: { Authorization: `Bearer ${authToken}` },
      data: { name: 'Test Item', description: 'Created in QA' }
    })
    expect(res.status()).toBe(201)
    const body = await res.json()
    expect(body.data.id).toBeDefined()
    createdId = body.data.id
  })

  test('POST /api/[resource] rejects missing required fields', async ({ request }) => {
    const res = await request.post('/api/[resource]', {
      headers: { Authorization: `Bearer ${authToken}` },
      data: {}  // missing required fields
    })
    expect(res.status()).toBe(400)
    const body = await res.json()
    expect(body.error).toBeDefined()
  })

  test('GET /api/[resource] without auth returns 401', async ({ request }) => {
    const res = await request.get('/api/[resource]')
    expect(res.status()).toBe(401)
  })

  test('XSS: input is escaped in response', async ({ request }) => {
    const res = await request.post('/api/[resource]', {
      headers: { Authorization: `Bearer ${authToken}` },
      data: { name: '<script>alert("xss")</script>' }
    })
    const body = await res.json()
    expect(body.data?.name).not.toContain('<script>')
  })
})
```

---

## Template: UI component / screen

```typescript
import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

test.describe('[Screen name]', () => {
  test.beforeEach(async ({ page }) => {
    // set auth cookie/localStorage if needed
    await page.goto('/[route]')
  })

  test('renders without errors', async ({ page }) => {
    await expect(page.locator('main')).toBeVisible()
    // no console errors
    const errors: string[] = []
    page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()) })
    await page.reload()
    expect(errors).toHaveLength(0)
  })

  test('empty state is shown when no data', async ({ page }) => {
    // mock empty API response if needed
    await expect(page.getByTestId('empty-state')).toBeVisible()
    await expect(page.getByText(/no [items] yet/i)).toBeVisible()
  })

  test('keyboard navigation works', async ({ page }) => {
    await page.keyboard.press('Tab')
    const focused = page.locator(':focus')
    await expect(focused).toBeVisible()
    // tab through interactive elements
  })

  test('accessibility', async ({ page }) => {
    const results = await new AxeBuilder({ page }).analyze()
    expect(results.violations).toEqual([])
  })

  test('visual — desktop', async ({ page }) => {
    await expect(page).toHaveScreenshot('[screen]-desktop.png', { threshold: 0.05 })
  })

  test('visual — mobile', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 })
    await expect(page).toHaveScreenshot('[screen]-mobile.png', { threshold: 0.05 })
  })
})
```

---

## Installing Playwright in the project

Run once during scaffold PR setup:

```bash
pnpm add -D @playwright/test @axe-core/playwright
npx playwright install chromium  # only chromium for speed
```

Add to `package.json`:
```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:wpr": "playwright test --config=.claude/weekend-project/playwright/wpr.config.ts"
  }
}
```
