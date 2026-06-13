# CI/CD — GitHub Actions

!!! warning "Planned feature — not yet active"
    GitHub Actions CI/CD pipelines are a **planned feature** and are not yet configured in the Jinbocho repositories. This page documents the target architecture as a reference for future implementation.

    **In the meantime, run all quality checks locally before every commit:**

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

## Target Workflow Structure

When implemented, each service will have its own workflow file in `.github/workflows/`. The pipeline will be identical for all backend services; the frontend will have a separate workflow.

### Backend Services (auth, catalog, gateway, ai)

**Triggers**: push to `main`, pull requests targeting `main`

```yaml
# .github/workflows/ci-auth.yml  (replicate for catalog, gateway, ai)
name: CI — auth-service

on:
  push:
    branches: [main]
    paths:
      - "jinbocho-auth-v1/**"
      - ".github/workflows/ci-auth.yml"
  pull_request:
    branches: [main]
    paths:
      - "jinbocho-auth-v1/**"

jobs:
  quality:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: jinbocho-auth-v1

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: auth_db_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: "pip"
          cache-dependency-path: jinbocho-auth-v1/requirements.txt

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Lint (ruff)
        run: ruff check app tests

      - name: Type check (mypy)
        run: python -m mypy app --strict

      - name: Unit tests
        run: pytest tests/unit/ -v

      - name: Integration tests
        env:
          DATABASE_URL: postgresql+asyncpg://postgres:postgres@localhost:5432/auth_db_test
          JWT_SECRET_KEY: test-secret-key-for-ci
          DEBUG: "false"
        run: pytest tests/integration/ -v

      - name: Docker build check
        run: docker build -t jinbocho-auth:ci .
```

### Frontend

**Triggers**: push to `main`, pull requests targeting `main`, changes in `jinbocho-fe/`

```yaml
# .github/workflows/ci-frontend.yml
name: CI — frontend

on:
  push:
    branches: [main]
    paths:
      - "jinbocho-fe/**"
      - ".github/workflows/ci-frontend.yml"
  pull_request:
    branches: [main]
    paths:
      - "jinbocho-fe/**"

jobs:
  quality:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: jinbocho-fe

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: jinbocho-fe/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Type check
        run: npm run typecheck

      - name: Lint
        run: npm run lint

      - name: Tests
        run: npm run test

      - name: Build
        env:
          VITE_API_BASE_URL: https://jinbocho-api-gateway.onrender.com
        run: npm run build
```

## Target Branch Protection Rules

When CI is active, configure these in GitHub → Repository Settings → Branches → Add branch protection rule for `main`:

| Rule | Setting |
|------|--------|
| **Require status checks to pass** | ✅ Enable |
| Required checks | `quality` (for each service workflow) |
| **Require branches to be up to date** | ✅ Enable |
| **Restrict force pushes** | ✅ Enable |
| **Require pull request reviews** | ✅ Enable (at least 1 review) |
| **Allow deletions** | ✅ Disable |

## Target Release Tagging

Releases will follow the pattern `<service>/v<semver>`:

```bash
git tag auth-service/v0.2.0
git tag catalog-service/v0.2.0
git push --tags
```

## Running Quality Checks Locally (Current Process)

Until CI is in place, run the full quality suite before every push:

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
