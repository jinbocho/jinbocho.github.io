# Prerequisiti

Prima di installare Jinbocho in locale o in produzione, assicurati che il tuo sistema soddisfi i seguenti requisiti.

## Sistema operativo

Jinbocho funziona su:
- **Linux** (Ubuntu 22.04 LTS o superiore, Debian 12+)
- **macOS** (12.0 o superiore, Intel o Apple Silicon)
- **Windows 11** (WSL2 con Ubuntu 22.04)

### Utenti Windows: configurazione WSL2

Se sei su Windows, usa Windows Subsystem for Linux 2:

```bash
# Installa WSL2 con Ubuntu 22.04
wsl --install -d Ubuntu-22.04

# Nel terminale WSL, verifica che siano disponibili almeno 4 GB di RAM
free -h
```

## Docker & Docker Compose

**Docker Desktop** o **Docker Engine** v20.10+ con **Docker Compose** v2.20+

### Installazione

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

**Verifica**:
```bash
docker --version      # v20.10.0 o superiore
docker compose version  # v2.20.0 o superiore
```

## Python 3.12

Tutti i servizi backend richiedono **Python 3.12** o superiore.

### Installazione

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

Lo sviluppo del frontend richiede **Node.js 18.0.0** o superiore con **npm 9.0.0** o superiore.

### Installazione

**macOS (Homebrew)**:
```bash
brew install node@18
node --version   # v18.x.x
npm --version    # 9.x.x o superiore
```

**Linux/WSL2**:
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version
npm --version
```

## Git

Necessario per clonare i repository.

**macOS**:
```bash
brew install git
```

**Linux/WSL2**:
```bash
sudo apt install git
```

**Verifica**:
```bash
git --version
```

## Client PostgreSQL (psql)

Facoltativo ma consigliato per ispezionare il database locale.

**macOS**:
```bash
brew install postgresql
```

**Linux/Ubuntu**:
```bash
sudo apt install postgresql-client
```

## Chiavi API esterne (facoltative)

Per la ricerca ISBN avanzata, considera di ottenere:

### Google Books API Key
- **Perché**: fallback per i metadati ISBN quando Open Library è lento
- **Costo**: livello gratuito (100 richieste/giorno)
- **Come ottenerla**: https://developers.google.com/books/docs/v1/using#APIKey
- **Quando serve**: imposta `GOOGLE_BOOKS_API_KEY` nel file `.env` del catalog-service

### LLM API Key (per ai-service)
- **Perché**: alimenta l'`ai-service` opzionale (presentazione/incipit dei libri, suggerimenti di tag, indizi di duplicati, raccomandazioni). Il servizio è **disattivato di default** — senza chiave continua a funzionare e gli endpoint AI restituiscono risultati vuoti, quindi il resto della piattaforma funziona invariato.
- **Costo**: livello gratuito disponibile (es. Groq)
- **Provider**: qualsiasi endpoint compatibile OpenAI — Groq, OpenAI, Google Gemini, o un'installazione locale di Ollama
- **Quando serve**: imposta `LLM_ENABLED=true` e `LLM_API_KEY` nel file `.env` dell'ai-service (vedi `jinbocho-ai-v1/README.md`)

## Account cloud (solo produzione)

Per il deploy su Render + Neon:

### Account Neon.tech
- **Scopo**: database PostgreSQL gestito
- **Costo**: livello gratuito (0,5 GB, sospensione automatica dopo 30 giorni di inattività)
- **Registrazione**: https://neon.tech
- **Perché**: migliore di Render Postgres (che è effimero)

### Account Render.com
- **Scopo**: hosting dei servizi backend + frontend
- **Costo**: livello gratuito (cold start accettabili), Starter a $7/mese per servizio
- **Registrazione**: https://render.com
- **Perché**: deploy Docker semplice, integrazione GitHub, SSL integrato

## Checkout dei repository

Crea una cartella di lavoro e clona tutti i repository Jinbocho dall'organizzazione GitHub:

```bash
mkdir -p ~/workspace/jinbocho && cd ~/workspace/jinbocho

# Clona i repository pubblici Jinbocho
git clone https://github.com/jinbocho/jinbocho-auth-v1.git
git clone https://github.com/jinbocho/jinbocho-catalog-v1.git
git clone https://github.com/jinbocho/jinbocho-api-gateway-v1.git
git clone https://github.com/jinbocho/jinbocho-ai-v1.git   # opzionale: funzionalità AI, disattivate di default
git clone https://github.com/jinbocho/jinbocho-fe.git

# Verifica che tutti i servizi siano presenti
ls | grep jinbocho
# Atteso: jinbocho-auth-v1  jinbocho-catalog-v1  jinbocho-api-gateway-v1  jinbocho-ai-v1  jinbocho-fe
```

Tutti i repository si trovano nell'organizzazione GitHub `jinbocho`: https://github.com/jinbocho

## Script di verifica dei prerequisiti

Esegui questo script per verificare che tutti i prerequisiti siano installati:

```bash
#!/bin/bash
echo "=== Verifica prerequisiti Jinbocho ==="
echo "OS: $(uname -s)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker compose version)"
echo "Python: $(python3.12 --version)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Git: $(git --version)"
echo "psql: $(psql --version 2>/dev/null || echo 'Non installato')"
echo "✅ Tutti i prerequisiti sono installati!"
```

## Prossimi passi

Una volta verificati tutti i prerequisiti:
1. Vai a **[Sviluppo Locale](02-local-development.md)** per configurare l'ambiente di sviluppo
2. Per il deploy in produzione, vedi **[Deploy in Produzione](07-production-deployment.md)**