# Local Development Setup

Get your local development environment running with Docker Compose in a few minutes.

## Overview

The Community edition consists of three backend services, two PostgreSQL databases, and one React frontend. Because there is no shared infrastructure repository, you create a minimal `docker-compose.yml` yourself — it lives in your local workspace and is never committed to any service repo.

## 1. Set Up the Workspace

If you haven't cloned the repositories yet, follow [Repositories Checkout](01-prerequisites.md#repositories-checkout).

Your workspace should look like this:

```
~/workspace/jinbocho/
├── jinbocho-auth-v1/
├── jinbocho-catalog-v1/
├── jinbocho-api-gateway-v1/
├── jinbocho-fe/
└── docker-compose.yml        ← you will create this now
```

## 2. Create docker-compose.yml

In `~/workspace/jinbocho/`, create `docker-compose.yml` with the following content:

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

## 3. Configure Environment Variables

Each service needs a `.env` file. Copy the provided templates:

```bash
cp jinbocho-auth-v1/.env.example    jinbocho-auth-v1/.env
cp jinbocho-catalog-v1/.env.example jinbocho-catalog-v1/.env
cp jinbocho-api-gateway-v1/.env.example jinbocho-api-gateway-v1/.env
cp jinbocho-fe/.env.example          jinbocho-fe/.env
```

Then set the following values. **`JWT_SECRET_KEY` must be the same string in all three backend services.**

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
GOOGLE_BOOKS_API_KEY=        # optional — leave empty to rely on Open Library only
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

!!! note "Container hostnames"
    Inside Docker Compose, services communicate using their service names as hostnames
    (`auth-service`, `catalog-service`, `postgres_auth`, `postgres_catalog`).
    The port numbers in `DATABASE_URL` are the **internal** container ports (`5432`),
    not the host-mapped ports (`5432`/`5433`).

!!! warning "Never commit .env files"
    All `.env` files are (and must remain) in each repo's `.gitignore`.

## 4. Start Docker Compose

```bash
cd ~/workspace/jinbocho
docker compose up --build -d
```

**Flags explained**:

- `--build`: Rebuild images if any Dockerfile changed
- `-d`: Run in background (detached mode)

**Check status**:

```bash
docker compose ps
```

Expected output:

```
NAME               COMMAND               STATUS           PORTS
auth-service       uvicorn app.main...   Up               0.0.0.0:8001->8000/tcp
catalog-service    uvicorn app.main...   Up               0.0.0.0:8002->8000/tcp
api-gateway        uvicorn app.main...   Up               0.0.0.0:8000->8000/tcp
postgres_auth      postgres -c ...       Up               127.0.0.1:5432->5432/tcp
postgres_catalog   postgres -c ...       Up               127.0.0.1:5433->5432/tcp
```

**Tail logs**:

```bash
docker compose logs -f              # all services
docker compose logs -f auth-service # one service only
```

## Port Mapping

| Service | Host Port | Type | Purpose |
|---------|-----------|------|--------|
| **api-gateway** | `8000` | Public | Entry point for frontend requests |
| **auth-service** | `8001` | Internal | User / family / JWT management |
| **catalog-service** | `8002` | Internal | Books, locations, ISBN lookup |
| **postgres (auth)** | `5432` | Internal | Auth database |
| **postgres (catalog)** | `5433` | Internal | Catalog database |

Swagger UI is available at:

- Gateway: `http://localhost:8000/docs`
- Auth: `http://localhost:8001/docs`
- Catalog: `http://localhost:8002/docs`

## 5. Start the Frontend Dev Server

In a new terminal:

```bash
cd ~/workspace/jinbocho/jinbocho-fe
npm ci          # Install dependencies (first time only)
npm run dev
```

The frontend starts on `http://localhost:5173` with hot reload.

## Database Inspection

```bash
# Auth database
psql -U postgres -h 127.0.0.1 -p 5432 -d auth_db

# Catalog database
psql -U postgres -h 127.0.0.1 -p 5433 -d catalog_db
```

Password: `postgres` (local dev only).

## Verification

### Health Checks

```bash
curl http://localhost:8000/health   # {"status":"ok"}
curl http://localhost:8001/health   # {"status":"ok"}
curl http://localhost:8002/health   # {"status":"ok"}
```

### Test a Full Flow

```bash
# 1. Register a family
curl -X POST http://localhost:8000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "family_name": "Test Family",
    "user_name": "Alice",
    "email": "alice@example.com",
    "password": "SecurePassword123!"
  }'

# 2. Login
curl -X POST http://localhost:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"SecurePassword123!"}'
# Copy the access_token from the response

# 3. Create a room
TOKEN="your-access-token-here"
curl -X POST http://localhost:8000/v1/locations/rooms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Living Room"}'
```

## Stopping the Environment

```bash
docker compose stop        # stop containers, keep data
docker compose down        # remove containers, keep volumes
docker compose down -v     # remove everything including databases ⚠️
```

!!! danger
    `docker compose down -v` deletes all local data permanently.

## Troubleshooting

### Port Already in Use

```bash
lsof -i :8000        # find what is using the port
kill -9 <PID>        # free the port
```

Alternatively, change the host-side port in `docker-compose.yml` (e.g. `"8010:8000"`).

### Service Won't Start

```bash
docker compose logs auth-service         # read error messages
docker compose build --no-cache auth-service
docker compose up -d auth-service
```

### Database Connection Refused

```bash
docker compose ps    # check postgres containers are running
docker compose restart postgres_auth postgres_catalog
```

### Environment Variables Not Applied

`.env` files are read at container startup. After any change:

```bash
docker compose restart auth-service
```

## Next Steps

- **View API docs**: `http://localhost:8001/docs` (auth) / `http://localhost:8002/docs` (catalog)
- **Run tests**: `cd jinbocho-auth-v1 && pytest tests/ -v`
- **Deploy to production**: See **[Production Deployment](07-production-deployment.md)**
