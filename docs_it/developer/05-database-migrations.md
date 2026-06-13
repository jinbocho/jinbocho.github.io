# Database e migrazioni

Jinbocho usa **PostgreSQL 16** con un database per servizio. Le migrazioni sono gestite da **Alembic** e vengono eseguite automaticamente all'avvio del servizio.

## Database

| Database | Servizio | Porta locale |
|----------|---------|-------------|
| `auth_db` | auth-service | `5432` |
| `catalog_db` | catalog-service | `5433` |
| `ai_db` | ai-service (opzionale) | `5434` |

In Docker Compose queste porte sono legate solo a `127.0.0.1` — non sono accessibili dall'esterno della macchina.

## Migrazioni automatiche all'avvio

Sia auth-service che catalog-service eseguono `alembic upgrade head` automaticamente prima di avviare uvicorn (configurato nel CMD del loro `Dockerfile`). Non è necessario eseguire le migrazioni manualmente in sviluppo locale o in produzione.

Cioè: quando esegui `docker compose up`, i database sono sempre aggiornati all'ultimo schema.

## Accesso al database locale

### Connettiti con psql

```bash
# auth_db
psql -U postgres -h 127.0.0.1 -p 5432 -d auth_db

# catalog_db
psql -U postgres -h 127.0.0.1 -p 5433 -d catalog_db

# ai_db (se in esecuzione)
psql -U postgres -h 127.0.0.1 -p 5434 -d ai_db
```

Password: `postgres` (solo sviluppo locale).

### Comandi psql utili

```sql
-- Elenca tutte le tabelle
\dt

-- Mostra lo schema di una tabella
\d users
\d owned_books

-- Query rapida
SELECT id, email, role FROM users LIMIT 10;

-- Esci
\q
```

## Flusso di lavoro Alembic

### Controlla lo stato corrente della migrazione

```bash
cd jinbocho-auth-v1   # o jinbocho-catalog-v1
source .venv/bin/activate
alembic current       # mostra la revisione corrente
alembic history       # mostra la cronologia completa delle migrazioni
```

### Crea una nuova migrazione

Dopo aver modificato un modello SQLAlchemy:

```bash
alembic revision --autogenerate -m "add language column to users"
# Rivedi il file generato in migrations/versions/
# Modifica se autogenerate ha perso qualcosa
alembic upgrade head   # testa in locale prima di committare
```

Rivedi sempre le migrazioni autogenerate prima di committarle. Alembic può mancarne:
- Tipi di indice personalizzati
- Indici parziali
- Valori predefiniti per le righe esistenti

### Applica le migrazioni manualmente

```bash
alembic upgrade head        # applica tutte le migrazioni in sospeso
alembic upgrade +1          # applica una migrazione in avanti
alembic downgrade -1        # annulla una migrazione
alembic downgrade <revision> # annulla fino a una revisione specifica
```

### Migrazioni in produzione (Neon)

Le migrazioni vengono eseguite automaticamente all'avvio del servizio. Se devi eseguirle manualmente contro il database Neon:

```bash
# Imposta DATABASE_URL alla stringa di connessione Neon
export DATABASE_URL="postgresql+asyncpg://user:pass@ep-xxx.neon.tech/auth_db?ssl=require"

cd jinbocho-auth-v1
source .venv/bin/activate
alembic upgrade head
```

!!! warning "Testa sempre le migrazioni in locale prima"
    Testa sempre le migrazioni su un database locale prima di applicarle in produzione.
    Una migrazione fallita su Neon può lasciare lo schema in uno stato parziale.

## Schema del servizio Auth

```sql
-- families
CREATE TABLE families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    email VARCHAR UNIQUE NOT NULL,
    hashed_password VARCHAR NOT NULL,
    full_name VARCHAR NOT NULL,
    role VARCHAR NOT NULL DEFAULT 'viewer',   -- admin | editor | viewer
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- refresh_tokens (revoca lato server)
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
```

## Schema del servizio Catalog

```sql
-- rooms
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- bookcases
CREATE TABLE bookcases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL
);

-- sections (colonne verticali)
CREATE TABLE sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bookcase_id UUID NOT NULL REFERENCES bookcases(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    position INTEGER NOT NULL
);

-- shelves (ripiani orizzontali)
CREATE TABLE shelves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    position INTEGER NOT NULL
);

-- bibliographic_records (uno per ISBN / edizione)
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

-- owned_books (copie fisiche)
CREATE TABLE owned_books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bibliographic_record_id UUID NOT NULL REFERENCES bibliographic_records(id),
    shelf_id UUID REFERENCES shelves(id) ON DELETE SET NULL,
    position INTEGER,
    reading_status VARCHAR NOT NULL DEFAULT 'to_read',  -- to_read | reading | read
    added_by UUID,     -- user_id da auth-service (non FK, cross-service)
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- isbn_cache (cache metadati con TTL)
CREATE TABLE isbn_cache (
    isbn VARCHAR PRIMARY KEY,
    data JSONB NOT NULL,
    cached_at TIMESTAMP NOT NULL DEFAULT now()
);

-- audit_log (storico movimenti + cambi stato)
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owned_book_id UUID NOT NULL REFERENCES owned_books(id) ON DELETE CASCADE,
    event_type VARCHAR NOT NULL,   -- moved | status_changed | created
    payload JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    user_id UUID
);
```

## Reset dei database locali

Per cancellare tutti i dati locali e ripartire da zero:

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
docker compose down -v   # rimuove container E volumi
docker compose up --build -d   # ricrea tutto da zero
# Le migrazioni vengono eseguite automaticamente all'avvio
```

!!! danger "Perdita di dati"
    `docker compose down -v` elimina tutti i dati locali in modo permanente.
    Usalo solo in sviluppo, mai in produzione.