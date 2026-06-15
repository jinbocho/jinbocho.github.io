# Monitoring & Logging

## Viewing Logs on Render

Every service (Web Service, Private Service, Static Site) has a **Logs** tab in the Render dashboard.

### Access Service Logs

1. Render Dashboard → click the service name
2. Click the **Logs** tab
3. Logs stream in real time; use the search box to filter

### What to Look For at Startup

After a deploy, check the logs for these lines confirming a healthy startup:

```
# auth-service and catalog-service:
INFO  [alembic] Running upgrade -> <revision>, <description>
INFO  [alembic] Done.
INFO:     Application startup complete.

# api-gateway:
INFO:     Application startup complete.

# Any service — bad sign:
ERROR - Connection refused
sqlalchemy.exc.OperationalError: (asyncpg.exceptions.InvalidPasswordError)
```

If Alembic lines are missing or show errors, the `DATABASE_URL` is misconfigured.

## Health Checks

All backend services expose `GET /health`. Render polls this endpoint and automatically restarts a service if it fails to respond.

```bash
# Check all services manually
curl https://jinbocho-api-gateway.onrender.com/health

# In local development
curl http://localhost:8000/health   # gateway
curl http://localhost:8001/health   # auth
curl http://localhost:8002/health   # catalog
```

Expected response: `{"status": "ok"}`

## SQL Logging (DEBUG Mode)

Setting `DEBUG=true` enables SQLAlchemy query logging — every SQL statement is printed to stdout.

```bash
# Local .env — enable for development
DEBUG=true

# Render / production — always disable
DEBUG=false
```

SQL logging is useful for diagnosing N+1 queries or slow queries locally. Never enable it in production: it is verbose, leaks data to logs, and degrades performance.

## Application Logging

All services use Python's standard `logging` library. Log levels:

| Level | When |
|-------|------|
| `INFO` | Service start, migration completions, request summaries |
| `WARNING` | Non-fatal issues (e.g. ISBN not found in any source) |
| `ERROR` | Exceptions, failed requests, database errors |

Logs are written to stdout and collected by Render automatically.

### Sample Log Output (auth-service)

```
INFO:uvicorn.access:POST /v1/auth/login HTTP/1.1 200
INFO:uvicorn.access:POST /v1/auth/refresh HTTP/1.1 200
WARNING:app.infrastructure:ISBN 9999999999 not found in Open Library or Google Books
ERROR:app.api:Unhandled exception in POST /v1/auth/login
Traceback (most recent call last): ...
```

## Monitoring Neon Databases

The [Neon console](https://console.neon.tech) provides:

- **Storage usage** — stay within the 0.5 GB free tier
- **Query history** — recent queries and durations (useful for performance debugging)
- **Connection count** — monitor active connections; asyncpg pools a small number per service
- **Compute status** — shows if compute is active or suspended (auto-suspend after 5 min of inactivity on free tier)

!!! tip "Neon auto-suspend"
    On the free tier, Neon suspends compute after 5 minutes of inactivity. The first query after suspension takes ~500ms to reconnect. For a home library this is imperceptible. If it becomes an issue, upgrade to Neon Launch ($19/month) to disable auto-suspend.

## Render Service Status

The Render dashboard shows:

- **Deploy history** — every deploy with its status (deploying / live / failed)
- **Metrics** — CPU and memory usage graphs per service
- **Events** — auto-restarts, health check failures, deploys

For free-tier services, the **Suspended** indicator means the service is in cold-start mode. The next request wakes it up (30-60 second delay).

## Error Tracking (Optional)

For production use beyond a single family, add [Sentry](https://sentry.io):

1. Create a Sentry project (free tier available)
2. Add `sentry-sdk[fastapi]` to `requirements.txt`
3. Initialize in `app/main.py`:

```python
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn=os.environ.get("SENTRY_DSN", ""),
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1,   # 10% of requests traced
    environment="production",
)
```

4. Add `SENTRY_DSN` to the Render environment variables for each service

Sentry captures unhandled exceptions with full stack traces and groups them by type — much easier than reading raw logs.
