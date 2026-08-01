# TDD Patterns Reference

Test-first patterns for the Sr. Developer, organised by tech stack and concern. Read the section matching `config.yaml → stack.framework`.

---

## Universal TDD rules

1. Write the test. Run it. See it fail with the right error (not "import not found").
2. Write the minimum implementation to make it pass.
3. Refactor only after the test is green.
4. Commit the test and implementation together in one commit.
5. Never delete a failing test to make a build pass.

---

## Next.js / React (Vitest + Testing Library)

### Setup
```bash
pnpm add -D vitest @vitejs/plugin-react @testing-library/react @testing-library/user-event jsdom
```

`vitest.config.ts`:
```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
  },
})
```

### Server action test
```typescript
// src/actions/__tests__/create-post.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { createPost } from '../create-post'
import { db } from '@/lib/db'

vi.mock('@/lib/db')

describe('createPost', () => {
  beforeEach(() => vi.clearAllMocks())

  it('creates a post with valid input', async () => {
    vi.mocked(db.post.create).mockResolvedValue({ id: '1', title: 'Test', content: 'Body' } as any)
    const result = await createPost({ title: 'Test', content: 'Body', userId: 'user-1' })
    expect(result.success).toBe(true)
    expect(db.post.create).toHaveBeenCalledWith({
      data: { title: 'Test', content: 'Body', authorId: 'user-1' }
    })
  })

  it('returns error when title is empty', async () => {
    const result = await createPost({ title: '', content: 'Body', userId: 'user-1' })
    expect(result.success).toBe(false)
    expect(result.error).toMatch(/title.*required/i)
    expect(db.post.create).not.toHaveBeenCalled()
  })
})
```

### Component test
```typescript
// src/components/__tests__/Button.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from '../Button'

describe('Button', () => {
  it('calls onClick when clicked', async () => {
    const user = userEvent.setup()
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    await user.click(screen.getByRole('button', { name: /click me/i }))
    expect(handleClick).toHaveBeenCalledOnce()
  })

  it('is disabled when loading', () => {
    render(<Button loading>Submit</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })

  it('shows loading indicator when loading', () => {
    render(<Button loading>Submit</Button>)
    expect(screen.getByRole('status')).toBeInTheDocument()  // aria-label="loading"
  })
})
```

### API route test
```typescript
// src/app/api/posts/__tests__/route.test.ts
import { describe, it, expect, vi } from 'vitest'
import { GET, POST } from '../route'
import { NextRequest } from 'next/server'

vi.mock('@/lib/db')
vi.mock('@/lib/auth', () => ({ getSession: vi.fn() }))

import { getSession } from '@/lib/auth'

describe('GET /api/posts', () => {
  it('returns 401 when unauthenticated', async () => {
    vi.mocked(getSession).mockResolvedValue(null)
    const req = new NextRequest('http://localhost/api/posts')
    const res = await GET(req)
    expect(res.status).toBe(401)
  })
})
```

---

## Node.js / Express / Fastify (Vitest or Jest)

### API handler test
```typescript
describe('POST /api/users', () => {
  it('creates user with valid payload', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ email: 'user@example.com', name: 'Test User' })
      .set('Authorization', `Bearer ${testToken}`)
    
    expect(res.status).toBe(201)
    expect(res.body.data.email).toBe('user@example.com')
    expect(res.body.data.password).toBeUndefined()  // never returned
  })

  it('returns 400 with validation errors for invalid email', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ email: 'not-an-email', name: 'Test' })
      .set('Authorization', `Bearer ${testToken}`)
    
    expect(res.status).toBe(400)
    expect(res.body.errors).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ field: 'email' })
      ])
    )
  })
})
```

---

## Angular (Jest + Testing Library)

### Service test
```typescript
describe('AuthService', () => {
  let service: AuthService
  let httpMock: HttpTestingController

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [AuthService]
    })
    service = TestBed.inject(AuthService)
    httpMock = TestBed.inject(HttpTestingController)
  })

  afterEach(() => httpMock.verify())

  it('should return user on successful login', () => {
    service.login('user@example.com', 'password').subscribe(user => {
      expect(user.email).toBe('user@example.com')
    })

    const req = httpMock.expectOne('/api/auth/login')
    expect(req.request.method).toBe('POST')
    req.flush({ email: 'user@example.com', token: 'abc123' })
  })
})
```

---

## Database / Prisma patterns

Always use a test database. Never run tests against the development or production database.

```typescript
// src/test/setup.ts
import { execSync } from 'child_process'
import { db } from '@/lib/db'

beforeAll(() => {
  // Use TEST_DATABASE_URL from .env.test
  execSync('pnpm prisma migrate deploy', {
    env: { ...process.env, DATABASE_URL: process.env.TEST_DATABASE_URL }
  })
})

afterEach(async () => {
  // Clean tables in reverse dependency order after each test
  await db.$transaction([
    db.post.deleteMany(),
    db.user.deleteMany(),
  ])
})

afterAll(async () => {
  await db.$disconnect()
})
```

---

## TDD discipline reminders

- If a function is hard to test, the function has a design problem. Fix the design, not the test.
- Mock at the boundary (HTTP, database, filesystem, time). Do not mock internal application code.
- Test names are documentation. `it('returns 401 when token is expired')` is better than `it('auth test 3')`.
- Avoid testing implementation details. Test behaviour: given this input, produce this output/side-effect.
- `expect.assertions(N)` in async tests — ensures the test doesn't pass silently if an async assertion is never reached.
