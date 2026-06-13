# Production Deployment

Jinbocho runs on **Render** (application services + frontend) and **Neon** (PostgreSQL databases).

## Architecture on Render

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│  jinbocho-fe  (Render Static Site)      │  https://jinbocho-fe.onrender.com
└──────────────────────┬─────────────────┘
                       │ HTTPS
                       ▼
┌─────────────────────────────────────────┐
│  jinbocho-api-gateway  (Web Service)    │  https://jinbocho-api-gateway.onrender.com
└───────────┬──────────────────────────────┘
             │ Render internal network
    ┌────────┼────────┐
    ▼        ▼        ▼
┌────────┐ ┌────────┐ ┌────────┐
│ auth   │ │catalog │ │  ai   │  Private Services
│:8001   │ │:8002   │ │:8003   │
└───┬────┘ └───┬────┘ └────────┘
    │           │
    ▼           ▼
┌─────────┐ ┌──────────┐
│ auth_db │ │catalog_db│   Neon PostgreSQL
└─────────┘ └──────────┘
```

## Step 0 — Generate Secrets

```bash
openssl rand -hex 32
```

Save this value as `<JWT_SECRET>` — you will enter it multiple times.

## Step 1 — Create Neon Databases

!!! warning "Do not use Render's built-in PostgreSQL"
    Render's free PostgreSQL is deleted after ~30 days. Use Neon instead.

1. Register at [neon.tech](https://neon.tech) → **Create project** (name: `jinbocho`, PostgreSQL 16)
2. Create databases: `auth_db`, `catalog_db`, `ai_db` (optional)
3. For each: copy connection string and transform it:

```
# Neon default:
postgresql://user:password@ep-xxxx.neon.tech/auth_db?sslmode=require

# Required for asyncpg:
postgresql+asyncpg://user:password@ep-xxxx.neon.tech/auth_db?ssl=require
```

## Step 2 — Deploy Backend Services

Deploy in order: **auth → catalog → (ai) → gateway**.

### auth-service

Render → **New + → Private Service** → Docker → env vars:

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | Neon `auth_db` connection string |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` |
| `JWT_ALGORITHM` | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `30` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` |
| `DEBUG` | `false` |
| `PORT` | `8001` |

### catalog-service

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | Neon `catalog_db` connection string |
| `AUTH_SERVICE_URL` | Internal address of auth-service |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` |
| `GOOGLE_BOOKS_API_KEY` | Your Google Books API key |
| `DEBUG` | `false` |
| `PORT` | `8002` |

### api-gateway

Render → **New + → Web Service** (not Private!)

| Variable | Value |
|----------|-------|
| `JWT_SECRET_KEY` | `<JWT_SECRET>` |
| `AUTH_SERVICE_URL` | Internal address of auth-service |
| `CATALOG_SERVICE_URL` | Internal address of catalog-service |
| `CORS_ORIGINS` | `["https://jinbocho-fe.onrender.com"]` |
| `DEBUG` | `false` |

## Step 3 — Deploy the Frontend

Render → **New + → Static Site**
- Build Command: `npm ci && npm run build`
- Publish Directory: `dist`
- Redirect/Rewrite: `/*` → `/index.html` (Rewrite)
- `VITE_API_BASE_URL`: Public URL of api-gateway

## Step 4 — Close the URL Loop

Update `CORS_ORIGINS` on api-gateway to the actual frontend URL, then redeploy.

## Step 5 — Verify

```bash
GW=https://jinbocho-api-gateway.onrender.com
curl $GW/health
curl -X POST $GW/v1/auth/register -H "Content-Type: application/json" \
  -d '{"family_name":"Test","full_name":"Alice","email":"alice@test.com","password":"Password123!"}'
```

## Costs

| Component | Cost | Notes |
|-----------|------|-------|
| Neon databases | €0 | 0.5 GB each, persistent |
| Render services (free) | €0 | Cold starts after 15 min |
| Render services (Starter) | $7/mo/service | No cold starts |
