---
title: Un'alternativa a Goodreads self-hosted per la tua biblioteca fisica
description: Jinbocho è un'alternativa a Goodreads e Libib gratuita, open source e self-hosted, che in più mappa su quale scaffale si trova ogni libro fisico.
---

# Un'alternativa a Goodreads self-hosted

Goodreads è ottimo per tracciare cosa hai **letto** e cosa vuoi leggere. Ma vive sui server
di qualcun altro, è costruito attorno a un feed sociale di lettura e non ha idea di dove
siano i tuoi libri fisici. Se vuoi **possedere i tuoi dati** e **catalogare i libri sugli
scaffali**, ti serve un'alternativa self-hosted.

**[Jinbocho](https://github.com/jinbocho)** è un gestionale per la biblioteca di casa
gratuito e open source (CC BY-NC-ND 4.0) che gestisci tu.

## Come si confronta Jinbocho

| | Goodreads | Libib / LibraryThing | **Jinbocho** |
|---|:---:|:---:|:---:|
| Tracciare cosa hai letto | ✅ | ✅ | ✅ |
| Catalogare cosa possiedi | ❌ | ✅ | ✅ |
| **Su quale scaffale è un libro** | ❌ | ❌ | **✅** |
| Self-hosted / dati tuoi | ❌ | ❌ | **✅** |
| Biblioteca di famiglia multi-utente | ❌ | parziale | **✅** |
| Open source | ❌ | ❌ | **✅** |
| Esporta tutto il catalogo (CSV/JSON) | limitato | ✅ | ✅ |

## Perché self-hostare il catalogo di lettura?

- **I dati restano tuoi.** Nessun lock-in, nessun rischio di chiusura, esportazione CSV/JSON sempre disponibile.
- **Gira sul tuo hardware** — un home server, un NAS, una piccola VPS o un Raspberry Pi.
- **Privacy.** La tua lista di lettura non è un feed sociale né un profilo per la pubblicità.

## Cosa ottieni oltre a Goodreads

Jinbocho aggiunge l'unica cosa che i cataloghi online non possono avere: una **mappa fisica
della biblioteca**. Modelli la casa come Stanza → Libreria → Sezione → Scaffale, scansioni
l'ISBN di un libro e lo fissi al suo punto esatto. Cercare un titolo ti dice la stanza *e*
lo scaffale.

## Provala con un comando

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-v1.git
cd jinbocho-infrastructure-v1
docker compose -f docker-compose.ghcr.yml up -d
```

Oppure dai un'occhiata prima alla **[demo live](https://jinbocho.onrender.com)**.

**Vedi anche:** [Come catalogare la biblioteca di casa](come-catalogare-biblioteca-di-casa.md) ·
[Sapere su quale scaffale è un libro](sapere-su-quale-scaffale-e-un-libro.md)