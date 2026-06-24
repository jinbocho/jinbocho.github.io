# Monitoring e logging

## Visualizzare i log su Render

Ogni servizio (Web Service, Private Service, Static Site) ha una scheda **Logs** nella dashboard di Render.

### Accedi ai log del servizio

1. Dashboard Render → clicca sul nome del servizio
2. Clicca sulla scheda **Logs**
3. I log vengono trasmessi in tempo reale; usa la casella di ricerca per filtrare

### Cosa cercare all'avvio

Dopo un deploy, controlla i log per queste righe che confermano un avvio sano:

```
# auth-service, catalog-service e ai-service (ognuno ha il proprio database):
INFO  [alembic] Running upgrade -> <revision>, <description>
INFO  [alembic] Done.
INFO:     Application startup complete.

# api-gateway (nessun database):
INFO:     Application startup complete.

# Qualsiasi servizio — segnale negativo:
ERROR - Connection refused
sqlalchemy.exc.OperationalError: (asyncpg.exceptions.InvalidPasswordError)
```

Se le righe di Alembic mancano o mostrano errori, `DATABASE_URL` è configurato in modo errato.

## Health check

Tutti i servizi backend espongono `GET /health`. Render interroga questo endpoint e riavvia automaticamente un servizio se non risponde.

```bash
# Controlla tutti i servizi manualmente
curl https://jinbocho-api-gateway.onrender.com/health

# In sviluppo locale
curl http://localhost:8000/health   # gateway
curl http://localhost:8001/health   # auth
curl http://localhost:8002/health   # catalog
curl http://localhost:8003/health   # ai (servizio opzionale)
```

Risposta attesa: `{"status": "ok"}`

## Logging SQL (modalità DEBUG)

Impostare `DEBUG=true` abilita il logging delle query SQLAlchemy — ogni istruzione SQL viene stampata su stdout.

```bash
# .env locale — abilita per lo sviluppo
DEBUG=true

# Render / produzione — disabilita sempre
DEBUG=false
```

Il logging SQL è utile per diagnosticare query N+1 o lente in locale. Non abilitarlo mai in produzione: è verboso, espone dati nei log e degrada le prestazioni.

## Logging dell'applicazione

Tutti i servizi usano la libreria `logging` standard di Python. Livelli di log:

| Livello | Quando |
|--------|-------|
| `INFO` | Avvio del servizio, completamento migrazioni, riepiloghi delle richieste |
| `WARNING` | Problemi non critici (es. ISBN non trovato in nessuna fonte) |
| `ERROR` | Eccezioni, richieste fallite, errori del database |

I log vengono scritti su stdout e raccolti automaticamente da Render.

### Esempio di output di log (auth-service)

```
INFO:uvicorn.access:POST /v1/auth/login HTTP/1.1 200
INFO:uvicorn.access:POST /v1/auth/refresh HTTP/1.1 200
WARNING:app.infrastructure:ISBN 9999999999 not found in Open Library or Google Books
ERROR:app.api:Unhandled exception in POST /v1/auth/login
Traceback (most recent call last): ...
```

## Monitoraggio dei database Neon

La [console Neon](https://console.neon.tech) fornisce:

- **Utilizzo dello storage** — rimani entro i 0,5 GB del livello gratuito
- **Cronologia delle query** — query recenti e durate (utile per il debug delle prestazioni)
- **Conteggio connessioni** — monitora le connessioni attive; asyncpg ne mantiene un piccolo pool per servizio
- **Stato del compute** — mostra se il compute è attivo o sospeso (sospensione automatica dopo 5 min di inattività nel livello gratuito)

!!! tip "Sospensione automatica Neon"
    Nel livello gratuito, Neon sospende il compute dopo 5 minuti di inattività. La prima query dopo la sospensione impiega ~500ms per riconnettersi. Per una biblioteca domestica questo è impercettibile. Se diventa un problema, passa a Neon Launch ($19/mese) per disabilitare la sospensione automatica.

## Stato del servizio Render

La dashboard Render mostra:

- **Cronologia dei deploy** — ogni deploy con il suo stato (in corso / attivo / fallito)
- **Metriche** — grafici di utilizzo CPU e memoria per servizio
- **Eventi** — riavvii automatici, fallimenti degli health check, deploy

Per i servizi del livello gratuito, l'indicatore **Suspended** indica che il servizio è in modalità cold start. La prossima richiesta lo risveglia (ritardo di 30-60 secondi).

## Tracciamento degli errori (opzionale)

Per uso in produzione oltre una singola famiglia, aggiungi [Sentry](https://sentry.io):

1. Crea un progetto Sentry (livello gratuito disponibile)
2. Aggiungi `sentry-sdk[fastapi]` a `requirements.txt`
3. Inizializza in `app/main.py`:

```python
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn=os.environ.get("SENTRY_DSN", ""),
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1,   # 10% delle richieste tracciate
    environment="production",
)
```

4. Aggiungi `SENTRY_DSN` alle variabili d'ambiente Render per ogni servizio

Sentry cattura le eccezioni non gestite con stack trace completi e le raggruppa per tipo — molto più comodo che leggere i log grezzi.