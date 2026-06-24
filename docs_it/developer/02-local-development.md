# Configurazione dell'ambiente di sviluppo locale

Avvia il tuo ambiente di sviluppo locale con Docker Compose in pochi minuti.

## Panoramica

Il backend di Jinbocho viene distribuito tramite un repository di orchestrazione separato,
[`jinbocho-infrastructure-v1`](https://github.com/jinbocho/jinbocho-infrastructure-v1). Non
contiene codice applicativo — solo i file Docker Compose, i template delle
variabili d'ambiente e gli strumenti di deploy per VPS/Render per i servizi
`auth`, `catalog`, `api-gateway` e il servizio opzionale `ai`.

Sono disponibili cinque file Compose, da scegliere in base alle immagini che
vuoi eseguire e se il modulo AI (edizione Pro) è abilitato:

| File | Immagini | Edizione | Caso d'uso |
|---|---|---|---|
| `docker/docker-compose.community.yml` | GHCR (pre-build) | Community | Self-hosting, senza checkout del codice sorgente |
| `docker/docker-compose.pro.yml` | GHCR (pre-build) | Pro | Self-hosting con modulo AI |
| `docker/docker-compose.community.local.yml` | Build da `../jinbocho-*-v1` | Community | Sviluppo locale dal codice sorgente |
| `docker/docker-compose.pro.local.yml` | Build da `../jinbocho-*-v1` | Pro | Sviluppo locale dal codice sorgente — usato da `./scripts/dev.sh` |
| `docker/docker-compose.all.yml` | Backend da GHCR + frontend buildato localmente | Entrambe (`COMPOSE_PROFILES=pro`) | Deploy su VPS singolo, include Caddy + TLS |

Questo capitolo descrive lo **sviluppo locale dal codice sorgente** (`*.local.yml`).
Per il self-hosting con immagini pre-build o un'installazione VPS in un unico
passaggio, vedi [Deploy in Produzione](07-production-deployment.md).

## 1. Preparare la workspace

Se non hai ancora clonato i repository, segui le istruzioni di [Checkout dei repository](01-prerequisites.md#checkout-dei-repository).

`jinbocho-infrastructure-v1` si aspetta che i repository dei servizi siano
clonati come cartelle "fratelle":

```
~/workspace/jinbocho/
├── jinbocho-infrastructure-v1/
├── jinbocho-auth-v1/
├── jinbocho-catalog-v1/
├── jinbocho-api-gateway-v1/
├── jinbocho-ai-v1/            ← necessario solo per l'edizione Pro
└── jinbocho-fe/
```

## 2. Configurare le variabili d'ambiente

Da `jinbocho-infrastructure-v1/`, copia il file `.env` di root e i template
per ciascun servizio da `envs/`:

```bash
cd jinbocho-infrastructure-v1

cp .env.example .env
cp envs/auth-service.env.example    envs/auth-service.env
cp envs/catalog-service.env.example envs/catalog-service.env
cp envs/api-gateway.env.example     envs/api-gateway.env
```

Le variabili non elencate qui sotto hanno già un valore di default funzionante
nel relativo file `*.example` — non serve modificarle per lo sviluppo locale.

**`.env`** (root del repository — letto da Docker Compose stesso):

| Variabile | Default | Obbligatoria | Descrizione |
|---|---|---|---|
| `POSTGRES_PASSWORD` | `change_me_local_dev` | Sempre | Password per i container Postgres locali |
| `JINBOCHO_VERSION` | `latest` | No | Tag dell'immagine GHCR (usato solo dai file compose non `.local`) |
| `COMPOSE_PROFILES` | non impostata | No | Imposta `pro` su `docker-compose.all.yml` per avviare anche `postgres-ai` + `ai-service` |

**`envs/auth-service.env`** — variabili principali:

| Variabile | Default | Obbligatoria | Descrizione |
|---|---|---|---|
| `DATABASE_URL` | punta a `jinbocho-postgres-auth:5432/auth_db` | Sì | Deve corrispondere a `POSTGRES_PASSWORD` del `.env` di root |
| `JWT_SECRET_KEY` | — | **Sì** | Deve essere **identica** tra `auth-service`, `catalog-service` e `api-gateway`. Generala con `openssl rand -hex 32` |
| `FRONTEND_BASE_URL` | `http://localhost:5173` | No | Usata per costruire i link nelle email di invito/reset password |
| `SMTP_HOST` / `SMTP_PORT` / `SMTP_USER` / `SMTP_PASSWORD` / `EMAIL_FROM` | — | No | Lascia `SMTP_USER` vuoto per stampare i link di reset/invito nei log invece di inviare email reali |

**`envs/catalog-service.env`** — variabili principali:

| Variabile | Default | Obbligatoria | Descrizione |
|---|---|---|---|
| `DATABASE_URL` | punta a `jinbocho-postgres-catalog:5432/catalog_db` | Sì | Deve corrispondere a `POSTGRES_PASSWORD` del `.env` di root |
| `JWT_SECRET_KEY` | — | **Sì** | Deve corrispondere al valore di `auth-service` |
| `GOOGLE_BOOKS_API_KEY` | — | Consigliata | Chiave gratuita dell'API Google Books; senza di essa la quota condivisa (1000 richieste/giorno) si esaurisce rapidamente |

**`envs/api-gateway.env`** — variabili principali:

| Variabile | Default | Obbligatoria | Descrizione |
|---|---|---|---|
| `JWT_SECRET_KEY` | — | **Sì** | Deve corrispondere al valore di `auth-service` |
| `AUTH_SERVICE_URL` / `CATALOG_SERVICE_URL` / `AI_SERVICE_URL` | hostname Docker interni | No | Lasciali invariati per lo sviluppo locale |
| `CORS_ORIGINS` | `["*"]` | No | Imposta l'URL del tuo frontend in produzione |
| `JINBOCHO_FEATURES` | `catalog,auth` | No | Moduli abilitati, separati da virgola. Aggiungi `ai` solo per l'edizione Pro |

Per l'edizione Pro, copia anche `envs/ai-service.env.example` e consulta
[Servizi Backend](03-backend-services.md#ai-service-porta-8003-solo-edizione-pro) per le sue variabili.

!!! warning "Non committare mai i file .env"
    Tutti i file `.env` sotto `jinbocho-infrastructure-v1/` sono (e devono rimanere) nel `.gitignore`.

## 3. Avviare lo stack

Da `jinbocho-infrastructure-v1/`:

```bash
# Edizione Community (senza modulo AI):
docker compose -f docker/docker-compose.community.local.yml up --build -d

# Edizione Pro (con modulo AI):
docker compose -f docker/docker-compose.pro.local.yml up --build -d
```

**Controlla lo stato**:

```bash
docker compose -f docker/docker-compose.community.local.yml ps
```

**Visualizza i log**:

```bash
docker compose -f docker/docker-compose.community.local.yml logs -f              # tutti i servizi
docker compose -f docker/docker-compose.community.local.yml logs -f auth-service # un solo servizio
```

La Swagger UI è disponibile su:

- Gateway: `http://localhost:8000/docs`
- Auth: `http://localhost:8001/docs`
- Catalog: `http://localhost:8002/docs`
- AI (solo Pro): `http://localhost:8003/docs`

## 4. Avviare backend e frontend insieme

`./scripts/dev.sh` avvia lo stack Compose Pro locale e poi lancia il server di
sviluppo del frontend nello stesso terminale:

```bash
cd jinbocho-infrastructure-v1
./scripts/dev.sh
```

È equivalente a eseguire `docker compose -f docker/docker-compose.pro.local.yml up --build -d`
seguito da `npm run dev` in `jinbocho-fe/`.

Per avviare il frontend separatamente, in un nuovo terminale:

```bash
cd jinbocho-fe
npm ci          # Installa le dipendenze (solo la prima volta)
npm run dev
```

Il frontend si avvierà su `http://localhost:5173` con hot reload.

## Ispezione del database

```bash
# Database auth
psql -U postgres -h 127.0.0.1 -p 5432 -d auth_db

# Database catalog
psql -U postgres -h 127.0.0.1 -p 5433 -d catalog_db

# Database AI (solo edizione Pro)
psql -U postgres -h 127.0.0.1 -p 5434 -d ai_db
```

Password: il valore di `POSTGRES_PASSWORD` da `jinbocho-infrastructure-v1/.env`
(`change_me_local_dev` di default).

## Verifica

### Health check

```bash
curl http://localhost:8000/health   # {"status":"ok"}
curl http://localhost:8001/health   # {"status":"ok"}
curl http://localhost:8002/health   # {"status":"ok"}
curl http://localhost:8003/health   # {"status":"ok"}  — solo edizione Pro
```

### Smoke-test dell'intero stack

`jinbocho-infrastructure-v1` include uno script che registra una famiglia di
test ed esercita i principali endpoint tramite il gateway:

```bash
cd jinbocho-infrastructure-v1
./scripts/validate-api.sh
```

### Test di un flusso completo manuale

```bash
# 1. Registra una famiglia
curl -X POST http://localhost:8000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "family_name": "Famiglia Test",
    "user_name": "Alice",
    "email": "alice@example.com",
    "password": "SecurePassword123!"
  }'

# 2. Login
curl -X POST http://localhost:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"SecurePassword123!"}'
# Copia l'access_token dalla risposta

# 3. Crea una stanza
TOKEN="il-tuo-access-token"
curl -X POST http://localhost:8000/v1/location/rooms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Soggiorno"}'
```

## Arresto dell'ambiente

```bash
docker compose -f docker/docker-compose.community.local.yml stop        # ferma i container, conserva i dati
docker compose -f docker/docker-compose.community.local.yml down        # rimuove i container, conserva i volumi
docker compose -f docker/docker-compose.community.local.yml down -v     # rimuove tutto, database inclusi ⚠️
```

!!! danger
    `docker compose down -v` elimina tutti i dati locali in modo permanente.

## Risoluzione dei problemi

### Porta già in uso

```bash
lsof -i :8000        # trova cosa sta usando la porta
kill -9 <PID>        # libera la porta
```

In alternativa, cambia la porta lato host nel file compose che stai usando
(es. `"8010:8000"`).

### Il servizio non si avvia

```bash
docker compose -f docker/docker-compose.community.local.yml logs auth-service         # leggi i messaggi di errore
docker compose -f docker/docker-compose.community.local.yml build --no-cache auth-service
docker compose -f docker/docker-compose.community.local.yml up -d auth-service
```

### Connessione al database rifiutata

```bash
docker compose -f docker/docker-compose.community.local.yml ps    # verifica che i container postgres siano in esecuzione
docker compose -f docker/docker-compose.community.local.yml restart jinbocho-postgres-auth jinbocho-postgres-catalog
```

### Variabili d'ambiente non applicate

I file `envs/*.env` vengono letti all'avvio del container. Dopo qualsiasi modifica:

```bash
docker compose -f docker/docker-compose.community.local.yml restart auth-service
```

## Prossimi passi

- **Documentazione API**: `http://localhost:8001/docs` (auth) / `http://localhost:8002/docs` (catalog) / `http://localhost:8003/docs` (ai, solo Pro)
- **Esegui i test**: `cd jinbocho-auth-v1 && pytest tests/ -v`
- **Deploy in produzione**: Vedi **[Deploy in Produzione](07-production-deployment.md)**
