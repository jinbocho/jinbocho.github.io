# Risoluzione dei problemi

Problemi comuni e come risolverli, raggruppati per area.

---

## Problemi di database

### `OperationalError: Connection refused` all'avvio

**Causa**: il servizio si è avviato prima che PostgreSQL fosse pronto.

**Soluzione locale**: Docker Compose usa gli health check — non dovrebbe accadere. Se accade:
```bash
docker compose restart auth-service   # riprova dopo che il DB è sano
```

**Soluzione Render**: il `DATABASE_URL` del servizio è errato — probabilmente un errore di battitura nell'host o nella porta. Verifica la stringa di connessione Neon nell'ambiente Render, poi triggera un rideploy manuale.

---

### `asyncpg.exceptions.InvalidAuthorizationSpecificationError`

**Causa**: password errata nella stringa di connessione.

**Soluzione**: ricopia la stringa di connessione Neon da **Dettagli di connessione** nella console Neon. Assicurati di non aver modificato accidentalmente il segmento della password.

---

### `SSL SYSCALL error: EOF detected` / `ssl=require not recognized`

**Causa**: asyncpg non capisce `sslmode=require` (la stringa predefinita di Neon usa questo). Devi usare `ssl=require` invece.

**Soluzione**: nel `DATABASE_URL`, sostituisci `?sslmode=require` con `?ssl=require`.

```
# Sbagliato
postgresql+asyncpg://...?sslmode=require

# Corretto
postgresql+asyncpg://...?ssl=require
```

---

### La migrazione Alembic fallisce all'avvio

**Sintomo**: nei log del servizio vedi `alembic.util.exc.CommandError` o `relation "xxx" already exists`.

**Soluzione**:

1. Controlla se è stata eseguita una migrazione parziale: connettiti a Neon con psql e ispeziona `alembic_version`
2. Esegui la migrazione manualmente per identificare il passo che fallisce:
   ```bash
   cd jinbocho-auth-v1
   export DATABASE_URL="postgresql+asyncpg://...neon.tech/auth_db?ssl=require"
   alembic upgrade head
   ```
3. Se lo schema è in uno stato inconsistente, resettalo:
   ```bash
   # Elimina e ricrea il database nella console Neon, poi ridistribuisci
   # (Alembic rieseguirà tutte le migrazioni da zero)
   ```

---

## Problemi tra servizi

### Il catalog service restituisce 401 per ogni richiesta

**Causa**: il `JWT_SECRET_KEY` del catalog-service non corrisponde all'auth-service.

**Verifica**: il JWT è firmato da auth e verificato da catalog. Se i segreti differiscono, ogni token fallirà la validazione silenziosamente.

**Soluzione**: conferma che `JWT_SECRET_KEY` sia **esattamente la stessa** stringa nelle variabili d'ambiente di auth, catalog e gateway su Render. Gli errori di copia-incolla (spazi finali, ritorni a capo) sono comuni.

---

### Il gateway restituisce `502 Bad Gateway`

**Causa**: il gateway non riesce a raggiungere un Servizio Privato interno.

**Controlli**:

1. L'URL del servizio interno nell'ambiente del gateway è errato — copialo direttamente dalla pagina del servizio su Render (non dall'URL pubblico — i Servizi Privati non hanno URL pubblico)
2. Il Servizio Privato sta ancora eseguendo il deploy o si è bloccato — controlla i suoi log
3. Il gateway e il servizio interno sono in **regioni Render diverse** — i Servizi Privati comunicano solo all'interno della stessa regione

---

### `AUTH_SERVICE_URL` da catalog restituisce `Connection refused`

**Causa**: il catalog usa `http://jinbocho-auth:8001` ma il nome host interno Render effettivo è diverso.

**Soluzione**: su Render, il nome host interno di un servizio è mostrato nella pagina del servizio. Usa esattamente quel valore — non cercare di indovinarlo o costruirlo manualmente.

---

## Problemi Frontend / CORS

### Errore CORS nella console del browser: `Access-Control-Allow-Origin mancante`

**Causa**: il `CORS_ORIGINS` del gateway non include l'URL del frontend.

**Soluzione**:

1. Render → api-gateway → **Environment**
2. Imposta `CORS_ORIGINS` all'origin esatta del frontend: `["https://jinbocho-fe.onrender.com"]`
   - Nessuna barra finale
   - Deve essere un array JSON valido (virgolette doppie, parentesi quadre)
3. Salva e attendi il rideploy

---

### Il frontend mostra una pagina bianca dopo il deploy

**Causa**: `VITE_API_BASE_URL` non era impostato al momento della build, quindi le chiamate API vanno all'URL sbagliato.

**Soluzione**: su Render Static Site, verifica che `VITE_API_BASE_URL` sia impostato all'URL pubblico del gateway. Poi clicca **Clear build cache & deploy** — Vite incorpora le variabili d'ambiente al momento della build, quindi un semplice rideploy non basta se la variabile è stata aggiunta dopo l'ultima build.

---

### Il login ha successo ma tutte le chiamate API successive restituiscono 401

**Causa**: il token di accesso viene inviato correttamente ma il gateway o un servizio backend lo rifiuta.

**Controlli**:

1. Apri DevTools del browser → scheda Network → ispeziona l'header `Authorization` di una richiesta che fallisce
2. Decodifica il JWT su [jwt.io](https://jwt.io) — controlla che `iss` e `aud` corrispondano a ciò che catalog si aspetta (`iss: jinbocho-auth`, `aud: jinbocho`)
3. Conferma che `JWT_ALGORITHM` sia `HS256` su tutti i servizi

---

## Problemi di ricerca ISBN

### La ricerca ISBN restituisce 404 per un ISBN valido

**Causa**: il libro non è in Open Library o Google Books, o la chiave API di Google Books è mancante/non valida.

**Controlli**:

1. Testa Open Library direttamente:
   ```bash
   curl "https://openlibrary.org/api/books?bibkeys=ISBN:9788845292613&format=json&jscmd=data"
   ```
2. Se Open Library restituisce dati ma il servizio non lo fa, controlla i log del catalog-service per gli errori
3. Se `GOOGLE_BOOKS_API_KEY` è mancante, la ricerca di fallback viene saltata — aggiungi la chiave all'ambiente Render

---

### La ricerca ISBN è lenta (> 2 secondi)

**Causa**: l'ISBN non è nella cache locale e la ricerca esterna è lenta.

**Soluzione**: è previsto per la prima ricerca di qualsiasi ISBN. Le ricerche successive per lo stesso ISBN vengono servite dalla tabella `isbn_cache` e sono veloci. Se le ricerche esterne sono costantemente lente, controlla la latenza tra la tua regione Neon e la regione Render.

---

## Cold Start (livello gratuito)

### La prima richiesta dopo l'inattività impiega 30-60 secondi

**Causa**: i servizi del livello gratuito di Render si addormentano dopo 15 minuti di inattività. La prima richiesta li risveglia.

**Opzioni**:

1. **Accettalo** — per una biblioteca domestica usata da poche persone, i cold start sono tollerabili
2. **Passa a Render Starter** ($7/mese per servizio) — i servizi rimangono sempre attivi
3. **Pinga periodicamente il gateway** — un servizio cron esterno (es. cron-job.org, gratuito) può chiamare `/health` ogni 10 minuti per mantenere attivo il gateway. I Servizi Privati dietro di esso avranno ancora il cold start, ma il gateway risponde istantaneamente.

```bash
# Esempio: configura un cron job gratuito per pingare il gateway ogni 10 minuti
# URL: https://jinbocho-api-gateway.onrender.com/health
# Metodo: GET
# Schedule: */10 * * * *
```

4. **Risveglia tutto a richiesta** — `jinbocho-infrastructure-v1` include una GitHub Action `wake-render.yml` (trigger solo `workflow_dispatch`, manuale — **non** è schedulata) che pinga in sequenza frontend, gateway, auth, catalog e ai-service e attende che tutti rispondano `200`. Eseguila dalla scheda **Actions** poco prima di una demo o di una sessione di test manuale, invece di aspettare 4-5 cold start separati uno alla volta. È uno strumento di comodità, non un sostituto dell'opzione 3 se vuoi che i servizi non si addormentino mai.

---

## Problemi di sviluppo locale

### Porta già in uso

```bash
# Trova il processo che usa la porta 8000
lsof -i :8000

# Terminalo
kill -9 <PID>

# Oppure cambia la porta in docker-compose.yml
```

### `mypy` in modalità strict fallisce su un nuovo modulo

Se aggiungi un nuovo file e `mypy --strict` si lamenta delle annotazioni di tipo mancanti:

```bash
# Esegui mypy e vedi gli errori specifici
python -m mypy app --strict 2>&1 | grep error

# Correzioni comuni:
# - Aggiungi annotazione del tipo di ritorno a ogni funzione
# - Aggiungi annotazioni di tipo a tutte le variabili
# - Segna i parametri opzionali con Optional[T] o T | None
```

### `ruff check` fallisce dopo la modifica

```bash
# Vedi esattamente cosa è fallito
ruff check app tests

# Auto-correggi ciò che ruff può
ruff check --fix app tests

# Per i problemi rimanenti, correggili manualmente (ruff mostra i numeri di riga)
```