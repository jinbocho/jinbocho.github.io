# Database & Migrations

Jinbocho uses **PostgreSQL 16** with one database per service. Migrations are managed by **Alembic** and run automatically on service startup.

## Databases

| Database | Service | Local Port |
|----------|---------|------------|
| `auth_db` | auth-service | `5432` |
| `catalog_db` | catalog-service | `5433` |
| `ai_db` | ai-service (optional) | `5434` |

## Automatic Migrations on Startup

Both auth-service and catalog-service run `alembic upgrade head` automatically before starting uvicorn. You do not need to run migrations manually in local development or production.

## Local Database Access

```bash
# auth_db
psql -U postgres -h 127.0.0.1 -p 5432 -d auth_db

# catalog_db
psql -U postgres -h 127.0.0.1 -p 5433 -d catalog_db

# ai_db (if running)
psql -U postgres -h 127.0.0.1 -p 5434 -d ai_db
```

Password: `postgres` (local dev only).

## Alembic Workflow

```bash
cd jinbocho-auth-v1
source .venv/bin/activate
alembic current       # shows current revision
alembic history       # shows full migration history
```

### Create a New Migration

```bash
alembic revision --autogenerate -m "add language column to users"
alembic upgrade head   # test it locally before committing
```

### Apply Migrations Manually

```bash
alembic upgrade head        # apply all pending migrations
alembic upgrade +1          # apply one migration forward
alembic downgrade -1        # revert one migration
```

### Migration on Production (Neon)

```bash
export DATABASE_URL="postgresql+asyncpg://user:pass@ep-xxx.neon.tech/auth_db?ssl=require"
cd jinbocho-auth-v1
source .venv/bin/activate
alembic upgrade head
```

!!! warning "Test migrations locally first"
    Always test migrations on a local database before applying to production.

## Auth Service Schema

```sql
CREATE TABLE families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    email VARCHAR UNIQUE NOT NULL,
    hashed_password VARCHAR NOT NULL,
    full_name VARCHAR NOT NULL,
    role VARCHAR NOT NULL DEFAULT 'viewer',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
```

## Catalog Service Schema

```sql
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE bookcases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL
);

CREATE TABLE sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bookcase_id UUID NOT NULL REFERENCES bookcases(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    position INTEGER NOT NULL
);

CREATE TABLE shelves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    position INTEGER NOT NULL
);

CREATE TABLE bibliographic_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL,
    title VARCHAR NOT NULL,
    author VARCHAR,
    isbn VARCHAR,
    publisher VARCHAR,
    published_year INTEGER,
    cover_url VARCHAR,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE owned_books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bibliographic_record_id UUID NOT NULL REFERENCES bibliographic_records(id),
    shelf_id UUID REFERENCES shelves(id) ON DELETE SET NULL,
    position INTEGER,
    reading_status VARCHAR NOT NULL DEFAULT 'to_read',
    added_by UUID,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE isbn_cache (
    isbn VARCHAR PRIMARY KEY,
    data JSONB NOT NULL,
    cached_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owned_book_id UUID NOT NULL REFERENCES owned_books(id) ON DELETE CASCADE,
    event_type VARCHAR NOT NULL,
    payload JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    user_id UUID
);
```

## Reset Local Databases

```bash
cd jinbocho-infrastructure-v1
docker compose down -v
docker compose up --build -d
```

!!! danger "Data loss"
    `docker compose down -v` deletes all local data permanently.
