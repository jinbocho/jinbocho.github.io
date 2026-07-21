# Kids Mode

Kids Mode trasforma Jinbocho in uno strumento per far crescere lettori in famiglia, non solo
per catalogare cosa hanno letto. È un modulo opzionale, indipendente dal modulo AI — alcune
sotto-funzionalità qui sotto possono *opzionalmente* usare l'AI, ed è indicato dove succede.

## Attivare Kids Mode

!!! info "Serve un Admin"
    Solo un Admin può attivare o disattivare Kids Mode, e solo se questa installazione ha il
    modulo Kids abilitato — Community non lo include, Education e Pro sì.

1. Vai su **Impostazioni**
2. Nella sezione **Kids Mode**, attiva l'interruttore
3. Se l'interruttore è disabilitato, questa installazione non ha il modulo Kids abilitato —
   contatta chi gestisce la tua installazione

## Account bambini

Una volta attivo Kids Mode, Admin ed Editor possono creare un **account bambino** per ogni
figlio della famiglia:

1. Vai su **Impostazioni → Utenti**
2. Clicca **Aggiungi bambino**
3. Inserisci il nome del bambino, una password e (per il reset password) l'email reale di un
   genitore — l'email dell'account del bambino non è un indirizzo realmente recapitabile
4. Il bambino può ora accedere con la password che hai impostato

Gli account bambini non vedono affatto l'interfaccia di gestione del catalogo. Arrivano invece
su una pagina dedicata, **La mia lettura**.

## Cosa vede un bambino: La mia lettura

- Registrare una **sessione di lettura** per il libro che sta leggendo
- Rispondere a un **quiz di comprensione** — scritto a mano da un genitore, oppure (se anche
  il modulo AI è attivo) generato automaticamente dal contenuto del libro
- Scrivere una voce nel **diario di lettura** — un'emoji e una frase breve per i lettori più
  piccoli, un racconto libero per quelli più grandi, con spunti creativi come "immagina un
  finale diverso"
- Seguire un **percorso di lettura** — una sequenza tematica di libri già nella collezione
  della famiglia
- Provare un **libro al buio** — un genitore sceglie un libro e il bambino riceve un indizio,
  non il titolo
- Vedere la barra di avanzamento condivisa della **sfida di lettura** della famiglia, se attiva

Niente di tutto questo viene confrontato con un altro lettore della famiglia — non esiste
alcuna classifica tra fratelli in nessuna parte di Kids Mode, nemmeno a livello di dati.

## Cosa vede un genitore: Dashboard Kids

Admin ed Editor hanno una **Dashboard genitore** (navigazione principale → Kids) con, per
ogni bambino:

- Storico delle letture e libro attuale
- Risultati dei quiz, con il dettaglio di quali risposte erano corrette o sbagliate
- Voci del diario
- **Domande da cena** — spunti di conversazione aperti sul libro che il bambino sta leggendo,
  generati solo per il genitore, mai mostrati al bambino (richiede il modulo AI)
- Riconoscimenti di lettura ottenuti — legati alla costanza e all'abitudine, mai alla velocità
  o al volume
- La possibilità di segnare un libro come **abbandonato** (normalizzato, non penalizzato) o
  **riletto**

### Sfide di lettura in famiglia

Qualsiasi Admin/Editor può avviare un obiettivo condiviso di famiglia — per esempio "1000
minuti letti insieme quest'estate" — con una sola barra di avanzamento condivisa. Non esiste
deliberatamente alcuna suddivisione per singolo membro mostrata da nessuna parte, così nessuna
versione dell'interfaccia può trasformare una sfida cooperativa in una classifica implicita.

### Lettura condivisa (0-5 anni)

Per i bambini troppo piccoli per leggere in autonomia, un genitore registra la sessione dopo
aver letto ad alta voce insieme. Il riconoscimento per la costanza va al *genitore*, non al
bambino — che a questa età non ha ancora un ruolo attivo nel software.

## Fasce d'età

Kids Mode adatta cosa mostra in base all'età del bambino, derivata automaticamente dall'anno
di nascita (viene raccolto solo l'anno, per minimizzare i dati personali di un minore):

| Età | Esperienza |
|---|---|
| 0-5 anni | Il genitore legge ad alta voce e registra la sessione; nessun ruolo attivo per il bambino |
| 6-8 anni | Prime letture autonome; emoji + frase breve invece del diario scritto |
| 9-12 anni | Autonomia piena; il diario usa il racconto libero |
| 13 anni e oltre | Nessun elemento infantile; i riconoscimenti sono un elenco sobrio di fatti; recensioni private, solo in famiglia |

## Perché è fatto così

Kids Mode non ha classifiche, non premia la velocità e non penalizza chi abbandona un libro —
di proposito. Vedi **[La filosofia dietro Kids Mode](https://jinbocho.github.io/manuals/it/philosophy/la-filosofia-di-kids-mode/)**
per il ragionamento e le quattro idee su cui è costruito.

**Vedi anche:** [Gestione utenti](09-user-management.md) per i ruoli ·
[Presentazione del libro e AI](15-book-presentation.md) per come funziona il modulo AI nel resto di Jinbocho
