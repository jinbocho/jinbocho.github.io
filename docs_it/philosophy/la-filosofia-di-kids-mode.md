---
title: La filosofia dietro Kids Mode
description: Perché Kids Mode di Jinbocho non ha classifiche, non premia la velocità e non fa sentire in colpa chi abbandona un libro — e le quattro idee su cui è costruito.
---

# La filosofia dietro Kids Mode

Molte app che spingono i bambini a leggere copiano il manuale del videogioco: punti, streak,
badge, classifiche. Funziona, nel breve periodo — e può insegnare senza volerlo a un bambino
che si legge per il premio, non per il piacere di leggere.

**Kids Mode** di Jinbocho è stato costruito apposta per evitare questa trappola. È un modulo
piccolo e volutamente non ambizioso dentro un gestionale per biblioteche di casa: sessioni di
lettura, un diario personale, quiz opzionali, sfide di famiglia. Quello che lo rende diverso
non è l'elenco delle funzionalità: è quello che abbiamo rifiutato di costruire.

## Come si confronta con una tipica app di gamification della lettura

| | App di lettura tipica | **Jinbocho Kids Mode** |
|---|:---:|:---:|
| Punti / contatori di streak | ✅ | ❌ |
| Classifica tra fratelli | ✅ (spesso) | **❌ — nemmeno nei dati sottostanti** |
| Premio legato a velocità o volume di lettura | ✅ | ❌ |
| Libro abbandonato segnato come fallimento/incompleto | ✅ (di solito) | **❌ — normalizzato: "capita anche ai grandi lettori"** |
| Rilettura segnata come duplicato | ✅ (di solito) | **❌ — mostrata positivamente, come "riletto"** |
| Stessa interfaccia per un bambino di 5 anni e un ragazzo di 14 | ✅ (spesso) | **❌ — quattro fasce d'età, un'esperienza diversa per ciascuna** |
| Comprensione verificata solo con quiz a risposta multipla | ✅ | ❌ — racconto libero e spunti creativi vengono prima |
| Funziona senza un abbonamento AI/LLM | dipende | **✅ — Kids Mode non richiede mai il modulo AI** |

## Cosa abbiamo deliberatamente evitato di costruire

- Nessuna classifica tra fratelli, in nessuna funzionalità.
- Nessun premio legato alla velocità di lettura o al numero di libri letti confrontato con un altro membro della famiglia.
- Nessuna conseguenza negativa, visibile o anche solo implicita, per aver abbandonato un libro.
- Le sessioni di lettura condivisa — un genitore che legge ad alta voce a un bambino di 0-5 anni — sono tenute nettamente separate dai riconoscimenti che il bambino guadagna per la propria lettura autonoma. Mescolare le due cose era un vero bug in una versione precedente del software; l'abbiamo corretto perché violava il primo principio qui sotto.
- Per la fascia 0-5 anni l'intera area dei quiz e del diario scritto è nascosta. Non ha senso chiedere a un bambino che non legge ancora da solo di rispondere a un quiz.

## Le quattro idee su cui è costruito

**Motivazione intrinseca, non punteggi.** La teoria dell'autodeterminazione di Edward Deci e
Richard Ryan documenta l'*effetto di sovragiustificazione*: quando si introduce una ricompensa
esterna per un'attività che una persona già svolgeva per piacere proprio, la motivazione
intrinseca verso quell'attività tende a indebolirsi. L'esempio classico sono bambini che
disegnavano spontaneamente per gusto, ai quali è stata poi promessa una ricompensa per il
disegno: in seguito disegnavano spontaneamente meno di prima. La lettura, per un bambino che
la scopre, è esattamente questo tipo di attività. Per questo ogni riconoscimento in Kids Mode
è legato alla costanza e alla curiosità personale del bambino — mai alla velocità, mai al
volume, mai al confronto con un altro lettore. Un badge deve dire "hai coltivato un'abitudine",
non "hai vinto".

**I diritti del lettore, da Daniel Pennac.** In *Come un romanzo* (1992), Pennac elenca i
diritti "imprescrittibili" del lettore — tra cui il diritto di non finire un libro, il diritto
di rileggere, il diritto di saltare le pagine. Gran parte del software di lettura, anche per
adulti, viola silenziosamente questi diritti: registra come fallimento un libro abbandonato,
tratta una rilettura come un duplicato da correggere, spinge verso il completamento con barre
di avanzamento e notifiche. Kids Mode fa il contrario, e rende questa scelta visibile al
bambino, non solo nascosta nel backend.

**La lettura come innesco di immaginazione, da Gianni Rodari.** *Grammatica della fantasia*
(1973) sostiene che le storie servono a innescare l'invenzione, non solo la comprensione o la
memorizzazione. Un quiz a risposta multipla misura una fetta molto stretta di ciò che accade
quando un bambino legge, e rischia di comunicargli che leggere serve a superare un test. Per
questo il diario di lettura di Kids Mode privilegia il racconto libero e gli spunti creativi —
"immagina un finale diverso" — rispetto ai quiz, che restano opzionali e secondari, mai al
centro.

**Il genitore come alleato, da Nati per Leggere.** Il programma nazionale italiano di lettura
ad alta voce (promosso da pediatri, biblioteche e centri per la salute del bambino) sostiene
che per i più piccoli conta il rito e la sua costanza, non una misura di prestazione. Per la
fascia 0-5 anni il "protagonista" del software è quindi il genitore che legge ad alta voce — il
riconoscimento va a *lui*, per aver mantenuto l'abitudine — non al bambino, che a quell'età non
ha ancora un ruolo attivo.

## Quattro età, quattro esperienze diverse

| Fascia | Cosa cambia |
|---|---|
| 0-5 anni | Il genitore legge ad alta voce e registra la sessione; il bambino non ha ancora un ruolo attivo |
| 6-8 anni | Prime letture autonome; un'emoji e una frase breve sostituiscono il diario scritto; il gioco è centrale |
| 9-12 anni | Autonomia piena; la comprensione si esprime nel racconto proprio; nasce un'identità di lettore |
| 13 anni e oltre | Nessun elemento infantile; socialità solo interna alla famiglia; spazio al giudizio critico personale |

## Una nota onesta

Non siamo esperti di pedagogia: siamo genitori e lettori che hanno costruito tutto questo a
partire da Deci e Ryan, Pennac, Rodari e Nati per Leggere, e stiamo attivamente cercando una
revisione esterna e qualificata. Se qualcosa qui ti sembra ingenuo, o se pensi che una
funzionalità superi un limite che non abbiamo notato, ci farebbe piacere saperlo.

## Provalo

Kids Mode è incluso nei piani **[Education e Pro](https://jinbocho.github.io/pricing/#education)**
— Education lo aggiunge senza il modulo AI, Pro lo aggiunge insieme alle funzionalità AI.
Consulta il **[manuale utente](../user/index.md)** per sapere come attivarlo e usarlo ogni giorno.

**Vedi anche:** [Prezzi](https://jinbocho.github.io/pricing/) · [Manuale utente](../user/index.md)
