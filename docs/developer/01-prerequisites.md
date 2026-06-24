# Prerequisites

Before deploying Jinbocho locally or to production, ensure your system meets the following requirements.

## Operating System

Jinbocho runs on:
- **Linux** (Ubuntu 22.04 LTS or later, Debian 12+)
- **macOS** (12.0 or later, Intel or Apple Silicon)
- **Windows 11** (WSL2 with Ubuntu 22.04)

### Windows Users: WSL2 Setup

If you're on Windows, use Windows Subsystem for Linux 2:

```bash
# Install WSL2 and Ubuntu 22.04
wsl --install -d Ubuntu-22.04

# Inside WSL terminal, verify you have at least 4GB RAM available
free -h
```

## Docker & Docker Compose

**Docker Desktop** or **Docker Engine** v20.10+ with **Docker Compose** v2.20+

### Installation

**macOS (Homebrew)**:
```bash
brew install docker docker-compose
```

**Linux (Ubuntu/Debian)**:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

**Verify**:
```bash
docker --version      # v20.10.0 or later
docker compose version  # v2.20.0 or later
```

## Python 3.12

All backend services require **Python 3.12** or later.

### Installation

**macOS (Homebrew)**:
```bash
brew install python@3.12
python3.12 --version
```

**Linux (Ubuntu/Debian)**:
```bash
sudo apt update
sudo apt install python3.12 python3.12-venv python3.12-dev
python3.12 --version
```

**Windows (WSL2)**:
```bash
sudo apt update
sudo apt install python3.12 python3.12-venv python3.12-dev
```

## Node.js 18+

Frontend development requires **Node.js 18.0.0** or later with **npm 9.0.0** or later.

### Installation

**macOS (Homebrew)**:
```bash
brew install node@18
node --version   # v18.x.x
npm --version    # 9.x.x or later
```

**Linux/WSL2**:
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version
npm --version
```

## Git

Required for cloning repositories.

**macOS**:
```bash
brew install git
```

**Linux/WSL2**:
```bash
sudo apt install git
```

**Verify**:
```bash
git --version
```

## PostgreSQL Client (psql)

Optional but recommended for local database inspection.

**macOS**:
```bash
brew install postgresql
```

**Linux/Ubuntu**:
```bash
sudo apt install postgresql-client
```

## External API Keys (Optional)

For enhanced ISBN lookup functionality, consider obtaining:

### Google Books API Key
- **Why**: Fallback for ISBN metadata when Open Library is slow
- **Cost**: Free tier (100 queries/day)
- **How to get**: https://developers.google.com/books/docs/v1/using#APIKey
- **When needed**: Set `GOOGLE_BOOKS_API_KEY` in the catalog-service `.env`

### LLM API Key (for ai-service)
- **Why**: Powers the optional `ai-service` (book presentation/incipit, tag suggestions, dedup hints, recommendations). The service is **off by default** — with no key it still runs and AI endpoints return empty results, so the rest of the platform works unchanged.
- **Cost**: Free tier available (e.g. Groq)
- **Providers**: any OpenAI-compatible endpoint — Groq, OpenAI, Google Gemini, or a local Ollama install
- **When needed**: Set `LLM_ENABLED=true` and `LLM_API_KEY` in the ai-service `.env` (see `jinbocho-ai-v1/README.md`)

## Cloud Accounts (Production Only)

For production deployment on Render + Neon:

### Neon.tech Account
- **Purpose**: Managed PostgreSQL databases
- **Cost**: Free tier (0.5GB, auto-suspend after 30 days inactivity)
- **Sign up**: https://neon.tech
- **Why**: Better than Render Postgres (which is ephemeral)

### Render.com Account
- **Purpose**: Hosting backend services + frontend
- **Cost**: Free tier (cold starts OK), Starter $7/mo per service
- **Sign up**: https://render.com
- **Why**: Easy Docker deployment, GitHub integration, built-in SSL

## Repositories Checkout

Create a workspace folder and clone all Jinbocho repositories from the GitHub organization:

```bash
mkdir -p ~/workspace/jinbocho && cd ~/workspace/jinbocho

# Clone the public Jinbocho repositories
git clone https://github.com/jinbocho/jinbocho-auth-v1.git
git clone https://github.com/jinbocho/jinbocho-catalog-v1.git
git clone https://github.com/jinbocho/jinbocho-api-gateway-v1.git
git clone https://github.com/jinbocho/jinbocho-ai-v1.git   # optional: AI features, off by default
git clone https://github.com/jinbocho/jinbocho-fe.git

# Verify all services are present
ls | grep jinbocho
# Expected: jinbocho-auth-v1  jinbocho-catalog-v1  jinbocho-api-gateway-v1  jinbocho-ai-v1  jinbocho-fe
```

All public repositories live under the `jinbocho` GitHub organization: https://github.com/jinbocho

## System Check Script

Run this to verify all prerequisites are installed:

```bash
#!/bin/bash
echo "=== Jinbocho Prerequisites Check ==="
echo "OS: $(uname -s)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker compose version)"
echo "Python: $(python3.12 --version)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Git: $(git --version)"
echo "psql: $(psql --version 2>/dev/null || echo 'Not installed')"
echo "✅ All prerequisites installed!"
```

## Next Steps

Once you've verified all prerequisites:
1. Go to **[Local Development](02-local-development.md)** to set up your development environment
2. For production deployment, see **[Production Deployment](07-production-deployment.md)**
