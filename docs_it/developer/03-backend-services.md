# Servizi backend

Il backend di Jinbocho è composto da tre microservizi FastAPI. Due sono **Servizi Privati** (solo uso interno); uno è l'**API Gateway** pubblico.

## Architettura in sintesi

```
                    ┌─────────────────────────────────┐
Client (Browser)    │   API Gateway  :8000  (PUBBLICO)   │
──────────────────► │  Validazione JWT · CORS · Proxy   │
                    └───────────┬─────────────────┘
                                │ HTTP interno
                    ┌───────────┴───────────┐
                    ↓                       ↓
         ┌──────────────┐        ┌──────────────────┐
         │ auth-service │        │ catalog-service   │
         │    :8001     │        │    :8002          │
         │  (Privato)   │        │  (Privato)        │
         └──────┬───────┘        └──────┬────────────┘
                │                       │
         ┌──────┴───────┐       ┌───────┴──────┐
         │  auth_db     │       │  catalog_db  │
         │ (PostgreSQL) │       │ (PostgreSQL) │
         └──────────────┘       └──────────────┘
```

Ogni servizio ha il proprio database. I servizi non condividono mai un database e comunicano solo via HTTP attraverso le regole di routing del gateway.

---

## auth-service (porta 8001)

**Repository**: `jinbocho-auth-v1`

### Responsabilità

- Registrare le famiglie e il primo utente admin
- Autenticare gli utenti (email + password)
- Emettere e ruotare i token JWT di accesso e refresh
- Gestire i metadati della famiglia e gli account utente
- Gestire l'assegnazione dei ruoli (Admin, Editor, Viewer)

### Endpoint principali

| Metodo | Percorso | Auth | Descrizione |
|--------|---------|------|------------|
| `POST` | `/v1/auth/register` | — | Crea famiglia + primo admin |
| `POST` | `/v1/auth/login` | — | Ottieni token di accesso + refresh |
| `POST` | `/v1/auth/refresh` | — | Ruota il refresh token |
| `POST` | `/v1/auth/logout` | Bearer | Revoca il refresh token |
| `GET` | `/v1/families/me` | Bearer | Ottieni la famiglia corrente |
| `PATCH` | `/v1/families/me` | Bearer (Admin) | Aggiorna la famiglia |
| `GET` | `/v1/users/` | Bearer | Elenca i membri della famiglia |
| `POST` | `/v1/users/` | Bearer (Admin) | Crea un utente |
| `PATCH` | `/v1/users/{id}` | Bearer (Admin) | Aggiorna utente / cambia ruolo |
| `DELETE` | `/v1/users/{id}` | Bearer (Admin) | Rimuovi un utente |
| `GET` | `/health` | — | Health check |

### Variabili d'ambiente

| Variabile | Obbligatoria | Default | Descrizione |
|-----------|-------------|---------|------------|
| `DATABASE_URL` | ✅ | — | `postgresql+asyncpg://...` |
| `JWT_SECRET_KEY` | ✅ | — | Segreto condiviso — **deve corrispondere** a catalog + gateway |
| `JWT_ALGORITHM` | — | `HS256` | Algoritmo di firma |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | — | `30` | Durata del token di accesso |
| `REFRESH_TOKEN_EXPIRE_DAYS` | — | `30` | Durata del refresh token |
| `DEBUG` | — | `false` | Abilita il logging delle query SQL |

### Payload del token JWT

I token emessi dall'auth-service contengono:

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

Sia catalog-service che il gateway validano questo token usando il `JWT_SECRET_KEY` condiviso.

### Avvio in locale (senza Docker)

```bash
cd jinbocho-auth-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # modifica DATABASE_URL per Postgres locale
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

Swagger UI: [http://localhost:8001/docs](http://localhost:8001/docs)

### Esecuzione dei test

```bash
cd jinbocho-auth-v1
source .venv/bin/activate
pytest tests/ -v

# Solo unit test (senza DB):
pytest tests/unit/ -v

# Test di integrazione (richiede Postgres in esecuzione):
pytest tests/integration/ -v
```

### Schema del database

Tabelle gestite tramite migrazioni Alembic (applicate automaticamente all'avvio):

- `families` — Account famiglia (nome, id)
- `users` — Account utente (email, hashed_password, ruolo, family_id)
- `refresh_tokens` — Refresh token emessi con supporto alla revoca

---

## catalog-service (porta 8002)

**Repository**: `jinbocho-catalog-v1`

### Responsabilità

- Gestire la gerarchia fisica delle posizioni: stanze → librerie → sezioni → scaffali
- Gestire i record bibliografici (titolo, autore, ISBN, editore, copertina)
- Gestire i libri posseduti (copie che collegano un record a uno scaffale + stato di lettura)
- Ricerca ISBN tramite Open Library (primario) e Google Books (fallback), con cache locale
- Ricerca libri, log storico/audit, esportazione (CSV/JSON)
- Mappa visiva della libreria

### Endpoint principali

| Metodo | Percorso | Auth | Descrizione |
|--------|---------|------|------------|
| `GET/POST` | `/v1/rooms/` | Bearer | Elenca / crea stanze |
| `GET/PATCH/DELETE` | `/v1/rooms/{id}` | Bearer | CRUD stanza |
| `GET/POST` | `/v1/bookcases/` | Bearer | Elenca (filtra per stanza) / crea librerie |
| `GET/PATCH/DELETE` | `/v1/bookcases/{id}` | Bearer | CRUD libreria |
| `GET/POST` | `/v1/sections/` | Bearer | Sezioni per libreria |
| `GET/POST` | `/v1/shelves/` | Bearer | Scaffali per sezione |
| `GET/POST` | `/v1/bibliographic-records/` | Bearer | Record bibliografici (cerca con `?q=`, filtra con `?genre=<codice>`) |
| `GET/PATCH/DELETE` | `/v1/bibliographic-records/{id}` | Bearer | CRUD record |
| `GET` | `/v1/bibliographic-records/genres` | Bearer | Generi normalizzati distinti nella biblioteca di famiglia (con conteggi) |
| `GET` | `/v1/bibliographic-records/{id}/incipit` | Bearer | Ottieni o genera la presentazione del libro |
| `PUT` | `/v1/bibliographic-records/{id}/incipit` | Bearer (Admin/Editor) | Imposta la presentazione (testo manuale o generato da AI) |
| `POST` | `/v1/records/isbn-lookup` | Bearer | Ricerca metadati ISBN |
| `GET/POST` | `/v1/books/` | Bearer | Libri posseduti (lista con `limit`/`offset`) |
| `GET/PATCH/DELETE` | `/v1/books/{id}` | Bearer | CRUD libro posseduto |
| `POST` | `/v1/books/{id}/position` | Bearer | Aggiorna posizione sullo scaffale (query param) |
| `POST` | `/v1/books/{id}/reading-status` | Bearer | Aggiorna stato di lettura (query param) |
| `GET` | `/v1/map/bookcases/{id}` | Bearer | Dati mappa visiva della libreria |
| `GET` | `/v1/export/` | Bearer (Admin) | Esporta biblioteca in CSV o JSON |
| `GET` | `/health` | — | Health check |

!!! warning "Query param, non corpo JSON"
    `POST /v1/books/{id}/position` e `POST /v1/books/{id}/reading-status` leggono i
    parametri dalla **query string**, non da un corpo JSON. Costruisci gli URL di conseguenza:
    ```
    POST /v1/books/abc/reading-status?reading_status=read
    POST /v1/books/abc/position?section_id=x&shelf_id=y&position=3
    ```

### Variabili d'ambiente

| Variabile | Obbligatoria | Default | Descrizione |
|-----------|-------------|---------|------------|
| `DATABASE_URL` | ✅ | — | `postgresql+asyncpg://...` |
| `AUTH_SERVICE_URL` | ✅ | — | URL interno di auth-service |
| `JWT_SECRET_KEY` | ✅ | — | **Deve corrispondere** a auth + gateway |
| `JWT_ALGORITHM` | — | `HS256` | Algoritmo di firma |
| `GOOGLE_BOOKS_API_KEY` | — | — | Ricerca ISBN di fallback (chiave gratuita, 100 req/giorno) |
| `OPEN_LIBRARY_URL` | — | `https://openlibrary.org` | URL base Open Library |
| `GOOGLE_BOOKS_URL` | — | `https://www.googleapis.com` | URL base Google Books |
| `ISBN_CACHE_TTL_DAYS` | — | `30` | Giorni di cache dei metadati ISBN in locale |
| `DEBUG` | — | `false` | Logging delle query SQL |

### Flusso di ricerca ISBN

```
Richiesta /v1/records/isbn-lookup?isbn=9788845292613
     │
     ├─► Cache locale nel DB? → risponde immediatamente
     │
     ├─► Open Library → recupera metadati (gratuito, nessuna chiave)
     │       Trovato? → salva in cache → risponde
     │
     └─► Google Books → recupera metadati (richiede chiave API)
             Trovato? → salva in cache → risponde
             Non trovato? → 404 "ISBN non trovato"
```

### Avvio in locale (senza Docker)

```bash
cd jinbocho-catalog-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # imposta DATABASE_URL e AUTH_SERVICE_URL
uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
```

Swagger UI: [http://localhost:8002/docs](http://localhost:8002/docs)

### Esecuzione dei test

```bash
cd jinbocho-catalog-v1
source .venv/bin/activate
pytest tests/ -v
```

### Schema del database

Tabelle gestite tramite migrazioni Alembic:

- `rooms` — Stanze fisiche (per famiglia)
- `bookcases` — Librerie in una stanza
- `sections` — Colonne verticali in una libreria
- `shelves` — Ripiani orizzontali in una sezione
- `bibliographic_records` — Metadati del libro (titolo, autore, ISBN, editore, cover_url)
- `owned_books` — Copie fisiche che collegano un record a uno scaffale + stato di lettura + posizione
- `isbn_cache` — Risultati di ricerca ISBN in cache (con TTL)
- `audit_log` — Storico dei movimenti dei libri e dei cambi di stato

---

## api-gateway (porta 8000)

**Repository**: `jinbocho-api-gateway-v1`

### Responsabilità

- Unico punto di ingresso pubblico per tutte le richieste del client
- Validazione JWT al confine (verifica il token prima di fare il proxy)
- Applicazione della policy CORS
- Routing delle richieste ai servizi interni
- Aggregazione delle risposte (pattern BFF)

Tutti gli endpoint sono montati sotto `/v1` e replicati dai servizi interni.

### Tabella di routing

| Percorso Gateway | Inoltrato a |
|-----------------|------------|
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
| `/health` | locale |

### Variabili d'ambiente

| Variabile | Obbligatoria | Default | Descrizione |
|-----------|-------------|---------|------------|
| `JWT_SECRET_KEY` | ✅ | — | **Deve corrispondere** a auth + catalog |
| `JWT_ALGORITHM` | — | `HS256` | Algoritmo di firma |
| `AUTH_SERVICE_URL` | ✅ | — | URL interno di auth-service |
| `CATALOG_SERVICE_URL` | ✅ | — | URL interno di catalog-service |
| `CORS_ORIGINS` | ✅ | — | Array JSON delle origini consentite, es. `["https://jinbocho-fe.onrender.com"]` |
| `DEBUG` | — | `false` | Modalità debug FastAPI + logging dettagliato |

!!! danger "CORS in produzione"
    Non usare mai `["*"]` in produzione. Imposta `CORS_ORIGINS` all'URL esatto del frontend.
    In sviluppo locale il docker-compose usa `["*"]` — accettabile.

### Avvio in locale (senza Docker)

```bash
cd jinbocho-api-gateway-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Swagger UI: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## Qualità del codice — tutti i servizi

Esegui prima di ogni commit:

```bash
# Type checking (strict)
python -m mypy app --strict

# Linting + auto-fix
ruff check app tests
ruff check --fix app tests

# Test
pytest tests/ -v
```