# CI/CD — GitHub Actions

!!! warning "Image publishing is active — quality gates are not"
    Every backend service already has a working GitHub Actions pipeline that builds and publishes a Docker image to GHCR on every push to `main`. **None of these pipelines run lint, type-check, or tests** — there is currently no CI quality gate. You must run the checks below locally before pushing.

    ```bash
    # Backend (in each changed service directory)
    ruff check app tests
    python -m mypy app --strict
    pytest tests/ -v

    # Frontend
    cd jinbocho-fe
    npm run typecheck && npm run test
    ```

---

## Image Publishing (all backend services)

Each backend service repository — `jinbocho-auth-v1`, `jinbocho-catalog-v1`, `jinbocho-api-gateway-v1`, `jinbocho-ai-v1` — has an identical `.github/workflows/publish-image.yml`. It builds the service's Docker image and pushes it to the **GitHub Container Registry (GHCR)**, so the infrastructure repo's `docker-compose.ghcr.yml` can pull pre-built images instead of building from source (1-command self-host).

**Triggers**: push to `main`, push of a tag matching `v*`, or manual `workflow_dispatch`.

```yaml
# .github/workflows/publish-image.yml (identical in auth-v1, catalog-v1, api-gateway-v1, ai-v1)
name: Publish image

on:
  push:
    branches: [main]
    tags: ["v*"]
  workflow_dispatch:

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Docker metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=raw,value=latest,enable={{is_default_branch}}
            type=ref,event=tag
            type=sha,format=short

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

This job has **no lint, type-check, or test step** — it only builds and pushes the image. A broken or untested commit on `main` will be published to GHCR as `latest`.

**Resulting images**: `ghcr.io/<org>/<repo>:latest`, `ghcr.io/<org>/<repo>:<tag>` (when pushing a `v*` tag), and `ghcr.io/<org>/<repo>:sha-<short-sha>` on every build.

## Database Backups (infrastructure repo)

`jinbocho-infrastructure-v1/.github/workflows/db-backup.yml` runs daily (`cron: "0 2 * * *"`, 02:00 UTC) or on manual `workflow_dispatch`. It dumps the Neon-hosted `auth_db` and `catalog_db` with `pg_dump`, gzips each dump, and uploads them as build artifacts with a **90-day retention**.

**Required repository secrets**:

| Secret | Format |
|--------|--------|
| `NEON_AUTH_DB_URL` | `postgresql://user:pass@ep-xxx.neon.tech/auth_db?sslmode=require` |
| `NEON_CATALOG_DB_URL` | `postgresql://user:pass@ep-xxx.neon.tech/catalog_db?sslmode=require` |

Use the original Neon connection string (`postgresql://`), **not** the asyncpg-transformed one used by the services at runtime.

!!! note "ai_db is not backed up yet"
    The workflow only dumps `auth_db` and `catalog_db`. If you provision a separate database for `jinbocho-ai-v1`, add an equivalent dump step for it.

**Restore a backup**:

```bash
# 1. Download the artifact from GitHub → Actions → the run → Artifacts
gunzip auth_db_YYYYMMDD_HHMM.sql.gz
psql "$NEON_AUTH_DB_URL" < auth_db_YYYYMMDD_HHMM.sql
# (same for catalog_db)
```

## Waking Render Services

`jinbocho-infrastructure-v1/.github/workflows/wake-render.yml` pings all Render-hosted services (frontend, api-gateway, auth-service, catalog-service, ai-service `/health`) in parallel and waits up to 90 seconds for each to return HTTP 200 — useful to warm up free-tier Render services after a cold start.

This workflow only has a `workflow_dispatch` trigger — **it does not run on a schedule by itself**. To wake services automatically before they're needed, trigger it externally (e.g. an external cron service calling the GitHub Actions "dispatch workflow" API) — see [Troubleshooting](09-troubleshooting.md) for the recommended setup.

## Recommended Practices (Not Yet Enforced)

The following are sensible defaults for this repository, but **nothing in CI currently enforces them** — there is no required status check today, since `publish-image.yml` has no quality job.

**Branch protection** (GitHub → Repository Settings → Branches → rule for `main`):

| Rule | Setting |
|------|---------|
| **Require pull request reviews** | ✅ Enable (at least 1 review) |
| **Restrict force pushes** | ✅ Enable |
| **Allow deletions** | ✅ Disable |

If you later add a quality workflow (lint/type-check/test), make its job a required status check here.

**Tagging**: `publish-image.yml` triggers on any tag matching `v*` (e.g. `v0.2.0`) and publishes that tag as a GHCR image tag — it does not use a `<service>/v<semver>` namespaced pattern, since each service already lives in its own repository.

```bash
git tag v0.2.0
git push --tags
```

## Running Quality Checks Locally

Since CI does not gate merges on lint/type-check/tests, run the full quality suite before every push:

**Backend service:**
```bash
cd jinbocho-auth-v1   # or any service
source .venv/bin/activate
ruff check app tests
python -m mypy app --strict
pytest tests/ -v
```

**Frontend:**
```bash
cd jinbocho-fe
npm run typecheck && npm run test && npm run build
```
