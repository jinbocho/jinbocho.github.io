# Troubleshooting

Common issues and how to resolve them, grouped by area.

---

## Database Issues

### `OperationalError: Connection refused` at startup

**Local fix**: `docker compose restart auth-service`

**Render fix**: Verify the Neon connection string in the Render environment, then trigger a manual redeploy.

### `asyncpg.exceptions.InvalidAuthorizationSpecificationError`

**Fix**: Re-copy the Neon connection string from **Connection Details** in the Neon console.

### `ssl=require not recognized`

**Fix**: Replace `?sslmode=require` with `?ssl=require` in `DATABASE_URL`.

```
# Wrong
postgresql+asyncpg://...?sslmode=require

# Correct
postgresql+asyncpg://...?ssl=require
```

### Alembic migration fails at startup

```bash
cd jinbocho-auth-v1
export DATABASE_URL="postgresql+asyncpg://...neon.tech/auth_db?ssl=require"
alembic upgrade head
```

---

## Service-to-Service Issues

### Catalog service returns 401 for every request

**Cause**: `JWT_SECRET_KEY` on catalog-service does not match auth-service.

**Fix**: Confirm `JWT_SECRET_KEY` is **exactly the same** string on auth, catalog, and gateway.

### Gateway returns `502 Bad Gateway`

**Checks**:
1. Internal service URL in gateway env is wrong
2. Private Service is still deploying or crashed
3. Gateway and internal service are in **different Render regions**

---

## Frontend / CORS Issues

### `Access-Control-Allow-Origin missing`

**Fix**: Set `CORS_ORIGINS` to the exact frontend origin: `["https://jinbocho-fe.onrender.com"]` (no trailing slash, valid JSON array).

### Frontend shows blank page after deploy

**Fix**: Verify `VITE_API_BASE_URL` is set. Then click **Clear build cache & deploy** — Vite inlines env vars at build time.

### Login succeeds but all subsequent API calls return 401

**Checks**:
1. Browser DevTools → Network → inspect `Authorization` header
2. Decode JWT at [jwt.io](https://jwt.io) — check `iss` and `aud`
3. Confirm `JWT_ALGORITHM` is `HS256` on all services

---

## ISBN Lookup Issues

### ISBN lookup returns 404

```bash
curl "https://openlibrary.org/api/books?bibkeys=ISBN:9788845292613&format=json&jscmd=data"
```

If Open Library returns data but service doesn't, check catalog-service logs.

---

## Cold Starts (Free Tier)

### First request takes 30-60 seconds

**Options**:
1. Accept it — tolerable for home use
2. Upgrade to Render Starter ($7/month per service)
3. Ping `/health` every 10 minutes with a free cron service (cron-job.org)

---

## Local Development Issues

### Port already in use

```bash
lsof -i :8000
kill -9 <PID>
```

### `mypy` strict mode fails

```bash
python -m mypy app --strict 2>&1 | grep error
```

### `ruff check` fails

```bash
ruff check --fix app tests
```
