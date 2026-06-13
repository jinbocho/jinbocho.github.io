# Backend Services

Jinbocho's backend is composed of four FastAPI microservices. Three are **Private Services** (internal only); one is the public **API Gateway**.

## Architecture at a Glance

```
                    ┌─────────────────────────────────┐
Client (Browser)    │   API Gateway  :8000  (PUBLIC)   │
──────────────────► │  JWT validation · CORS · Proxy   │
                    └───────────┬─────────────────────┘
                                │ internal HTTP
              ┌─────────────────┼──────────────────┐
              ▼                 ▼                  ▼
     ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
     │ auth-service │  │catalog-service│  │  ai-service  │
     │    :8001     │  │    :8002      │  │    :8003     │
     │  (Private)   │  │  (Private)   │  │  (Private)   │
     └──────┬───────┘  └──────┬───────┘  └──────────────┘
            │                 │
     ┌──────▼───────┐  ┌──────▼───────┐
     │  auth_db     │  │  catalog_db  │
     │ (PostgreSQL) │  │ (PostgreSQL) │
     └──────────────┘  └──────────────┘
```

Each service has its own database. Services never share a database and communicate only via HTTP through the gateway's routing rules.

---

## auth-service (port 8001)

**Repository**: `jinbocho-auth-v1`

### Responsibilities

- Register families and their first admin user
- Authenticate users (email + password)
- Issue and rotate JWT access + refresh tokens
- Manage family metadata and user accounts
- Handle role assignment (Admin, Editor, Viewer)

### Key Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/v1/auth/register` | — | Create family + first admin |
| `POST` | `/v1/auth/login` | — | Obtain access + refresh tokens |
| `POST` | `/v1/auth/refresh` | — | Rotate refresh token |
| `POST` | `/v1/auth/logout` | Bearer | Revoke refresh token |
| `GET` | `/v1/families/me` | Bearer | Get current family |
| `PATCH` | `/v1/families/me` | Bearer (Admin) | Update family |
| `GET` | `/v1/users/` | Bearer | List family members |
| `POST` | `/v1/users/` | Bearer (Admin) | Create user |
| `PATCH` | `/v1/users/{id}` | Bearer (Admin) | Update user / change role |
| `DELETE` | `/v1/users/{id}` | Bearer (Admin) | Remove user |
| `GET` | `/health` | — | Health check |

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | — | `postgresql+asyncpg://...` |
| `JWT_SECRET_KEY` | ✅ | — | Shared secret — **must match** catalog + gateway |
| `JWT_ALGORITHM` | — | `HS256` | Signing algorithm |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | — | `30` | Access token lifetime |
| `REFRESH_TOKEN_EXPIRE_DAYS` | — | `30` | Refresh token lifetime |
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

Both catalog-service and the gateway validate this token using the shared `JWT_SECRET_KEY`.

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

---

## catalog-service (port 8002)

**Repository**: `jinbocho-catalog-v1`

### Responsibilities

- Manage the physical location hierarchy: rooms → bookcases → sections → shelves
- Manage bibliographic records (title, author, ISBN, publisher, cover)
- Manage owned books (copies linking a record to a shelf + reading status)
- ISBN lookup via Open Library (primary) and Google Books (fallback), with local cache
- Book search, history/audit log, export (CSV/JSON)
- Bookcase visual map

### Key Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET/POST` | `/v1/rooms/` | Bearer | List / create rooms |
| `GET/PATCH/DELETE` | `/v1/rooms/{id}` | Bearer | Room CRUD |
| `GET/POST` | `/v1/bookcases/` | Bearer | List (filter by room) / create bookcases |
| `GET/PATCH/DELETE` | `/v1/bookcases/{id}` | Bearer | Bookcase CRUD |
| `GET/POST` | `/v1/sections/` | Bearer | Sections per bookcase |
| `GET/POST` | `/v1/shelves/` | Bearer | Shelves per section |
| `GET/POST` | `/v1/bibliographic-records/` | Bearer | Bibliographic records (search with `?q=`, filter with `?genre=<code>`) |
| `GET/PATCH/DELETE` | `/v1/bibliographic-records/{id}` | Bearer | Record CRUD |
| `GET` | `/v1/bibliographic-records/genres` | Bearer | Distinct normalized genres in the family library (with counts) |
| `GET` | `/v1/bibliographic-records/{id}/incipit` | Bearer | Get or lazily derive the book presentation |
| `PUT` | `/v1/bibliographic-records/{id}/incipit` | Bearer (Admin/Editor) | Set the presentation (manual text or AI-generated) |
| `POST` | `/v1/records/isbn-lookup` | Bearer | Lookup ISBN metadata |
| `GET/POST` | `/v1/books/` | Bearer | Owned books (list with `limit`/`offset`) |
| `GET/PATCH/DELETE` | `/v1/books/{id}` | Bearer | Owned book CRUD |
| `POST` | `/v1/books/{id}/position` | Bearer | Update shelf position (query params) |
| `POST` | `/v1/books/{id}/reading-status` | Bearer | Update reading status (query params) |
| `GET` | `/v1/map/bookcases/{id}` | Bearer | Bookcase visual map data |
| `GET` | `/v1/export/` | Bearer (Admin) | Export library as CSV or JSON |
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
| `AUTH_SERVICE_URL` | ✅ | — | Internal URL of auth-service |
| `JWT_SECRET_KEY` | ✅ | — | **Must match** auth + gateway |
| `JWT_ALGORITHM` | — | `HS256` | Signing algorithm |
| `GOOGLE_BOOKS_API_KEY` | — | — | Fallback ISBN lookup (free key, 100 req/day) |
| `OPEN_LIBRARY_URL` | — | `https://openlibrary.org` | Open Library base URL |
| `GOOGLE_BOOKS_URL` | — | `https://www.googleapis.com` | Google Books base URL |
| `ISBN_CACHE_TTL_DAYS` | — | `30` | Days to cache ISBN metadata locally |
| `DEBUG` | — | `false` | SQL query logging |

### ISBN Lookup Flow

```
Request /v1/records/isbn-lookup?isbn=9788845292613
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
cp .env.example .env   # set DATABASE_URL and AUTH_SERVICE_URL
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
- `bibliographic_records` — Book metadata (title, author, ISBN, publisher, cover_url)
- `owned_books` — Copies linking a record to a shelf + reading status + position
- `isbn_cache` — Cached ISBN lookup results (TTL-based)
- `audit_log` — History of book movements and status changes

---

## api-gateway (port 8000)

**Repository**: `jinbocho-api-gateway-v1`

### Responsibilities

- Single public entry point for all client requests
- JWT validation at the edge (verifies token before proxying)
- CORS policy enforcement
- Request routing to internal services
- Response aggregation (BFF pattern)

All endpoints are mounted under `/v1` and mirrored from internal services.

### Routing Table

| Gateway Path | Proxied To |
|--------------|------------|
| `/v1/auth/*` | `auth-service:8001/v1/auth/*` |
| `/v1/families/*` | `auth-service:8001/v1/families/*` |
| `/v1/users/*` | `auth-service:8001/v1/users/*` |
| `/v1/rooms/*` | `catalog-service:8002/v1/rooms/*` |
| `/v1/bookcases/*` | `catalog-service:8002/v1/bookcases/*` |
| `/v1/sections/*` | `catalog-service:8002/v1/sections/*` |
| `/v1/shelves/*` | `catalog-service:8002/v1/shelves/*` |
| `/v1/records/*` | `catalog-service:8002/v1/records/*` |
| `/v1/books/*` | `catalog-service:8002/v1/books/*` |
| `/v1/map/*` | `catalog-service:8002/v1/map/*` |
| `/v1/export/*` | `catalog-service:8002/v1/export/*` |
| `/health` | local |

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `JWT_SECRET_KEY` | ✅ | — | **Must match** auth + catalog |
| `JWT_ALGORITHM` | — | `HS256` | Signing algorithm |
| `AUTH_SERVICE_URL` | ✅ | — | Internal URL of auth-service |
| `CATALOG_SERVICE_URL` | ✅ | — | Internal URL of catalog-service |
| `AI_SERVICE_URL` | — | — | Internal URL of ai-service (omit if not deployed) |
| `CORS_ORIGINS` | ✅ | — | JSON array of allowed origins, e.g. `["https://jinbocho-fe.onrender.com"]` |
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

## ai-service (port 8003) — Optional

**Repository**: `jinbocho-ai-v1`

### Responsibilities

- **Book presentation (incipit)** — generate a short, spoiler-free presentation of a book from its title, author and genre, so readers can decide what to read next.
- Auto-tagging suggestions (scaffold)
- Duplicate detection hints (scaffold)
- Reading recommendations (future)

### Pluggable LLM — disabled by default

The AI layer is **optional and off by default**. With `LLM_ENABLED=false` (the default) the service still runs and every AI endpoint returns an empty result (`{"text": null}`) — it never errors and needs **no API key**. The book-presentation feature degrades gracefully: the catalog still serves the free editorial description, and only the "Generate with AI" button is inert.

The client is **OpenAI-compatible**, so you can point it at any provider via `LLM_BASE_URL` / `LLM_MODEL` / `LLM_API_KEY`:

| Provider | `LLM_BASE_URL` | Notes |
|----------|----------------|-------|
| Groq | `https://api.groq.com/openai/v1` | Free tier — e.g. `llama-3.3-70b-versatile` |
| OpenAI | `https://api.openai.com/v1` | Pay-as-you-go — e.g. `gpt-4o-mini` |
| Google Gemini | `https://generativelanguage.googleapis.com/v1beta/openai` | OpenAI-compatible endpoint |
| Ollama (local) | `http://localhost:11434/v1` | Self-hosted, no key |

### Key Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/v1/suggestions/incipit` | (internal) | Generate a presentation; returns `{"text": null}` when the LLM is disabled |
| `POST` | `/v1/suggestions/tags` | (internal) | Tag suggestions (scaffold) |
| `GET` | `/health` | — | Health check |

The gateway proxies `/v1/ai/{path}` → ai-service `/v1/suggestions/{path}`, so the frontend calls `POST /v1/ai/incipit`.

!!! info "Where the presentation is stored"
    Generated or manually edited presentations are persisted by the **catalog-service** on the
    bibliographic record (`incipit`, `incipit_source`, `incipit_generated_at`) via
    `PUT /v1/bibliographic-records/{id}/incipit`. For this feature the ai-service is **stateless** —
    the catalog never calls it in the write path (services stay decoupled).

### When to Deploy

The AI service is **optional**. You can skip it entirely: book presentations still work from the
free editorial description served by the catalog. Deploy it only when you want AI-generated
presentations — and even then it costs nothing if you point it at a free tier (Groq) or a local Ollama.

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | — | `postgresql+asyncpg://...` pointing to `ai_db` |
| `CATALOG_SERVICE_URL` | ✅ | — | Internal URL of catalog-service |
| `LLM_ENABLED` | — | `false` | Master switch. `false` → no AI calls, no key required |
| `LLM_BASE_URL` | — | `https://api.openai.com/v1` | OpenAI-compatible endpoint |
| `LLM_MODEL` | — | `gpt-4o-mini` | Model name |
| `LLM_API_KEY` | — | — | Provider API key (required only when `LLM_ENABLED=true`) |
| `DEBUG` | — | `false` | SQL query logging |

### Run Locally (without Docker)

```bash
cd jinbocho-ai-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # leave LLM_ENABLED=false, or configure Groq / OpenAI / Ollama
uvicorn app.main:app --reload --host 0.0.0.0 --port 8003
```

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
