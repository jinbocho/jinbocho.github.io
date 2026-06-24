# Local Development Setup

Get your local development environment running with Docker Compose in a few minutes.

## Overview

The Jinbocho backend ships as a separate orchestration repository,
[`jinbocho-infrastructure-v1`](https://github.com/jinbocho/jinbocho-infrastructure-v1). No
application code lives there — it only contains Docker Compose files, env
templates, and the VPS/Render deploy tooling for the `auth`, `catalog`,
`api-gateway`, and optional `ai` services.

There are five Compose files, picked depending on which images you want to run
and whether the AI module (Pro edition) is enabled:

| File | Images | Edition | Use case |
|---|---|---|---|
| `docker/docker-compose.community.yml` | GHCR (pre-built) | Community | Self-host, no source checkout |
| `docker/docker-compose.pro.yml` | GHCR (pre-built) | Pro | Self-host with AI module |
| `docker/docker-compose.community.local.yml` | Built from `../jinbocho-*-v1` | Community | Local dev from source |
| `docker/docker-compose.pro.local.yml` | Built from `../jinbocho-*-v1` | Pro | Local dev from source — used by `./scripts/dev.sh` |
| `docker/docker-compose.all.yml` | GHCR backend + locally-built frontend | Either (`COMPOSE_PROFILES=pro`) | Single-server VPS deploy, includes Caddy + TLS |

This chapter covers **local development from source** (`*.local.yml`). For
self-hosting with pre-built images or a one-shot VPS install, see
[Production Deployment](07-production-deployment.md).

## 1. Set Up the Workspace

If you haven't cloned the repositories yet, follow [Repositories Checkout](01-prerequisites.md#repositories-checkout).

`jinbocho-infrastructure-v1` expects the service repos checked out as
siblings:

```
~/workspace/jinbocho/
├── jinbocho-infrastructure-v1/
├── jinbocho-auth-v1/
├── jinbocho-catalog-v1/
├── jinbocho-api-gateway-v1/
├── jinbocho-ai-v1/            ← only needed for the Pro edition
└── jinbocho-fe/
```

## 2. Configure Environment Variables

From `jinbocho-infrastructure-v1/`, copy the root `.env` and the per-service
templates from `envs/`:

```bash
cd jinbocho-infrastructure-v1

cp .env.example .env
cp envs/auth-service.env.example    envs/auth-service.env
cp envs/catalog-service.env.example envs/catalog-service.env
cp envs/api-gateway.env.example     envs/api-gateway.env
```

Variables not listed below already have a working default in the matching
`*.example` file — you don't need to touch them for local dev.

**`.env`** (repo root — read by Docker Compose itself):

| Variable | Default | Required | Description |
|---|---|---|---|
| `POSTGRES_PASSWORD` | `change_me_local_dev` | Always | Password for the local Postgres containers |
| `JINBOCHO_VERSION` | `latest` | No | GHCR image tag (only used by the non-`.local` compose files) |
| `COMPOSE_PROFILES` | unset | No | Set to `pro` on `docker-compose.all.yml` to also start `postgres-ai` + `ai-service` |

**`envs/auth-service.env`** — key variables:

| Variable | Default | Required | Description |
|---|---|---|---|
| `DATABASE_URL` | points at `jinbocho-postgres-auth:5432/auth_db` | Yes | Must match `POSTGRES_PASSWORD` from root `.env` |
| `JWT_SECRET_KEY` | — | **Yes** | Must be **identical** across `auth-service`, `catalog-service`, `api-gateway`. Generate with `openssl rand -hex 32` |
| `FRONTEND_BASE_URL` | `http://localhost:5173` | No | Used to build links in invite/reset-password emails |
| `SMTP_HOST` / `SMTP_PORT` / `SMTP_USER` / `SMTP_PASSWORD` / `EMAIL_FROM` | — | No | Leave `SMTP_USER` empty to print reset/invite links to the logs instead of sending real email |

**`envs/catalog-service.env`** — key variables:

| Variable | Default | Required | Description |
|---|---|---|---|
| `DATABASE_URL` | points at `jinbocho-postgres-catalog:5432/catalog_db` | Yes | Must match `POSTGRES_PASSWORD` from root `.env` |
| `JWT_SECRET_KEY` | — | **Yes** | Must match `auth-service`'s value |
| `GOOGLE_BOOKS_API_KEY` | — | Recommended | Free key from the Google Books API; without it the shared quota (1000 req/day) is exhausted quickly |

**`envs/api-gateway.env`** — key variables:

| Variable | Default | Required | Description |
|---|---|---|---|
| `JWT_SECRET_KEY` | — | **Yes** | Must match `auth-service`'s value |
| `AUTH_SERVICE_URL` / `CATALOG_SERVICE_URL` / `AI_SERVICE_URL` | internal Docker hostnames | No | Leave as-is for local dev |
| `CORS_ORIGINS` | `["*"]` | No | Set to your frontend URL in production |
| `JINBOCHO_FEATURES` | `catalog,auth` | No | Comma-separated enabled modules. Add `ai` only for the Pro edition |

For the Pro edition, also copy `envs/ai-service.env.example` and see
[Backend Services](03-backend-services.md#ai-service-port-8003-pro-edition-only) for its variables.

!!! warning "Never commit .env files"
    All `.env` files under `jinbocho-infrastructure-v1/` are (and must remain) gitignored.

## 3. Start the Stack

From `jinbocho-infrastructure-v1/`:

```bash
# Community edition (no AI module):
docker compose -f docker/docker-compose.community.local.yml up --build -d

# Pro edition (with AI module):
docker compose -f docker/docker-compose.pro.local.yml up --build -d
```

**Check status**:

```bash
docker compose -f docker/docker-compose.community.local.yml ps
```

**Tail logs**:

```bash
docker compose -f docker/docker-compose.community.local.yml logs -f              # all services
docker compose -f docker/docker-compose.community.local.yml logs -f auth-service # one service only
```

Swagger UI is available at:

- Gateway: `http://localhost:8000/docs`
- Auth: `http://localhost:8001/docs`
- Catalog: `http://localhost:8002/docs`
- AI (Pro only): `http://localhost:8003/docs`

## 4. Start Backend + Frontend Together

`./scripts/dev.sh` brings up the Pro local Compose stack and then starts the
frontend dev server in the same terminal:

```bash
cd jinbocho-infrastructure-v1
./scripts/dev.sh
```

It is equivalent to running `docker compose -f docker/docker-compose.pro.local.yml up --build -d`
followed by `npm run dev` in `jinbocho-fe/`.

To start the frontend on its own, in a new terminal:

```bash
cd jinbocho-fe
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

# AI database (Pro edition only)
psql -U postgres -h 127.0.0.1 -p 5434 -d ai_db
```

Password: the value of `POSTGRES_PASSWORD` from `jinbocho-infrastructure-v1/.env`
(`change_me_local_dev` by default).

## Verification

### Health Checks

```bash
curl http://localhost:8000/health   # {"status":"ok"}
curl http://localhost:8001/health   # {"status":"ok"}
curl http://localhost:8002/health   # {"status":"ok"}
curl http://localhost:8003/health   # {"status":"ok"}  — Pro edition only
```

### Smoke-Test the Whole Stack

`jinbocho-infrastructure-v1` ships a script that registers a test family and
exercises the main endpoints through the gateway:

```bash
cd jinbocho-infrastructure-v1
./scripts/validate-api.sh
```

### Test a Full Flow Manually

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
curl -X POST http://localhost:8000/v1/location/rooms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Living Room"}'
```

## Stopping the Environment

```bash
docker compose -f docker/docker-compose.community.local.yml stop        # stop containers, keep data
docker compose -f docker/docker-compose.community.local.yml down        # remove containers, keep volumes
docker compose -f docker/docker-compose.community.local.yml down -v     # remove everything including databases ⚠️
```

!!! danger
    `docker compose down -v` deletes all local data permanently.

## Troubleshooting

### Port Already in Use

```bash
lsof -i :8000        # find what is using the port
kill -9 <PID>        # free the port
```

Alternatively, change the host-side port in the compose file you're using
(e.g. `"8010:8000"`).

### Service Won't Start

```bash
docker compose -f docker/docker-compose.community.local.yml logs auth-service         # read error messages
docker compose -f docker/docker-compose.community.local.yml build --no-cache auth-service
docker compose -f docker/docker-compose.community.local.yml up -d auth-service
```

### Database Connection Refused

```bash
docker compose -f docker/docker-compose.community.local.yml ps    # check postgres containers are running
docker compose -f docker/docker-compose.community.local.yml restart jinbocho-postgres-auth jinbocho-postgres-catalog
```

### Environment Variables Not Applied

`envs/*.env` files are read at container startup. After any change:

```bash
docker compose -f docker/docker-compose.community.local.yml restart auth-service
```

## Next Steps

- **View API docs**: `http://localhost:8001/docs` (auth) / `http://localhost:8002/docs` (catalog) / `http://localhost:8003/docs` (ai, Pro only)
- **Run tests**: `cd jinbocho-auth-v1 && pytest tests/ -v`
- **Deploy to production**: See **[Production Deployment](07-production-deployment.md)**
