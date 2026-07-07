# CI/CD — GitHub Actions

!!! warning "La pubblicazione delle immagini è attiva — i quality gate no"
    Ogni servizio backend ha già una pipeline GitHub Actions funzionante che builda e pubblica un'immagine Docker su GHCR a ogni push su `main`. **Nessuna di queste pipeline esegue lint, type-check o test** — al momento non esiste alcun quality gate in CI. Devi eseguire i controlli sotto in locale prima di ogni push.

    ```bash
    # Backend (nella directory di ogni servizio modificato)
    ruff check app tests
    python -m mypy app --strict
    pytest tests/ -v

    # Frontend
    cd jinbocho-fe
    npm run typecheck && npm run test
    ```

---

## Pubblicazione delle immagini (tutti i servizi backend)

Ogni repository di servizio backend — `jinbocho-auth-v1`, `jinbocho-catalog-v1`, `jinbocho-api-gateway-v1` — ha un identico `.github/workflows/publish-image.yml`. Builda l'immagine Docker del servizio e la pubblica sul **GitHub Container Registry (GHCR)**, così il `docker-compose.community.yml` del repo infrastruttura può scaricare immagini già costruite invece di buildare dal sorgente (self-host con un solo comando).

**Trigger**: push su `main`, push di un tag che corrisponde a `v*`, oppure `workflow_dispatch` manuale.

```yaml
# .github/workflows/publish-image.yml (identico in auth-v1, catalog-v1, api-gateway-v1)
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

Questo job **non ha alcuno step di lint, type-check o test** — builda e pubblica solo l'immagine. Un commit rotto o non testato su `main` verrà pubblicato su GHCR come `latest`.

**Immagini risultanti**: `ghcr.io/<org>/<repo>:latest`, `ghcr.io/<org>/<repo>:<tag>` (quando si pusha un tag `v*`), e `ghcr.io/<org>/<repo>:sha-<short-sha>` a ogni build.

## Backup del database (repo infrastruttura)

`jinbocho-infrastructure-community-v1/.github/workflows/db-backup.yml` viene eseguito ogni giorno (`cron: "0 2 * * *"`, 02:00 UTC) oppure manualmente via `workflow_dispatch`. Esegue il dump di `auth_db` e `catalog_db` ospitati su Neon con `pg_dump`, comprime ogni dump con gzip e li carica come artifact della build con una **retention di 90 giorni**.

**Secret di repository richiesti**:

| Secret | Formato |
|--------|--------|
| `NEON_AUTH_DB_URL` | `postgresql://user:pass@ep-xxx.neon.tech/auth_db?sslmode=require` |
| `NEON_CATALOG_DB_URL` | `postgresql://user:pass@ep-xxx.neon.tech/catalog_db?sslmode=require` |

Usa la connection string Neon originale (`postgresql://`), **non** quella trasformata per asyncpg usata dai servizi a runtime.

**Ripristinare un backup**:

```bash
# 1. Scarica l'artifact da GitHub → Actions → la run → Artifacts
gunzip auth_db_YYYYMMDD_HHMM.sql.gz
psql "$NEON_AUTH_DB_URL" < auth_db_YYYYMMDD_HHMM.sql
# (lo stesso per catalog_db)
```

## Risveglio dei servizi Render

`jinbocho-infrastructure-community-v1/.github/workflows/wake-render.yml` esegue il ping di tutti i servizi ospitati su Render (frontend, api-gateway, auth-service, catalog-service `/health`) in parallelo e attende fino a 90 secondi che ciascuno risponda con HTTP 200 — utile per "scaldare" i servizi Render del piano gratuito dopo un cold start.

Questo workflow ha solo un trigger `workflow_dispatch` — **non viene eseguito automaticamente in base a uno schedule**. Per risvegliare i servizi automaticamente prima che siano necessari, va invocato esternamente (ad es. un servizio cron esterno che chiama l'API "dispatch workflow" di GitHub Actions) — vedi [Risoluzione dei problemi](09-troubleshooting.md) per la configurazione raccomandata.

## Pratiche raccomandate (non ancora applicate)

Quanto segue sono default sensati per questo repository, ma **al momento nulla in CI li applica** — non esiste oggi alcun controllo di stato obbligatorio, dato che `publish-image.yml` non ha un job di qualità.

**Protezione del branch** (GitHub → Impostazioni Repository → Branch → regola per `main`):

| Regola | Impostazione |
|------|---------|
| **Richiedi revisioni delle pull request** | ✅ Abilita (almeno 1 revisione) |
| **Blocca i force push** | ✅ Abilita |
| **Consenti eliminazioni** | ✅ Disabilita |

Se in futuro aggiungi un workflow di qualità (lint/type-check/test), rendi il suo job un controllo di stato obbligatorio qui.

**Tagging**: `publish-image.yml` si attiva su qualsiasi tag che corrisponde a `v*` (es. `v0.2.0`) e pubblica quel tag come tag dell'immagine GHCR — non usa un pattern namespaced `<servizio>/v<semver>`, poiché ogni servizio vive già nel proprio repository.

```bash
git tag v0.2.0
git push --tags
```

## Esecuzione dei controlli di qualità in locale

Poiché la CI non vincola i merge a lint/type-check/test, esegui la suite di qualità completa prima di ogni push:

**Servizio backend:**
```bash
cd jinbocho-auth-v1   # o qualsiasi servizio
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
