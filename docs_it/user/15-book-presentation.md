# Presentazione del libro

Ogni libro può mostrare una breve **presentazione** — poche righe senza spoiler che ti aiutano
a decidere se iniziare a leggerlo. La trovi nella pagina di dettaglio del libro, subito sotto i metadati.

---

## Da dove arriva il testo

Jinbocho compila la presentazione in tre modi possibili, ciascuno indicato da un piccolo badge:

| Fonte | Badge | Come viene prodotta |
|-------|-------|---------------------|
| Descrizione editoriale | **Dalla scheda editoriale** | La descrizione recuperata durante la ricerca ISBN — gratuita, senza AI |
| Generazione AI | **Generata con AI** | Una breve presentazione scritta da un modello AI, se la tua biblioteca ha l'AI attiva |
| Manuale | **Modificata a mano** | Testo che hai scritto o sistemato tu |

!!! note "Non è l'incipit reale del libro"
    La "presentazione" è una breve sintesi per aiutarti a scegliere — **non** una copia letterale
    della prima pagina del libro. Quando si usa l'AI, al modello è esplicitamente vietato
    inventare dettagli della trama, citazioni o finali.

---

## Leggere una presentazione

1. Apri la **pagina di dettaglio** di un libro.
2. La scheda **Presentazione** si trova subito sotto i metadati del libro.
3. Se è disponibile una presentazione, compare con un piccolo badge che ne indica la fonte.

La prima volta che apri un libro aggiunto tramite ISBN, Jinbocho ricava automaticamente la
presentazione dalla descrizione editoriale gratuita — senza che tu debba fare nulla.

---

## Generare con l'AI

Se sei **Amministratore** o **Editor** e l'AI è attiva per la tua biblioteca:

1. Apri la pagina di dettaglio del libro.
2. Nella scheda **Presentazione**, premi **Genera con AI**.
3. Viene generata e salvata una breve presentazione; il badge passa a **Generata con AI**.

!!! info "L'AI è opzionale e si può tranquillamente non usare"
    Se la tua biblioteca non ha un provider AI configurato, il pulsante mostra semplicemente
    *"La generazione AI non è configurata"* e non succede altro — la presentazione editoriale
    e la modifica manuale continuano a funzionare. Chiedi all'amministratore di attivarla
    (vedi **Manuale Sviluppatori → Servizi backend → ai-service**); un provider gratuito come
    Groq, o un Ollama locale, funziona a costo zero.

---

## Modificare a mano

1. Apri la pagina di dettaglio del libro → scheda **Presentazione** → **Modifica**.
2. Scrivi o sistema il testo.
3. Premi **Salva** — il badge passa a **Modificata a mano**.

Utile quando la descrizione editoriale manca, è troppo lunga o è nella lingua sbagliata.

---

## Chi può fare cosa

| Azione | Lettore | Editor | Amministratore |
|--------|:-------:|:------:|:--------------:|
| Leggere la presentazione | ✅ | ✅ | ✅ |
| Generare con l'AI | — | ✅ | ✅ |
| Modificare a mano | — | ✅ | ✅ |

---

## Lingue

Etichette e pulsanti seguono la lingua dell'interfaccia. Il testo generato dall'AI segue la
lingua dichiarata nei metadati del libro, quando disponibile.
