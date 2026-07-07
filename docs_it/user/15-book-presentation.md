# Presentazione del libro e AI

Ogni libro può mostrare una breve **presentazione** — poche righe senza spoiler che ti aiutano
a decidere se iniziare a leggerlo. La trovi nella pagina di dettaglio del libro, subito sotto i metadati.
Questa pagina copre anche i **Consigli AI**, una funzione separata che suggerisce cosa leggere dopo.

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

Se sei **Admin** o **Editor** e l'AI è attiva per la tua biblioteca:

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

| Azione | Viewer | Editor | Admin |
|--------|:-------:|:------:|:--------------:|
| Leggere la presentazione | ✅ | ✅ | ✅ |
| Generare con l'AI | — | ✅ | ✅ |
| Modificare a mano | — | ✅ | ✅ |

---

## Consigli AI

Se l'AI è attiva per la tua biblioteca, Jinbocho può suggerire libri da leggere
dopo, calibrati su di te personalmente invece che sull'intera biblioteca.

### Come vengono costruiti i suggerimenti

I consigli combinano:

- Il tuo **genere preferito** (ricavato dai libri che hai segnato come letti)
- Le tue **letture recenti**
- Il resto del **catalogo** che non hai ancora letto

Il modello AI usa questi elementi per proporre titoli già nella tua
biblioteca (o, a seconda della configurazione, titoli da aggiungere) che si
adattano ai tuoi gusti di lettura.

### Ottenere i consigli

1. Apri la sezione **Consigli** (barra laterale o dashboard, a seconda della tua istanza)
2. Jinbocho genera una breve lista di suggerimenti con una motivazione per ciascuno
3. I consigli si aggiornano man mano che cambia la tua cronologia di lettura

!!! info "Funzione opzionale"
    Come la Presentazione del libro, richiede che la tua biblioteca abbia un
    provider AI configurato. Se non lo è, la sezione Consigli semplicemente non offre suggerimenti.

---

## Lingue

Etichette e pulsanti seguono la lingua dell'interfaccia. Il testo generato dall'AI segue la
lingua dichiarata nei metadati del libro, quando disponibile.
