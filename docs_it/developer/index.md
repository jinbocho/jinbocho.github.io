# Manuale Sviluppatori

Guida completa per sviluppatori e ingegneri DevOps che vogliono installare, distribuire e gestire Jinbocho.

## Sezioni

| # | Sezione | Contenuto |
|---|---------|----------|
| 1 | [Prerequisiti](01-prerequisites.md) | Docker, Python 3.12, Node.js 18, chiavi API |
| 2 | [Sviluppo locale](02-local-development.md) | Docker Compose, porte, variabili d'ambiente, verifica |
| 3 | [Servizi backend](03-backend-services.md) | auth, catalog, gateway, ai (opzionale) — endpoint, env var, test |
| 4 | [Frontend](04-frontend.md) | Setup React, pattern TanStack Query, gotcha critici |
| 5 | [Database e migrazioni](05-database-migrations.md) | Alembic, schema PostgreSQL, reset locale |
| 6 | [CI/CD](06-cicd.md) | Workflow GitHub Actions pianificati per tutti i servizi |
| 7 | [Deploy in produzione](07-production-deployment.md) | Guida passo per passo su Render + Neon |
| 8 | [Monitoring e logging](08-monitoring-logging.md) | Log Render, health check, console Neon |
| 9 | [Troubleshooting](09-troubleshooting.md) | Problemi comuni e soluzioni |
| 10 | [Architettura](10-architecture.md) | Diagramma di sistema, bounded context, flusso dati, sicurezza |

## Percorsi rapidi

### Voglio eseguire Jinbocho in locale

1. [Prerequisiti](01-prerequisites.md) — installa Docker, Python, Node.js
2. [Sviluppo locale](02-local-development.md) — `docker compose up --build -d` e sei pronto

### Voglio fare il deploy in produzione

1. [Prerequisiti](01-prerequisites.md) — crea account Neon e Render
2. [Sviluppo locale](02-local-development.md) — verifica che funzioni in locale prima
3. [Deploy in produzione](07-production-deployment.md) — guida passo per passo su Render + Neon

### Devo capire il codice

1. [Architettura](10-architecture.md) — diagramma di sistema, bounded context, scelte progettuali
2. [Servizi backend](03-backend-services.md) — analisi servizio per servizio
3. [Frontend](04-frontend.md) — architettura React e gotcha critici

### Qualcosa non funziona

1. [Troubleshooting](09-troubleshooting.md) — raggruppato per area (database, CORS, JWT, cold start)
2. [Monitoring e logging](08-monitoring-logging.md) — come leggere i log di Render

## Stack tecnologico

| Livello | Tecnologia |
|---------|----------|
| Backend | Python 3.12, FastAPI, SQLAlchemy (async) |
| Database | PostgreSQL 16 (Neon in produzione) |
| Migrazioni | Alembic |
| Frontend | React 18, TypeScript strict, Vite, TanStack Query, Zustand |
| HTTP client | ky |
| Deploy | Docker Compose (dev), Render + Neon (prod) |
| CI/CD | GitHub Actions (pianificato) |
| Qualità del codice | mypy (strict), ruff, pytest, vitest |

## Prima di ogni commit

```bash
# Backend (esegui nella directory di ogni servizio modificato)
ruff check app tests
python -m mypy app --strict
pytest tests/ -v

# Frontend
cd jinbocho-fe
npm run typecheck && npm run test
```