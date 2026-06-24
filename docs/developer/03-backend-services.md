# Backend Services

Jinbocho's backend is composed of FastAPI microservices: three are always present (Community edition), a fourth — **ai-service** — is optional and only required for the **Pro edition**. Two are **Private Services** (internal only); one is the public **API Gateway**.

## Architecture at a Glance

```
                    ┌─────────────────────────────────┐
Client (Browser)    │   API Gateway  :8000  (PUBLIC)   │
──────────────────► │  JWT validation · CORS · Proxy   │
                    └───────────┼─────────────────┘
                                │ internal HTTP
              ┌─────────────────┼─────────────────┬─────────────────┐
              │                 │                 │
   ┌──────────────┐   ┌──────────────────┐   ┌──────────────┐
   │ auth-service │   │ catalog-service   │   │  ai-service   │
   │    :8001     │   │    :8002          │   │    :8003      │
   │  (Private)   │   │  (Private)        │   │ (Private, Pro)│
   └──────┼───────┘   └──────┼────────────┘   └──────┼────────┘
          │                  │                       │
   ┌──────┴──────┐   ┌───────┴──────┐         ┌──────┴──────┐
   │  auth_db     │   │  catalog_db  │         │   ai_db      │
   │ (PostgreSQL) │   │ (PostgreSQL) │         │ (PostgreSQL) │
   └──────────────┘   └──────────────┘         └──────────────┘
```

Each service has its own database. Services never share a database. `catalog-service` validates JWTs locally (it does **not** call back into `auth-service`); `ai-service` calls out to `catalog-service` for ISBN/cover lookups and to the configured LLM provider.

---

## auth-service (port 8001)

**Repository**: `jinbocho-auth-v1`

### Responsibilities

- Register families and their first admin user
- Authenticate users (email + password)
- Issue and rotate JWT access + refresh tokens
- Manage family metadata, including the irreversible full-account deletion flow
- Invite, manage and export/import user accounts; handle role assignment (Admin, Editor, Viewer)
- Password reset via email (SMTP), with a console fallback in development

### Key Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/v1/auth/register` | — | Create family + first admin |
| `POST` | `/v1/auth/login` | — | Obtain access + refresh tokens |
| `POST` | `/v1/auth/refresh` | — | Rotate refresh token |
| `POST` | `/v1/auth/logout` | Bearer | Revoke refresh token |
| `POST` | `/v1/auth/forgot-password` | — | Send a password reset email (or log it to console in dev) |
| `POST` | `/v1/auth/reset-password` | — | Consume the reset token and set a new password |
| `GET` | `/v1/families/{family_id}` | Bearer | Get family information (any member) |
| `PATCH` | `/v1/families/{family_id}` | Bearer (Admin) | Update family information |
| `POST` | `/v1/families/{family_id}/confirm-deletion` | Bearer (Admin) | Verify password + family name before the irreversible deletion below |
| `DELETE` | `/v1/families/{family_id}` | Bearer (Admin) | Permanently delete the family and every user, cascading to refresh + reset tokens |
| `GET` | `/v1/users/me` | Bearer | Get current authenticated user |
| `PATCH` | `/v1/users/me` | Bearer | Update own name / reading goal |
| `GET` | `/v1/users/` | Bearer | List family members |
| `POST` | `/v1/users/` | Bearer (Admin) | Invite new user (sends an invite email; no password set yet) |
| `PATCH` | `/v1/users/{id}` | Bearer (Admin) | Update user / change role |
| `DELETE` | `/v1/users/{id}` | Bearer (Admin) | Remove user |
| `GET` | `/v1/users/export` | Bearer (Admin) | Export the family's identity + member roster for backup |
| `POST` | `/v1/users/import` | Bearer (Admin) | Restore users from a backup export into the current family |
| `GET` | `/health` | — | Health check |

!!! info "Account deletion is a two-service operation"
    Full account deletion spans both `auth-service` and `catalog-service`. The frontend calls
    `POST /v1/families/{id}/confirm-deletion` (verifies credentials), then
    `DELETE /v1/catalog/account` (wipes location/catalog data, see below), then
    `DELETE /v1/families/{id}` (wipes the family and its users) — in that order.

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | — | `postgresql+asyncpg://...` |
| `JWT_SECRET_KEY` | ✅ | — | Shared secret — **must match** catalog + gateway |
| `JWT_ALGORITHM` | — | `HS256` | Signing algorithm |
| `JWT_ISSUER` | — | `jinbocho-auth` | Token issuer claim (`iss`) |
| `JWT_AUDIENCE` | — | `jinbocho` | Token audience claim (`aud`) |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | — | `30` | Access token lifetime |
| `REFRESH_TOKEN_EXPIRE_DAYS` | — | `30` | Refresh token lifetime |
| `PASSWORD_RESET_EXPIRE_MINUTES` | — | `15` | Password reset token lifetime |
| `FRONTEND_BASE_URL` | — | `http://localhost:5173` | Used to build the reset-password link sent by email |
| `SMTP_HOST` | — | *(empty)* | SMTP server for outgoing email. Leave empty to log emails to the console instead of sending them (development) |
| `SMTP_PORT` | — | `587` | SMTP port |
| `SMTP_USER` | — | *(empty)* | SMTP auth username |
| `SMTP_PASSWORD` | — | *(empty)* | SMTP auth password |
| `EMAIL_FROM` | — | `noreply@jinbocho.local` | "From" address on outgoing emails |
| `DEBUG` | — | `false` | Enables SQL query logging |

### JWT Token Payload

Tokens issued by auth-service contain:

```json
{
  "sub": "user-uuid",
  "email": "alice@example.com",
  "family_id": "family-uuid",
  "role": "admin",
  "exp": 1234567890,
  "iss": "jinbocho-auth",
  "aud": "jinbocho"
}
```

Both catalog-service and the gateway validate this token using the shared `JWT_SECRET_KEY` — neither one calls back into auth-service to do so.

### Run Locally (without Docker)

```bash
cd jinbocho-auth-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # edit DATABASE_URL for local Postgres
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

Swagger UI: [http://localhost:8001/docs](http://localhost:8001/docs)

### Run Tests

```bash
cd jinbocho-auth-v1
source .venv/bin/activate
pytest tests/ -v

# Unit tests only (no DB):
pytest tests/unit/ -v

# Integration tests (needs a running Postgres):
pytest tests/integration/ -v
```

### Database Schema

Tables managed via Alembic migrations (applied automatically on startup):

- `families` — Family account (name, id)
- `users` — User accounts (email, hashed_password, role, family_id)
- `refresh_tokens` — Issued refresh tokens with revocation support
- `password_reset_tokens` — Issued password reset / invite tokens with expiry

---

## catalog-service (port 8002)

**Repository**: `jinbocho-catalog-v1`

### Responsibilities

- Manage the physical location hierarchy: rooms → bookcases → sections → shelves
- Manage bibliographic records (title, author, ISBN, publisher, cover, AI-assisted "incipit" presentation)
- Manage owned books (copies linking a record to a shelf + reading status), multi-reader tracking (`reads`) and intra-family loans (`loans`)
- ISBN lookup and online search via Open Library (primary) and Google Books (fallback), with local cache
- Book search, history/audit log, CSV/JSON export, full-library export/import for backups
- Bookcase visual map
- GDPR-style full account data deletion (its half of the cross-service flow described under auth-service)

### Key Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET/POST` | `/v1/rooms/` | Bearer | List / create rooms |
| `GET/PATCH/DELETE` | `/v1/rooms/{id}` | Bearer | Room CRUD |
| `GET/POST` | `/v1/bookcases/` | Bearer | List (filter by `room_id`) / create bookcases |
| `GET/PATCH/DELETE` | `/v1/bookcases/{id}` | Bearer | Bookcase CRUD |
| `GET/POST` | `/v1/sections/` | Bearer | List (filter by `bookcase_id`) / create sections |
| `GET/PATCH/DELETE` | `/v1/sections/{id}` | Bearer | Section CRUD |
| `GET/POST` | `/v1/shelves/` | Bearer | List (filter by `section_id`) / create shelves |
| `GET/PATCH/DELETE` | `/v1/shelves/{id}` | Bearer | Shelf CRUD |
| `GET/POST` | `/v1/bibliographic-records/` | Bearer | Search records (`?q=`) / create record |
| `GET/PATCH/DELETE` | `/v1/bibliographic-records/{id}` | Bearer | Record CRUD |
| `GET` | `/v1/bibliographic-records/genres` | Bearer | Distinct normalized genres in the family library, with counts |
| `GET` | `/v1/bibliographic-records/{id}/incipit` | Bearer | Get or lazily derive the book presentation |
| `PUT` | `/v1/bibliographic-records/{id}/incipit` | Bearer | Set the presentation (manual text or AI-generated) |
| `GET` | `/v1/ingestion/isbn/{isbn}` | Bearer | Lookup ISBN metadata (cache → Open Library → Google Books) |
| `GET` | `/v1/ingestion/search` | Bearer | Search books online by title/author |
| `POST` | `/v1/ingestion/bulk-lookup` | Bearer | Bulk ISBN lookup |
| `GET/POST` | `/v1/books/` | Bearer | Owned books (list with `limit`/`offset`) |
| `GET` | `/v1/books/reads` | Bearer | List all reads for the family |
| `GET` | `/v1/books/loans/active` | Bearer | List all active loans for the family |
| `GET/PATCH/DELETE` | `/v1/books/{id}` | Bearer | Owned book CRUD |
| `POST` | `/v1/books/{id}/position` | Bearer | Update shelf position (query params) |
| `POST` | `/v1/books/{id}/reading-status` | Bearer | Update reading status (query params) |
| `GET` | `/v1/books/{id}/history` | Bearer | Get book history |
| `GET/POST` | `/v1/books/{id}/reads` | Bearer | List readers of a book / mark a member as having read it |
| `DELETE` | `/v1/books/{id}/reads/{user_id}` | Bearer | Remove a member's read mark |
| `GET/POST` | `/v1/books/{id}/loans` | Bearer | List loan history for a book / lend it to a family member |
| `POST` | `/v1/books/{id}/loans/return` | Bearer | Mark the active loan as returned |
| `GET` | `/v1/map/bookcase/{id}` | Bearer | Bookcase visual map data |
| `GET` | `/v1/export/books.csv` | Bearer (Admin) | Export owned books as CSV |
| `GET` | `/v1/export/books.json` | Bearer (Admin) | Export owned books as JSON |
| `GET` | `/v1/export/full` | Bearer (Admin) | Full library backup: locations, records, books, loans, reads, history |
| `POST` | `/v1/import/full` | Bearer (Admin) | Restore a full library backup produced by `/v1/export/full` |
| `POST` | `/v1/members/removed` | Bearer (Admin) | Snapshot a family member's name/email/role just before `auth-service` hard-deletes them |
| `DELETE` | `/v1/account/` | Bearer (Admin) | Catalog-service half of full account deletion (see auth-service section) |
| `GET` | `/health` | — | Health check |

!!! warning "Query params, not JSON body"
    `POST /v1/books/{id}/position` and `POST /v1/books/{id}/reading-status` read their
    parameters from the **query string**, not a JSON body. Build URLs accordingly:
    ```
    POST /v1/books/abc/reading-status?reading_status=read
    POST /v1/books/abc/position?section_id=x&shelf_id=y&position=3
    ```

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | — | `postgresql+asyncpg://...` |
| `JWT_SECRET_KEY` | ✅ | — | **Must match** auth + gateway |
| `JWT_ALGORITHM` | — | `HS256` | Signing algorithm |
| `JWT_ISSUER` | — | `jinbocho-auth` | Must match the issuer in tokens from auth-service |
| `JWT_AUDIENCE` | — | `jinbocho` | Must match the audience in tokens from auth-service |
| `GOOGLE_BOOKS_API_KEY` | — | *(empty)* | Fallback ISBN lookup; without a key the quota is shared/limited |
| `OPEN_LIBRARY_URL` | — | `https://openlibrary.org` | Open Library base URL |
| `GOOGLE_BOOKS_URL` | — | `https://www.googleapis.com/books/v1` | Google Books base URL |
| `ISBN_CACHE_TTL_DAYS` | — | `30` | Days to cache ISBN metadata locally |
| `DEBUG` | — | `false` | SQL query logging |

!!! note "No call back into auth-service"
    Earlier versions of this service called `auth-service` to validate tokens. It now validates
    JWTs **locally** using the shared `JWT_SECRET_KEY` / `JWT_ISSUER` / `JWT_AUDIENCE` — there is
    no `AUTH_SERVICE_URL` setting, even though one is still present (unused) in the repo's
    `.env.example`.

### ISBN Lookup Flow

```
Request /v1/ingestion/isbn/9788845292613
     │
     ├─► Local DB cache hit? → return immediately
     │
     ├─► Open Library → fetch metadata (free, no key needed)
     │       Hit? → save to cache → return
     │
     └─► Google Books → fetch metadata (requires API key)
             Hit? → save to cache → return
             Miss? → 404 "ISBN not found"
```

### Run Locally (without Docker)

```bash
cd jinbocho-catalog-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # set DATABASE_URL and JWT_SECRET_KEY
uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
```

Swagger UI: [http://localhost:8002/docs](http://localhost:8002/docs)

### Run Tests

```bash
cd jinbocho-catalog-v1
source .venv/bin/activate
pytest tests/ -v
```

### Database Schema

Tables managed via Alembic migrations:

- `rooms` — Physical rooms (family-scoped)
- `bookcases` — Bookcases within a room
- `sections` — Vertical columns within a bookcase
- `shelves` — Horizontal shelves within a section
- `bibliographic_records` — Book metadata (title, author, ISBN, publisher, cover_url, incipit)
- `owned_books` — Copies linking a record to a shelf + reading status + position
- `book_reads` — Which family members have read which owned book
- `book_loans` — Loan history (borrower, lent/returned dates) per owned book
- `isbn_cache` — Cached ISBN lookup results (TTL-based)
- `audit_log` — History of book movements and status changes
- `removed_members` — Snapshot of deleted users' name/email/role for export/import continuity

---

## ai-service (port 8003) — Pro edition only

**Repository**: `jinbocho-ai-v1`

### Responsibilities

- Generate AI book presentations ("incipit") on demand for `catalog-service`
- Tag suggestions, duplicate detection and recommendations (currently stubbed, return empty results)
- Cover-photo OCR/classification pipeline (implemented but **paused** — disabled in the router because OCR accuracy is currently inadequate)
- Talks to an OpenAI-compatible LLM endpoint (works out of the box with Groq's free tier) and to `catalog-service` / Google Books for cover lookups

This service is optional. It is only started, and only reachable through the gateway, when `ai` is included in the gateway's `JINBOCHO_FEATURES` (the **Pro edition**). The **Community edition** runs without it.

### Key Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/v1/suggestions/tags` | Tag suggestions (currently returns an empty list — not yet implemented) |
| `POST` | `/v1/suggestions/incipit` | Generate a book presentation via the configured LLM |
| `POST` | `/v1/suggestions/dedup` | Duplicate detection (currently returns an empty list — not yet implemented) |
| `GET` | `/v1/suggestions/recommendations/{family_id}` | Recommendations (currently returns an empty list — not yet implemented) |
| `GET` | `/health` | Health check |

!!! warning "Cover OCR is implemented but disabled"
    `app/api/v1/endpoints/cover.py` and its `POST /v1/cover/extract` endpoint exist in the
    codebase, but the route is **commented out** in `app/api/v1/router.py` pending accuracy
    improvements. The gateway's `/v1/ai/cover/*` proxy path will 404 until this is re-enabled.

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | — | `postgresql+asyncpg://...` (own `ai_db`) |
| `LLM_ENABLED` | — | `false` | Master switch for all LLM-backed features |
| `LLM_BASE_URL` | — | `https://api.openai.com/v1` | Any OpenAI-compatible endpoint (Groq, OpenAI, Gemini, local Ollama, ...) |
| `LLM_MODEL` | — | `gpt-4o-mini` | Model name for the configured provider |
| `LLM_API_KEY` | — | *(empty)* | API key for the configured provider |
| `CATALOG_SERVICE_URL` | — | `http://catalog-service:8002` | Internal URL of catalog-service |
| `GOOGLE_BOOKS_API_KEY` | — | *(empty)* | Same key as catalog-service's; used for cover lookups |
| `GOOGLE_BOOKS_TIMEOUT` | — | `3.0` | Seconds before giving up on a Google Books request |
| `COVER_MAX_IMAGE_DIMENSION` | — | `1200` | Downscale covers larger than this (px, longest side) before OCR |
| `COVER_MAX_FILE_SIZE_MB` | — | `5` | Reject cover uploads above this size before reading them into memory |
| `DEBUG` | — | `false` | SQL query logging |

!!! info "Bring your own LLM provider"
    The default `.env.example` is pre-filled for Groq's free tier (`LLM_BASE_URL=https://api.groq.com/openai/v1`),
    while `LLM_BASE_URL`'s own default and the Render blueprint both fall back to OpenAI. Pick whichever
    OpenAI-compatible provider you want — Groq, OpenAI, Gemini, or a local Ollama instance — by setting
    `LLM_BASE_URL` / `LLM_MODEL` / `LLM_API_KEY` together.

### Run Locally (without Docker)

```bash
cd jinbocho-ai-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # set DATABASE_URL, and LLM_* if you want real suggestions
uvicorn app.main:app --reload --host 0.0.0.0 --port 8003
```

Swagger UI: [http://localhost:8003/docs](http://localhost:8003/docs)

### Database Schema

- `ai_suggestions` — Cached/generated suggestions (incipit text, tags, dedup hints) keyed by bibliographic record

---

## api-gateway (port 8000)

**Repository**: `jinbocho-api-gateway-v1`

### Responsibilities

- Single public entry point for all client requests
- JWT validation at the edge (verifies token before proxying)
- CORS policy enforcement
- Request routing to internal services, gated by `JINBOCHO_FEATURES`

All endpoints are mounted under `/v1` and proxied to internal services. Unlike a 1:1 mirror, the gateway groups catalog-service's endpoints into two public prefixes — `/v1/catalog/*` for books/records/ingestion/export/import/account/members, and `/v1/location/*` for rooms/bookcases/sections/shelves — even though both are served by the same catalog-service process.

### Routing Table

| Gateway Path | Proxied To | Notes |
|--------------|------------|-------|
| `/v1/auth/*` | `auth-service:8001/v1/auth/*` | |
| `/v1/families/*` | `auth-service:8001/v1/families/*` | |
| `/v1/users/*` | `auth-service:8001/v1/users/*` | |
| `/v1/catalog/*` | `catalog-service:8002/v1/*` | Records, books, ingestion, export, import, members, account |
| `/v1/location/*` | `catalog-service:8002/v1/*` | Rooms, bookcases, sections, shelves |
| `/v1/ai/cover/*` | `ai-service:8003/v1/cover/*` | Requires `ai` in `JINBOCHO_FEATURES`; currently 404s (cover route disabled, see ai-service) |
| `/v1/ai/*` | `ai-service:8003/v1/suggestions/*` | Requires `ai` in `JINBOCHO_FEATURES` |
| `/health` | local | |

So, for example, the frontend's `bibliographic-records` calls go to `/v1/catalog/bibliographic-records`, and `rooms` calls go to `/v1/location/rooms` — not to `/v1/records` or `/v1/rooms` directly.

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `JWT_SECRET_KEY` | ✅ | — | **Must match** auth + catalog |
| `JWT_ALGORITHM` | — | `HS256` | Signing algorithm |
| `AUTH_SERVICE_URL` | — | `http://auth-service:8001` | Internal URL of auth-service |
| `CATALOG_SERVICE_URL` | — | `http://catalog-service:8002` | Internal URL of catalog-service |
| `AI_SERVICE_URL` | — | `http://ai-service:8003` | Internal URL of ai-service (only reachable when `ai` is in `JINBOCHO_FEATURES`) |
| `CORS_ORIGINS` | — | `["*"]` | JSON array of allowed origins, e.g. `["https://jinbocho-fe.onrender.com"]` |
| `JINBOCHO_FEATURES` | — | `catalog,auth` | Comma-separated enabled modules. Community edition: `catalog,auth`. Pro edition: `catalog,auth,ai` (requires ai-service + Pro license) |
| `DEBUG` | — | `false` | FastAPI debug mode + verbose logging |

!!! danger "CORS in production"
    Never use `["*"]` in production. Set `CORS_ORIGINS` to the exact frontend URL.
    In local development the docker-compose env uses `["*"]` — this is acceptable.

### Run Locally (without Docker)

```bash
cd jinbocho-api-gateway-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Swagger UI: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## Code Quality — All Services

Run these before every commit:

```bash
# Type checking (strict)
python -m mypy app --strict

# Linting + auto-fix
ruff check app tests
ruff check --fix app tests

# Tests
pytest tests/ -v
```
