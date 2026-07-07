---
title: Come catalogare la biblioteca di casa (e trovare ogni libro in pochi secondi)
description: Guida pratica per catalogare la collezione di libri di casa — per ISBN, per stanza, per scaffale — con software gratuito, source-available e self-hosted.
---

# Come catalogare la biblioteca di casa

Superati qualche centinaio di volumi, il "tanto mi ricordo dov'è" smette di funzionare.
Catalogare la biblioteca di casa significa rispondere subito a due domande: *ce l'ho?*
e *dov'è adesso?*

Questa guida mostra un metodo semplice e duraturo per farlo — gratis.

## 1. Definisci cosa significa "posizione" in casa tua

Non catalogare in una lista piatta. Rispecchia lo spazio reale, così la ricerca ti porta
a un punto fisico. Un modello a quattro livelli copre quasi ogni casa:

- **Stanza** — Studio, Soggiorno, Camera…
- **Libreria** — il mobile
- **Sezione** — una colonna o un gruppo di ripiani
- **Scaffale** — la fila esatta in cui sta il libro

## 2. Aggiungi i libri scansionando l'ISBN

Digitare i titoli a mano è ciò che fa naufragare la maggior parte dei progetti di
catalogazione. Scansiona invece il codice a barre sul retro del libro: l'ISBN recupera
in automatico titolo, autore, copertina ed editore (Open Library e Google Books sono
fonti gratuite). Un libro si aggiunge in un paio di secondi.

## 3. Assegna ogni libro al suo scaffale

Mentre scansioni, posiziona il libro su Stanza → Libreria → Sezione → Scaffale. Ora il
catalogo non è più una lista: è una **mappa**. In seguito, cercare un titolo restituisce
la stanza e lo scaffale.

## 4. Tienilo usabile per tutta la famiglia

Se più persone aggiungono o prendono in prestito libri, serve un catalogo condiviso con
utenti separati — così "chi ha il secondo volume?" ha una risposta.

## 5. I dati restano tuoi

Scegli uno strumento che ti permetta di **esportare tutto** (CSV/JSON) e, idealmente, che
puoi **self-hostare**. Il tuo catalogo deve sopravvivere a qualsiasi azienda.

## Uno strumento che fa tutto questo

**[Jinbocho](https://github.com/jinbocho)** è un gestionale per la biblioteca di casa
gratuito, source-available e self-hosted, costruito esattamente su questo flusso: posizioni a
quattro livelli, scansione ISBN, mappa visiva degli scaffali, account famiglia multi-utente
ed esportazione completa.

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-community-v1.git
cd jinbocho-infrastructure-community-v1
docker compose -f docker/docker-compose.community.yml up -d
```

(Copia prima i file .env di esempio — vedi il **[Manuale Sviluppatori](../developer/02-local-development.md)** per il setup completo.)

Preferisci guardare prima di installare? Apri la **[demo live](https://jinbocho.github.io/jinbocho-demo/)**.

**Vedi anche:** [Sapere su quale scaffale è un libro](sapere-su-quale-scaffale-e-un-libro.md) ·
[Alternativa a Goodreads self-hosted](alternativa-goodreads-self-hosted.md) ·
[Jinbocho vs Libib vs Skoolib](jinbocho-vs-libib-vs-skoolib.md)