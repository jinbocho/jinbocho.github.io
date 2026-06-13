# Configurazione dell'ambiente di sviluppo locale

Avvia il tuo ambiente di sviluppo locale con Docker Compose in 5 minuti.

## Avvio rapido

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
docker compose up --build -d
```

Fatto. Tutti i servizi backend e i database sono ora in esecuzione. Vai alla sezione **[Verifica](#verifica)** per testare.

## Guida completa alla configurazione

### 1. Preparare la workspace

Se non hai ancora clonato i repository, segui le istruzioni di [Checkout dei repository](01-prerequisites.md#checkout-dei-repository) nella sezione Prerequisiti. Ogni repository si trova nell'organizzazione [jinbocho](https://github.com/jinbocho) su GitHub.

Una volta clonati, spostati nella directory dell'infrastruttura:

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
```

### 2. Configurare le variabili d'ambiente

Ogni servizio ha bisogno di un file `.env`. Usa i template forniti:

```bash
# Auth Service
cp ../jinbocho-auth-v1/.env.example ../jinbocho-auth-v1/.env

# Catalog Service
cp ../jinbocho-catalog-v1/.env.example ../jinbocho-catalog-v1/.env

# API Gateway
cp ../jinbocho-api-gateway-v1/.env.example ../jinbocho-api-gateway-v1/.env

# Frontend (se necessario)
cp ../jinbocho-fe/.env.example ../jinbocho-fe/.env
```

**Variabili d'ambiente principali per lo sviluppo locale**:

| Variabile | Valore | Scopo |
|-----------|--------|------|
| `DEBUG` | `true` | Abilita il logging SQL per vedere tutte le query al database |
| `DATABASE_URL` | `postgresql+asyncpg://postgres:password@postgres:5432/auth_db` | Connessione al DB locale (fornita da Docker Compose) |
| `JWT_SECRET_KEY` | `dev-secret-key-change-in-prod` | **Condivisa** tra tutti i servizi per la validazione JWT |
| `CORS_ORIGINS` | `["http://localhost:5173", "http://localhost:3000"]` | Consente le richieste dal frontend |
| `AUTH_SERVICE_URL` | `http://auth-service:8001` | Indirizzo interno del servizio (rete Docker) |
| `CATALOG_SERVICE_URL` | `http://catalog-service:8002` | Indirizzo interno del servizio |

**Nota**: tutti i file `.env` sono in `.gitignore`. Non commitarli mai.

### 3. Avviare Docker Compose

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
docker compose up --build -d
```

**Spiegazione dei flag**:
- `--build`: ricostruisce le immagini se il Dockerfile è cambiato
- `-d`: esecuzione in background (modalità detached)

**Controlla lo stato**:
```bash
docker compose ps
```

Output atteso:
```
NAME               COMMAND               STATUS           PORTS
auth-service       uvicorn app.main...   Up 5 seconds     0.0.0.0:8001->8000/tcp
catalog-service    uvicorn app.main...   Up 5 seconds     0.0.0.0:8002->8000/tcp
api-gateway        uvicorn app.main...   Up 5 seconds     0.0.0.0:8000->8000/tcp
ai-service         uvicorn app.main...   Up 5 seconds     0.0.0.0:8003->8000/tcp
postgres_auth      postgres -c ...       Up 10 seconds    127.0.0.1:5432->5432/tcp
postgres_catalog   postgres -c ...       Up 10 seconds    127.0.0.1:5433->5432/tcp
postgres_ai        postgres -c ...       Up 10 seconds    127.0.0.1:5434->5432/tcp
```

### 4. Visualizzare i log

**Segui tutti i servizi**:
```bash
docker compose logs -f
```

**Segui un servizio specifico**:
```bash
docker compose logs -f auth-service
```

**Solo i log recenti** (senza coda):
```bash
docker compose logs auth-service
```

Premi `Ctrl+C` per smettere di seguire.

## Mappatura delle porte

| Servizio | Porta | Tipo | Scopo |
|---------|-------|------|------|
| **api-gateway** | `8000` | Pubblica | Punto di ingresso per le richieste del frontend |
| **auth-service** | `8001` | Interna | Gestione utenti/famiglie/JWT |
| **catalog-service** | `8002` | Interna | Libri, posizioni, ricerca ISBN |
| **ai-service** | `8003` | Interna | Tag, deduplicazione, raccomandazioni |
| **postgres (auth)** | `5432` | Interna | Database auth |
| **postgres (catalog)** | `5433` | Interna | Database catalog |
| **postgres (ai)** | `5434` | Interna | Database AI |

**Accedere ai servizi dalla tua macchina**:
- Frontend → Backend: `http://localhost:8000`
- Swagger docs (auth): `http://localhost:8001/docs`
- Swagger docs (catalog): `http://localhost:8002/docs`
- Swagger docs (gateway): `http://localhost:8000/docs`

## Server di sviluppo del frontend

In un nuovo terminale:

```bash
cd ~/workspace/jinbocho/jinbocho-fe
npm ci              # Installa le dipendenze (solo la prima volta)
npm run dev
```

Il frontend si avvierà su `http://localhost:5173` con hot reload abilitato.

### Variabili d'ambiente per il frontend

Modifica `jinbocho-fe/.env`:

```env
VITE_API_BASE_URL=http://localhost:8000
```

Questo dice al frontend dove trovare il backend. In produzione punta all'URL di Render.

## Script di avvio rapido

Avvia backend e frontend con un solo comando:

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
bash dev.sh
```

Questo script:
1. Avvia Docker Compose in background
2. Attende che i servizi siano sani
3. Lancia il server Vite in un nuovo terminale

## Ispezione del database

### Connettiti al database di un servizio

```bash
# Database auth
psql -U postgres -h localhost -p 5432 -d auth_db

# Database catalog
psql -U postgres -h localhost -p 5433 -d catalog_db

# Database AI
psql -U postgres -h localhost -p 5434 -d ai_db
```

### Comandi psql utili

```sql
-- Elenca tutte le tabelle
\dt

-- Mostra la struttura di una tabella
\d users

-- Esegui una query
SELECT * FROM users LIMIT 5;

-- Esci
\q
```

## Verifica

### Health check

```bash
curl http://localhost:8000/health
# Atteso: {"status":"ok"}

curl http://localhost:8001/health
# Atteso: {"status":"ok"}

curl http://localhost:8002/health
# Atteso: {"status":"ok"}
```

### Test di un flusso completo

```bash
# 1. Registra una famiglia/utente
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
  -d '{
    "email": "alice@example.com",
    "password": "SecurePassword123!"
  }'
# Copia l'access_token dalla risposta

# 3. Crea una stanza (usando il token)
TOKEN="il-tuo-access-token"
curl -X POST http://localhost:8000/v1/locations/rooms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Soggiorno"
  }'
```

## Arresto dell'ambiente di sviluppo

**Ferma tutti i servizi** (conserva i dati):
```bash
docker compose stop
```

**Rimuovi i container** (conserva volumi/dati):
```bash
docker compose down
```

**Rimuovi tutto** (database inclusi):
```bash
docker compose down -v
```

⚠️ **Attenzione**: `docker compose down -v` elimina tutti i dati locali. Usalo solo per resettare il database.

## Risoluzione dei problemi

### Porta già in uso

Se la porta 8000 (o un'altra) è già occupata:

```bash
# Trova il processo che usa la porta
lsof -i :8000

# Terminalo (macOS/Linux)
kill -9 <PID>

# Oppure cambia la porta in docker-compose.yml
# Modifica: ports: "8001:8000" (mappa 8001 sull'host a 8000 nel container)
```

### Connessione al database rifiutata

```bash
docker compose ps
# Se i container postgres non sono in esecuzione, riavviali:
docker compose restart postgres_auth postgres_catalog postgres_ai
```

### Il servizio non si avvia

```bash
# Controlla i log per i messaggi di errore
docker compose logs auth-service

# Ricostruisci l'immagine
docker compose build --no-cache auth-service
docker compose up -d auth-service
```

### Variabili d'ambiente non applicate

I file `.env` vengono letti all'avvio del container. Se cambi una variabile:

```bash
# Riavvia il servizio
docker compose restart auth-service
```

## Prossimi passi

- **Esegui i test**: vedi **[Database e Migrazioni](05-database-migrations.md)** per la configurazione dei test
- **Avvia il frontend**: vedi **[Frontend](04-frontend.md)** per i comandi npm
- **Ispeziona il database**: usa i comandi `psql` sopra per connetterti in locale
- **Visualizza la documentazione API**: visita `http://localhost:8001/docs` (Swagger UI di auth-service)