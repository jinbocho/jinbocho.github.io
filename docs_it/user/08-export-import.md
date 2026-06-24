# Esportazione e Backup

Jinbocho offre due strumenti separati, per due scopi diversi:

| Strumento | Dove | Per cosa serve |
|------|-------|----------------|
| **Esporta libri (CSV/JSON)** | Impostazioni → Esporta libri, oppure il menu di esportazione nella pagina Libri | Un elenco leggero, solo libri, per foglio di calcolo o analisi rapida. **Non è un formato di ripristino.** |
| **Backup e ripristino** | Impostazioni → Backup e ripristino | Uno snapshot completo e ripristinabile di tutta la biblioteca famiglia — posizioni, libri, prestiti, cronologia letture e l'elenco dei membri. Usalo per migrare a un nuovo database senza perdere nulla. |

Questa pagina copre entrambi gli strumenti, più come ripristinare da un backup.

---

## Esportare la libreria (CSV/JSON)

Jinbocho supporta due formati di esportazione leggeri:

| Formato | Ideale per |
|--------|----------|
| **CSV** | Foglio di calcolo, Excel, Google Sheets, editing testo semplice |
| **JSON** | Scripting, utenti tecnici, esportazioni strutturate rapide |

### Come esportare

1. Apri **Impostazioni** (icona ingranaggio nella sidebar)
2. Sotto **Esporta libri (CSV/JSON)**, scegli il formato: **CSV** o **JSON**
3. Clicca sul bottone di download — il browser salva il file immediatamente

Il bottone di esportazione è disponibile anche direttamente nella pagina **Libri**, nel menu di esportazione in alto a destra.

!!! note "Non è un formato di ripristino"
    Questa esportazione contiene solo i libri posseduti e dove sono collocati. Non
    include prestiti, cronologia di lettura per membro, o l'elenco dei membri famiglia,
    e non esiste una funzione "importa CSV" corrispondente. Per qualsiasi cosa che
    potresti dover ripristinare in futuro, usa **Backup e ripristino** più sotto.

---

## Esportazione CSV

Il CSV esportato ha una riga per ogni copia di libro posseduta.

### Colonne del CSV

| Colonna | Descrizione | Esempio |
|--------|-------------|----------|
| `id` | ID interno della copia posseduta | `c3f1a2b4` |
| `isbn` | ISBN-13 del record bibliografico | `9788845292613` |
| `title` | Titolo del libro | `Il deserto dei Tartari` |
| `author` | Autore/i, separati da virgola | `Dino Buzzati` |
| `publisher` | Nome dell'editore | `Mondadori` |
| `published_date` | Anno o data di pubblicazione | `1940` |
| `language` | Codice lingua | `it` |
| `page_count` | Numero di pagine | `256` |
| `room` | Nome della stanza | `Salotto` |
| `bookcase` | Nome della libreria | `IKEA Billy` |
| `section` | Nome della sezione (se presente) | `Colonna sinistra` |
| `shelf` | Nome dello scaffale | `Scaffale 2` |
| `position` | Numero di posizione sullo scaffale | `3` |
| `reading_status` | Stato di lettura attuale | `finished` |
| `added_at` | Quando la copia è stata aggiunta (ISO 8601) | `2026-01-15T18:30:00Z` |

### Esempio di CSV

```csv
id,isbn,title,author,publisher,published_date,language,page_count,room,bookcase,section,shelf,position,reading_status,added_at
c3f1a2b4,9788845292613,Il deserto dei Tartari,Dino Buzzati,Mondadori,1940,it,256,Salotto,IKEA Billy,Colonna sinistra,Scaffale 2,3,finished,2026-01-15T18:30:00Z
a7e9c123,9780261103573,The Fellowship of the Ring,J.R.R. Tolkien,HarperCollins,1954,en,432,Studio,Mensola d'angolo,,Scaffale 1,1,want_to_read,2026-02-03T10:00:00Z
```

!!! tip "Apri in Excel o Google Sheets"
    Il CSV usa codifica UTF-8 e separatore virgola. Se i caratteri speciali
    (accenti, alfabeti non latini) appaiono corrotti in Excel, importalo
    specificando la codifica UTF-8:
    **Dati → Da testo/CSV → Origine file: 65001 Unicode (UTF-8)**.

---

## Esportazione JSON

L'esportazione JSON è un backup strutturato completo, che preserva tutti i dati
inclusi gli oggetti di posizione annidati.

### Struttura JSON

```json
{
  "exported_at": "2026-06-11T20:00:00Z",
  "family_id": "fam_abc123",
  "books": [
    {
      "id": "c3f1a2b4",
      "bibliographic_record": {
        "isbn": "9788845292613",
        "title": "Il deserto dei Tartari",
        "author": "Dino Buzzati",
        "publisher": "Mondadori",
        "published_date": "1940",
        "language": "it",
        "page_count": 256,
        "description": "..."
      },
      "location": {
        "room": "Salotto",
        "bookcase": "IKEA Billy",
        "section": "Colonna sinistra",
        "shelf": "Scaffale 2",
        "position": 3
      },
      "reading_status": "finished",
      "added_at": "2026-01-15T18:30:00Z"
    }
  ]
}
```

---

## Backup e ripristino

Per un backup completo e ripristinabile della tua biblioteca famiglia, usa
**Backup e ripristino** in Impostazioni — non l'esportazione CSV/JSON sopra.

### Cosa è incluso

Un backup completo contiene tutto:

- La famiglia e l'elenco dei suoi membri (nomi, email, ruoli)
- Stanze, librerie, sezioni e scaffali
- Ogni libro posseduto e il suo record bibliografico
- Prestiti (attivi e passati)
- Cronologia di lettura per membro ("reads")

### Come fare un backup

1. Apri **Impostazioni** (icona ingranaggio nella sidebar)
2. Sotto **Backup e ripristino**, clicca **Scarica backup completo**
3. Il browser scarica un singolo file JSON (`jinbocho-backup-AAAA-MM-GG.json`)

**Frequenza consigliata**: una volta al mese, scarica un backup completo e
conservalo in una cartella di storage cloud (Google Drive, Dropbox, iCloud).

### Come ripristinare

1. Apri **Impostazioni** → **Backup e ripristino**
2. Clicca **Ripristina da backup** e seleziona un file di backup scaricato precedentemente
3. Controlla la finestra di conferma: mostra il nome della famiglia, quando il
   backup è stato esportato, e il conteggio di membri famiglia, stanze, libri e
   prestiti che contiene
4. Clicca **Ripristina** per confermare

!!! tip "Il ripristino fa il merge, non sovrascrive"
    Ripristinare un backup lo unisce (merge) alla tua libreria *attuale* invece
    di sostituirla: stanze, librerie, libri e membri già presenti vengono
    riconosciuti e riutilizzati, così niente viene duplicato — anche se ripristini
    lo stesso file due volte. Questo rende anche sicuro l'uso di un backup per
    migrare la tua libreria su una nuova istanza di Jinbocho.

Se un membro della famiglia è stato rimosso dopo che il backup è stato fatto ma
è ancora referenziato in esso (ad es. possedeva o aveva letto un libro), il
ripristino lo ricrea con il suo nome e email originali, così la cronologia non
viene persa.

Se il ripristino fallisce a metà, Jinbocho indica quale passaggio è fallito
(elenco membri o dati della libreria), così sai se è sicuro semplicemente
riprovare.

Per aggiungere singoli libri invece di ripristinare un backup, vedi:

- **[Scansione ISBN](07-isbn-scanning.md)** — il metodo più rapido per libri fisici
- **[Inserimento manuale dell'ISBN](03-managing-library.md#metodo-2-inserimento-isbn-manuale)** — digita o incolla un ISBN
- **[Inserimento manuale](03-managing-library.md#metodo-3-inserimento-manuale)** — per libri senza ISBN

---

## Valori dello stato di lettura

Quando rivedi le esportazioni, questi sono i valori validi di `reading_status`:

| Valore | Significato |
|-------|---------|
| `want_to_read` | Nella pila da leggere |
| `reading` | Lettura in corso |
| `finished` | Completato |
