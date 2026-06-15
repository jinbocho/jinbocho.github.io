# Configurazione dell'ambiente di sviluppo locale

Avvia il tuo ambiente di sviluppo locale con Docker Compose in pochi minuti.

## Panoramica

L'edizione Community è composta da tre servizi backend, due database PostgreSQL e un frontend React. Poiché non esiste un repository di infrastruttura condiviso, crei tu stesso un `docker-compose.yml` minimo — risiede nella tua workspace locale e non viene mai committato in nessun repository dei servizi.

## 1. Preparare la workspace

Se non hai ancora clonato i repository, segui le istruzioni di [Checkout dei repository](01-prerequisites.md#checkout-dei-repository).

La tua workspace dovrebbe avere questa struttura:

```
~/workspace/jinbocho/
├── jinbocho-auth-v1/
├── jinbocho-catalog-v1/
├── jinbocho-api-gateway-v1/
├── jinbocho-fe/
└── docker-compose.yml        ← lo creerai ora
```

## 2. Creare docker-compose.yml

In `~/workspace/jinbocho/`, crea `docker-compose.yml` con il seguente contenuto:

```yaml
version: "3.9"

services:

  postgres_auth:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: auth_db
    ports:
      - "127.0.0.1:5432:5432"
    volumes:
      - auth_data:/var/lib/postgresql/data

  postgres_catalog:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: catalog_db
    ports:
      - "127.0.0.1:5433:5432"
    volumes:
      - catalog_data:/var/lib/postgresql/data

  auth-service:
    build:
      context: ./jinbocho-auth-v1
    env_file: ./jinbocho-auth-v1/.env
    ports:
      - "8001:8000"
    depends_on:
      - postgres_auth

  catalog-service:
    build:
      context: ./jinbocho-catalog-v1
    env_file: ./jinbocho-catalog-v1/.env
    ports:
      - "8002:8000"
    depends_on:
      - postgres_catalog
      - auth-service

  api-gateway:
    build:
      context: ./jinbocho-api-gateway-v1
    env_file: ./jinbocho-api-gateway-v1/.env
    ports:
      - "8000:8000"
    depends_on:
      - auth-service
      - catalog-service

volumes:
  auth_data:
  catalog_data:
```

## 3. Configurare le variabili d'ambiente

Ogni servizio ha bisogno di un file `.env`. Copia i template forniti:

```bash
cp jinbocho-auth-v1/.env.example    jinbocho-auth-v1/.env
cp jinbocho-catalog-v1/.env.example jinbocho-catalog-v1/.env
cp jinbocho-api-gateway-v1/.env.example jinbocho-api-gateway-v1/.env
cp jinbocho-fe/.env.example          jinbocho-fe/.env
```

Imposta i seguenti valori. **`JWT_SECRET_KEY` deve essere la stessa stringa in tutti e tre i servizi backend.**

**`jinbocho-auth-v1/.env`:**

```env
DATABASE_URL=postgresql+asyncpg://postgres:postgres@postgres_auth:5432/auth_db
JWT_SECRET_KEY=dev-secret-key-change-in-prod
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=30
DEBUG=true
```

**`jinbocho-catalog-v1/.env`:**

```env
DATABASE_URL=postgresql+asyncpg://postgres:postgres@postgres_catalog:5432/catalog_db
AUTH_SERVICE_URL=http://auth-service:8001
JWT_SECRET_KEY=dev-secret-key-change-in-prod
JWT_ALGORITHM=HS256
GOOGLE_BOOKS_API_KEY=        # facoltativo — lascia vuoto per usare solo Open Library
DEBUG=true
```

**`jinbocho-api-gateway-v1/.env`:**

```env
JWT_SECRET_KEY=dev-secret-key-change-in-prod
JWT_ALGORITHM=HS256
AUTH_SERVICE_URL=http://auth-service:8001
CATALOG_SERVICE_URL=http://catalog-service:8002
CORS_ORIGINS=["http://localhost:5173","http://localhost:3000"]
DEBUG=true
```

**`jinbocho-fe/.env`:**

```env
VITE_API_BASE_URL=http://localhost:8000
```

!!! note "Hostname dei container"
    All'interno di Docker Compose, i servizi comunicano usando i nomi dei servizi come hostname
    (`auth-service`, `catalog-service`, `postgres_auth`, `postgres_catalog`).
    I numeri di porta in `DATABASE_URL` sono le porte **interne** del container (`5432`),
    non le porte mappate sull'host (`5432`/`5433`).

!!! warning "Non committare mai i file .env"
    Tutti i file `.env` sono (e devono rimanere) nel `.gitignore` di ogni repository.

## 4. Avviare Docker Compose

```bash
cd ~/workspace/jinbocho
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
auth-service       uvicorn app.main...   Up               0.0.0.0:8001->8000/tcp
catalog-service    uvicorn app.main...   Up               0.0.0.0:8002->8000/tcp
api-gateway        uvicorn app.main...   Up               0.0.0.0:8000->8000/tcp
postgres_auth      postgres -c ...       Up               127.0.0.1:5432->5432/tcp
postgres_catalog   postgres -c ...       Up               127.0.0.1:5433->5432/tcp
```

**Visualizza i log**:

```bash
docker compose logs -f              # tutti i servizi
docker compose logs -f auth-service # un solo servizio
```

## Mappatura delle porte

| Servizio | Porta host | Tipo | Scopo |
|---------|-----------|------|------|
| **api-gateway** | `8000` | Pubblica | Punto di ingresso per le richieste del frontend |
| **auth-service** | `8001` | Interna | Gestione utenti/famiglie/JWT |
| **catalog-service** | `8002` | Interna | Libri, posizioni, ricerca ISBN |
| **postgres (auth)** | `5432` | Interna | Database auth |
| **postgres (catalog)** | `5433` | Interna | Database catalog |

La Swagger UI è disponibile su:

- Gateway: `http://localhost:8000/docs`
- Auth: `http://localhost:8001/docs`
- Catalog: `http://localhost:8002/docs`

## 5. Avviare il server di sviluppo del frontend

In un nuovo terminale:

```bash
cd ~/workspace/jinbocho/jinbocho-fe
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
```

Password: `postgres` (solo sviluppo locale).

## Verifica

### Health check

```bash
curl http://localhost:8000/health   # {"status":"ok"}
curl http://localhost:8001/health   # {"status":"ok"}
curl http://localhost:8002/health   # {"status":"ok"}
```

### Test di un flusso completo

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
curl -X POST http://localhost:8000/v1/locations/rooms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Soggiorno"}'
```

## Arresto dell'ambiente

```bash
docker compose stop        # ferma i container, conserva i dati
docker compose down        # rimuove i container, conserva i volumi
docker compose down -v     # rimuove tutto, database inclusi ⚠️
```

!!! danger
    `docker compose down -v` elimina tutti i dati locali in modo permanente.

## Risoluzione dei problemi

### Porta già in uso

```bash
lsof -i :8000        # trova cosa sta usando la porta
kill -9 <PID>        # libera la porta
```

In alternativa, cambia la porta lato host in `docker-compose.yml` (es. `"8010:8000"`).

### Il servizio non si avvia

```bash
docker compose logs auth-service         # leggi i messaggi di errore
docker compose build --no-cache auth-service
docker compose up -d auth-service
```

### Connessione al database rifiutata

```bash
docker compose ps    # verifica che i container postgres siano in esecuzione
docker compose restart postgres_auth postgres_catalog
```

### Variabili d'ambiente non applicate

I file `.env` vengono letti all'avvio del container. Dopo qualsiasi modifica:

```bash
docker compose restart auth-service
```

## Prossimi passi

- **Documentazione API**: `http://localhost:8001/docs` (auth) / `http://localhost:8002/docs` (catalog)
- **Esegui i test**: `cd jinbocho-auth-v1 && pytest tests/ -v`
- **Deploy in produzione**: Vedi **[Deploy in Produzione](07-production-deployment.md)**
