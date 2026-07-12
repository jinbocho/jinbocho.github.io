# Production Deployment

Jinbocho has two deployment paths. Both are documented below, each starting with
the fastest way to get a working stack, followed by the fully manual,
step-by-step version for when you want to understand or control every piece.

All deployment tooling (compose files, env templates, scripts) lives in the
sibling repo `jinbocho-infrastructure-community-v1` — both sections below pull
from it.

| | **Self-hosted VPS** | **Render + Neon** |
|---|---|---|
| Cost | Price of the VPS only (~€4-6/month) | €0 on free tiers |
| Setup | One command | Click-ops or one-shot Blueprint |
| Maintenance | You patch and manage the box | Fully managed |
| Cold starts | None | Free tier sleeps after 15 min idle |
| TLS | Automatic (Caddy + Let's Encrypt) | Automatic (Render) |
| Best for | Full control, existing VPS, no cold starts | Zero-ops, fastest to try, no server to manage |

Pick one — you don't need both.

## Self-hosted VPS deploy

### Quick start

One command turns a fresh Debian/Ubuntu VPS into a fully running Jinbocho
stack: Postgres ×2, the three backend services, the frontend, and Caddy as a
reverse proxy with automatic HTTPS.

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-v1.git
cd jinbocho-infrastructure-v1

sudo ./scripts/setup-vps-community.sh \
  --domain library.example.com \
  --email you@example.com \
  --google-books-key AIza...
```

Requirements:

- A fresh **Debian/Ubuntu VPS** with a public IP, run as `root` (or via `sudo`).
- `--domain` must **already resolve** to the server's IP — Caddy requests a
  Let's Encrypt certificate for it on first start. Omit `--domain`/`--email`
  entirely to serve over plain HTTP on the bare IP instead (no TLS).
- Any option not passed as a flag is asked interactively. Add
  `--non-interactive` to skip every prompt and rely only on flags/defaults —
  useful for unattended installs (e.g. cloud-init).

Within a couple of minutes the script prints the frontend URL, the API
gateway URL, and where secrets were written. Open the frontend and register
the first family — it becomes the admin account.

!!! tip "Re-running is safe"
    The script is idempotent: existing secrets, `envs/*.env` files, and the
    generated `Caddyfile` are kept as-is on a second run, unless you delete
    them first.

### What the script does

`scripts/setup-vps-community.sh` runs `docker/docker-compose.all.yml`
end-to-end:

1. Installs Docker (via `get.docker.com`) if it isn't already present.
2. Optionally configures `ufw` to open 22/80/443 (`--enable-firewall`).
3. Clones (or updates) `jinbocho-fe` next to the infrastructure repo.
4. Generates `POSTGRES_PASSWORD`, `JWT_SECRET_KEY`, and
   `INTERNAL_SERVICE_TOKEN`, and writes every `envs/*.env` file from the
   `*.example` templates.
5. Writes a `Caddyfile` that reverse-proxies `/api/*` to the gateway and
   everything else to the frontend, with automatic TLS if `--domain` was set.
6. Pulls the backend images from GHCR, builds the frontend image from
   source, and brings the whole stack up with `docker compose ... up -d`.
7. Polls `/health` through the gateway and reports whether the stack came up
   cleanly.

### All script options

| Flag | Value | Default | Description |
|---|---|---|---|
| `--domain` | `<fqdn>` | — (uses server IP, HTTP only) | Public domain already pointed at this server. Enables automatic HTTPS. |
| `--email` | `<email>` | — | Let's Encrypt contact email. **Required** if `--domain` is set. |
| `--google-books-key` | `<key>` | — | Google Books API key, used for catalog ISBN lookups. Can be added later by editing `envs/catalog-service.env`. |
| `--smtp-user` | `<gmail address>` | — | Gmail address used to send invite/reset-password emails. SMTP host/port are set automatically. Leave unset to fall back to logging the link instead of sending it. |
| `--smtp-password` | `<app password>` | — | Gmail [App Password](https://myaccount.google.com/apppasswords) for `--smtp-user` — not your normal account password. |
| `--email-from` | `<email>` | value of `--smtp-user` | From-address shown on outgoing emails. |
| `--grafana-enabled` | `true`\|`false` | asked interactively | Ship metrics/logs/traces to Grafana Cloud via the built-in Alloy collector (ADR-012). Optional, off by default. |
| `--grafana-otlp-endpoint` | `<url>` | Grafana's EU-West-2 gateway | OTLP endpoint from Grafana Cloud → Connections → OpenTelemetry. |
| `--grafana-otlp-instance-id` | `<id>` | — | Instance ID from the same Grafana Cloud page. Required if `--grafana-enabled true`. |
| `--grafana-otlp-api-token` | `<token>` | — | API token from the same Grafana Cloud page. Required if `--grafana-enabled true`. |
| `--frontend-base-url` | `<url>` | derived from `--domain`/server IP | Public frontend URL baked into email links. |
| `--fe-repo` | `<git url>` | `jinbocho/jinbocho-fe` | Frontend repository to clone. |
| `--fe-branch` | `<branch>` | `main` | Frontend branch to clone. |
| `--version` | `<tag>` | `latest` | GHCR image tag to pull for the backend services. |
| `--enable-firewall` | flag | off | Configure and enable `ufw`, opening 22/80/443. |
| `--skip-docker-install` | flag | off | Don't attempt to install Docker (use if it's already provisioned by other tooling). |
| `--non-interactive` | flag | off | Never prompt; use only the flags/defaults given. |
| `-h`, `--help` | flag | — | Print the full flag list and exit. |

### Verifying the deployment

```bash
./scripts/validate-api.sh
```

This registers a test family and exercises the main endpoints through the
gateway (`http://localhost:8000`, or your domain), the same smoke test used
on Render (see [Step 5](#step-5-verify-the-deployment) below).

Useful day-2 commands (the script prints the exact invocation for your setup,
including `--profile observability` if Grafana is enabled):

```bash
docker compose -f docker/docker-compose.all.yml --env-file .env logs -f   # tail logs
docker compose -f docker/docker-compose.all.yml --env-file .env ps        # service status
docker compose -f docker/docker-compose.all.yml --env-file .env down      # stop (volumes/data kept)
```

### Manual install (no installer script)

If you'd rather not run the automated script — for example to review every
file before it's written, or because you already manage TLS with your own
reverse proxy — install piece by piece with `docker-compose.community.yml`
instead:

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-v1.git
cd jinbocho-infrastructure-v1

cp .env.example .env
cp envs/auth-service.env.example envs/auth-service.env
cp envs/catalog-service.env.example envs/catalog-service.env
cp envs/api-gateway.env.example envs/api-gateway.env

# edit the files above — see the field tables below

docker compose -f docker/docker-compose.community.yml up -d
```

!!! warning "No TLS or reverse proxy in this mode"
    Unlike the one-shot script, `docker-compose.community.yml` does not run
    Caddy. The gateway is exposed directly on port `8000`. Put your own
    reverse proxy (Caddy, nginx, Traefik, a load balancer) in front of it if
    you need HTTPS or a domain name.

**`.env` (repo root, read by Docker Compose itself):**

| Variable | Default | Required | Description |
|---|---|---|---|
| `POSTGRES_PASSWORD` | `change_me_local_dev` | Yes | Password for the local Postgres containers. Change it before exposing anything publicly. |
| `JINBOCHO_VERSION` | `latest` | No | GHCR image tag to pull for the backend services. |

**`envs/auth-service.env`:**

| Variable | Required | Description |
|---|---|---|
| `DEBUG` | No | Set `false` in production; `true` also enables SQL logging. |
| `DATABASE_URL` | Yes | Must point at `jinbocho-postgres-auth` and match `POSTGRES_PASSWORD` from the root `.env`. |
| `JWT_SECRET_KEY` | **Yes** | Must be **identical** across `auth-service`, `catalog-service`, and `api-gateway`. Generate with `openssl rand -hex 32`. |
| `INTERNAL_SERVICE_TOKEN` | **Yes** | Must match `catalog-service`'s value — authenticates catalog→auth calls (loan reminder emails). Generate with `openssl rand -hex 32`. |
| `FRONTEND_BASE_URL` | No | Used to build links in invite/reset-password emails. |
| `SMTP_USER` / `SMTP_PASSWORD` | No | Leave empty to print invite/reset links to logs instead of emailing them. |

**`envs/catalog-service.env`:**

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | Yes | Must point at `jinbocho-postgres-catalog` and match `POSTGRES_PASSWORD`. |
| `JWT_SECRET_KEY` | **Yes** | Identical to `auth-service`'s value. |
| `INTERNAL_SERVICE_TOKEN` | **Yes** | Identical to `auth-service`'s value. |
| `GOOGLE_BOOKS_API_KEY` | Recommended | Free key at [console.cloud.google.com](https://console.cloud.google.com/). Without it the shared quota (1000 req/day) is exhausted quickly. |

**`envs/api-gateway.env`:**

| Variable | Required | Description |
|---|---|---|
| `JWT_SECRET_KEY` | **Yes** | Identical to `auth-service`'s value. |
| `CORS_ORIGINS` | No | `["*"]` by default — set to your frontend's real URL in production. |

Open `http://<server-ip>:8000/docs` to confirm the gateway is up, then
proceed as in [Verifying the deployment](#verifying-the-deployment) above.

### Optional: metrics & logs (Grafana Cloud)

Off by default — skip this if you don't need it, the stack works exactly as
described above without it. When enabled (`--grafana-enabled true`, or by
hand later), a local Grafana Alloy collector scrapes `/metrics`, receives
OTLP traces, tails container logs, and forwards all three to Grafana Cloud
over one OTLP connection. See `README.md` (section 6) in
`jinbocho-infrastructure-community-v1` for the full setup, and the ADR-012
document in `jinbocho-docs/architecture/adr/` for the rationale.

## Render + Neon deploy

### Quick start — Render Blueprint (IaC)

The fastest way onto Render: deploy the whole stack in one pass with the
Render Blueprint at `jinbocho-infrastructure-community-v1/render.yaml`,
instead of clicking through the manual walkthrough below by hand.

1. Fork/clone `jinbocho-auth-v1`, `jinbocho-catalog-v1`,
   `jinbocho-api-gateway-v1`, `jinbocho-fe` under your own GitHub account or
   org, and replace every `CHANGEME` placeholder in `render.yaml` with that
   account.
2. Render Dashboard → **New + → Blueprint** → point it at your fork of
   `jinbocho-infrastructure-community-v1`.
3. Render creates all four services in one go: `jinbocho-auth` and
   `jinbocho-catalog` as Private Services (`type: pserv`, not reachable from
   the internet — defense in depth), `jinbocho-api-gateway` as the only
   public Web Service, and `jinbocho-fe` as a static site.
4. `JWT_SECRET_KEY`, `JWT_ALGORITHM`, `JWT_ISSUER`, `JWT_AUDIENCE` are defined
   once in the shared `jinbocho-jwt` env var group and injected into auth,
   catalog, and gateway — you only set `JWT_SECRET_KEY` once.
5. Every `sync: false` variable (`DATABASE_URL` for auth/catalog,
   `GOOGLE_BOOKS_API_KEY`, `CORS_ORIGINS`, `VITE_API_BASE_URL`, the
   auth-service SMTP variables, `FRONTEND_BASE_URL`) is **not stored in
   git** — Render prompts you for each on first deploy.
6. There's a circular dependency between the gateway (which needs the
   frontend URL for CORS) and the frontend (which needs the gateway URL for
   API calls) — same as [Step 4](#step-4-close-the-url-loop) below: deploy
   once, then fill in `CORS_ORIGINS` (gateway) and `VITE_API_BASE_URL`
   (frontend) once you know each other's public URL, and redeploy those two
   services.
7. Private Services (`pserv`) require a paid Render plan (~$7/mo each). To
   stay on the free tier at the cost of exposing auth/catalog publicly,
   change their `type` from `pserv` to `web` in your fork of `render.yaml` —
   they remain protected by JWT validation either way.

See `RENDER_DEPLOYMENT.md` in `jinbocho-infrastructure-community-v1` for the
fully worked example with sample values.

### Architecture on Render

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

**Only two components are public**: the API gateway and the frontend. The two
backend services are Private Services — reachable only from within Render's
internal network.

### Manual walkthrough (Step 0 – Step 5)

Prefer full manual control, or want to understand exactly what the Blueprint
above automates? Follow these steps by hand — same result, zero cost on the
free tiers.

#### Step 0 — Generate secrets

```bash
# JWT_SECRET_KEY — must be identical on auth, catalog, and gateway
openssl rand -hex 32
```

Save this value. You will enter it multiple times. Call it `<JWT_SECRET>` in
the steps below.

#### Step 1 — Create Neon databases

!!! warning "Do not use Render's built-in PostgreSQL"
    Render's free PostgreSQL is deleted after ~30 days. Use Neon instead —
    its free tier is persistent and does not expire.

1. Register at [neon.tech](https://neon.tech) → **Create project**
   - Name: `jinbocho`
   - PostgreSQL version: `16`
   - Region: closest to your Render region (e.g. EU-Central for Frankfurt)
2. From the Neon console → **Databases → New Database**, create:
   - `auth_db`
   - `catalog_db`
3. For each database, go to **Connection Details** → copy the connection
   string.

**Adapting the connection string** — Neon provides a string like:

```
postgresql://user:password@ep-xxxx.eu-central-1.aws.neon.tech/auth_db?sslmode=require
```

You must transform it before using it in Render:

| Change | Reason |
|--------|--------|
| `postgresql://` → `postgresql+asyncpg://` | asyncpg driver |
| `?sslmode=require` → `?ssl=require` | asyncpg does not understand `sslmode` |

Final result:

```
postgresql+asyncpg://user:password@ep-xxxx.eu-central-1.aws.neon.tech/auth_db?ssl=require
```

Do this transformation for each database URL. Keep both URLs private.

#### Step 2 — Deploy backend services

Deploy in this order: **auth → catalog → gateway**. The gateway needs the
internal URLs of the other services.

**auth-service:**

1. Render Dashboard → **New + → Private Service**
2. Connect repository: `jinbocho-auth-v1`
3. Runtime: **Docker**
4. Region: same as Neon databases
5. Instance Type: **Free** (or Starter to avoid cold starts)
6. Docker Command: **leave empty** (already in Dockerfile)
7. Add environment variables (see table below)
8. **Deploy**
9. After deploy completes: copy the **internal address** shown on the
   service page (format: `http://jinbocho-auth:8001`). You will need it for
   catalog and gateway.

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | Neon `auth_db` connection string (transformed) |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` |
| `JWT_ALGORITHM` | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `30` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` |
| `DEBUG` | `false` |
| `PORT` | `8001` |

**catalog-service:**

1. **New + → Private Service**
2. Repository: `jinbocho-catalog-v1`, Docker, same region
3. Add environment variables (see table below)
4. **Deploy**
5. Copy internal address after deploy.

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | Neon `catalog_db` connection string (transformed) |
| `AUTH_SERVICE_URL` | Internal address of auth-service (e.g. `http://jinbocho-auth:8001`) |
| `JWT_SECRET_KEY` | `<JWT_SECRET>` — **identical to auth** |
| `JWT_ALGORITHM` | `HS256` |
| `GOOGLE_BOOKS_API_KEY` | Your Google Books API key (get one free) |
| `DEBUG` | `false` |
| `PORT` | `8002` |

**api-gateway** — the **only public** backend component:

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
| `CORS_ORIGINS` | `["https://jinbocho-fe.onrender.com"]` — set after FE is deployed |
| `DEBUG` | `false` |

5. **Deploy** → Render assigns a public URL like
   `https://jinbocho-api-gateway.onrender.com`. **Save this URL** — it is the
   `VITE_API_BASE_URL` for the frontend.

#### Step 3 — Deploy the frontend

1. **New + → Static Site**
2. Repository: `jinbocho-fe`
3. Build Command: `npm ci && npm run build`
4. Publish Directory: `dist`
5. Add Redirect/Rewrite Rule: Source `/*` → Destination `/index.html` →
   Action **Rewrite** (SPA routing)
6. Environment variable:

| Variable | Value |
|----------|-------|
| `VITE_API_BASE_URL` | Public URL of api-gateway (from Step 2) |

7. **Deploy** → Render assigns a public URL like
   `https://jinbocho-fe.onrender.com`.

#### Step 4 — Close the URL loop

There is a circular dependency between the gateway (which needs the frontend
URL for CORS) and the frontend (which needs the gateway URL for API calls).
Resolve it now:

1. Go to **api-gateway** on Render → **Environment**
2. Set `CORS_ORIGINS` to the frontend URL:
   `["https://jinbocho-fe.onrender.com"]`
3. Click **Save Changes** → Render triggers an automatic redeploy
4. Wait for the redeploy to complete

#### Step 5 — Verify the deployment

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
- [ ] Alembic migrations applied (check auth and catalog service logs: look
      for `alembic upgrade head` success)
- [ ] POST `/v1/auth/register` returns `{ family_id, user_id }`
- [ ] POST `/v1/auth/login` returns `{ access_token, refresh_token }`
- [ ] Frontend loads at the Render static site URL
- [ ] Login from the frontend works
- [ ] ISBN lookup returns metadata (Google Books key is set)
- [ ] No CORS errors in browser developer console

### Costs and free tier limits

| Component | Provider | Cost | Limits |
|-----------|----------|------|--------|
| `auth_db`, `catalog_db` | Neon free | €0 | 0.5 GB each, no expiry |
| `auth-service`, `catalog-service` | Render free | €0 | Cold start after 15 min idle (~30-60s) |
| `api-gateway` | Render free | €0 | Cold start after 15 min idle |
| `jinbocho-fe` | Render Static Site | €0 | No cold start (CDN) |
| Total | — | **€0/month** | Cold starts acceptable for home use |

To eliminate cold starts, upgrade to Render Starter ($7/month per service).
The databases remain free on Neon regardless.

!!! tip "Keep services in the same region"
    Render Private Services can only communicate within the same region.
    Always deploy auth, catalog, and gateway in the same region. Choose the
    Neon region closest to that Render region to minimize database latency.
