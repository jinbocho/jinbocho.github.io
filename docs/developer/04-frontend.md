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
└── styles/index.css      # Tailwind directives + CSS custom properties
```

**Convention**: `features/` holds data logic (hooks, helpers, types) — zero JSX. `routes/` and `components/` hold JSX.

## Critical Backend Gotchas

### 1. OwnedBook Has No Title or Author

`GET /v1/books/` returns `OwnedBook[]`. Each item only has `bibliographic_record_id`, location fields, and reading status — **no title, no author**.

Always join to bibliographic records in memory:

```ts
function joinBooksToRecords(books: OwnedBook[], records: BibliographicRecord[]) {
  const recordMap = new Map(records.map(r => [r.id, r]))
  return books.map(b => ({ ...b, record: recordMap.get(b.bibliographic_record_id) }))
}
```

### 2. Position and Reading-Status Use Query Params

```ts
// CORRECT
api.post(`v1/books/${id}/reading-status`, {
  searchParams: { reading_status: 'read' }
})

// WRONG — body is ignored
api.post(`v1/books/${id}/reading-status`, { json: { reading_status: 'read' } })
```

### 3. Register Returns No Token

`POST /v1/auth/register` returns only `{ family_id, user_id }`. After registration, immediately call login.

### 4. Search Is on Records, Not Books

`GET /v1/records/?q=` searches title/author/ISBN. `GET /v1/books/` supports only `limit`/`offset`.

## Design System

| Token | Color | Use |
|-------|-------|-----|
| `paper` | `#FBF7F0` | App background |
| `ink` | `#2B2622` | Primary text |
| `brand` | `#A8503A` | Primary actions (terracotta) |
| `sage` | `#7A8B6F` | "read" status |
| `amber` | `#C9912E` | "reading" status |
| `stone` | `#9A9187` | "to_read" status |
