# Uso su mobile

Jinbocho è un'applicazione web che funziona su qualsiasi smartphone o tablet moderno
senza bisogno di installazione. Aprila nel browser del telefono e si adatta automaticamente allo schermo.

---

## Nessuna app da installare

Jinbocho funziona nel browser. Su mobile, apri il browser che preferisci
e vai all'URL di Jinbocho:

- **iOS** — Safari, Chrome o Firefox
- **Android** — Chrome, Firefox o Samsung Internet

!!! tip "Aggiungi alla schermata Home"
    Jinbocho è una normale web app — non esiste una PWA installabile (nessun
    manifest dell'app, nessun supporto offline). Puoi comunque aggiungere una
    scorciatoia alla schermata Home per un accesso rapido:

    **iOS (Safari)**: tocca l'icona Condividi → **Aggiungi alla schermata Home** → **Aggiungi**

    **Android (Chrome)**: tocca il menu → **Aggiungi a schermata Home** → **Aggiungi**

    Questo crea una scorciatoia in stile segnalibro. Se si apre a schermo intero
    o con la barra degli indirizzi del browser visibile dipende dal browser e dal
    sistema operativo — non è garantito che sia priva di elementi del browser come
    una vera app installata.

---

## Layout mobile

Sotto il breakpoint desktop (768px), Jinbocho passa a un **layout mobile**:
una sottile barra superiore sostituisce la sidebar completa, e la navigazione
si sposta in un drawer scorrevole laterale.

```
┌─────────────────────────────┐
│  ☰   Jinbocho          ⏻   │  ← Barra superiore (menu, logout)
├─────────────────────────────┤
│                             │
│  [Scheda libro]              │
│  The Name of the Wind       │
│  Patrick Rothfuss · 🟡      │
│                             │
│  [Scheda libro]              │
│  Il deserto dei Tartari     │
│  Dino Buzzati · 🟢          │
│                             │
│  [Scheda libro]              │
│  …                          │
│                             │
└─────────────────────────────┘
```

Toccando `☰` si apre un drawer con la navigazione completa: Home, Libri,
Lista dei desideri, In Prestito, Posizioni, Statistiche, Utenti (solo admin) e
Impostazioni — le stesse voci mostrate nella sidebar su desktop.

---

## Scansione ISBN su mobile

Lo scanner di codici a barre funziona meglio su mobile perché le fotocamere
degli smartphone hanno autofocus e una buona lente macro.

### Usare la fotocamera posteriore

1. Tocca **Aggiungi libro** (pulsante `+`)
2. Seleziona **Scansiona ISBN**
3. Concedi l'accesso alla fotocamera quando richiesto
4. Jinbocho usa automaticamente la **fotocamera posteriore** su mobile
5. Punta la fotocamera verso il codice a barre

```
             📱
         ┌───────┐
         │ 📷 ←──┼── fotocamera posteriore
         │       │
         │       │
         └───────┘
              │
              ↓ (15–25 cm)
    ══════════════════
    ▐▌▐▌▐▌▐▌▐▌▐▌▐▌▐▌  ← codice a barre
    ══════════════════
```

- Tieni il telefono **sopra** il libro, non inclinato
- Mantieni il codice a barre interamente nell'inquadratura
- Tocca lo schermo per messa a fuoco se l'immagine è sfocata

Vedi **[Scansione ISBN](07-isbn-scanning.md)** per la guida completa.

---

## Gesti touch

| Gesto | Azione |
|-------|--------|
| Tocca una scheda libro | Apre il dettaglio del libro |
| Tocca il badge di stato | Cambia lo stato di lettura |
| Tocca `☰` | Apre il drawer di navigazione |

---

## Selettore posizione su mobile

Il selettore di posizione è un insieme di quattro menu a cascata — Stanza, Libreria,
Sezione, Scaffale — che su schermi stretti si impilano in un'unica colonna:

1. Tocca **Aggiungi libro** → **Scansiona** o **Manuale**
2. Nel form, tocca il menu **Stanza** e selezionane una
3. Il menu **Libreria** si sblocca e si popola con le librerie di quella stanza
4. Ripeti per **Sezione** e **Scaffale** — ognuno si sblocca quando il livello superiore è scelto
5. Lascia un livello non selezionato se non vuoi essere così specifico

---

## Suggerimenti per le prestazioni su mobile

### Caricamento lento alla prima visita

Jinbocho usa **TanStack Query** per mettere in cache le risposte API in memoria.
La prima volta che apri una pagina, viene caricata dal server.
Le visite successive nella stessa sessione sono istantanee (cache).

Se l'app sembra lenta alla prima apertura, potrebbe dipendere dai
cold start del piano gratuito di Render. Vedi **[FAQ → Tecnico](13-faq.md#tecnico)**.

### Dispositivi con poca memoria

Se l'app diventa poco reattiva dopo un uso prolungato, chiudi e riapri la scheda del browser.
Questo pulisce la cache in memoria e libera RAM.

---

## Supporto offline

Jinbocho **richiede attualmente una connessione internet** per funzionare.
Non esiste una modalità offline — tutti i dati sono memorizzati sul server.

Se perdi la connettività mentre stai scansionando:

- La fotocamera continua a decodificare il codice a barre
- La ricerca dei metadati tramite ISBN fallisce (nessun internet → nessun metadato)
- Il libro non può essere salvato finché la connessione non viene ripristinata

---

## Breakpoint responsive

La navigazione e la griglia dei libri cambiano in modo indipendente, a larghezze diverse:

| Larghezza schermo | Navigazione | Colonne griglia libri |
|-------------|------------|--------------------|
| < 640 px | Barra superiore + drawer (`☰`) | 1 colonna |
| 640 – 767 px | Barra superiore + drawer (`☰`) | 2 colonne |
| 768 – 1023 px | Sidebar completa | 2 colonne |
| ≥ 1024 px | Sidebar completa | 4 colonne |
