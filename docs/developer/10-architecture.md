# Architecture Overview

## System Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                           BROWSER / MOBILE                       │
└──────────────────────────────┬──────────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  jinbocho-fe  (React 18 SPA — Render Static Site)               │
│  features/ (TanStack Query) → lib/api.ts (ky) → gateway :8000  │
└──────────────────────────────┬──────────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  api-gateway  (FastAPI — Render Web Service, PUBLIC)             │
│  JWT validation · CORS · Reverse proxy                          │
└─────────┬───────────────────┬────────────────────────────────────┘
          │ internal HTTP       │ internal HTTP
          ▼                     ▼
┌──────────────────┐   ┌──────────────────┐   ┌───────────────┐
│  auth-service    │   │  catalog-service  │   │  ai-service   │
│  (Private)       │   │  (Private)        │   │  (Private)    │
└────────┬─────────┘   └────────┬─────────┘   └───────┬───────┘
         │                      │                       │
         ▼                      ▼                       ▼
   ┌──────────┐         ┌──────────┐           ┌──────────┐
   │ auth_db  │         │catalog_db│           │  ai_db   │
   │ (Neon)   │         │ (Neon)   │           │  (Neon)  │
   └──────────┘         └──────────┘           └──────────┘
```

## Bounded Contexts

### Auth Context
Owns everything about **who can access the system**: family lifecycle, user lifecycle, JWT issuance, refresh token rotation, roles.

### Catalog Context
Owns everything about **what books exist and where they are**: location hierarchy, bibliographic records, owned copies, ISBN ingestion, audit log, export.

### Gateway Context
No domain logic, no database. JWT validator, CORS enforcer, reverse proxy.

### AI Context (Optional)
Optional service for AI-powered book presentations, tagging, dedup.

## Data Flow: Adding a Book via ISBN

```
1. User scans barcode → frontend decodes ISBN via @zxing/browser
2. POST /v1/records/isbn-lookup?isbn=... → gateway validates JWT → catalog
3. Catalog checks isbn_cache → miss → queries Open Library → saves to cache
4. Returns BibliographicRecord → frontend pre-fills form
5. User selects shelf → POST /v1/books/ with bibliographic_record_id + shelf_id
6. Catalog creates OwnedBook + audit_log in single transaction
7. Frontend joins OwnedBook to BibliographicRecord in memory
```

## Code Architecture (Per Service)

Each microservice follows **Clean / Hexagonal Architecture**:

```
Presentation Layer  →  app/api/v1/endpoints/, app/api/v1/schemas/
Application Layer   →  app/application/use_cases/, app/application/services/
Domain Layer        →  app/domain/entities/, app/domain/repositories/
Infrastructure      →  app/infrastructure/repositories/, app/infrastructure/external/
```

**Rules**: Domain layer has zero knowledge of HTTP/SQLAlchemy. Use cases accept/return domain entities. Every endpoint calls exactly one use case.

## Security Model

- Stateless JWTs; refresh tokens stored server-side (enables revocation)
- Access token: 30 min. Refresh token: 30 days (rotated on use)
- JWT payload encodes `family_id` and `role` — no extra DB lookup per request
- Every catalog query filters by `family_id` from the token
- Private Services not reachable from internet — only from within Render's internal network

## Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|----------|
| Framework | FastAPI | Async-first, OpenAPI built-in |
| ORM | SQLAlchemy (async) | Async-capable, declarative |
| Database | PostgreSQL 16 | ACID for catalog operations |
| Auth | JWT + server-side refresh | Stateless access, revocable refresh |
| One DB per service | ✅ | Prevents tight coupling |
| Clean Architecture | ✅ | Domain logic testable without DB |
| Frontend state | TanStack Query | Eliminates most useState/useEffect |
