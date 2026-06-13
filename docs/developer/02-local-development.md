# Local Development Setup

Get your local development environment running with Docker Compose in 5 minutes.

## Quick Start

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
docker compose up --build -d
```

That's it. All backend services and databases are now running. Move to **[Verification](#verification)** to test.

## Full Setup Guide

### 1. Set Up the Workspace

If you haven't cloned the repositories yet, follow the [Repositories Checkout](01-prerequisites.md#repositories-checkout) instructions in Prerequisites. Each repository is hosted under the [jinbocho](https://github.com/jinbocho) GitHub organization.

Once cloned, navigate to the infrastructure directory:

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
```

### 2. Configure Environment Variables

Each service needs a `.env` file. Use the provided templates:

```bash
# Auth Service
cp ../jinbocho-auth-v1/.env.example ../jinbocho-auth-v1/.env

# Catalog Service
cp ../jinbocho-catalog-v1/.env.example ../jinbocho-catalog-v1/.env

# API Gateway
cp ../jinbocho-api-gateway-v1/.env.example ../jinbocho-api-gateway-v1/.env

# Frontend (if needed)
cp ../jinbocho-fe/.env.example ../jinbocho-fe/.env
```

**Key environment variables for local development**:

| Variable | Value | Purpose |
|----------|-------|--------|
| `DEBUG` | `true` | Enable SQL logging to see all database queries |
| `DATABASE_URL` | `postgresql+asyncpg://postgres:password@postgres:5432/auth_db` | Local DB connection (Docker Compose provides this) |
| `JWT_SECRET_KEY` | `dev-secret-key-change-in-prod` | **Shared** across all services for JWT validation |
| `CORS_ORIGINS` | `["http://localhost:5173", "http://localhost:3000"]` | Allow frontend requests |
| `AUTH_SERVICE_URL` | `http://auth-service:8001` | Internal service address (Docker network) |
| `CATALOG_SERVICE_URL` | `http://catalog-service:8002` | Internal service address |

**Note**: All `.env` files are in `.gitignore`. Never commit them.

### 3. Start Docker Compose

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
docker compose up --build -d
```

**Flags explained**:
- `--build`: Rebuild images if Dockerfile changed
- `-d`: Run in background (detached mode)

**Check status**:
```bash
docker compose ps
```

Expected output:
```
NAME               COMMAND               STATUS           PORTS
auth-service       uvicorn app.main...   Up 5 seconds     0.0.0.0:8001->8000/tcp
catalog-service    uvicorn app.main...   Up 5 seconds     0.0.0.0:8002->8000/tcp
api-gateway        uvicorn app.main...   Up 5 seconds     0.0.0.0:8000->8000/tcp
ai-service         uvicorn app.main...   Up 5 seconds     0.0.0.0:8003->8000/tcp
postgres_auth      postgres -c ...       Up 10 seconds    127.0.0.1:5432->5432/tcp
postgres_catalog   postgres -c ...       Up 10 seconds    127.0.0.1:5433->5432/tcp
postgres_ai        postgres -c ...       Up 10 seconds    127.0.0.1:5434->5432/tcp
```

### 4. View Logs

**Tail all services**:
```bash
docker compose logs -f
```

**Tail a specific service**:
```bash
docker compose logs -f auth-service
```

**View only recent logs** (no tail):
```bash
docker compose logs auth-service
```

Press `Ctrl+C` to stop tailing.

## Port Mapping

| Service | Port | Type | Purpose |
|---------|------|------|--------|
| **api-gateway** | `8000` | Public | Entry point for frontend requests |
| **auth-service** | `8001` | Internal | User/family/JWT management |
| **catalog-service** | `8002` | Internal | Books, locations, ISBN lookup |
| **ai-service** | `8003` | Internal | Tagging, dedup, recommendations |
| **postgres (auth)** | `5432` | Internal | Auth database |
| **postgres (catalog)** | `5433` | Internal | Catalog database |
| **postgres (ai)** | `5434` | Internal | AI database |

**Accessing services from your machine**:
- Frontend → Backend: `http://localhost:8000`
- Swagger docs (auth): `http://localhost:8001/docs`
- Swagger docs (catalog): `http://localhost:8002/docs`
- Swagger docs (gateway): `http://localhost:8000/docs`

## Frontend Development Server

In a new terminal:

```bash
cd ~/workspace/jinbocho/jinbocho-fe
npm ci              # Install dependencies (first time only)
npm run dev
```

The frontend will start on `http://localhost:5173` with hot reload enabled.

### Environment Variables for Frontend

Edit `jinbocho-fe/.env`:

```env
VITE_API_BASE_URL=http://localhost:8000
```

This tells the frontend where to find the backend API. In production, this points to your Render URL.

## Convenience Script

Start both backend and frontend in one command:

```bash
cd ~/workspace/jinbocho/jinbocho-infrastructure-v1
bash dev.sh
```

This script:
1. Starts Docker Compose in background
2. Waits for services to be healthy
3. Launches the Vite dev server in a new terminal

## Database Inspection

### Connect to a Service Database

```bash
# Auth service database
psql -U postgres -h localhost -p 5432 -d auth_db

# Catalog service database
psql -U postgres -h localhost -p 5433 -d catalog_db

# AI service database
psql -U postgres -h localhost -p 5434 -d ai_db
```

### Useful psql Commands

```sql
-- List all tables
\dt

-- Show table structure
\d users

-- Run a query
SELECT * FROM users LIMIT 5;

-- Exit
\q
```

## Verification

### Health Checks

```bash
curl http://localhost:8000/health
# Expected: {"status":"ok"}

curl http://localhost:8001/health
# Expected: {"status":"ok"}

curl http://localhost:8002/health
# Expected: {"status":"ok"}
```

### Test a Full Flow

```bash
# 1. Register a family/user
curl -X POST http://localhost:8000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "family_name": "Test Family",
    "user_name": "Alice",
    "email": "alice@example.com",
    "password": "SecurePassword123!"
  }'

# 2. Login
curl -X POST http://localhost:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePassword123!"
  }'
# Copy the access_token from response

# 3. Create a room (using the token)
TOKEN="your-access-token-here"
curl -X POST http://localhost:8000/v1/locations/rooms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Living Room"
  }'
```

## Stopping Development Environment

**Stop all services** (but keep data):
```bash
docker compose stop
```

**Remove containers** (but keep volumes/data):
```bash
docker compose down
```

**Remove everything** (including databases):
```bash
docker compose down -v
```

⚠️ **Warning**: `docker compose down -v` deletes all local data. Use this to reset the database.

## Troubleshooting

### Port Already in Use

If port 8000 (or another) is already in use:

```bash
# Find what's using the port
lsof -i :8000

# Kill the process (macOS/Linux)
kill -9 <PID>

# Or change the port in docker-compose.yml
# Edit: ports: "8001:8000" (maps 8001 on host to 8000 in container)
```

### Database Connection Refused

```bash
docker compose ps
# If postgres containers are not running, restart:
docker compose restart postgres_auth postgres_catalog postgres_ai
```

### Service Won't Start

```bash
# Check logs for error messages
docker compose logs auth-service

# Rebuild the image
docker compose build --no-cache auth-service
docker compose up -d auth-service
```

### Environment Variables Not Applied

`.env` files are read at container startup. If you change an env var:

```bash
# Restart the service
docker compose restart auth-service
```

## Next Steps

- **Run tests**: See **[Database & Migrations](05-database-migrations.md)** for test setup
- **Deploy frontend**: See **[Frontend](04-frontend.md)** for npm commands
- **Inspect database**: Use `psql` commands above to connect locally
- **View API docs**: Visit `http://localhost:8001/docs` (auth-service Swagger UI)
