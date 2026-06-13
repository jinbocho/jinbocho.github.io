# CI/CD — GitHub Actions

!!! warning "Planned feature — not yet active"
    GitHub Actions CI/CD pipelines are a **planned feature** and are not yet configured in the Jinbocho repositories.

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

### Backend Services (auth, catalog, gateway, ai)

```yaml
name: CI — auth-service

on:
  push:
    branches: [main]
    paths:
      - "jinbocho-auth-v1/**"
  pull_request:
    branches: [main]
    paths:
      - "jinbocho-auth-v1/**"

jobs:
  quality:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: auth_db_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
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
        run: pytest tests/integration/ -v
```

### Frontend

```yaml
name: CI — frontend

on:
  push:
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
      - run: npm ci
      - run: npm run typecheck
      - run: npm run lint
      - run: npm run test
      - run: npm run build
        env:
          VITE_API_BASE_URL: https://jinbocho-api-gateway.onrender.com
```
