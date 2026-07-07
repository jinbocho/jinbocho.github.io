# Troubleshooting

Common issues and how to resolve them, grouped by area.

---

## Database Issues

### `OperationalError: Connection refused` at startup

**Cause**: The service started before PostgreSQL was ready.

**Local fix**: Docker Compose uses healthchecks — this should not happen. If it does:
```bash
docker compose restart auth-service   # retry after DB is healthy
```

**Render fix**: The service's `DATABASE_URL` is wrong — likely a typo in the host or port. Verify the Neon connection string in the Render environment, then trigger a manual redeploy.

---

### `asyncpg.exceptions.InvalidAuthorizationSpecificationError`

**Cause**: Wrong password in the connection string.

**Fix**: Re-copy the Neon connection string from **Connection Details** in the Neon console. Make sure you did not accidentally modify the password segment.

---

### `SSL SYSCALL error: EOF detected` / `ssl=require not recognized`

**Cause**: asyncpg does not understand `sslmode=require` (Neon's default string uses this). You must use `ssl=require` instead.

**Fix**: In `DATABASE_URL`, replace `?sslmode=require` with `?ssl=require`.

```
# Wrong
postgresql+asyncpg://...?sslmode=require

# Correct
postgresql+asyncpg://...?ssl=require
```

---

### Alembic migration fails at startup

**Symptom**: In the service logs you see `alembic.util.exc.CommandError` or `relation "xxx" already exists`.

**Fix**:

1. Check if a partial migration ran: connect to Neon with psql and inspect `alembic_version`
2. Run the migration manually to identify the failing step:
   ```bash
   cd jinbocho-auth-v1
   export DATABASE_URL="postgresql+asyncpg://...neon.tech/auth_db?ssl=require"
   alembic upgrade head
   ```
3. If the schema is in an inconsistent state, reset it:
   ```bash
   # Drop and recreate the database in Neon console, then redeploy
   # (Alembic will rerun all migrations from scratch)
   ```

---

## Service-to-Service Issues

### Catalog service returns 401 for every request

**Cause**: `JWT_SECRET_KEY` on catalog-service does not match auth-service.

**Verification**: The JWT is signed by auth and verified by catalog. If the secrets differ, every token will fail validation silently.

**Fix**: Confirm that `JWT_SECRET_KEY` is **exactly the same** string in auth, catalog, and gateway environment variables on Render. Copy-paste errors (trailing spaces, newlines) are common.

---

### Gateway returns `502 Bad Gateway`

**Cause**: The gateway cannot reach an internal Private Service.

**Checks**:

1. The internal service URL in the gateway env is wrong — copy it directly from the service's page in Render (not the public URL — Private Services have no public URL)
2. The Private Service is still deploying or has crashed — check its logs
3. The gateway and the internal service are in **different Render regions** — Private Services only communicate within the same region

---

### `AUTH_SERVICE_URL` from catalog returns `Connection refused`

**Cause**: Catalog is using `http://jinbocho-auth:8001` but the actual Render internal hostname is different.

**Fix**: On Render, the internal hostname for a service is shown on its service page. Use exactly that value — do not guess or construct it manually.

---

## Frontend / CORS Issues

### CORS error in browser console: `Access-Control-Allow-Origin missing`

**Cause**: The gateway's `CORS_ORIGINS` does not include the frontend URL.

**Fix**:

1. Render → api-gateway → **Environment**
2. Set `CORS_ORIGINS` to the exact frontend origin: `["https://jinbocho-fe.onrender.com"]`
   - No trailing slash
   - Must be a valid JSON array (double quotes, square brackets)
3. Save and wait for redeploy

---

### Frontend shows blank page after deploy

**Cause**: `VITE_API_BASE_URL` was not set at build time, so API calls go to the wrong URL.

**Fix**: On Render Static Site, verify `VITE_API_BASE_URL` is set to the gateway's public URL. Then click **Clear build cache & deploy** — Vite inlines env vars at build time, so a simple redeploy is not enough if the variable was added after the last build.

---

### Login succeeds but all subsequent API calls return 401

**Cause**: The access token is being sent correctly but the gateway or a backend service is rejecting it.

**Checks**:

1. Open browser DevTools → Network tab → inspect a failing request's `Authorization` header
2. Decode the JWT at [jwt.io](https://jwt.io) — check `iss` and `aud` match what catalog expects (`iss: jinbocho-auth`, `aud: jinbocho`)
3. Confirm `JWT_ALGORITHM` is `HS256` on all services

---

## ISBN Lookup Issues

### ISBN lookup returns 404 for a valid ISBN

**Cause**: The book is not in Open Library or Google Books, or the Google Books API key is missing/invalid.

**Checks**:

1. Test Open Library directly:
   ```bash
   curl "https://openlibrary.org/api/books?bibkeys=ISBN:9788845292613&format=json&jscmd=data"
   ```
2. If Open Library returns data but the service does not, check catalog-service logs for errors
3. If `GOOGLE_BOOKS_API_KEY` is missing, the fallback lookup is skipped — add the key to the Render environment

---

### ISBN lookup is slow (> 2 seconds)

**Cause**: The ISBN is not in the local cache, and the external lookup is slow.

**Fix**: This is expected for the first lookup of any ISBN. Subsequent lookups for the same ISBN are served from the `isbn_cache` table and are fast. If external lookups are consistently slow, check your Neon region vs Render region latency.

---

## Cold Starts (Free Tier)

### First request after inactivity takes 30-60 seconds

**Cause**: Render free-tier services sleep after 15 minutes of inactivity. The first request wakes them up.

**Options**:

1. **Accept it** — for a home library used by a few people, cold starts are tolerable
2. **Upgrade to Render Starter** ($7/month per service) — services stay always-on
3. **Ping the gateway periodically** — an external cron service (e.g. cron-job.org, free) can hit `/health` every 10 minutes to keep the gateway warm. The Private Services behind it still cold-start, but the gateway responds instantly.

```bash
# Example: setup a free cron job to ping the gateway every 10 minutes
# URL: https://jinbocho-api-gateway.onrender.com/health
# Method: GET
# Schedule: */10 * * * *
```

4. **Wake everything on demand** — `jinbocho-infrastructure-community-v1` ships a `wake-render.yml` GitHub Action (`workflow_dispatch`, manual trigger only — it does **not** run on a schedule) that pings frontend, gateway, auth and catalog in parallel and waits for all of them to respond with `200`. Run it from the **Actions** tab right before a demo or a manual test session instead of waiting through 3-4 separate cold starts one request at a time. It is a convenience tool, not a substitute for option 3 if you want the services to never sleep.

---

## Local Development Issues

### Port already in use

```bash
# Find the process using port 8000
lsof -i :8000

# Kill it
kill -9 <PID>

# Or change the port in docker-compose.yml
```

### `mypy` strict mode fails on a new module

If you add a new file and `mypy --strict` complains about missing type annotations:

```bash
# Run mypy and see specific errors
python -m mypy app --strict 2>&1 | grep error

# Common fixes:
# - Add return type annotation to every function
# - Add type annotations to all variables
# - Mark optional parameters with Optional[T] or T | None
```

### `ruff check` fails after editing

```bash
# See exactly what failed
ruff check app tests

# Auto-fix what ruff can
ruff check --fix app tests

# For remaining issues, fix manually (ruff shows line numbers)
```
