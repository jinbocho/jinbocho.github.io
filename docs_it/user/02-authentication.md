# Autenticazione e gestione account

Come accedere, proteggere il tuo account e gestire la sessione in Jinbocho.

## Accesso

1. Vai all'URL di Jinbocho
2. Inserisci il tuo **indirizzo email**
3. Inserisci la **password**
4. Clicca **"Accedi"**

Verrai reindirizzato alla tua dashboard.

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

---

## Prossimi passi

- **Gestisci i familiari**: vedi [Gestione utenti](09-user-management.md)
- **Inizia a usare Jinbocho**: vedi [Gestire la biblioteca](03-managing-library.md)
- **Problemi?**: vedi [Risoluzione problemi](14-troubleshooting.md) o [Domande frequenti](13-faq.md)