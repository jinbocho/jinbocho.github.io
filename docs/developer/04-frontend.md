# Frontend

**Repository**: `jinbocho-fe`  
**Stack**: React 18 + TypeScript strict · Vite · Tailwind CSS · TanStack Query · Zustand · React Router · ky · React Hook Form + Zod

## Setup

```bash
cd jinbocho-fe
npm ci               # install dependencies (respects lockfile)
cp .env.example .env # edit VITE_API_BASE_URL
npm run dev          # dev server on http://localhost:5173
```

### Environment Variables

| Variable | Example | Description |
|----------|---------|-------------|
| `VITE_API_BASE_URL` | `http://localhost:8000` | Backend gateway URL |

In production, set `VITE_API_BASE_URL` to the public Render gateway URL. Vite inlines this at build time — **rebuild required after changing it**.

## Commands

```bash
npm run dev          # dev server with HMR
npm run build        # production build → dist/
npm run typecheck    # tsc --noEmit (run before every commit)
npm run test         # vitest run (all unit + component tests)
npm run lint         # ESLint + Prettier check
```

Always run `npm run typecheck && npm run test` before pushing.

## Project Structure

```
src/
├── main.tsx              # Bootstrap: router + QueryClient + providers
├── App.tsx               # Route tree
├── routes/               # One file per page (JSX only, no data logic)
│   ├── auth/LoginPage.tsx
│   ├── auth/RegisterPage.tsx
│   ├── DashboardPage.tsx
│   ├── books/BookCatalogPage.tsx
│   ├── books/BookDetailPage.tsx
│   ├── books/AddBookPage.tsx
│   ├── locations/LocationsPage.tsx
│   ├── locations/BookcaseMapPage.tsx
│   ├── users/UsersPage.tsx
│   └── settings/SettingsPage.tsx
├── features/             # Data layer (TanStack hooks, types, helpers — no JSX)
│   ├── auth/             # useLogin, useRegister, token store, JWT decode, guards
│   ├── books/            # useBooks, useBookWithRecord, mutations, joinBooksToRecords()
│   ├── records/          # useRecords (search), useIsbnLookup
│   ├── locations/        # useRooms, useBookcases, useSections, useShelves
│   ├── users/            # useUsers, useCurrentUser
│   └── family/           # useFamily
├── components/
│   ├── ui/               # Primitives: Button, Input, Modal, Toast, Badge…
│   ├── layout/           # AppShell, Sidebar, BottomNav, TopBar
│   └── feedback/         # EmptyState, ErrorState, Spinner
├── lib/
│   ├── api.ts            # ky instance + bearer token + 401→refresh→retry interceptor
│   ├── queryClient.ts    # TanStack Query config
│   ├── jwt.ts            # Token decode + expiry helpers
│   └── format.ts         # Date, label, reading-status formatters
├── types/
│   └── api.ts            # Hand-written TS types mirroring backend Pydantic schemas
├── hooks/                # Generic hooks (useDebounce, useMediaQuery)
└── styles/index.css      # Tailwind directives + CSS custom properties (Pergamena palette)
```

**Convention**: `features/` holds data logic (hooks, helpers, types) — zero JSX. `routes/` and `components/` hold JSX.

## State Management

| State Type | Tool |
|------------|------|
| Server state (books, rooms, etc.) | **TanStack Query** |
| Auth session (JWT tokens) | **Zustand** (`features/auth/store.ts`) |
| Form state | **React Hook Form + Zod** |
| Everything else | Local `useState` |

There is no other global state. Do not add Zustand stores for server data.

## API Client (`lib/api.ts`)

All requests go through a `ky` instance configured with:

1. `Authorization: Bearer <access_token>` header on every request
2. A `401 → refresh → retry` interceptor: on a 401 response, attempts to refresh the access token silently, then retries the original request
3. `VITE_API_BASE_URL` as the prefix

```ts
// Usage in features:
import { api } from '@/lib/api'

const books = await api.get('v1/books/', { searchParams: { limit: 50 } }).json()
```

## Feature Hooks Pattern

Each `features/<domain>/hooks.ts` exports TanStack Query hooks:

```ts
// Reading — returns cached + refetched data
export function useBooks() { ... }
export function useBookWithRecord(id: string) { ... }

// Writing — mutations that invalidate caches
export function useAddBook() { ... }
export function useUpdateBookPosition() { ... }
export function useUpdateReadingStatus() { ... }
```

Pages compose these hooks; they never call `api` directly.

## Critical Backend Gotchas

These are non-obvious backend behaviours that affect frontend implementation.

### 1. OwnedBook Has No Title or Author

`GET /v1/books/` returns `OwnedBook[]`. Each item only has `bibliographic_record_id`, location fields, and reading status — **no title, no author**.

Always join to bibliographic records in memory:

```ts
// features/books/hooks.ts
function joinBooksToRecords(books: OwnedBook[], records: BibliographicRecord[]) {
  const recordMap = new Map(records.map(r => [r.id, r]))
  return books.map(b => ({ ...b, record: recordMap.get(b.bibliographic_record_id) }))
}
```

### 2. Position and Reading-Status Use Query Params

These two endpoints do **not** accept a JSON body — parameters must go in the query string:

```ts
// CORRECT
api.post(`v1/books/${id}/reading-status`, {
  searchParams: { reading_status: 'read' }
})

api.post(`v1/books/${id}/position`, {
  searchParams: { section_id: sectionId, shelf_id: shelfId, position: pos }
})

// WRONG — body is ignored
api.post(`v1/books/${id}/reading-status`, { json: { reading_status: 'read' } })
```

### 3. Register Returns No Token

`POST /v1/auth/register` returns only `{ family_id, user_id }`. It does not issue a JWT. After registration, immediately call login:

```ts
await api.post('v1/auth/register', { json: data })
const tokens = await api.post('v1/auth/login', { json: { email, password } }).json()
```

### 4. Catalog Timestamps Are ISO Strings

Backend serializes `datetime` fields as ISO 8601 strings. Type them as `string` in `types/api.ts`, not `Date`. Parse with `new Date(str)` only when needed for display.

### 5. Search Is on Records, Not Books

`GET /v1/records/?q=` searches title/author/ISBN. `GET /v1/books/` supports only `limit`/`offset`. Filtering books by room or reading status is **client-side** over the loaded set — this is acceptable for a home library.

### 6. JWT Payload — Decode Client-Side

The access token encodes `sub` (user_id), `email`, `family_id`, `role`, and `exp`. Decode it in `lib/jwt.ts` to read the current user's role and family_id without an extra request.

## Types (`types/api.ts`)

This file is the **single source of truth** for all backend shapes — hand-written to mirror Pydantic schemas. Update it whenever the backend schema changes.

```ts
// Correct reading-status values (from backend enums.py)
export type ReadingStatus = 'to_read' | 'reading' | 'read'

export interface OwnedBook {
  id: string
  bibliographic_record_id: string
  shelf_id: string
  position: number
  reading_status: ReadingStatus
  created_at: string    // ISO string — not Date
  updated_at: string
}

export interface BibliographicRecord {
  id: string
  title: string
  author: string
  isbn: string | null
  publisher: string | null
  published_year: number | null
  cover_url: string | null
}
```

## Design System

Colors are CSS custom properties in `styles/index.css` (Pergamena palette). Tailwind maps to them via `tailwind.config.ts`. **Never hardcode hex values in components** — always use the Tailwind tokens.

| Token | Color | Use |
|-------|-------|-----|
| `paper` | `#FBF7F0` | App background |
| `ink` | `#2B2622` | Primary text |
| `brand` | `#A8503A` | Primary actions (terracotta) |
| `sage` | `#7A8B6F` | "read" status |
| `amber` | `#C9912E` | "reading" status |
| `stone` | `#9A9187` | "to_read" status |

Reading status → color mapping is centralized in `lib/format.ts`. Do not duplicate it in components.

## Building for Production

```bash
cd jinbocho-fe
VITE_API_BASE_URL=https://jinbocho-api-gateway.onrender.com npm run build
# Output: dist/
```

The `dist/` folder is a static site — serve it from Render Static Site or any CDN. The `render.yaml` in `jinbocho-fe` already configures the correct publish directory and the SPA rewrite rule (`/* → /index.html`).
