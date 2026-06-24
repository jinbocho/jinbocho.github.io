# Panoramica dell'architettura

## Diagramma di sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                           BROWSER / MOBILE                       │
└──────────────────────────────┬─────────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  jinbocho-fe  (React 18 SPA — Render Static Site)               │
│                                                                  │
│  features/ (TanStack Query) → lib/api.ts (ky) → gateway :8000  │
└──────────────────────────────┬──────────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  api-gateway  (FastAPI — Render Web Service, PUBBLICO)            │
│                                                                  │
│  Validazione JWT · CORS · Reverse proxy                         │
│  route: /v1/auth /v1/users /v1/families /v1/catalog              │
│         /v1/location /v1/ai                                     │
└─────────┬─────────────────┬─────────────────┬──────────────────┘
          │ HTTP interno    │ HTTP interno    │ HTTP interno
          ▼                 ▼                 ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│  auth-service    │ │  catalog-service  │ │  ai-service       │
│  (Privato)       │ │  (Privato)        │ │  (Privato, Pro)   │
│                  │ │                   │ │                   │
│  famiglie        │ │  stanze           │ │  suggerimenti tag │
│  utenti          │ │  librerie         │ │  rilevamento dup. │
│  JWT             │ │  libri / prestiti │ │  raccomandazioni  │
│  refresh token   │ │  acquisizione ISBN│ │  generazione incipit│
└────────┬────────┘ └────────┬─────────┘ └────────┬─────────┘
         │                    │                     │
         ▼                    ▼                     ▼
   ┌──────────┐       ┌────────────┐       ┌──────────┐
   │ auth_db  │       │ catalog_db │       │  ai_db   │
   │ (Neon)   │       │ (Neon)     │       │ (Neon)   │
   └──────────┘       └────────────┘       └──────────┘
```

`ai-service` è presente solo nella **Pro edition** (vedi [07-production-deployment.md](07-production-deployment.md)); la Community edition funziona senza di esso e il gateway semplicemente non monta nessuna route `/v1/ai`.

**Roadmap:** `jinbocho-auth-v2` (login passwordless con magic-link + MFA TOTP opzionale) esiste solo come scaffold — le entità di dominio e gli stub dei casi d'uso sono completi, ma i livelli infrastructure, API e persistenza non sono ancora implementati, quindi non è distribuito da nessuna parte. Il contratto JWT è progettato per essere identico a v1, quindi nessun altro servizio dovrà essere modificato quando verrà rilasciato.

## Bounded Context

### Contesto Auth (`auth-service` + `auth_db`)

Gestisce tutto ciò che riguarda **chi può accedere al sistema**:
- Ciclo di vita dell'account famiglia (creazione, aggiornamento)
- Ciclo di vita degli utenti (creazione, invito, cambio ruolo, disattivazione)
- Autenticazione: hashing delle password, emissione JWT, rotazione dei refresh token
- Ruoli di autorizzazione: `admin | editor | viewer`

L'auth-service è l'unico emettitore di JWT. Tutti gli altri servizi validano i token usando il `JWT_SECRET_KEY` condiviso ma non ne emettono di nuovi.

### Contesto Catalog (`catalog-service` + `catalog_db`)

Gestisce tutto ciò che riguarda **quali libri esistono e dove si trovano**:
- Gerarchia fisica delle posizioni: stanze → librerie → sezioni → scaffali
- Record bibliografici (titolo, autore, ISBN, metadati)
- Copie fisiche dei libri (quale copia è su quale scaffale, stato di lettura, posizione)
- Acquisizione metadati ISBN tramite Open Library e Google Books
- Log di audit dei movimenti dei libri e dei cambi di stato
- Esportazione (CSV, JSON)

Questo servizio fonde intenzionalmente Posizione + Catalog + Acquisizione in un unico servizio per mantenere la creazione di un libro e l'assegnazione allo scaffale in un'unica transazione ACID.

### Contesto AI (`ai-service` + `ai_db`, solo Pro edition)

Gestisce funzionalità di intelligenza opzionali e non critiche, sovrapposte al catalog:
- Suggerimenti di tag per un libro
- Indizi di rilevamento di record duplicati
- Raccomandazioni per famiglia
- Presentazioni "incipit" del libro generate dall'AI

Questo servizio non detiene mai i dati del catalog come fonte di verità — legge da catalog-service via HTTP e cachea/deriva i propri dati in `ai_db`. Può essere disabilitato completamente (Community edition) senza alcun impatto su auth o catalog.

### Contesto Gateway (`api-gateway`)

Nessuna logica di dominio, nessun database. Agisce come:
- Unico punto di ingresso per tutto il traffico client
- Validatore JWT (sicurezza al confine)
- Applicatore della policy CORS
- Reverse proxy verso i servizi interni

## Flusso dati: aggiunta di un libro tramite ISBN

```
1. L'utente punta la fotocamera al codice a barre → il frontend decodifica l'ISBN tramite @zxing/browser

2. Frontend → GET /v1/catalog/ingestion/isbn/9788845292613
   Il gateway valida il JWT, rimuove il prefisso /v1/catalog e fa il
   proxy a /v1/ingestion/isbn/{isbn} del catalog-service

3. Il catalog controlla la cache locale isbn_cache
   Cache miss → interroga Open Library → dati trovati → salva in cache

4. Il catalog restituisce i dati BibliographicRecord al frontend
   Il frontend pre-compila titolo, autore, editore, copertina

5. L'utente seleziona la posizione (stanza → libreria → sezione → scaffale → posizione)
   e clicca Salva

6. Frontend → POST /v1/catalog/books/
   Body: { bibliographic_record_id, shelf_id, position, reading_status }

7. Il catalog crea OwnedBook + aggiorna audit_log in una singola transazione
   Restituisce la risposta OwnedBook (senza titolo/autore — quelli sono sul record)

8. Il frontend collega OwnedBook a BibliographicRecord in memoria usando
   joinBooksToRecords() → mostra la scheda completa del libro all'utente
```

## Architettura del codice (per servizio)

Ogni microservizio segue la **Clean / Hexagonal Architecture**:

```
Livello di Presentazione
└── app/api/v1/endpoints/       Handler delle route FastAPI
    app/api/v1/schemas/         Modelli Pydantic richiesta/risposta

Livello Applicativo
└── app/application/use_cases/  Orchestrazione della logica di business
    app/application/services/   Servizi di dominio (token, email, ecc.)

Livello di Dominio
└── app/domain/entities/        Entità di dominio in puro Python
    app/domain/repositories/    Interfacce astratte dei repository
    app/domain/exceptions.py    Eccezioni di dominio

Livello Infrastrutturale
└── app/infrastructure/repositories/   Implementazioni SQLAlchemy
    app/infrastructure/external/        Client HTTP (Open Library, Google Books)
    app/infrastructure/database.py      Setup AsyncSession
```

**Regole da rispettare sempre**:

1. Il livello di dominio ha **zero conoscenza** di HTTP, SQLAlchemy o API esterne
2. I casi d'uso accettano e restituiscono entità di dominio, non schema HTTP
3. Tutta la logica di dominio va nei casi d'uso o nelle entità di dominio — mai negli endpoint
4. Nessuna logica nei file `__init__.py`
5. Ogni endpoint chiama esattamente un caso d'uso

## Modello di sicurezza

### Autenticazione

- JWT stateless; nessun session store necessario per le richieste normali
- Refresh token archiviati lato server in `auth_db` (abilita la revoca al logout)
- Durata del token di accesso: 30 minuti
- Durata del refresh token: 30 giorni (ruotato all'uso)

### Autorizzazione

- Il payload JWT codifica `family_id` e `role` — nessuna query DB aggiuntiva per richiesta
- Ogni query del catalog-service filtra per `family_id` dal token (isolamento della famiglia)
- I ruoli vengono applicati a livello del caso d'uso, non a livello dell'endpoint

### Endpoint pubblici vs protetti

| Endpoint | Auth |
|---------|-----|
| `POST /v1/auth/register` | Pubblico |
| `POST /v1/auth/login` | Pubblico |
| `POST /v1/auth/refresh` | Pubblico |
| `GET /health` | Pubblico |
| Tutto il resto | JWT Bearer richiesto |

### Isolamento di rete

- I Servizi Privati su Render non sono raggiungibili da internet — solo dagli altri servizi nella stessa regione Render
- Il gateway è l'unico servizio con URL pubblico
- I database (Neon) sono accessibili solo tramite stringhe di connessione autenticate — non esposti su una porta pubblica

## Scelte tecnologiche

| Decisione | Scelta | Motivazione |
|-----------|--------|------------|
| Framework | FastAPI | Async-first, OpenAPI/Swagger integrato, eccellente supporto ai type hint |
| ORM | SQLAlchemy (async) | Async-capable, schema dichiarativo, funziona con PostgreSQL e asyncpg |
| Database | PostgreSQL 16 | Transazioni ACID richieste per le operazioni del catalog (atomicità libro + posizione) |
| Auth | JWT + refresh token lato server | Accesso stateless, refresh revocabile, nessun session store necessario |
| Comunicazione tra servizi | HTTP (nessun message broker) | Minimizza il footprint del deploy; le chiamate sincrone sono sufficienti a questa scala |
| Un DB per servizio | ✅ | Previene l'accoppiamento stretto; abilita scaling indipendente e evoluzione degli schema |
| Clean Architecture | ✅ | Chiara separazione delle responsabilità; la logica di dominio è testabile senza database |
| Stato del frontend | TanStack Query | Stato server normalizzato in cache; elimina la maggior parte dei pattern useState e useEffect |

## Ambienti di deployment

| Ambiente | Infrastruttura | Quando usato |
|---------|--------------|-------------|
| **Locale** | Docker Compose | Sviluppo quotidiano — stack completo con un comando |
| **Produzione** | Render + Neon | Sistema live — utenti della famiglia |
| **Staging** | *(non configurato)* | Può essere aggiunto duplicando i servizi Render con variabili d'ambiente separate |