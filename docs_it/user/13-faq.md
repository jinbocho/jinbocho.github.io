# Domande frequenti

Raccolta delle domande più comuni su Jinbocho.

---

## Account e biblioteca

??? question "Posso usare Jinbocho da solo, senza invitare nessuno?"
    Sì. Quando ti registri, crei automaticamente una biblioteca con te come unico membro (Admin).
    Puoi invitare altri in seguito dalla sezione Utenti, ma non è obbligatorio.

??? question "Quanti utenti può avere una biblioteca?"
    Non c'è un limite tecnico al numero di membri. Una biblioteca può avere uno o decine di utenti.

??? question "Posso appartenere a più di una biblioteca con lo stesso account?"
    Sì. Lo stesso account può essere membro di più biblioteche contemporaneamente
    — ad esempio la tua e quella di un amico o partner — e può avere un ruolo
    diverso in ciascuna. Se appartieni a più di una, dopo il login vedrai un
    **selettore di biblioteche** per scegliere quale aprire, e potrai passare
    dall'una all'altra in seguito dall'header. Le biblioteche restano comunque
    isolate: appartenere a due biblioteche non unisce i loro libri o membri.
    Vedi **[Autenticazione → Appartenere a più biblioteche](02-authentication.md#appartenere-a-piu-biblioteche)**.

??? question "Cosa succede se dimentico la password?"
    Nella pagina di login clicca **"Password dimenticata"** e inserisci la tua email.
    Riceverai un link per reimpostare la password. Su un'istanza self-hosted senza
    email configurata, il link viene scritto nei log invece che inviato — chiedi
    a chi gestisce l'istanza di controllarli.

??? question "Posso cambiare l'email del mio account?"
    Sì, dalla pagina **Profilo → Modifica email**. Riceverai una email di conferma al nuovo indirizzo.

??? question "Posso eliminare il mio account?"
    L'eliminazione è **riservata agli Admin ed elimina l'intera biblioteca**, non
    solo il singolo account — al momento non esiste un modo per un membro non-Admin
    di autoeliminare solo il proprio account. Chiedi a un Admin di rimuoverti come
    membro se vuoi solo lasciare la biblioteca, oppure vedi
    **[Autenticazione → Eliminare una biblioteca](02-authentication.md#eliminare-una-biblioteca)**
    se sei un Admin e vuoi eliminare tutto.

??? question "Posso ottenere una copia dei miei dati personali?"
    Non esiste ancora un pulsante self-service "esporta i miei dati" per il
    singolo membro. Chiedi al tuo Admin di scaricare un
    **[backup completo](08-export-import.md#backup-e-ripristino)** (che include
    l'elenco membri, i libri, i prestiti e la cronologia di lettura), oppure
    contatta **support@jinbocho.eu** direttamente.

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

??? question "Perché non vedo l'opzione per scansionare un intero scaffale?"
    La Scansione scaffale compare solo quando il modulo AI della tua istanza è
    attivo **e** configurato con un modello capace di leggere immagini. Se manca
    uno dei due, l'opzione resta nascosta — chiedi al tuo amministratore, oppure
    usa la scansione ISBN normale. Vedi
    **[Scansione ISBN → Scansione scaffale](07-isbn-scanning.md#scansione-scaffale-fotografa-un-intero-scaffale)**.

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

??? question "Lo stato di lettura è condiviso tra tutti i membri?"
    Lo **stato** (Da leggere/In lettura/Letto) è personale per ogni copia fisica.
    Ma se più membri condividono la stessa copia, ognuno può comunque segnare
    *personalmente* di averla letta tramite la funzione **Letto da** sulla
    pagina di dettaglio — indipendentemente dallo stato generale della copia.
    Vedi **[Progressi di lettura → Chi ha letto questo libro](10-reading-progress.md#chi-ha-letto-questo-libro-letture-di-biblioteca)**.

??? question "Posso vedere la cronologia dei cambi di stato?"
    Sì. Nella pagina di dettaglio di ogni libro c'è un log che mostra tutti i cambi di stato
    con data, ora e utente che ha fatto la modifica.

---

## Esportazione e dati

??? question "I miei dati sono al sicuro? Posso portarli via?"
    Sì. Jinbocho è source-available (Jinbocho Source-Available License) e puoi esportare l'intera biblioteca in CSV o JSON
    in qualsiasi momento da Impostazioni → Esporta libri, oppure scaricare un backup completo
    da Impostazioni → Backup e ripristino. Non sei mai bloccato.

??? question "Posso importare libri da Goodreads?"
    Sì — un Admin o Editor può importare un export CSV di Goodreads da
    **Impostazioni → Dati biblioteca**. Vedi
    **[Esportazione → Importare da Goodreads](08-export-import.md#importare-da-goodreads)**.
    L'importazione da Calibre o altri servizi non è ancora disponibile.

---

## Tecnico

??? question "Jinbocho funziona offline?"
    No. Jinbocho richiede una connessione internet per funzionare. I dati sono sul server
    e non vengono memorizzati localmente (eccetto la sessione di login).

??? question "Su quali browser funziona?"
    Jinbocho funziona su tutti i browser moderni: Chrome, Firefox, Safari, Edge.
    La scansione ISBN richiede HTTPS e un browser che supporti l'API `getUserMedia`.

??? question "C'è un'app nativa per iOS/Android?"
    No. Jinbocho è un'applicazione web — si usa nel browser del telefono. Puoi
    aggiungere una scorciatoia alla schermata home dal menu del browser, ma non
    è un'installazione vera e propria: il comportamento varia da browser a browser.
    Vedi [Uso su mobile](11-mobile.md) per le istruzioni.

??? question "Il codice sorgente è disponibile?"
    Sì. Jinbocho è source-available con licenza Jinbocho Source-Available License. Il codice è disponibile su GitHub.
