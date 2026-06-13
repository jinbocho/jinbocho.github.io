# Monitoring & Logging

## Viewing Logs on Render

Render Dashboard → service name → **Logs** tab. Logs stream in real time.

### What to Look For at Startup

```
# Healthy startup:
INFO  [alembic] Running upgrade -> <revision>, <description>
INFO  [alembic] Done.
INFO:     Application startup complete.

# Bad sign:
ERROR - Connection refused
sqlalchemy.exc.OperationalError: (asyncpg.exceptions.InvalidPasswordError)
```

## Health Checks

```bash
curl https://jinbocho-api-gateway.onrender.com/health
# Expected: {"status": "ok"}

# Local development
curl http://localhost:8000/health
curl http://localhost:8001/health
curl http://localhost:8002/health
```

## SQL Logging (DEBUG Mode)

```bash
# Local .env — enable for development
DEBUG=true

# Render / production — always disable
DEBUG=false
```

Never enable `DEBUG=true` in production: it is verbose, leaks data to logs, and degrades performance.

## Application Logging

| Level | When |
|-------|------|
| `INFO` | Service start, migration completions, request summaries |
| `WARNING` | Non-fatal issues (e.g. ISBN not found) |
| `ERROR` | Exceptions, failed requests, database errors |

## Monitoring Neon Databases

The [Neon console](https://console.neon.tech) provides:
- **Storage usage** — stay within the 0.5 GB free tier
- **Query history** — recent queries and durations
- **Connection count** — monitor active connections
- **Compute status** — active or suspended

!!! tip "Neon auto-suspend"
    On the free tier, Neon suspends compute after 5 minutes of inactivity. The first query after suspension takes ~500ms.

## Error Tracking (Optional)

For production use, add [Sentry](https://sentry.io):

```python
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn=os.environ.get("SENTRY_DSN", ""),
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1,
    environment="production",
)
```
