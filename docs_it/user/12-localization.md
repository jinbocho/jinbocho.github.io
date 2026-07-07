# Lingua e aspetto

Jinbocho supporta più lingue sia nell'interfaccia che nella gestione della biblioteca, e permette a ogni membro di scegliere il proprio tema visivo.

---

## Lingue dell'interfaccia

L'interfaccia di Jinbocho è disponibile in:

| Lingua | Codice | Stato |
|--------|--------|------|
| Italiano | `it` | ✅ Disponibile |
| Inglese | `en` | ✅ Disponibile |
| Spagnolo | `es` | ✅ Disponibile |
| Francese | `fr` | ✅ Disponibile |

### Cambiare la lingua

La lingua si cambia dalle impostazioni del profilo:

1. Clicca sul tuo **nome utente** (in alto a destra)
2. Seleziona **"Profilo"**
3. Trova la voce **"Lingua"**
4. Seleziona la lingua dal menu
5. La pagina si aggiorna immediatamente

La preferenza di lingua viene salvata sia in locale (nel browser, così vale
anche prima del login) sia nel tuo profilo sul server, e sincronizzata su
tutti i dispositivi dove accedi.

!!! info "Preferenza personale"
    La lingua è una preferenza personale — ogni membro della biblioteca può
    usare Jinbocho nella propria lingua. Il contenuto (titoli, descrizioni dei
    libri) non cambia — solo l'interfaccia.

---

## Tema e aspetto

Sotto **Impostazioni → Aspetto**, ogni membro può scegliere in modo
indipendente:

- **Tema colore** — tre palette: **Pergamena**, **Akabeni** e **Sumi**
- **Modalità** — **Chiara**, **Scura** o **Sistema** (segue le impostazioni del dispositivo/browser)

Come la lingua, la scelta del tema è personale e ti segue su tutti i dispositivi.

---

## Lingue dei libri

La **lingua di un libro** è un dato bibliografico separato dalla lingua dell'interfaccia.

Quando aggiungi un libro puoi specificare la lingua in cui è scritto:

| Codice | Lingua |
|--------|-------|
| `it` | Italiano |
| `en` | Inglese |
| `es` | Spagnolo |
| `fr` | Francese |
| `de` | Tedesco |
| `pt` | Portoghese |
| `ja` | Giapponese |
| `zh` | Cinese |
| … | Tutti i codici ISO 639-1 |

Quando aggiungi un libro tramite ISBN, la lingua viene compilata automaticamente dai metadati di Open Library o Google Books.

### Filtrare per lingua del libro

Puoi filtrare la biblioteca per mostrare solo i libri in una certa lingua:

1. Vai su **Biblioteca**
2. Apri **"Filtri"**
3. Seleziona la **lingua** dal filtro dedicato

Questo è utile se hai libri in più lingue e vuoi vedere, ad esempio, solo la collezione in inglese.

---

## Formati data e numero

Jinbocho usa i formati locali automaticamente in base alla lingua selezionata:

| Lingua | Formato data | Esempio |
|--------|--------------|--------|
| Italiano | GG/MM/AAAA | `15/01/2024` |
| Inglese | MM/DD/YYYY | `01/15/2024` |
| Francese | JJ/MM/AAAA | `15/01/2024` |
| Spagnolo | DD/MM/AAAA | `15/01/2024` |

---

## Contribuire a una traduzione

Jinbocho è source-available (Jinbocho Source-Available License). Se vuoi migliorare la traduzione in una lingua esistente o aggiungerne una nuova, consulta le istruzioni nel repository GitHub.

Le traduzioni si trovano nei file JSON nella cartella `jinbocho-fe/src/features/i18n/locales/`.
