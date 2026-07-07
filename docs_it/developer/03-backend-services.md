# Servizi backend

Il backend di Jinbocho è composto da tre microservizi FastAPI. Due sono **Servizi Privati** (solo uso interno); uno è l'**API Gateway** pubblico.

## Architettura in sintesi

```
                    ┌─────────────────────────────────┐
Client (Browser)    │   API Gateway  :8000  (PUBBLICO) │
──────────────────► │  Validazione JWT · CORS · Proxy  │
                    └───────────┼─────────────────┘
                                │ HTTP interno
                  ┌─────────────┴─────────────┐
                  │                           │
       ┌──────────────┐             ┌──────────────────┐
       │ auth-service │             │ catalog-service   │
       │    :8001     │             │    :8002          │
       │  (Privato)   │             │  (Privato)        │
       └──────┼───────┘             └──────┼────────────┘
              │                            │
       ┌──────┴──────┐             ┌───────┴──────┐
       │  auth_db     │             │  catalog_db  │
       │ (PostgreSQL) │             │ (PostgreSQL) │
       └──────────────┘             └──────────────┘
```

Ogni servizio ha il proprio database. I servizi non condividono mai un database. `catalog-service` valida i JWT localmente (**non** richiama `auth-service`).

---

## auth-service (porta 8001)

**Repository**: `jinbocho-auth-v1`

### Responsabilità

- Registrare le famiglie e il primo utente admin
- Autenticare gli utenti (email + password)
- Emettere e ruotare i token JWT di accesso e refresh
- Gestire i metadati della famiglia, incluso il flusso irreversibile di cancellazione completa dell'account
- Invitare, gestire ed esportare/importare gli account utente; gestire l'assegnazione dei ruoli (Admin, Editor, Viewer)
- Reset della password via email (SMTP), con fallback su console in sviluppo

### Endpoint principali

| Metodo | Percorso | Auth | Descrizione |
|--------|---------|------|------------|
| `POST` | `/v1/auth/register` | — | Crea famiglia + primo admin |
| `POST` | `/v1/auth/login` | — | Ottieni token di accesso + refresh |
| `POST` | `/v1/auth/refresh` | — | Ruota il refresh token |
| `POST` | `/v1/auth/logout` | Bearer | Revoca il refresh token |
| `POST` | `/v1/auth/forgot-password` | — | Invia un'email di reset password (o la logga su console in sviluppo) |
| `POST` | `/v1/auth/reset-password` | — | Consuma il token di reset e imposta una nuova password |
| `GET` | `/v1/families/{family_id}` | Bearer | Ottieni informazioni sulla famiglia (qualsiasi membro) |
| `PATCH` | `/v1/families/{family_id}` | Bearer (Admin) | Aggiorna le informazioni della famiglia |
| `POST` | `/v1/families/{family_id}/confirm-deletion` | Bearer (Admin) | Verifica password + nome famiglia prima della cancellazione irreversibile sotto |
| `DELETE` | `/v1/families/{family_id}` | Bearer (Admin) | Cancella permanentemente la famiglia e tutti gli utenti, in cascata su refresh + reset token |
| `GET` | `/v1/users/me` | Bearer | Ottieni l'utente autenticato corrente |
| `PATCH` | `/v1/users/me` | Bearer | Aggiorna il proprio nome / obiettivo di lettura |
| `GET` | `/v1/users/` | Bearer | Elenca i membri della famiglia |
| `POST` | `/v1/users/` | Bearer (Admin) | Invita un nuovo utente (invia un'email di invito; password non ancora impostata) |
| `PATCH` | `/v1/users/{id}` | Bearer (Admin) | Aggiorna utente / cambia ruolo |
| `DELETE` | `/v1/users/{id}` | Bearer (Admin) | Rimuovi un utente |
| `GET` | `/v1/users/export` | Bearer (Admin) | Esporta l'identità della famiglia + l'elenco dei membri per backup |
| `POST` | `/v1/users/import` | Bearer (Admin) | Ripristina gli utenti da un export di backup nella famiglia corrente |
| `GET` | `/health` | — | Health check |

!!! info "La cancellazione dell'account coinvolge due servizi"
    La cancellazione completa dell'account coinvolge sia `auth-service` che `catalog-service`. Il frontend chiama
    `POST /v1/families/{id}/confirm-deletion` (verifica le credenziali), poi
    `DELETE /v1/catalog/account` (elimina i dati di location/catalogo, vedi sotto), poi
    `DELETE /v1/families/{id}` (elimina la famiglia e i suoi utenti) — in quest'ordine.

### Variabili d'ambiente

| Variabile | Obbligatoria | Default | Descrizione |
|-----------|-------------|---------|------------|
| `DATABASE_URL` | ✅ | — | `postgresql+asyncpg://...` |
| `JWT_SECRET_KEY` | ✅ | — | Segreto condiviso — **deve corrispondere** a catalog + gateway |
| `JWT_ALGORITHM` | — | `HS256` | Algoritmo di firma |
| `JWT_ISSUER` | — | `jinbocho-auth` | Claim issuer del token (`iss`) |
| `JWT_AUDIENCE` | — | `jinbocho` | Claim audience del token (`aud`) |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | — | `30` | Durata del token di accesso |
| `REFRESH_TOKEN_EXPIRE_DAYS` | — | `30` | Durata del refresh token |
| `PASSWORD_RESET_EXPIRE_MINUTES` | — | `15` | Durata del token di reset password |
| `FRONTEND_BASE_URL` | — | `http://localhost:5173` | Usato per costruire il link di reset password inviato via email |
| `SMTP_HOST` | — | *(vuoto)* | Server SMTP per l'invio email. Lascia vuoto per loggare le email su console invece di inviarle (sviluppo) |
| `SMTP_PORT` | — | `587` | Porta SMTP |
| `SMTP_USER` | — | *(vuoto)* | Username di autenticazione SMTP |
| `SMTP_PASSWORD` | — | *(vuoto)* | Password di autenticazione SMTP |
| `EMAIL_FROM` | — | `noreply@jinbocho.local` | Indirizzo "From" sulle email in uscita |
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

Sia catalog-service che il gateway validano questo token usando il `JWT_SECRET_KEY` condiviso — nessuno dei due richiama auth-service per farlo.

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
- `password_reset_tokens` — Token di reset password / invito emessi, con scadenza

---

## catalog-service (porta 8002)

**Repository**: `jinbocho-catalog-v1`

### Responsabilità

- Gestire la gerarchia fisica delle posizioni: stanze → librerie → sezioni → scaffali
- Gestire i record bibliografici (titolo, autore, ISBN, editore, copertina, presentazione "incipit" assistita da AI)
- Gestire i libri posseduti (copie che collegano un record a uno scaffale + stato di lettura), tracciamento di lettori multipli (`reads`) e prestiti tra membri della famiglia (`loans`)
- Ricerca ISBN online tramite Open Library (primario) e Google Books (fallback), con cache locale
- Ricerca libri, log storico/audit, esportazione CSV/JSON, export/import completo della libreria per i backup
- Mappa visiva della libreria
- Cancellazione completa dei dati account in stile GDPR (la sua metà del flusso cross-service descritto sotto auth-service)

### Endpoint principali

| Metodo | Percorso | Auth | Descrizione |
|--------|---------|------|------------|
| `GET/POST` | `/v1/rooms/` | Bearer | Elenca / crea stanze |
| `GET/PATCH/DELETE` | `/v1/rooms/{id}` | Bearer | CRUD stanza |
| `GET/POST` | `/v1/bookcases/` | Bearer | Elenca (filtra per `room_id`) / crea librerie |
| `GET/PATCH/DELETE` | `/v1/bookcases/{id}` | Bearer | CRUD libreria |
| `GET/POST` | `/v1/sections/` | Bearer | Elenca (filtra per `bookcase_id`) / crea sezioni |
| `GET/PATCH/DELETE` | `/v1/sections/{id}` | Bearer | CRUD sezione |
| `GET/POST` | `/v1/shelves/` | Bearer | Elenca (filtra per `section_id`) / crea scaffali |
| `GET/PATCH/DELETE` | `/v1/shelves/{id}` | Bearer | CRUD scaffale |
| `GET/POST` | `/v1/bibliographic-records/` | Bearer | Cerca record (`?q=`) / crea record |
| `GET/PATCH/DELETE` | `/v1/bibliographic-records/{id}` | Bearer | CRUD record |
| `GET` | `/v1/bibliographic-records/genres` | Bearer | Generi normalizzati distinti nella biblioteca di famiglia, con conteggi |
| `GET` | `/v1/bibliographic-records/{id}/incipit` | Bearer | Ottieni o genera pigramente la presentazione del libro |
| `PUT` | `/v1/bibliographic-records/{id}/incipit` | Bearer | Imposta la presentazione (testo manuale o generato da AI) |
| `GET` | `/v1/ingestion/isbn/{isbn}` | Bearer | Ricerca metadati ISBN (cache → Open Library → Google Books) |
| `GET` | `/v1/ingestion/search` | Bearer | Cerca libri online per titolo/autore |
| `POST` | `/v1/ingestion/bulk-lookup` | Bearer | Ricerca ISBN massiva |
| `GET/POST` | `/v1/books/` | Bearer | Libri posseduti (lista con `limit`/`offset`) |
| `GET` | `/v1/books/reads` | Bearer | Elenca tutte le letture della famiglia |
| `GET` | `/v1/books/loans/active` | Bearer | Elenca tutti i prestiti attivi della famiglia |
| `GET/PATCH/DELETE` | `/v1/books/{id}` | Bearer | CRUD libro posseduto |
| `POST` | `/v1/books/{id}/position` | Bearer | Aggiorna posizione sullo scaffale (query param) |
| `POST` | `/v1/books/{id}/reading-status` | Bearer | Aggiorna stato di lettura (query param) |
| `GET` | `/v1/books/{id}/history` | Bearer | Ottieni la storia del libro |
| `GET/POST` | `/v1/books/{id}/reads` | Bearer | Elenca i lettori di un libro / segna un membro come avente letto il libro |
| `DELETE` | `/v1/books/{id}/reads/{user_id}` | Bearer | Rimuovi la marcatura di lettura di un membro |
| `GET/POST` | `/v1/books/{id}/loans` | Bearer | Elenca lo storico prestiti di un libro / prestalo a un membro della famiglia |
| `POST` | `/v1/books/{id}/loans/return` | Bearer | Segna il prestito attivo come restituito |
| `GET` | `/v1/map/bookcase/{id}` | Bearer | Dati mappa visiva della libreria |
| `GET` | `/v1/export/books.csv` | Bearer (Admin) | Esporta i libri posseduti come CSV |
| `GET` | `/v1/export/books.json` | Bearer (Admin) | Esporta i libri posseduti come JSON |
| `GET` | `/v1/export/full` | Bearer (Admin) | Backup completo della libreria: location, record, libri, prestiti, letture, storico |
| `POST` | `/v1/import/full` | Bearer (Admin) | Ripristina un backup completo della libreria prodotto da `/v1/export/full` |
| `POST` | `/v1/members/removed` | Bearer (Admin) | Salva uno snapshot di nome/email/ruolo di un membro della famiglia appena prima che `auth-service` lo elimini definitivamente |
| `DELETE` | `/v1/account/` | Bearer (Admin) | Metà lato catalog-service della cancellazione completa dell'account (vedi sezione auth-service) |
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
| `JWT_SECRET_KEY` | ✅ | — | **Deve corrispondere** a auth + gateway |
| `JWT_ALGORITHM` | — | `HS256` | Algoritmo di firma |
| `JWT_ISSUER` | — | `jinbocho-auth` | Deve corrispondere all'issuer dei token di auth-service |
| `JWT_AUDIENCE` | — | `jinbocho` | Deve corrispondere all'audience dei token di auth-service |
| `GOOGLE_BOOKS_API_KEY` | — | *(vuoto)* | Ricerca ISBN di fallback; senza chiave la quota è condivisa/limitata |
| `OPEN_LIBRARY_URL` | — | `https://openlibrary.org` | URL base Open Library |
| `GOOGLE_BOOKS_URL` | — | `https://www.googleapis.com/books/v1` | URL base Google Books |
| `ISBN_CACHE_TTL_DAYS` | — | `30` | Giorni di cache dei metadati ISBN in locale |
| `DEBUG` | — | `false` | Logging delle query SQL |

!!! note "Nessuna chiamata di ritorno verso auth-service"
    Versioni precedenti di questo servizio chiamavano `auth-service` per validare i token. Ora
    valida i JWT **localmente** usando `JWT_SECRET_KEY` / `JWT_ISSUER` / `JWT_AUDIENCE` condivisi —
    non esiste un'impostazione `AUTH_SERVICE_URL`, anche se ne è ancora presente una (inutilizzata)
    nel `.env.example` del repository.

### Flusso di ricerca ISBN

```
Richiesta /v1/ingestion/isbn/9788845292613
     │
     ├─► Cache locale nel DB? → risponde immediatamente
     │
     ├─► Open Library → recupera metadati (gratuito, nessuna chiave)
     │       Trovato? → salva in cache → risponde
     │
     └─► Google Books → recupera metadati (richiede chiave API)
             Trovato? → salva in cache → risponde
             Non trovato? → 404 "ISBN not found"
```

### Avvio in locale (senza Docker)

```bash
cd jinbocho-catalog-v1
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # imposta DATABASE_URL e JWT_SECRET_KEY
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
- `bibliographic_records` — Metadati del libro (titolo, autore, ISBN, editore, cover_url, incipit)
- `owned_books` — Copie che collegano un record a uno scaffale + stato di lettura + posizione
- `book_reads` — Quali membri della famiglia hanno letto quale libro posseduto
- `book_loans` — Storico prestiti (chi ha preso in prestito, date di prestito/restituzione) per libro posseduto
- `isbn_cache` — Risultati di ricerca ISBN in cache (con TTL)
- `audit_log` — Storico dei movimenti dei libri e dei cambi di stato
- `removed_members` — Snapshot di nome/email/ruolo degli utenti eliminati, per continuità di export/import

---

## api-gateway (porta 8000)

**Repository**: `jinbocho-api-gateway-v1`

### Responsabilità

- Unico punto di ingresso pubblico per tutte le richieste del client
- Validazione JWT al confine (verifica il token prima di fare il proxy)
- Applicazione della policy CORS
- Routing delle richieste ai servizi interni, controllato da `JINBOCHO_FEATURES`

Tutti gli endpoint sono montati sotto `/v1` e proxati ai servizi interni. A differenza di uno specchio 1:1, il gateway raggruppa gli endpoint di catalog-service in due prefissi pubblici — `/v1/catalog/*` per libri/record/ingestion/export/import/account/members, e `/v1/location/*` per stanze/librerie/sezioni/scaffali — anche se entrambi sono serviti dallo stesso processo catalog-service.

### Tabella di routing

| Percorso Gateway | Inoltrato a | Note |
|-----------------|------------|------|
| `/v1/auth/*` | `auth-service:8001/v1/auth/*` | |
| `/v1/families/*` | `auth-service:8001/v1/families/*` | |
| `/v1/users/*` | `auth-service:8001/v1/users/*` | |
| `/v1/catalog/*` | `catalog-service:8002/v1/*` | Record, libri, ingestion, export, import, members, account |
| `/v1/location/*` | `catalog-service:8002/v1/*` | Stanze, librerie, sezioni, scaffali |
| `/health` | locale | |

Quindi, ad esempio, le chiamate `bibliographic-records` del frontend vanno a `/v1/catalog/bibliographic-records`, e le chiamate `rooms` vanno a `/v1/location/rooms` — non direttamente a `/v1/records` o `/v1/rooms`.

### Variabili d'ambiente

| Variabile | Obbligatoria | Default | Descrizione |
|-----------|-------------|---------|------------|
| `JWT_SECRET_KEY` | ✅ | — | **Deve corrispondere** a auth + catalog |
| `JWT_ALGORITHM` | — | `HS256` | Algoritmo di firma |
| `AUTH_SERVICE_URL` | — | `http://auth-service:8001` | URL interno di auth-service |
| `CATALOG_SERVICE_URL` | — | `http://catalog-service:8002` | URL interno di catalog-service |
| `CORS_ORIGINS` | — | `["*"]` | Array JSON delle origini consentite, es. `["https://jinbocho-fe.onrender.com"]` |
| `JINBOCHO_FEATURES` | — | `catalog,auth` | Moduli abilitati separati da virgola |
| `DEBUG` | — | `false` | Modalità debug FastAPI + logging dettagliato |

!!! danger "CORS in produzione"
    Non usare mai `["*"]` in produzione. Imposta `CORS_ORIGINS` all'URL esatto del frontend.
    In sviluppo locale l'ambiente docker-compose usa `["*"]` — questo è accettabile.

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
