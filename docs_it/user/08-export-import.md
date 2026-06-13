# Esportazione e Backup

Jinbocho ti permette di esportare la tua biblioteca in formati standard per il backup o la condivisione. L'importazione è prevista in una versione futura.

---

## Esportare la biblioteca

### Come esportare

1. Apri il menu **Impostazioni** (icona ingranaggio in basso a sinistra)
2. Vai alla sezione **"Esporta dati"**
3. Scegli il formato desiderato
4. Clicca **"Esporta"** — il file viene scaricato nel tuo browser

### Formati disponibili

| Formato | Estensione | Ideale per |
|---------|------------|----------|
| CSV | `.csv` | Aprire in Excel/Fogli Google, analisi dati |
| JSON | `.json` | Backup tecnico, migrazione, sviluppatori |

---

## Formato CSV

Il file CSV include una riga per ogni copia fisica con i metadati del libro:

```
id,isbn,title,author,publisher,year,pages,language,room,bookcase,section,shelf,position,reading_status,added_at
1,9788845292613,"Il nome della rosa","Umberto Eco","Bompiani",1980,502,it,"Salotto","Billy","Narrativa","Scaffale 1",2,read,2024-01-15T10:30:00
```

| Colonna | Descrizione |
|---------|-------------|
| `id` | Identificatore interno della copia |
| `isbn` | ISBN-13 (se disponibile) |
| `title` | Titolo del libro |
| `author` | Autore/i |
| `publisher` | Editore |
| `year` | Anno di pubblicazione |
| `pages` | Numero di pagine |
| `language` | Codice lingua ISO (es. `it`, `en`) |
| `room` | Nome della stanza |
| `bookcase` | Nome della libreria |
| `section` | Nome della sezione (vuoto se non usato) |
| `shelf` | Nome dello scaffale |
| `position` | Numero di posizione sullo scaffale |
| `reading_status` | `to_read`, `reading`, `read` |
| `added_at` | Data e ora di aggiunta (ISO 8601) |

!!! tip "Aprire il CSV in Excel"
    Quando apri il file in Excel, usa **Dati → Da testo/CSV** per preservare correttamente
    i caratteri speciali (accenti, lettere straniere). Non fare doppio clic sul file.

---

## Formato JSON

Il JSON è strutturato come array di oggetti con le stesse informazioni del CSV, più i dati nidificati della posizione:

```json
[
  {
    "id": 1,
    "isbn": "9788845292613",
    "title": "Il nome della rosa",
    "author": "Umberto Eco",
    "publisher": "Bompiani",
    "year": 1980,
    "pages": 502,
    "language": "it",
    "location": {
      "room": "Salotto",
      "bookcase": "Billy",
      "section": "Narrativa",
      "shelf": "Scaffale 1",
      "position": 2
    },
    "reading_status": "read",
    "added_at": "2024-01-15T10:30:00Z"
  }
]
```

---

## Backup raccomandato

!!! info "Strategia di backup consigliata"
    Esporta in JSON una volta al mese e salva il file in:
    
    - Una cartella cloud sincronizzata (Google Drive, iCloud, Dropbox)
    - Un'altra posizione fuori dalla rete di casa

    Il JSON è il formato più fedele per il ripristino completo quando l'importazione sarà disponibile.

---

## Importazione (in arrivo)

!!! note "Funzionalità futura"
    L'importazione da CSV e JSON non è ancora disponibile in questa versione.
    
    È pianificata per una versione futura e permetterà di:
    
    - Importare una biblioteca esportata in precedenza (ripristino)
    - Migrare da Calibre, Goodreads, LibraryThing e altri servizi
    - Caricare in blocco centinaia di libri da un file

    Quando sarà disponibile, questa pagina verrà aggiornata con istruzioni dettagliate.