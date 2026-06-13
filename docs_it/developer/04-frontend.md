# Frontend

**Repository**: `jinbocho-fe`  
**Stack**: React 18 + TypeScript strict · Vite · Tailwind CSS · TanStack Query · Zustand · React Router · ky · React Hook Form + Zod

## Configurazione

```bash
cd ~/workspace/jinbocho/jinbocho-fe
npm ci               # installa le dipendenze (rispetta il lockfile)
cp .env.example .env # modifica VITE_API_BASE_URL
npm run dev          # server di sviluppo su http://localhost:5173
```

### Variabili d'ambiente

| Variabile | Esempio | Descrizione |
|-----------|---------|------------|
| `VITE_API_BASE_URL` | `http://localhost:8000` | URL del gateway backend |

In produzione, imposta `VITE_API_BASE_URL` sull'URL pubblico del gateway su Render. Vite integra questa variabile in fase di build — **è necessario ricompilare dopo averla cambiata**.

## Comandi

```bash
npm run dev          # server di sviluppo con HMR
npm run build        # build di produzione → dist/
npm run typecheck    # tsc --noEmit (esegui prima di ogni commit)
npm run test         # vitest run (tutti i test unit + component)
npm run lint         # ESLint + controllo Prettier
```

Esegui sempre `npm run typecheck && npm run test` prima di fare push.

## Struttura del progetto

```
src/
├── main.tsx              # Bootstrap: router + QueryClient + provider
├── App.tsx               # Albero delle route
├── routes/               # Un file per pagina (solo JSX, nessuna logica dati)
│   ├── auth/LoginPage.tsx
│   ├── auth/RegisterPage.tsx
│   ├── DashboardPage.tsx
│   ├── books/BookCatalogPage.tsx
│   ├── books/BookDetailPage.tsx
│   ├── books/AddBookPage.tsx
│   ├── locations/LocationsPage.tsx
│   ├── locations/BookcaseMapPage.tsx
│   ├── users/UsersPage.tsx
│   └── settings/SettingsPage.tsx
├── features/             # Layer dati (hook TanStack, tipi, helper — nessun JSX)
│   ├── auth/             # useLogin, useRegister, token store, decodifica JWT, guardie
│   ├── books/            # useBooks, useBookWithRecord, mutations, joinBooksToRecords()
│   ├── records/          # useRecords (ricerca), useIsbnLookup
│   ├── locations/        # useRooms, useBookcases, useSections, useShelves
│   ├── users/            # useUsers, useCurrentUser
│   └── family/           # useFamily
├── components/
│   ├── ui/               # Primitivi: Button, Input, Modal, Toast, Badge…
│   ├── layout/           # AppShell, Sidebar, BottomNav, TopBar
│   └── feedback/         # EmptyState, ErrorState, Spinner
├── lib/
│   ├── api.ts            # Istanza ky + bearer token + interceptor 401→refresh→retry
│   ├── queryClient.ts    # Configurazione TanStack Query
│   ├── jwt.ts            # Decodifica token + helper di scadenza
│   └── format.ts         # Formattatori di date, etichette, stato di lettura
├── types/
│   └── api.ts            # Tipi TS scritti a mano che rispecchiano gli schema Pydantic del backend
├── hooks/                # Hook generici (useDebounce, useMediaQuery)
└── styles/index.css      # Direttive Tailwind + proprietà CSS personalizzate (palette Pergamena)
```

**Convenzione**: `features/` contiene la logica dati (hook, helper, tipi) — nessun JSX. `routes/` e `components/` contengono JSX.

## Gestione dello stato

| Tipo di stato | Strumento |
|--------------|----------|
| Stato server (libri, stanze, ecc.) | **TanStack Query** |
| Sessione auth (token JWT) | **Zustand** (`features/auth/store.ts`) |
| Stato dei form | **React Hook Form + Zod** |
| Tutto il resto | `useState` locale |

Non esiste altro stato globale. Non aggiungere store Zustand per dati server.

## Client API (`lib/api.ts`)

Tutte le richieste passano attraverso un'istanza `ky` configurata con:

1. Header `Authorization: Bearer <access_token>` su ogni richiesta
2. Un interceptor `401 → refresh → retry`: in caso di risposta 401, tenta il refresh silenzioso del token di accesso, poi riprova la richiesta originale
3. `VITE_API_BASE_URL` come prefisso

```ts
// Utilizzo nelle features:
import { api } from '@/lib/api'

const books = await api.get('v1/books/', { searchParams: { limit: 50 } }).json()
```

## Pattern degli hook per le feature

Ogni `features/<dominio>/hooks.ts` esporta hook TanStack Query:

```ts
// Lettura — restituisce dati dalla cache + aggiornati
export function useBooks() { ... }
export function useBookWithRecord(id: string) { ... }

// Scrittura — mutation che invalidano le cache
export function useAddBook() { ... }
export function useUpdateBookPosition() { ... }
export function useUpdateReadingStatus() { ... }
```

Le pagine compongono questi hook; non chiamano mai `api` direttamente.

## Comportamenti critici del backend

Questi sono comportamenti non ovvi del backend che influenzano l'implementazione del frontend.

### 1. OwnedBook non ha titolo o autore

`GET /v1/books/` restituisce `OwnedBook[]`. Ogni elemento ha solo `bibliographic_record_id`, i campi di posizione e lo stato di lettura — **nessun titolo, nessun autore**.

Collegati sempre ai record bibliografici in memoria:

```ts
// features/books/hooks.ts
function joinBooksToRecords(books: OwnedBook[], records: BibliographicRecord[]) {
  const recordMap = new Map(records.map(r => [r.id, r]))
  return books.map(b => ({ ...b, record: recordMap.get(b.bibliographic_record_id) }))
}
```

### 2. Posizione e stato di lettura usano query param

Questi due endpoint **non accettano un corpo JSON** — i parametri devono essere nella query string:

```ts
// CORRETTO
api.post(`v1/books/${id}/reading-status`, {
  searchParams: { reading_status: 'read' }
})

api.post(`v1/books/${id}/position`, {
  searchParams: { section_id: sectionId, shelf_id: shelfId, position: pos }
})

// SBAGLIATO — il corpo viene ignorato
api.post(`v1/books/${id}/reading-status`, { json: { reading_status: 'read' } })
```

### 3. La registrazione non restituisce un token

`POST /v1/auth/register` restituisce solo `{ family_id, user_id }`. Non emette un JWT. Dopo la registrazione, chiama immediatamente il login:

```ts
await api.post('v1/auth/register', { json: data })
const tokens = await api.post('v1/auth/login', { json: { email, password } }).json()
```

### 4. I timestamp del catalog sono stringhe ISO

Il backend serializza i campi `datetime` come stringhe ISO 8601. Tipizzali come `string` in `types/api.ts`, non come `Date`. Usa `new Date(str)` solo quando necessario per la visualizzazione.

### 5. La ricerca è sui record, non sui libri

`GET /v1/records/?q=` cerca per titolo/autore/ISBN. `GET /v1/books/` supporta solo `limit`/`offset`. Filtrare i libri per stanza o stato di lettura avviene **lato client** sull'insieme caricato — accettabile per una biblioteca domestica.

### 6. Payload JWT — decodifica lato client

Il token di accesso codifica `sub` (user_id), `email`, `family_id`, `role` e `exp`. Decodificalo in `lib/jwt.ts` per leggere il ruolo e il family_id dell'utente corrente senza una richiesta aggiuntiva.

## Tipi (`types/api.ts`)

Questo file è la **fonte unica di verità** per tutte le strutture del backend — scritto a mano per rispecchiare gli schema Pydantic. Aggiornalo ogni volta che lo schema del backend cambia.

```ts
// Valori corretti di reading-status (da backend enums.py)
export type ReadingStatus = 'to_read' | 'reading' | 'read'

export interface OwnedBook {
  id: string
  bibliographic_record_id: string
  shelf_id: string
  position: number
  reading_status: ReadingStatus
  created_at: string    // stringa ISO — non Date
  updated_at: string
}

export interface BibliographicRecord {
  id: string
  title: string
  author: string
  isbn: string | null
  publisher: string | null
  published_year: number | null
  cover_url: string | null
}
```

## Design system

I colori sono proprietà CSS personalizzate in `styles/index.css` (palette Pergamena). Tailwind le mappa tramite `tailwind.config.ts`. **Non codificare mai valori esadecimali nei componenti** — usa sempre i token Tailwind.

| Token | Colore | Uso |
|-------|--------|
| `paper` | `#FBF7F0` | Sfondo dell'app |
| `ink` | `#2B2622` | Testo principale |
| `brand` | `#A8503A` | Azioni primarie (terracotta) |
| `sage` | `#7A8B6F` | Stato "letto" |
| `amber` | `#C9912E` | Stato "in lettura" |
| `stone` | `#9A9187` | Stato "da leggere" |

Il mapping stato di lettura → colore è centralizzato in `lib/format.ts`. Non duplicarlo nei componenti.

## Build per la produzione

```bash
cd ~/workspace/jinbocho/jinbocho-fe
VITE_API_BASE_URL=https://jinbocho-api-gateway.onrender.com npm run build
# Output: dist/
```

La cartella `dist/` è un sito statico — distribuiscila su Render Static Site o qualsiasi CDN. Il file `render.yaml` in `jinbocho-fe` configura già la directory di pubblicazione corretta e la regola di rewrite per SPA (`/* → /index.html`).