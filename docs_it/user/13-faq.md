# Domande frequenti

Raccolta delle domande più comuni su Jinbocho.

---

## Account e famiglia

??? question "Posso usare Jinbocho da solo, senza creare una famiglia?"
    Sì. Quando ti registri, crei automaticamente una famiglia con te come unico membro.
    Puoi invitare altri in seguito dalla sezione impostazioni, ma non è obbligatorio.

??? question "Quanti utenti può avere una famiglia?"
    Non c'è un limite tecnico al numero di membri. Una famiglia può avere uno o decine di utenti.

??? question "Posso avere più famiglie con lo stesso account?"
    No. Ogni account appartiene a una sola famiglia. Se vuoi gestire biblioteche separate,
    crea account separati con email diverse.

??? question "Cosa succede se dimentico la password?"
    Nella pagina di login clicca **"Password dimenticata"** e inserisci la tua email.
    Riceverai un link per reimpostare la password.

??? question "Posso cambiare l'email del mio account?"
    Sì, dalla pagina **Profilo → Modifica email**. Riceverai una email di conferma al nuovo indirizzo.

---

## Libri e metadati

??? question "Perché alcuni libri non hanno la copertina?"
    La copertina viene recuperata automaticamente da Open Library e Google Books tramite ISBN.
    Se il libro è molto raro, antico, o non è presente in questi database, la copertina potrebbe
    mancare. Puoi aggiungerne una manualmente dalla pagina di dettaglio (campo "URL copertina").

??? question "Posso aggiungere un libro senza ISBN?"
    Sì. Usa il metodo **"Inserimento manuale"** — puoi lasciare il campo ISBN vuoto.
    I libri molto vecchi (precedenti al 1970) spesso non hanno ISBN.

??? question "Un libro con lo stesso ISBN può essere aggiunto due volte?"
    Sì — puoi avere più **copie fisiche** dello stesso libro. Il sistema distingue tra il
    record bibliografico (dati del libro, condivisi) e le copie fisiche (la tua copia, con la sua
    posizione e il suo stato di lettura).

??? question "I metadati recuperati con l'ISBN sono sempre corretti?"
    No, occasionalmente Open Library o Google Books hanno dati incompleti o errati,
    soprattutto per edizioni regionali. Controlla sempre i dati dopo la ricerca ISBN e modifica
    quello che non va dalla pagina di dettaglio.

??? question "Posso aggiungere libri in lingue diverse?"
    Sì. Jinbocho supporta qualsiasi lingua — imposta il campo "Lingua" al codice ISO della
    lingua del libro (es. `en`, `it`, `de`, `ja`). La ricerca funziona anche con titoli
    in caratteri non latini.

---

## Posizioni

??? question "Cosa succede se una libreria cambia di posto in casa?"
    Le posizioni sono nomi, non luoghi fisici GPS. Se sposti una libreria da una stanza all'altra,
    rinomina semplicemente la stanza di destinazione o trascina (usando la funzione "sposta posizione")
    la libreria nella nuova stanza dall'interfaccia di gestione posizioni.

??? question "Posso avere libri senza posizione?"
    No. Ogni copia fisica deve essere associata almeno a uno scaffale. Se un libro è
    temporaneamente senza posto (in prestito, da catalogare), crea una stanza/scaffale speciale
    come "In prestito" o "Da catalogare".

??? question "Ci sono limiti al numero di stanze o librerie?"
    No. Puoi creare tutte le stanze, librerie, sezioni e scaffali che vuoi.

---

## Stato di lettura

??? question "Lo stato di lettura è condiviso tra i familiari?"
    No. Lo stato di lettura è personale per ogni copia. Se più familiari hanno la stessa
    copia sullo stesso scaffale, c'è un solo record di copia con un unico stato.
    Per tracciare stati individuali, ogni persona dovrebbe avere la propria copia registrata.

??? question "Posso vedere la cronologia dei cambi di stato?"
    Sì. Nella pagina di dettaglio di ogni libro c'è un log che mostra tutti i cambi di stato
    con data, ora e utente che ha fatto la modifica.

---

## Esportazione e dati

??? question "I miei dati sono al sicuro? Posso portarli via?"
    Sì. Jinbocho è open source (CC BY-NC-ND 4.0) e puoi esportare l'intera biblioteca in CSV o JSON
    in qualsiasi momento da Impostazioni → Esporta dati. Non sei mai bloccato.

??? question "Posso importare libri da Goodreads, Calibre o altri servizi?"
    L'importazione non è ancora disponibile in questa versione. È pianificata per una versione
    futura. Per ora, usa l'esportazione CSV di Goodreads come riferimento e aggiungi i libri
    manualmente o tramite ISBN.

---

## Tecnico

??? question "Jinbocho funziona offline?"
    No. Jinbocho richiede una connessione internet per funzionare. I dati sono sul server
    e non vengono memorizzati localmente (eccetto la sessione di login).

??? question "Su quali browser funziona?"
    Jinbocho funziona su tutti i browser moderni: Chrome, Firefox, Safari, Edge.
    La scansione ISBN richiede HTTPS e un browser che supporti l'API `getUserMedia`.

??? question "C'è un'app nativa per iOS/Android?"
    No. Jinbocho è una Progressive Web App (PWA) — funziona nel browser ma può essere
    aggiunta all'homescreen del telefono per un'esperienza simile a un'app nativa.
    Vedi [Uso su mobile](11-mobile.md) per le istruzioni.

??? question "Il codice sorgente è disponibile?"
    Sì. Jinbocho è open source con licenza CC BY-NC-ND 4.0. Il codice è disponibile su GitHub.
