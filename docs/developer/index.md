# Developer Manual

Complete guide for developers and DevOps engineers to set up, deploy, and maintain Jinbocho.

## Sections

| # | Section | What you'll find |
|---|---------|------------------|
| 1 | [Prerequisites](01-prerequisites.md) | System requirements: Docker, Python 3.12, Node.js 18, API keys |
| 2 | [Local Development](02-local-development.md) | Docker Compose setup, port mapping, env files, verification |
| 3 | [Backend Services](03-backend-services.md) | auth, catalog, gateway, ai (optional) — endpoints, env vars, tests |
| 4 | [Frontend](04-frontend.md) | React setup, TanStack Query patterns, critical gotchas |
| 5 | [Database & Migrations](05-database-migrations.md) | Alembic, PostgreSQL schema, local reset |
| 6 | [CI/CD](06-cicd.md) | GitHub Actions workflows for all services |
| 7 | [Production Deployment](07-production-deployment.md) | Step-by-step Render + Neon deployment |
| 8 | [Monitoring & Logging](08-monitoring-logging.md) | Render logs, health checks, Neon console |
| 9 | [Troubleshooting](09-troubleshooting.md) | Common issues and fixes |
| 10 | [Architecture](10-architecture.md) | System diagram, bounded contexts, data flow, security |

## Quick Paths

### I want to run Jinbocho locally

1. [Prerequisites](01-prerequisites.md) — install Docker, Python, Node.js
2. [Local Development](02-local-development.md) — create a `docker-compose.yml` and start all services

### I want to deploy to production

1. [Prerequisites](01-prerequisites.md) — create Neon and Render accounts
2. [Local Development](02-local-development.md) — verify it works locally first
3. [Production Deployment](07-production-deployment.md) — step-by-step Render + Neon guide

### I need to understand the codebase

1. [Architecture](10-architecture.md) — system diagram, bounded contexts, design decisions
2. [Backend Services](03-backend-services.md) — service-by-service breakdown
3. [Frontend](04-frontend.md) — React architecture and critical gotchas

### Something is broken

1. [Troubleshooting](09-troubleshooting.md) — grouped by area (database, CORS, JWT, cold starts)
2. [Monitoring & Logging](08-monitoring-logging.md) — how to read Render logs

## Technology Stack

| Layer | Technology |
|-------|------------|
| Backend | Python 3.12, FastAPI, SQLAlchemy (async) |
| Database | PostgreSQL 16 (Neon in production) |
| Migrations | Alembic |
| Frontend | React 18, TypeScript strict, Vite, TanStack Query, Zustand |
| HTTP client | ky |
| Deployment | Docker Compose (dev), Render + Neon (prod) |
| CI/CD | GitHub Actions |
| Code quality | mypy (strict), ruff, pytest, vitest |

## Before Every Commit

```bash
# Backend (run in each changed service directory)
ruff check app tests
python -m mypy app --strict
pytest tests/ -v

# Frontend
cd jinbocho-fe
npm run typecheck && npm run test
```
