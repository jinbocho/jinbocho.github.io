---
title: Jinbocho vs Libib vs Skoolib — quale app per la biblioteca di casa fa per te?
description: Un confronto oggettivo tra Jinbocho, Libib e Skoolib per catalogare una biblioteca di casa — modello di hosting, limiti del piano gratuito e mappatura fisica degli scaffali.
---

# Jinbocho vs Libib vs Skoolib

Libib e Skoolib sono entrambi strumenti di catalogazione solidi e ben fatti — questa
non è una pagina "loro sono peggio, noi siamo meglio". Sono servizi cloud pensati per
funzionare bene fin da subito su un'ampia gamma di dimensioni di collezione, incluse
piccole istituzioni. Jinbocho risolve un problema più circoscritto — una singola
biblioteca di casa, self-hosted — e scambia la loro comodità con la piena proprietà
dei dati e nessun limite per numero di elementi.

## Come si confrontano

| | Libib | Skoolib | **Jinbocho** |
|---|:---:|:---:|:---:|
| Hosting | Solo cloud | Solo cloud | **Self-hosted** |
| Piano gratuito | 5.000 elementi | 500 libri | **Nessun limite** (database tuo) |
| Mappatura fisica scaffale/stanza | ❌ | Scaffale virtuale (un livello) | **✅ Quattro livelli** (Stanza → Libreria → Sezione → Scaffale) |
| Multi-utente nel piano gratuito | ❌ (opzione a pagamento) | ✅ | **✅** |
| Scansione ISBN | ✅ | ✅ | **✅** |
| Source-available / codice ispezionabile | ❌ | ❌ | **✅** |

Le funzionalità e i prezzi cambiano nel tempo — questa tabella riflette quanto
documentato pubblicamente sui siti di Libib e Skoolib al momento della scrittura.
Verifica i loro piani attuali prima di decidere.

## Libib — il migliore per catalogare collezioni miste

Libib è pensato per catalogare più che libri (giochi da tavolo, film, musica, video
giochi) su un massimo di 100 collezioni, con un piano gratuito generoso da 5.000
elementi. È una buona scelta se vuoi uno strumento cloud curato e a manutenzione
zero e non ti serve sapere su quale scaffale fisico si trova qualcosa. Le sue
funzionalità multi-utente sono pensate per organizzazioni — piani Pro e Ultimate a
pagamento, non condivisione familiare gratuita.

## Skoolib — il migliore per piccole biblioteche istituzionali

Skoolib nasce come strumento per biblioteche scolastiche, e si vede nel set di
funzionalità: prestiti, statistiche di circolazione e ruoli multi-utente pensati per
un bibliotecario che gestisce utenti, non per una famiglia che condivide una
libreria. Il piano gratuito da 500 libri e la vista a scaffale virtuale lo rendono
utilizzabile per una biblioteca di casa, ma il prodotto è ottimizzato per un uso
diverso.

## Jinbocho — il migliore per una biblioteca di famiglia self-hosted

Jinbocho non compete su ampiezza delle collezioni o funzionalità istituzionali. Fa
una cosa sola: mappa le tue stanze, librerie, sezioni e scaffali reali, gira su
un'infrastruttura che controlli tu, senza un account che ti blocca e senza un
conteggio di elementi che fa scattare un paywall. Se la tua famiglia vuole
condividere un'unica biblioteca fisica e te la senti di far girare un container
Docker, è questo lo scambio su cui è costruito Jinbocho.

## Provala con un comando

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-community-v1.git
cd jinbocho-infrastructure-community-v1
docker compose -f docker/docker-compose.community.yml up -d
```

(Copia prima i file .env di esempio — vedi il **[Manuale Sviluppatori](../developer/02-local-development.md)** per il setup completo.)

Oppure prova prima la **[demo live](https://jinbocho.github.io/jinbocho-demo/)**.

**Vedi anche:** [Alternativa a Goodreads self-hosted](alternativa-goodreads-self-hosted.md) ·
[Come catalogare la biblioteca di casa](come-catalogare-biblioteca-di-casa.md) ·
[Sapere su quale scaffale è un libro](sapere-su-quale-scaffale-e-un-libro.md)
