# Deploy in produzione

Jinbocho prevede due percorsi di deployment. Entrambi sono documentati qui
sotto, ciascuno a partire dal modo più veloce per ottenere uno stack
funzionante, seguito dalla versione completamente manuale, passo per passo,
per quando vuoi capire o controllare ogni singolo pezzo.

Tutto il tooling di deployment (file compose, template env, script) si trova
nel repository gemello `jinbocho-infrastructure-community-v1` — entrambe le
sezioni sotto attingono da lì.

| | **VPS self-hosted** | **Render + Neon** |
|---|---|---|
| Costo | Solo il costo della VPS (~€4-6/mese) | €0 con i livelli gratuiti |
| Setup | Un comando | Click-ops oppure Blueprint in un passaggio |
| Manutenzione | Gestisci e aggiorni tu il server | Completamente gestito |
| Cold start | Nessuno | Il livello gratuito va in sleep dopo 15 min di inattività |
| TLS | Automatico (Caddy + Let's Encrypt) | Automatico (Render) |
| Ideale per | Controllo completo, VPS già disponibile, nessun cold start | Zero operatività, il più veloce da provare, nessun server da gestire |

Scegline uno — non servono entrambi.

## Deploy self-hosted su VPS

### Quick start

Un solo comando trasforma una VPS Debian/Ubuntu appena creata in uno stack
Jinbocho completamente funzionante: Postgres ×2, i tre servizi backend, il
frontend e Caddy come reverse proxy con HTTPS automatico.

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-v1.git
cd jinbocho-infrastructure-v1

sudo ./scripts/setup-vps-community.sh \
  --domain library.example.com \
  --email you@example.com \
  --google-books-key AIza...
```

Requisiti:

- Una **VPS Debian/Ubuntu** appena creata, con IP pubblico, eseguita come
  `root` (o con `sudo`).
- `--domain` deve **già risolvere** all'IP del server — Caddy richiede un
  certificato Let's Encrypt per quel dominio al primo avvio. Ometti del tutto
  `--domain`/`--email` per servire in HTTP semplice sull'IP nudo (senza TLS).
- Ogni opzione non passata come flag viene chiesta interattivamente. Aggiungi
  `--non-interactive` per saltare tutti i prompt e affidarti solo a
  flag/default — utile per installazioni non presidiate (es. cloud-init).

Nel giro di un paio di minuti lo script stampa l'URL del frontend, l'URL
dell'API gateway e dove sono stati scritti i segreti. Apri il frontend e
registra la prima famiglia — diventa l'account admin.

!!! tip "Ri-eseguirlo è sicuro"
    Lo script è idempotente: i segreti esistenti, i file `envs/*.env` e il
    `Caddyfile` generato vengono mantenuti così come sono a una seconda
    esecuzione, a meno che tu non li elimini prima.

### Cosa fa lo script

`scripts/setup-vps-community.sh` esegue `docker/docker-compose.all.yml` end
to end:

1. Installa Docker (via `get.docker.com`) se non è già presente.
2. Opzionalmente configura `ufw` per aprire 22/80/443 (`--enable-firewall`).
3. Clona (o aggiorna) `jinbocho-fe` accanto al repository infrastruttura.
4. Genera `POSTGRES_PASSWORD`, `JWT_SECRET_KEY` e `INTERNAL_SERVICE_TOKEN`, e
   scrive ogni file `envs/*.env` a partire dai template `*.example`.
5. Scrive un `Caddyfile` che fa da reverse proxy per `/api/*` verso il
   gateway e per tutto il resto verso il frontend, con TLS automatico se è
   stato indicato `--domain`.
6. Scarica le immagini backend da GHCR, builda l'immagine del frontend dal
   sorgente e avvia l'intero stack con `docker compose ... up -d`.
7. Interroga `/health` attraverso il gateway e segnala se lo stack si è
   avviato correttamente.

### Tutte le opzioni dello script

| Flag | Valore | Default | Descrizione |
|---|---|---|---|
| `--domain` | `<fqdn>` | — (usa l'IP del server, solo HTTP) | Dominio pubblico già puntato a questo server. Abilita HTTPS automatico. |
| `--email` | `<email>` | — | Email di contatto per Let's Encrypt. **Obbligatoria** se è impostato `--domain`. |
| `--google-books-key` | `<key>` | — | Chiave API Google Books, usata per la ricerca ISBN nel catalogo. Può essere aggiunta in seguito modificando `envs/catalog-service.env`. |
| `--smtp-user` | `<indirizzo Gmail>` | — | Indirizzo Gmail usato per inviare le email di invito/reset password. Host e porta SMTP vengono impostati automaticamente. Lascia vuoto per registrare il link nei log invece di inviarlo. |
| `--smtp-password` | `<app password>` | — | [App Password](https://myaccount.google.com/apppasswords) Gmail per `--smtp-user` — non la password normale dell'account. |
| `--email-from` | `<email>` | valore di `--smtp-user` | Indirizzo mittente mostrato sulle email in uscita. |
| `--grafana-enabled` | `true`\|`false` | chiesto interattivamente | Invia metriche/log/tracce a Grafana Cloud tramite il collector Alloy integrato (ADR-012). Opzionale, disabilitato di default. |
| `--grafana-otlp-endpoint` | `<url>` | gateway EU-West-2 di Grafana | Endpoint OTLP da Grafana Cloud → Connections → OpenTelemetry. |
| `--grafana-otlp-instance-id` | `<id>` | — | Instance ID dalla stessa pagina Grafana Cloud. Obbligatorio se `--grafana-enabled true`. |
| `--grafana-otlp-api-token` | `<token>` | — | API token dalla stessa pagina Grafana Cloud. Obbligatorio se `--grafana-enabled true`. |
| `--frontend-base-url` | `<url>` | derivato da `--domain`/IP del server | URL pubblico del frontend incluso nei link delle email. |
| `--fe-repo` | `<git url>` | `jinbocho/jinbocho-fe` | Repository del frontend da clonare. |
| `--fe-branch` | `<branch>` | `main` | Branch del frontend da clonare. |
| `--version` | `<tag>` | `latest` | Tag dell'immagine GHCR da scaricare per i servizi backend. |
| `--enable-firewall` | flag | disattivato | Configura e abilita `ufw`, aprendo le porte 22/80/443. |
| `--skip-docker-install` | flag | disattivato | Non tentare di installare Docker (usalo se è già presente tramite altro tooling). |
| `--non-interactive` | flag | disattivato | Non chiedere mai nulla; usa solo i flag/default forniti. |
| `-h`, `--help` | flag | — | Stampa l'elenco completo dei flag ed esce. |

### Verifica del deployment

```bash
./scripts/validate-api.sh
```

Registra una famiglia di test ed esercita gli endpoint principali tramite il
gateway (`http://localhost:8000`, o il tuo dominio) — lo stesso smoke test
usato su Render (vedi [Step 5](#step-5-verifica-il-deployment) qui sotto).

Comandi utili per la gestione quotidiana (lo script stampa l'invocazione
esatta per la tua configurazione, incluso `--profile observability` se
Grafana è abilitato):

```bash
docker compose -f docker/docker-compose.all.yml --env-file .env logs -f   # segui i log
docker compose -f docker/docker-compose.all.yml --env-file .env ps        # stato dei servizi
docker compose -f docker/docker-compose.all.yml --env-file .env down      # ferma tutto (dati/volumi mantenuti)
```

### Installazione manuale (senza script)

Se preferisci non eseguire lo script automatico — ad esempio per rivedere
ogni file prima che venga scritto, o perché gestisci già il TLS con un tuo
reverse proxy — installa pezzo per pezzo con `docker-compose.community.yml`:

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-v1.git
cd jinbocho-infrastructure-v1

cp .env.example .env
cp envs/auth-service.env.example envs/auth-service.env
cp envs/catalog-service.env.example envs/catalog-service.env
cp envs/api-gateway.env.example envs/api-gateway.env

# modifica i file sopra — vedi le tabelle dei campi qui sotto

docker compose -f docker/docker-compose.community.yml up -d
```

!!! warning "Nessun TLS o reverse proxy in questa modalità"
    A differenza dello script in un passaggio, `docker-compose.community.yml`
    non avvia Caddy. Il gateway è esposto direttamente sulla porta `8000`.
    Metti un tuo reverse proxy (Caddy, nginx, Traefik, un load balancer)
    davanti se ti serve HTTPS o un nome di dominio.

**`.env` (radice del repository, letto da Docker Compose stesso):**

| Variabile | Default | Obbligatoria | Descrizione |
|---|---|---|---|
| `POSTGRES_PASSWORD` | `change_me_local_dev` | Sì | Password per i container Postgres locali. Cambiala prima di esporre qualcosa pubblicamente. |
| `JINBOCHO_VERSION` | `latest` | No | Tag dell'immagine GHCR da scaricare per i servizi backend. |

**`envs/auth-service.env`:**

| Variabile | Obbligatoria | Descrizione |
|---|---|---|
| `DEBUG` | No | Imposta `false` in produzione; `true` abilita anche il logging SQL. |
| `DATABASE_URL` | Sì | Deve puntare a `jinbocho-postgres-auth` e coincidere con `POSTGRES_PASSWORD` del `.env` radice. |
| `JWT_SECRET_KEY` | **Sì** | Deve essere **identica** su `auth-service`, `catalog-service` e `api-gateway`. Genera con `openssl rand -hex 32`. |
| `INTERNAL_SERVICE_TOKEN` | **Sì** | Deve coincidere con il valore di `catalog-service` — autentica le chiamate catalog→auth (email di promemoria prestiti). Genera con `openssl rand -hex 32`. |
| `FRONTEND_BASE_URL` | No | Usato per costruire i link nelle email di invito/reset password. |
| `SMTP_USER` / `SMTP_PASSWORD` | No | Lascia vuoti per registrare i link di invito/reset nei log invece di inviarli via email. |

**`envs/catalog-service.env`:**

| Variabile | Obbligatoria | Descrizione |
|---|---|---|
| `DATABASE_URL` | Sì | Deve puntare a `jinbocho-postgres-catalog` e coincidere con `POSTGRES_PASSWORD`. |
| `JWT_SECRET_KEY` | **Sì** | Identica al valore di `auth-service`. |
| `INTERNAL_SERVICE_TOKEN` | **Sì** | Identica al valore di `auth-service`. |
| `GOOGLE_BOOKS_API_KEY` | Consigliata | Chiave gratuita su [console.cloud.google.com](https://console.cloud.google.com/). Senza, la quota condivisa (1000 richieste/giorno) si esaurisce rapidamente. |

**`envs/api-gateway.env`:**

| Variabile | Obbligatoria | Descrizione |
|---|---|---|
| `JWT_SECRET_KEY` | **Sì** | Identica al valore di `auth-service`. |
| `CORS_ORIGINS` | No | `["*"]` di default — imposta l'URL reale del tuo frontend in produzione. |

Apri `http://<ip-server>:8000/docs` per confermare che il gateway sia attivo,
poi procedi come descritto in
[Verifica del deployment](#verifica-del-deployment) qui sopra.

### Opzionale: metriche e log (Grafana Cloud)

Disabilitato di default — salta questa sezione se non ti serve, lo stack
funziona esattamente come descritto sopra anche senza. Quando abilitato
(`--grafana-enabled true`, oppure a mano in seguito), un collector Grafana
Alloy locale interroga `/metrics`, riceve le tracce OTLP, legge i log dei
container e inoltra tutti e tre a Grafana Cloud tramite un'unica connessione
OTLP. Vedi `README.md` (sezione 6) in `jinbocho-infrastructure-community-v1`
per la configurazione completa, e il documento ADR-012 in
`jinbocho-docs/architecture/adr/` per le motivazioni architetturali.

## Deploy su Render + Neon

### Quick start — Render Blueprint (IaC)

Il modo più veloce per arrivare su Render: distribuisci l'intero stack in un
solo passaggio con il Render Blueprint in
`jinbocho-infrastructure-community-v1/render.yaml`, invece di seguire a mano
la procedura manuale qui sotto.

1. Fai un fork/clone di `jinbocho-auth-v1`, `jinbocho-catalog-v1`,
   `jinbocho-api-gateway-v1`, `jinbocho-fe` sotto il tuo account o
   organizzazione GitHub, e sostituisci ogni placeholder `CHANGEME` in
   `render.yaml` con quell'account.
2. Dashboard Render → **New + → Blueprint** → puntalo al tuo fork di
   `jinbocho-infrastructure-community-v1`.
3. Render crea tutti e quattro i servizi in un colpo: `jinbocho-auth` e
   `jinbocho-catalog` come Servizi Privati (`type: pserv`, non raggiungibili
   da internet — defense in depth), `jinbocho-api-gateway` come unico Web
   Service pubblico, e `jinbocho-fe` come sito statico.
4. `JWT_SECRET_KEY`, `JWT_ALGORITHM`, `JWT_ISSUER`, `JWT_AUDIENCE` sono
   definite una sola volta nel gruppo di variabili d'ambiente condiviso
   `jinbocho-jwt` e iniettate in auth, catalog e gateway — imposti
   `JWT_SECRET_KEY` una sola volta.
5. Ogni variabile `sync: false` (`DATABASE_URL` per auth/catalog,
   `GOOGLE_BOOKS_API_KEY`, `CORS_ORIGINS`, `VITE_API_BASE_URL`, le variabili
   SMTP dell'auth-service, `FRONTEND_BASE_URL`) **non è salvata in git** —
   Render te la richiede al primo deploy.
6. Esiste una dipendenza circolare tra il gateway (che ha bisogno dell'URL
   del frontend per CORS) e il frontend (che ha bisogno dell'URL del gateway
   per le chiamate API) — come nello
   [Step 4](#step-4-chiudi-il-ciclo-degli-url) qui sotto: distribuisci una
   volta, poi compila `CORS_ORIGINS` (gateway) e `VITE_API_BASE_URL`
   (frontend) una volta che conosci gli URL pubblici reciproci, e
   ridistribuisci questi due servizi.
7. I Servizi Privati (`pserv`) richiedono un piano Render a pagamento
   (~$7/mese ciascuno). Per restare nel livello gratuito al costo di esporre
   pubblicamente auth/catalog, cambia il loro `type` da `pserv` a `web` nel
   tuo fork di `render.yaml` — restano comunque protetti dalla validazione
   JWT in entrambi i casi.

Vedi `RENDER_DEPLOYMENT.md` in `jinbocho-infrastructure-community-v1` per
l'esempio completo con valori di esempio.

### Architettura su Render

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

**Solo due componenti sono pubblici**: l'API gateway e il frontend. I due
servizi backend sono Servizi Privati — raggiungibili solo dalla rete interna
di Render.

### Procedura manuale (Step 0 – Step 5)

Preferisci il controllo manuale completo, o vuoi capire esattamente cosa
automatizza il Blueprint sopra? Segui questi passi a mano — stesso
risultato, costo zero con i livelli gratuiti.

#### Step 0 — Genera i segreti

```bash
# JWT_SECRET_KEY — deve essere identica su auth, catalog e gateway
openssl rand -hex 32
```

Salva questo valore. Lo inserirai più volte. Chiamalo `<JWT_SECRET>` nei
passi seguenti.

#### Step 1 — Crea i database Neon

!!! warning "Non usare il PostgreSQL integrato di Render"
    Il PostgreSQL gratuito di Render viene eliminato dopo circa 30 giorni.
    Usa Neon invece — il suo livello gratuito è persistente e non scade.

1. Registrati su [neon.tech](https://neon.tech) → **Crea progetto**
   - Nome: `jinbocho`
   - Versione PostgreSQL: `16`
   - Regione: più vicina alla tua regione Render (es. EU-Central per
     Francoforte)
2. Dalla console Neon → **Database → Nuovo Database**, crea:
   - `auth_db`
   - `catalog_db`
3. Per ogni database, vai su **Dettagli di connessione** → copia la stringa
   di connessione.

**Adattare la stringa di connessione** — Neon fornisce una stringa come:

```
postgresql://user:password@ep-xxxx.eu-central-1.aws.neon.tech/auth_db?sslmode=require
```

Devi trasformarla prima di usarla su Render:

| Modifica | Motivo |
|---------|-------|
| `postgresql://` → `postgresql+asyncpg://` | driver asyncpg |
| `?sslmode=require` → `?ssl=require` | asyncpg non capisce `sslmode` |

Risultato finale:

```
postgresql+asyncpg://user:password@ep-xxxx.eu-central-1.aws.neon.tech/auth_db?ssl=require
```

Fai questa trasformazione per ogni URL del database. Tieni privati entrambi
gli URL.

#### Step 2 — Distribuisci i servizi backend

Distribuisci in questo ordine: **auth → catalog → gateway**. Il gateway ha
bisogno degli URL interni degli altri servizi.

**auth-service:**

1. Dashboard Render → **New + → Private Service**
2. Connetti il repository: `jinbocho-auth-v1`
3. Runtime: **Docker**
4. Regione: stessa dei database Neon
5. Tipo di istanza: **Free** (o Starter per evitare cold start)
6. Docker Command: **lascia vuoto** (già nel Dockerfile)
7. Aggiungi le variabili d'ambiente (vedi tabella sotto)
8. **Distribuisci**
9. Dopo che il deploy è completato: copia l'**indirizzo interno** mostrato
   nella pagina del servizio (formato: `http://jinbocho-auth:8001`). Avrai
   bisogno di questo per catalog e gateway.

| Variabile | Valore |
|-----------|-------|
| `DATABASE_URL` | Stringa di connessione Neon `auth_db` (trasformata) |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` |
| `JWT_ALGORITHM` | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `30` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` |
| `DEBUG` | `false` |
| `PORT` | `8001` |

**catalog-service:**

1. **New + → Private Service**
2. Repository: `jinbocho-catalog-v1`, Docker, stessa regione
3. Aggiungi le variabili d'ambiente (vedi tabella sotto)
4. **Distribuisci**
5. Copia l'indirizzo interno dopo il deploy.

| Variabile | Valore |
|-----------|-------|
| `DATABASE_URL` | Stringa di connessione Neon `catalog_db` (trasformata) |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` — **identica ad auth** |
| `JWT_ALGORITHM` | `HS256` |
| `GOOGLE_BOOKS_API_KEY` | La tua chiave Google Books API (ottienila gratuitamente) |
| `DEBUG` | `false` |
| `PORT` | `8002` |

**api-gateway** — l'**unico** componente backend pubblico:

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

5. **Distribuisci** → Render assegna un URL pubblico come
   `https://jinbocho-api-gateway.onrender.com`. **Salva questo URL** — è il
   `VITE_API_BASE_URL` per il frontend.

#### Step 3 — Distribuisci il frontend

1. **New + → Static Site**
2. Repository: `jinbocho-fe`
3. Build Command: `npm ci && npm run build`
4. Publish Directory: `dist`
5. Aggiungi regola Redirect/Rewrite: Source `/*` → Destination
   `/index.html` → Action **Rewrite** (routing SPA)
6. Variabile d'ambiente:

| Variabile | Valore |
|-----------|-------|
| `VITE_API_BASE_URL` | URL pubblico dell'api-gateway (dallo Step 2) |

7. **Distribuisci** → Render assegna un URL pubblico come
   `https://jinbocho-fe.onrender.com`.

#### Step 4 — Chiudi il ciclo degli URL

Esiste una dipendenza circolare tra il gateway (che ha bisogno dell'URL del
frontend per CORS) e il frontend (che ha bisogno dell'URL del gateway per le
chiamate API). Risolvila ora:

1. Vai su **api-gateway** su Render → **Environment**
2. Imposta `CORS_ORIGINS` all'URL del frontend:
   `["https://jinbocho-fe.onrender.com"]`
3. Clicca **Save Changes** → Render attiva automaticamente un rideploy
4. Attendi il completamento del rideploy

#### Step 5 — Verifica il deployment

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
- [ ] Migrazioni Alembic applicate (controlla i log di auth e catalog: cerca
      il successo di `alembic upgrade head`)
- [ ] POST `/v1/auth/register` restituisce `{ family_id, user_id }`
- [ ] POST `/v1/auth/login` restituisce `{ access_token, refresh_token }`
- [ ] Il frontend si carica all'URL del sito statico Render
- [ ] Il login dal frontend funziona
- [ ] La ricerca ISBN restituisce metadati (la chiave Google Books è
      impostata)
- [ ] Nessun errore CORS nella console del browser

### Costi e limiti del livello gratuito

| Componente | Provider | Costo | Limiti |
|-----------|----------|------|-------|
| `auth_db`, `catalog_db` | Neon free | €0 | 0,5 GB ciascuno, nessuna scadenza |
| `auth-service`, `catalog-service` | Render free | €0 | Cold start dopo 15 min di inattività (~30-60s) |
| `api-gateway` | Render free | €0 | Cold start dopo 15 min di inattività |
| `jinbocho-fe` | Render Static Site | €0 | Nessun cold start (CDN) |
| Totale | — | **€0/mese** | Cold start accettabili per uso domestico |

Per eliminare i cold start, passa a Render Starter ($7/mese per servizio). I
database rimangono gratuiti su Neon indipendentemente.

!!! tip "Mantieni i servizi nella stessa regione"
    I Servizi Privati di Render possono comunicare solo all'interno della
    stessa regione. Distribuisci sempre auth, catalog e gateway nella stessa
    regione. Scegli la regione Neon più vicina a quella Render per
    minimizzare la latenza del database.
