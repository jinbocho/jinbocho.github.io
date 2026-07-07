# Autenticazione e gestione account

Come accedere, proteggere il tuo account, gestire la sessione e appartenere a
più di una biblioteca in Jinbocho.

## Accesso

1. Vai all'URL della tua istanza Jinbocho
2. Inserisci il tuo **indirizzo email**
3. Inserisci la **password**
4. Clicca **"Accedi"**

Verrai reindirizzato alla dashboard della tua biblioteca, oppure al
**selettore di biblioteche** se appartieni a più di una — vedi
**[Appartenere a più biblioteche](#appartenere-a-piu-biblioteche)** più sotto.

**Nota**: l'email non è case-sensitive (`Mario@esempio.it` e `mario@esempio.it` funzionano entrambi).

## Cos'è una sessione?

Quando accedi, Jinbocho crea una **sessione**:

- Il browser memorizza un **access token** (valido 30 minuti)
- Un **refresh token** viene conservato per estendere la sessione
- L'app si aggiorna automaticamente mentre sei attivo

Non devi fare nulla: l'app gestisce tutto in automatico.

## Scadenza della sessione

Se sei inattivo per più di 30 minuti:

- L'access token scade
- L'app cerca di aggiornarsi con il refresh token
- Se l'aggiornamento ha successo, rimani connesso
- Se fallisce, vieni disconnesso

**Se vedi "Sessione scaduta"**: vai alla pagina di login, inserisci le credenziali. I tuoi dati non sono persi.

## Disconnettersi

1. Clicca sul **menu utente** (avatar in alto a destra)
2. Clicca **"Esci"**
3. Vieni disconnesso e tornato alla schermata di login

## Recupero password

Hai dimenticato la password?

### Passo 1: vai alla pagina di recupero

Nella schermata di login, clicca **"Password dimenticata?"**

### Passo 2: inserisci l'email

Digita l'email associata al tuo account Jinbocho e clicca **"Invia email di recupero"**.

### Passo 3: controlla la posta

Cerca un'email con il link di recupero. Controlla anche la cartella spam.

!!! info "Istanze self-hosted senza email configurata"
    Se chi gestisce la tua istanza Jinbocho non ha configurato un provider
    email (SMTP), le email di recupero non vengono effettivamente inviate —
    vengono invece scritte nei log dell'auth-service. Chiedi di controllare i
    log per il link di recupero, oppure di configurare l'SMTP.

**Nota di sicurezza**: il link scade dopo **1 ora**. Se scade, ripeti la procedura.

### Passo 4: imposta la nuova password

Clicca il link nell'email, inserisci la nuova password (almeno 8 caratteri) e conferma.

Vedrai **"Password reimpostata"**. Torna al login e usa la nuova password.

## Cambiare la password

Puoi cambiare la password in qualsiasi momento senza disconnetterti:

1. Clicca sul tuo avatar → **"Profilo"**
2. Clicca **"Cambia password"**
3. Inserisci la **password attuale**
4. Inserisci e conferma la **nuova password** (almeno 8 caratteri)
5. Clicca **"Aggiorna password"**

## Appartenere a più biblioteche

Lo stesso account Jinbocho (una email) può appartenere a **più di una
biblioteca** — ad esempio la tua e quella di un amico o partner che ti ha
invitato — e può avere un **ruolo diverso in ciascuna** (Admin nella tua e
Viewer in quella di qualcun altro).

### Il selettore di biblioteche

Se il tuo account ha zero o due-o-più iscrizioni **attive**, dopo il login
finisci sul **selettore di biblioteche** invece che direttamente sulla
dashboard. Mostra:

| Sezione | Cosa mostra | Cosa puoi fare |
|---------|-------------|-----------------|
| **Le tue biblioteche** | Ogni biblioteca dove la tua iscrizione è attiva | Clicca **Entra** per aprirla |
| **Inviti in sospeso** | Inviti ricevuti sulla tua email/account a cui non hai ancora risposto | **Accetta** per unirti, o **Rifiuta** (richiede conferma) |
| **Sospese** | Biblioteche dove un Admin ha sospeso temporaneamente la tua iscrizione | In grigio, nessuna azione — contatta l'Admin di quella biblioteca |

Se appartieni a **esattamente una biblioteca attiva**, Jinbocho salta del
tutto il selettore e ti porta direttamente alla dashboard di quella biblioteca.

### Cambiare biblioteca in seguito

Una volta dentro una biblioteca, un **selettore** è sempre disponibile
dall'header — usalo per passare a un'altra biblioteca a cui appartieni, o per
controllare nuovi inviti in sospeso, senza doverti disconnettere.

### Accettare o rifiutare un invito

1. Apri il selettore di biblioteche (automatico dopo il login, o tramite quello nell'header)
2. Trova l'invito sotto **Inviti in sospeso**
3. Clicca **Accetta** per unirti con il ruolo assegnato dall'Admin, o **Rifiuta**
   per declinarlo (ti verrà chiesta conferma)

### I ruoli sono per biblioteca

Il tuo ruolo (**Admin**, **Editor** o **Viewer**) è impostato indipendentemente
per ogni biblioteca a cui appartieni. Vedi **[Gestione utenti](09-user-management.md)**
per cosa può fare ogni ruolo.

## Eliminare una biblioteca

⚠️ **Azione permanente**: eliminare una biblioteca non può essere annullato, e
cancella l'accesso di **ogni** membro, non solo dell'Admin che la elimina.

Solo un **Admin** può eliminare una biblioteca, da **Impostazioni → Zona pericolosa**.

### Cosa succede

1. Digiti il nome esatto della biblioteca e la tua password per confermare.
2. Jinbocho elimina i dati della biblioteca in sequenza: prima i dati del
   catalogo (libri, posizioni, prestiti), poi i dati AI (storico
   suggerimenti/deduplicazione, se il modulo AI è installato sulla tua
   istanza), infine la biblioteca e ogni account membro collegato nel
   servizio di autenticazione.
3. Ogni passaggio viene confermato prima di passare al successivo. **Non è
   istantaneo né atomico** — se un passaggio fallisce, Jinbocho ti dice
   esattamente quale (catalogo, AI, o l'ultimo passaggio account/biblioteca)
   così puoi riprovare in sicurezza da lì senza rifare ciò che è già riuscito.
4. Una volta completati tutti i passaggi, ogni membro — te compreso — perde
   l'accesso immediatamente e permanentemente.

!!! danger "Non si può tornare indietro"
    Non esiste un cestino né un periodo di grazia. Assicurati di avere un
    **[backup completo](08-export-import.md#backup-e-ripristino)** se pensi
    che potresti volere di nuovo questi dati.

**Se vuoi solo lasciare la biblioteca senza eliminarla**: chiedi a un altro
Admin di rimuoverti come membro (vedi **[Gestione utenti](09-user-management.md)**).
Se sei l'unico Admin, promuovi prima un altro membro ad Admin.

## La tua privacy: quali dati conserviamo e i tuoi diritti

Quando ti registri, ti viene chiesto di accettare l'attuale **Privacy Policy**
e i **Termini di Servizio** — questo viene registrato sul tuo account (quale
versione hai accettato, e quando).

- Ogni membro può leggere un riepilogo di quali dati vengono conservati e
  perché, e come contattarci a riguardo, sotto **Impostazioni → Privacy e i
  tuoi dati**.
- Al momento non esiste un pulsante self-service "esporta i miei dati" per il
  singolo membro. Se vuoi una copia dei tuoi dati, chiedi al tuo Admin di
  scaricare un **[backup completo](08-export-import.md#backup-e-ripristino)**
  (che include l'intero elenco membri, libri, prestiti e cronologia di
  lettura), oppure contatta direttamente **jinbochoapp@gmail.com**.
- Per far rimuovere i tuoi dati, chiedi a un Admin di rimuoverti come membro,
  oppure di eliminare l'intera biblioteca se vuoi che tutto scompaia (vedi sopra).

## Buone pratiche di sicurezza

### 🔐 Sicurezza della password
- Non condividere mai la password con nessuno (nemmeno con gli Admin)
- Usa una password unica che non usi altrove
- Valuta un password manager (1Password, Bitwarden, LastPass)

### 🔒 Sicurezza dell'account
- Disconnettiti sui computer condivisi prima di allontanarti
- Usa HTTPS (l'URL inizia con `https://`, non `http://`)

### 👥 Inviti
- Invita solo persone di cui ti fidi
- Gli Admin possono rimuovere o sospendere membri in qualsiasi momento
- Chiedi ai membri di usare password robuste

### 📱 Sicurezza del dispositivo
- Non restare connesso a lungo su WiFi pubbliche
- Usa una VPN se sei su WiFi pubbliche (opzionale ma consigliato)
- Svuota regolarmente i cookie del browser su dispositivi condivisi

## Sessione su più dispositivi

Puoi essere connesso su più dispositivi contemporaneamente:

- Stessa email, dispositivi diversi
- Ogni dispositivo ha il proprio access token
- Disconnettersi da un dispositivo non influisce sugli altri

**Esempio**: puoi essere connesso sia dal telefono che dal computer nello stesso momento.

## Risoluzione problemi di accesso

### "Email o password non valide"

- Controlla l'ortografia dell'email
- Verifica che il CAPS LOCK sia disattivato (la password è case-sensitive)
- Resetta la password se non la ricordi

### "Troppi tentativi di accesso"

Hai inserito la password sbagliata troppe volte. Per sicurezza:

1. Aspetta 15 minuti
2. Riprova

Oppure resetta la password tramite "Password dimenticata?".

### "La pagina di login continua a ricaricarsi"

Il token di sessione potrebbe essere corrotto:

1. Svuota i cookie del browser per questo sito
2. Ricarica la pagina
3. Accedi di nuovo

## Recupero dell'account

Se hai perso l'accesso al tuo account:

### Email persa

Se non hai più accesso all'email con cui ti sei registrato:
1. Crea un nuovo account Jinbocho con un'altra email
2. Chiedi a un Admin della tua biblioteca originale di invitare il nuovo account come membro (soluzione temporanea)

Stiamo lavorando a opzioni di recupero account. Per aiuto urgente, contatta **jinbochoapp@gmail.com**.

### Bloccato per password dimenticata + email persa

1. Contatta **jinbochoapp@gmail.com**
2. Fornisci il nome della biblioteca e l'email originale
3. Verificheremo la tua identità e ti aiuteremo a recuperare l'accesso

---

## Prossimi passi

- **Gestisci membri e ruoli**: vedi **[Gestione utenti](09-user-management.md)**
- **Inizia a usare Jinbocho**: vedi **[Gestire la biblioteca](03-managing-library.md)**
- **Problemi?**: vedi **[Risoluzione problemi](14-troubleshooting.md)** o **[Domande frequenti](13-faq.md)**
