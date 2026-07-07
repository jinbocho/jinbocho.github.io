# Architecture Overview

## System Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                           BROWSER / MOBILE                       │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  jinbocho-fe  (React 18 SPA — Render Static Site)               │
│                                                                  │
│  features/ (TanStack Query) → lib/api.ts (ky) → gateway :8000  │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  api-gateway  (FastAPI — Render Web Service, PUBLIC)             │
│                                                                  │
│  JWT validation · CORS · Reverse proxy                          │
│  routes: /v1/auth /v1/users /v1/families /v1/catalog            │
│          /v1/location                                           │
└─────────┬─────────────────┬──────────────────────────────────┘
          │ internal HTTP   │ internal HTTP
          ▼                 ▼
┌──────────────────┐ ┌──────────────────┐
│  auth-service    │ │  catalog-service  │
│  (Private)       │ │  (Private)        │
│                  │ │                   │
│  families        │ │  rooms            │
│  users           │ │  bookcases        │
│  JWT             │ │  books / loans    │
│  refresh tokens  │ │  ISBN ingestion   │
└────────┬────────┘ └────────┬─────────┘
         │                    │
         ▼                    ▼
   ┌──────────┐       ┌────────────┐
   │ auth_db  │       │ catalog_db │
   │ (Neon)   │       │ (Neon)     │
   └──────────┘       └────────────┘
```

**Roadmap:** `jinbocho-auth-v2` (passwordless magic-link login + optional TOTP MFA) exists as a scaffold only — domain entities and use-case stubs are done, but infrastructure, API, and persistence layers are not implemented yet, so it is not deployed anywhere. The JWT contract is designed to be identical to v1, so no other service will need changes when it ships.

## Bounded Contexts

### Auth Context (`auth-service` + `auth_db`)

Owns everything about **who can access the system**:
- Family account lifecycle (create, update)
- User lifecycle (create, invite, change role, deactivate)
- Authentication: password hashing, JWT issuance, refresh token rotation
- Authorization roles: `admin | editor | viewer`

The auth-service is the only issuer of JWTs. All other services validate tokens using the shared `JWT_SECRET_KEY` but never issue new ones.

### Catalog Context (`catalog-service` + `catalog_db`)

Owns everything about **what books exist and where they are**:
- Physical location hierarchy: rooms → bookcases → sections → shelves
- Bibliographic records (title, author, ISBN, metadata)
- Owned book copies (which copy is on which shelf, reading status, position)
- ISBN metadata ingestion via Open Library and Google Books
- Audit log of book movements and status changes
- Export (CSV, JSON)

This service intentionally fuses Location + Catalog + Ingestion into one service to keep book creation and shelf assignment in a single ACID transaction.

### Gateway Context (`api-gateway`)

No domain logic, no database. Acts as:
- The single entry point for all client traffic
- JWT validator (edge security)
- CORS policy enforcer
- Reverse proxy to internal services

## Data Flow Example: Adding a Book via ISBN

```
1. User points camera at barcode → frontend decodes ISBN via @zxing/browser

2. Frontend → GET /v1/catalog/ingestion/isbn/9788845292613
   Gateway validates JWT, strips the /v1/catalog prefix, proxies to
   catalog-service's /v1/ingestion/isbn/{isbn}

3. Catalog checks local isbn_cache
   Cache miss → queries Open Library → data found → saves to cache

4. Catalog returns BibliographicRecord data to frontend
   Frontend pre-fills title, author, publisher, cover

5. User selects location (room → bookcase → section → shelf → position)
   and clicks Save

6. Frontend → POST /v1/catalog/books/
   Body: { bibliographic_record_id, shelf_id, position, reading_status }

7. Catalog creates OwnedBook + updates audit_log in a single transaction
   Returns OwnedBook response (no title/author — those are on the record)

8. Frontend joins OwnedBook to BibliographicRecord in memory using
   joinBooksToRecords() → displays full book card to user
```

## Code Architecture (Per Service)

Each microservice follows **Clean / Hexagonal Architecture**:

```
Presentation Layer
└── app/api/v1/endpoints/       FastAPI route handlers
    app/api/v1/schemas/         Pydantic request/response models

Application Layer
└── app/application/use_cases/  Business logic orchestration
    app/application/services/   Domain services (token, email, etc.)

Domain Layer
└── app/domain/entities/        Pure Python domain entities
    app/domain/repositories/    Abstract repository interfaces
    app/domain/exceptions.py    Domain exceptions

Infrastructure Layer
└── app/infrastructure/repositories/   SQLAlchemy implementations
    app/infrastructure/external/        HTTP clients (Open Library, Google Books)
    app/infrastructure/database.py      AsyncSession setup
```

**Rules that must be upheld**:

1. The domain layer has **zero knowledge** of HTTP, SQLAlchemy, or external APIs
2. Use cases accept and return domain entities, not HTTP schemas
3. All domain logic goes in use cases or domain entities — never in endpoints
4. No logic in `__init__.py` files
5. Every endpoint calls exactly one use case

## Security Model

### Authentication

- Stateless JWTs; no session store needed for normal requests
- Refresh tokens stored server-side in `auth_db` (enables revocation on logout)
- Access token lifetime: 30 minutes
- Refresh token lifetime: 30 days (rotated on use)

### Authorization

- JWT payload encodes `family_id` and `role` — no extra DB lookup per request
- Every catalog-service query filters by `family_id` from the token (family isolation)
- Roles enforced at the use-case level, not the endpoint level

### Public vs Protected Endpoints

| Endpoint | Auth |
|----------|------|
| `POST /v1/auth/register` | Public |
| `POST /v1/auth/login` | Public |
| `POST /v1/auth/refresh` | Public |
| `GET /health` | Public |
| Everything else | Bearer JWT required |

### Network Isolation

- Private Services on Render are not reachable from the internet — only from other services in the same Render region
- The gateway is the only service with a public URL
- Databases (Neon) are accessible only via authenticated connection strings — not exposed on a public port

## Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|----------|
| Framework | FastAPI | Async-first, OpenAPI/Swagger built-in, excellent type hint support |
| ORM | SQLAlchemy (async) | Async-capable, declarative schema, works with PostgreSQL and asyncpg |
| Database | PostgreSQL 16 | ACID transactions required for catalog operations (book + position atomicity) |
| Auth | JWT + server-side refresh tokens | Stateless access, revocable refresh, no session store needed |
| Service communication | HTTP (no message broker) | Keeps deployment footprint minimal; synchronous calls are sufficient for this scale |
| One DB per service | ✅ | Prevents tight coupling; enables independent scaling and schema evolution |
| Clean Architecture | ✅ | Clear separation of concerns; domain logic is testable without database |
| Frontend state | TanStack Query | Server state normalized in cache; eliminates most useState and useEffect patterns |

## Deployment Environments

| Environment | Infrastructure | When Used |
|-------------|---------------|-----------|
| **Local** | Docker Compose | Daily development — full stack in one command |
| **Production** | Render + Neon | Live system — family users |
| **Staging** | *(not configured)* | Can be added by duplicating Render services with separate env vars |
