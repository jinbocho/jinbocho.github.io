# CI/CD — GitHub Actions

!!! warning "Funzionalità pianificata — non ancora attiva"
    Le pipeline CI/CD con GitHub Actions sono una **funzionalità pianificata** e non sono ancora configurate nei repository Jinbocho. Questa pagina documenta l'architettura target come riferimento per l'implementazione futura.

    **Nel frattempo, esegui tutti i controlli di qualità in locale prima di ogni commit:**

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

## Struttura dei workflow target

Quando implementato, ogni servizio avrà il proprio file di workflow in `.github/workflows/`. La pipeline sarà identica per tutti i servizi backend; il frontend avrà un workflow separato.

### Servizi backend (auth, catalog, gateway, ai)

**Trigger**: push su `main`, pull request verso `main`

```yaml
# .github/workflows/ci-auth.yml  (replica per catalog, gateway, ai)
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

      - name: Installa dipendenze
        run: pip install -r requirements.txt

      - name: Lint (ruff)
        run: ruff check app tests

      - name: Type check (mypy)
        run: python -m mypy app --strict

      - name: Unit test
        run: pytest tests/unit/ -v

      - name: Test di integrazione
        env:
          DATABASE_URL: postgresql+asyncpg://postgres:postgres@localhost:5432/auth_db_test
          JWT_SECRET_KEY: test-secret-key-for-ci
          DEBUG: "false"
        run: pytest tests/integration/ -v

      - name: Verifica build Docker
        run: docker build -t jinbocho-auth:ci .
```

### Frontend

**Trigger**: push su `main`, pull request verso `main`, modifiche in `jinbocho-fe/`

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

      - name: Installa dipendenze
        run: npm ci

      - name: Type check
        run: npm run typecheck

      - name: Lint
        run: npm run lint

      - name: Test
        run: npm run test

      - name: Build
        env:
          VITE_API_BASE_URL: https://jinbocho-api-gateway.onrender.com
        run: npm run build
```

## Regole di protezione del branch (target)

Quando la CI sarà attiva, configura queste regole in GitHub → Impostazioni Repository → Branch → Aggiungi regola per `main`:

| Regola | Impostazione |
|--------|-------------|
| **Richiedi che i controlli di stato passino** | ✅ Abilita |
| Controlli richiesti | `quality` (per ogni workflow di servizio) |
| **Richiedi che i branch siano aggiornati** | ✅ Abilita |
| **Blocca i force push** | ✅ Abilita |
| **Richiedi revisioni delle pull request** | ✅ Abilita (almeno 1 revisione) |
| **Consenti eliminazioni** | ✅ Disabilita |

## Tagging delle release (target)

Le release seguiranno il pattern `<servizio>/v<semver>`:

```bash
git tag auth-service/v0.2.0
git tag catalog-service/v0.2.0
git push --tags
```

## Esecuzione dei controlli di qualità in locale (processo attuale)

Finché la CI non è attiva, esegui la suite di qualità completa prima di ogni push:

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