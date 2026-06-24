# Deploy in produzione

Jinbocho è disponibile in due edizioni e due percorsi di deployment:

- **Community edition** — `auth` + `catalog` + `api-gateway` + frontend. Gratuita.
- **Pro edition** — aggiunge il modulo `ai-service` (tagging AI, deduplicazione, raccomandazioni) e un proprio database. Richiede una chiave di un provider LLM (o un'istanza locale di Ollama) e, per il percorso self-hosted, una licenza Jinbocho Pro per scaricare l'immagine privata `ghcr.io/jinbocho/jinbocho-ai-v1`.

E due modi per eseguire ciascuna edizione in produzione:

1. **Render + Neon** (questo capitolo, Step 0-5 sotto) — PaaS gestito, zero server da mantenere, livello gratuito disponibile. Si può distribuire a mano (click-ops, descritto sotto) oppure in un solo passaggio con il **Render Blueprint** (`render.yaml`) — vedi [Deploy con Render Blueprint](#deploy-con-render-blueprint-iac).
2. **VPS self-hosted** (Docker Compose + Caddy, TLS automatico) — vedi [Deploy self-hosted su VPS](#deploy-self-hosted-su-vps). Costo a lungo termine più basso, ma gestisci tu il server.

Tutto il tooling di deployment (file compose, template env, script) si trova nel repository gemello `jinbocho-infrastructure-v1` — sia la procedura manuale Render di questo capitolo sia la sezione VPS attingono da lì.

## Render + Neon (procedura manuale)

Questa combinazione offre uno stack Community completamente operativo a costo zero con i livelli gratuiti.

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
| `AI_SERVICE_URL` | Indirizzo interno di ai-service *(omettere se non distribuito)* |
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
curl "$GW/v1/catalog/ingestion/isbn/9788845292613" \
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

## Deploy con Render Blueprint (IaC)

Invece di seguire a mano gli Step 0-4 sopra, puoi distribuire l'intero stack Community in un solo passaggio con il Render Blueprint in `jinbocho-infrastructure-v1/render.yaml`:

1. Fai un fork/clone di `jinbocho-auth-v1`, `jinbocho-catalog-v1`, `jinbocho-api-gateway-v1`, `jinbocho-fe` sotto il tuo account o organizzazione GitHub, e sostituisci ogni placeholder `CHANGEME` in `render.yaml` con quell'account.
2. Dashboard Render → **New + → Blueprint** → puntalo al tuo fork di `jinbocho-infrastructure-v1`.
3. Render crea tutti e quattro i servizi in un colpo: `jinbocho-auth` e `jinbocho-catalog` come Servizi Privati (`type: pserv`, non raggiungibili da internet — defense in depth), `jinbocho-api-gateway` come unico Web Service pubblico, e `jinbocho-fe` come sito statico.
4. `JWT_SECRET_KEY`, `JWT_ALGORITHM`, `JWT_ISSUER`, `JWT_AUDIENCE` sono definite una sola volta nel gruppo di variabili d'ambiente condiviso `jinbocho-jwt` e iniettate in auth, catalog e gateway — imposti `JWT_SECRET_KEY` una sola volta.
5. Ogni variabile `sync: false` (`DATABASE_URL` per auth/catalog, `GOOGLE_BOOKS_API_KEY`, `CORS_ORIGINS`, `VITE_API_BASE_URL`, le variabili SMTP dell'auth-service, `FRONTEND_BASE_URL`) **non è salvata in git** — Render te la richiede al primo deploy.
6. Si applica la stessa risoluzione della dipendenza circolare descritta nello Step 4 sopra: distribuisci una volta, poi compila `CORS_ORIGINS` (gateway) e `VITE_API_BASE_URL` (frontend) una volta che conosci gli URL pubblici reciproci, e ridistribuisci questi due servizi.
7. I Servizi Privati (`pserv`) richiedono un piano Render a pagamento (~$7/mese ciascuno). Per restare nel livello gratuito al costo di esporre pubblicamente auth/catalog, cambia il loro `type` da `pserv` a `web` nel tuo fork di `render.yaml` — restano comunque protetti dalla validazione JWT in entrambi i casi.

Il blocco per l'ai-service è presente in `render.yaml` ma commentato — è scaffolding per la Pro edition. Per attivarlo: crea un database `ai_db` su Neon, decommenta il blocco, imposta `OPENAI_API_KEY` (oppure punta `LLM_BASE_URL`/`LLM_MODEL` a un altro provider compatibile con OpenAI nelle env vars del servizio), e aggiungi `AI_SERVICE_URL=http://jinbocho-ai:8003` alle env vars del gateway.

Vedi `RENDER_DEPLOYMENT.md` in `jinbocho-infrastructure-v1` per l'esempio completo con valori di esempio.

## Deploy self-hosted su VPS

`jinbocho-infrastructure-v1/scripts/setup-vps-community.sh` e `setup-vps-pro.sh` eseguono `docker/docker-compose.all.yml` end to end su un VPS Debian/Ubuntu pulito (Hetzner, Scaleway, DigitalOcean, ...): installano Docker se manca, generano i segreti, scrivono ogni file env, buildano l'immagine del frontend, e avviano l'intero stack (Postgres × N + backend + gateway + frontend + reverse proxy Caddy con TLS Let's Encrypt automatico) in un'unica esecuzione.

```bash
# Community edition — auth + catalog + gateway + frontend:
sudo ./scripts/setup-vps-community.sh \
  --domain library.example.com \
  --email you@example.com \
  --google-books-key AIza...

# Pro edition — aggiunge ai-service + il suo database; richiede il login a GHCR perché
# ghcr.io/jinbocho/jinbocho-ai-v1 è un'immagine privata (licenza Jinbocho Pro):
sudo ./scripts/setup-vps-pro.sh \
  --domain library.example.com \
  --email you@example.com \
  --google-books-key AIza... \
  --ghcr-user you --ghcr-token ghp_xxx
```

Flag utili su entrambi gli script: `--smtp-user`/`--smtp-password`/`--email-from` per abilitare l'invio email reale per i link di invito/reset (omettendoli, il servizio registra il link nei log invece di inviarlo), `--frontend-base-url` per sovrascrivere l'URL incluso nelle email, `--version` per fissare un tag di immagine GHCR invece di `latest`, `--enable-firewall` per configurare `ufw` (22/80/443). Esegui entrambi gli script con `--help` per l'elenco completo. Ri-eseguirli è sicuro — i segreti, i file env e il Caddyfile esistenti vengono mantenuti a meno che tu non li elimini prima.

Per lo script Pro, `--ghcr-token` deve essere un PAT **classico** con lo scope `read:packages` (GHCR non supporta ancora i token a granularità fine per questo) — generalo da un account macchina dedicato, non dal tuo account GitHub personale.

Una volta che lo stack è attivo, fai uno smoke-test con:

```bash
./scripts/validate-api.sh
```

Questo registra una famiglia di test ed esercita gli endpoint principali tramite il gateway su `http://localhost:8000` (o il tuo dominio).

## Community vs Pro edition

L'unica differenza tra le edizioni è il modulo `ai-service`:

| | Community | Pro |
|---|---|---|
| `auth`, `catalog`, `api-gateway`, frontend | ✅ | ✅ |
| `ai-service` + `ai_db` | ❌ | ✅ |
| File compose | `docker-compose.community*.yml` | `docker-compose.pro*.yml` |
| Installer VPS | `setup-vps-community.sh` | `setup-vps-pro.sh` |
| Immagine `ai-service` | — | privata (`ghcr.io/jinbocho/jinbocho-ai-v1`), richiede licenza Pro + login GHCR |
| Feature flag del gateway | `JINBOCHO_FEATURES=catalog,auth` | `JINBOCHO_FEATURES=catalog,auth,ai` |

Per passare un deployment Community attivo a Pro: aggiungi il modulo `ai` a `JINBOCHO_FEATURES` sul gateway, distribuisci `ai-service` (su Render: decommenta il blocco in `render.yaml`; su VPS: ri-esegui con `setup-vps-pro.sh`, oppure imposta `COMPOSE_PROFILES=pro` se stai eseguendo direttamente `docker-compose.all.yml`), e configura il suo provider LLM (`LLM_ENABLED=true` + `LLM_BASE_URL`/`LLM_MODEL`/`LLM_API_KEY` — OpenRouter, OpenAI, Gemini e Ollama locale funzionano tutti come endpoint compatibili OpenAI). Con `LLM_ENABLED=false` le funzionalità AI degradano in modo controllato nella UI invece di generare errori.
