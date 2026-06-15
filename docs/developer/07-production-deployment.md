# Production Deployment

Jinbocho runs on **Render** (application services + frontend) and **Neon** (PostgreSQL databases). This combination gives you a fully operational stack at zero cost with the free tiers.

## Architecture on Render

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
             │ Render internal network
    ┌────────┴────────┐
    ▼                 ▼
┌────────┐       ┌────────┐
│ auth   │       │catalog │   Private Services (not reachable from internet)
│:8001   │       │:8002   │
└───┬───┘       └───┬────┘
    │               │
    ▼               ▼
┌─────────┐   ┌──────────┐
│ auth_db │   │catalog_db│   Neon PostgreSQL (external — not on Render)
└─────────┘   └──────────┘
```

**Only two components are public**: the API gateway and the frontend. The two backend services are Private Services — reachable only from within Render's internal network.

## Step 0 — Generate Secrets

```bash
# JWT_SECRET_KEY — must be identical on auth, catalog, and gateway
openssl rand -hex 32
```

Save this value. You will enter it multiple times. Call it `<JWT_SECRET>` in the steps below.

## Step 1 — Create Neon Databases

!!! warning "Do not use Render's built-in PostgreSQL"
    Render's free PostgreSQL is deleted after ~30 days. Use Neon instead — its free tier is persistent and does not expire.

1. Register at [neon.tech](https://neon.tech) → **Create project**
   - Name: `jinbocho`
   - PostgreSQL version: `16`
   - Region: closest to your Render region (e.g. EU-Central for Frankfurt)
2. From the Neon console → **Databases → New Database**, create:
   - `auth_db`
   - `catalog_db`
3. For each database, go to **Connection Details** → copy the connection string

### Adapting the Connection String

Neon provides a connection string like:
```
postgresql://user:password@ep-xxxx.eu-central-1.aws.neon.tech/auth_db?sslmode=require
```

**You must transform it** before using it in Render:

| Change | Reason |
|--------|--------|
| `postgresql://` → `postgresql+asyncpg://` | asyncpg driver |
| `?sslmode=require` → `?ssl=require` | asyncpg does not understand `sslmode` |

Final result:
```
postgresql+asyncpg://user:password@ep-xxxx.eu-central-1.aws.neon.tech/auth_db?ssl=require
```

Do this transformation for each database URL. Keep both URLs private.

## Step 2 — Deploy Backend Services

Deploy in this order: **auth → catalog → gateway**. The gateway needs the internal URLs of the other services.

### auth-service

1. Render Dashboard → **New + → Private Service**
2. Connect repository: `jinbocho-auth-v1`
3. Runtime: **Docker**
4. Region: same as Neon databases
5. Instance Type: **Free** (or Starter to avoid cold starts)
6. Docker Command: **leave empty** (already in Dockerfile)
7. Add environment variables (see table below)
8. **Deploy**
9. After deploy completes: copy the **internal address** shown on the service page (format: `http://jinbocho-auth:8001`). You will need it for catalog and gateway.

**auth-service environment variables:**

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | Neon `auth_db` connection string (transformed) |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` |
| `JWT_ALGORITHM` | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `30` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` |
| `DEBUG` | `false` |
| `PORT` | `8001` |

### catalog-service

1. **New + → Private Service**
2. Repository: `jinbocho-catalog-v1`, Docker, same region
3. Add environment variables (see table below)
4. **Deploy**
5. Copy internal address after deploy.

**catalog-service environment variables:**

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | Neon `catalog_db` connection string (transformed) |
| `AUTH_SERVICE_URL` | Internal address of auth-service (e.g. `http://jinbocho-auth:8001`) |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` — **identical to auth** |
| `JWT_ALGORITHM` | `HS256` |
| `GOOGLE_BOOKS_API_KEY` | Your Google Books API key (get one free) |
| `DEBUG` | `false` |
| `PORT` | `8002` |

### api-gateway

The gateway is the **only public** backend component.

1. **New + → Web Service** (not Private!)
2. Repository: `jinbocho-api-gateway-v1`, Docker, same region
3. Health Check Path: `/health`
4. Add environment variables:

| Variable | Value |
|----------|-------|
| `JWT_SECRET_KEY` | `<JWT_SECRET>` — **identical to auth** |
| `JWT_ALGORITHM` | `HS256` |
| `AUTH_SERVICE_URL` | Internal address of auth-service |
| `CATALOG_SERVICE_URL` | Internal address of catalog-service |
| `AI_SERVICE_URL` | Internal address of ai-service *(omit if not deployed)* |
| `CORS_ORIGINS` | `["https://jinbocho-fe.onrender.com"]` — set after FE is deployed |
| `DEBUG` | `false` |

5. **Deploy** → Render assigns a public URL like `https://jinbocho-api-gateway.onrender.com`.  
   **Save this URL** — it is the `VITE_API_BASE_URL` for the frontend.

## Step 3 — Deploy the Frontend

1. **New + → Static Site**
2. Repository: `jinbocho-fe`
3. Build Command: `npm ci && npm run build`
4. Publish Directory: `dist`
5. Add Redirect/Rewrite Rule: Source `/*` → Destination `/index.html` → Action **Rewrite** (SPA routing)
6. Environment variable:

| Variable | Value |
|----------|-------|
| `VITE_API_BASE_URL` | Public URL of api-gateway (from Step 2) |

7. **Deploy** → Render assigns a public URL like `https://jinbocho-fe.onrender.com`.

## Step 4 — Close the URL Loop

There is a circular dependency between the gateway (which needs the frontend URL for CORS) and the frontend (which needs the gateway URL for API calls). Resolve it now:

1. Go to **api-gateway** on Render → **Environment**
2. Set `CORS_ORIGINS` to the frontend URL: `["https://jinbocho-fe.onrender.com"]`
3. Click **Save Changes** → Render triggers an automatic redeploy
4. Wait for the redeploy to complete

## Step 5 — Verify the Deployment

Run these checks after all services are live:

```bash
GW=https://jinbocho-api-gateway.onrender.com

# 1. Gateway health
curl $GW/health
# Expected: {"status":"ok"}

# 2. Register a test family
curl -X POST $GW/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"family_name":"Test Family","full_name":"Alice","email":"alice@test.com","password":"Password123!"}'

# 3. Login and get a token
curl -X POST $GW/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@test.com","password":"Password123!"}'
# Copy access_token from response

# 4. Test ISBN lookup
TOKEN="your-access-token"
curl "$GW/v1/records/isbn-lookup?isbn=9788845292613" \
  -H "Authorization: Bearer $TOKEN"
```

**Full verification checklist:**

- [ ] `GET /health` returns `{"status":"ok"}`
- [ ] Alembic migrations applied (check auth and catalog service logs: look for `alembic upgrade head` success)
- [ ] POST `/v1/auth/register` returns `{ family_id, user_id }`
- [ ] POST `/v1/auth/login` returns `{ access_token, refresh_token }`
- [ ] Frontend loads at the Render static site URL
- [ ] Login from the frontend works
- [ ] ISBN lookup returns metadata (Google Books key is set)
- [ ] No CORS errors in browser developer console

## Costs and Free Tier Limits

| Component | Provider | Cost | Limits |
|-----------|----------|------|--------|
| `auth_db`, `catalog_db` | Neon free | €0 | 0.5 GB each, no expiry |
| `auth-service`, `catalog-service` | Render free | €0 | Cold start after 15 min idle (~30-60s) |
| `api-gateway` | Render free | €0 | Cold start after 15 min idle |
| `jinbocho-fe` | Render Static Site | €0 | No cold start (CDN) |
| Total | — | **€0/month** | Cold starts acceptable for home use |

To eliminate cold starts, upgrade to Render Starter ($7/month per service). The databases remain free on Neon regardless.

!!! tip "Keep services in the same region"
    Render Private Services can only communicate within the same region. Always deploy auth, catalog, and gateway in the same region. Choose the Neon region closest to that Render region to minimize database latency.
