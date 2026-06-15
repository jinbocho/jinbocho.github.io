# Deploy in produzione

Jinbocho viene eseguito su **Render** (servizi applicativi + frontend) e **Neon** (database PostgreSQL). Questa combinazione offre uno stack completamente operativo a costo zero con i livelli gratuiti.

## Architettura su Render

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│  jinbocho-fe  (Render Static Site)      │  https://jinbocho-fe.onrender.com
└──────────────────────┬──────────────────┘
                       │ HTTPS
                       ▼
┌─────────────────────────────────────────┐
│  jinbocho-api-gateway  (Web Service)    │  https://jinbocho-api-gateway.onrender.com
└───────────┬──────────────────────────────┘
             │ Rete interna Render
    ┌────────┴────────┐
    ▼                 ▼
┌────────┐       ┌────────┐
│ auth   │       │catalog │   Servizi Privati (non raggiungibili da internet)
│:8001   │       │:8002   │
└───┬───┘       └───┬────┘
    │               │
    ▼               ▼
┌─────────┐   ┌──────────┐
│ auth_db │   │catalog_db│   Neon PostgreSQL (esterno — non su Render)
└─────────┘   └──────────┘
```

**Solo due componenti sono pubblici**: l'API gateway e il frontend. I due servizi backend sono Servizi Privati — raggiungibili solo dalla rete interna di Render.

## Step 0 — Genera i segreti

```bash
# JWT_SECRET_KEY — deve essere identica su auth, catalog e gateway
openssl rand -hex 32
```

Salva questo valore. Lo inserirai più volte. Chiamalo `<JWT_SECRET>` nei passi seguenti.

## Step 1 — Crea i database Neon

!!! warning "Non usare il PostgreSQL integrato di Render"
    Il PostgreSQL gratuito di Render viene eliminato dopo circa 30 giorni. Usa Neon invece — il suo livello gratuito è persistente e non scade.

1. Registrati su [neon.tech](https://neon.tech) → **Crea progetto**
   - Nome: `jinbocho`
   - Versione PostgreSQL: `16`
   - Regione: più vicina alla tua regione Render (es. EU-Central per Francoforte)
2. Dalla console Neon → **Database → Nuovo Database**, crea:
   - `auth_db`
   - `catalog_db`
3. Per ogni database, vai su **Dettagli di connessione** → copia la stringa di connessione

### Adattare la stringa di connessione

Neon fornisce una stringa di connessione come:
```
postgresql://user:password@ep-xxxx.eu-central-1.aws.neon.tech/auth_db?sslmode=require
```

**Devi trasformarla** prima di usarla su Render:

| Modifica | Motivo |
|---------|-------|
| `postgresql://` → `postgresql+asyncpg://` | driver asyncpg |
| `?sslmode=require` → `?ssl=require` | asyncpg non capisce `sslmode` |

Risultato finale:
```
postgresql+asyncpg://user:password@ep-xxxx.eu-central-1.aws.neon.tech/auth_db?ssl=require
```

Fai questa trasformazione per ogni URL del database. Tieni privati entrambi gli URL.

## Step 2 — Distribuisci i servizi backend

Distribuisci in questo ordine: **auth → catalog → gateway**. Il gateway ha bisogno degli URL interni degli altri servizi.

### auth-service

1. Dashboard Render → **New + → Private Service**
2. Connetti il repository: `jinbocho-auth-v1`
3. Runtime: **Docker**
4. Regione: stessa dei database Neon
5. Tipo di istanza: **Free** (o Starter per evitare cold start)
6. Docker Command: **lascia vuoto** (già nel Dockerfile)
7. Aggiungi le variabili d'ambiente (vedi tabella sotto)
8. **Distribuisci**
9. Dopo che il deploy è completato: copia l'**indirizzo interno** mostrato nella pagina del servizio (formato: `http://jinbocho-auth:8001`). Avrai bisogno di questo per catalog e gateway.

**Variabili d'ambiente auth-service:**

| Variabile | Valore |
|-----------|-------|
| `DATABASE_URL` | Stringa di connessione Neon `auth_db` (trasformata) |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` |
| `JWT_ALGORITHM` | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `30` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` |
| `DEBUG` | `false` |
| `PORT` | `8001` |

### catalog-service

1. **New + → Private Service**
2. Repository: `jinbocho-catalog-v1`, Docker, stessa regione
3. Aggiungi le variabili d'ambiente (vedi tabella sotto)
4. **Distribuisci**
5. Copia l'indirizzo interno dopo il deploy.

**Variabili d'ambiente catalog-service:**

| Variabile | Valore |
|-----------|-------|
| `DATABASE_URL` | Stringa di connessione Neon `catalog_db` (trasformata) |
| `AUTH_SERVICE_URL` | Indirizzo interno di auth-service (es. `http://jinbocho-auth:8001`) |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` — **identica ad auth** |
| `JWT_ALGORITHM` | `HS256` |
| `GOOGLE_BOOKS_API_KEY` | La tua chiave Google Books API (ottienila gratuitamente) |
| `DEBUG` | `false` |
| `PORT` | `8002` |

### api-gateway

Il gateway è l'**unico** componente backend pubblico.

1. **New + → Web Service** (non Private!)
2. Repository: `jinbocho-api-gateway-v1`, Docker, stessa regione
3. Percorso health check: `/health`
4. Aggiungi le variabili d'ambiente:

| Variabile | Valore |
|-----------|-------|
| `JWT_SECRET_KEY` | `<JWT_SECRET>` — **identica ad auth** |
| `JWT_ALGORITHM` | `HS256` |
| `AUTH_SERVICE_URL` | Indirizzo interno di auth-service |
| `CATALOG_SERVICE_URL` | Indirizzo interno di catalog-service |
| `CORS_ORIGINS` | `["https://jinbocho-fe.onrender.com"]` — imposta dopo il deploy del FE |
| `DEBUG` | `false` |

5. **Distribuisci** → Render assegna un URL pubblico come `https://jinbocho-api-gateway.onrender.com`.  
   **Salva questo URL** — è il `VITE_API_BASE_URL` per il frontend.

## Step 3 — Distribuisci il frontend

1. **New + → Static Site**
2. Repository: `jinbocho-fe`
3. Build Command: `npm ci && npm run build`
4. Publish Directory: `dist`
5. Aggiungi regola Redirect/Rewrite: Source `/*` → Destination `/index.html` → Action **Rewrite** (routing SPA)
6. Variabile d'ambiente:

| Variabile | Valore |
|-----------|-------|
| `VITE_API_BASE_URL` | URL pubblico dell'api-gateway (dallo Step 2) |

7. **Distribuisci** → Render assegna un URL pubblico come `https://jinbocho-fe.onrender.com`.

## Step 4 — Chiudi il ciclo degli URL

Esiste una dipendenza circolare tra il gateway (che ha bisogno dell'URL del frontend per CORS) e il frontend (che ha bisogno dell'URL del gateway per le chiamate API). Risolvila ora:

1. Vai su **api-gateway** su Render → **Environment**
2. Imposta `CORS_ORIGINS` all'URL del frontend: `["https://jinbocho-fe.onrender.com"]`
3. Clicca **Save Changes** → Render attiva automaticamente un rideploy
4. Attendi il completamento del rideploy

## Step 5 — Verifica il deployment

Esegui questi controlli dopo che tutti i servizi sono attivi:

```bash
GW=https://jinbocho-api-gateway.onrender.com

# 1. Health del gateway
curl $GW/health
# Atteso: {"status":"ok"}

# 2. Registra una famiglia di test
curl -X POST $GW/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"family_name":"Famiglia Test","full_name":"Alice","email":"alice@test.com","password":"Password123!"}'

# 3. Login e ottieni un token
curl -X POST $GW/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@test.com","password":"Password123!"}'
# Copia l'access_token dalla risposta

# 4. Test ricerca ISBN
TOKEN="il-tuo-access-token"
curl "$GW/v1/records/isbn-lookup?isbn=9788845292613" \
  -H "Authorization: Bearer $TOKEN"
```

**Checklist di verifica completa:**

- [ ] `GET /health` restituisce `{"status":"ok"}`
- [ ] Migrazioni Alembic applicate (controlla i log di auth e catalog: cerca il successo di `alembic upgrade head`)
- [ ] POST `/v1/auth/register` restituisce `{ family_id, user_id }`
- [ ] POST `/v1/auth/login` restituisce `{ access_token, refresh_token }`
- [ ] Il frontend si carica all'URL del sito statico Render
- [ ] Il login dal frontend funziona
- [ ] La ricerca ISBN restituisce metadati (la chiave Google Books è impostata)
- [ ] Nessun errore CORS nella console del browser

## Costi e limiti del livello gratuito

| Componente | Provider | Costo | Limiti |
|-----------|----------|------|-------|
| `auth_db`, `catalog_db` | Neon free | €0 | 0,5 GB ciascuno, nessuna scadenza |
| `auth-service`, `catalog-service` | Render free | €0 | Cold start dopo 15 min di inattività (~30-60s) |
| `api-gateway` | Render free | €0 | Cold start dopo 15 min di inattività |
| `jinbocho-fe` | Render Static Site | €0 | Nessun cold start (CDN) |
| Totale | — | **€0/mese** | Cold start accettabili per uso domestico |

Per eliminare i cold start, passa a Render Starter ($7/mese per servizio). I database rimangono gratuiti su Neon indipendentemente.

!!! tip "Mantieni i servizi nella stessa regione"
    I Servizi Privati di Render possono comunicare solo all'interno della stessa regione. Distribuisci sempre auth, catalog e gateway nella stessa regione. Scegli la regione Neon più vicina a quella Render per minimizzare la latenza del database.