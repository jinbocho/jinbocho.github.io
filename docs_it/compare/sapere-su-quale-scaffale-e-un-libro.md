---
title: Sapere su quale scaffale è un libro
description: Smetti di perdere i libri in casa tua. Jinbocho tiene traccia dello scaffale esatto di ogni libro — stanza, libreria, sezione, scaffale — con mappa visiva e scansione ISBN.
---

# Sapere su quale scaffale è un libro

La maggior parte delle app dei libri ti dice *se* possiedi un libro. Quasi nessuna ti dice
**dove si trova fisicamente**. Se ti è mai capitato di restare davanti alle librerie piene
senza trovare l'unico titolo che cerchi — o di ricomprare un libro che avevi già — questo è
il pezzo che manca.

## L'idea: dare a ogni libro un indirizzo fisico

Invece di un catalogo piatto, modella la casa com'è davvero disposta:

```
Stanza  →  Libreria  →  Sezione  →  Scaffale  →  il libro
```

Ogni libro riceve una posizione precisa. Cercare un titolo restituisce la sua **stanza e
scaffale**, non solo "sì, ce l'hai". Presti un libro? Lo segni come "fuori" invece di
cercare un buco vuoto sullo scaffale.

## Come funziona in pratica

1. **Scansiona** l'ISBN di un libro col telefono — metadati e copertina si compilano da soli.
2. **Posizionalo** sul suo scaffale, su una mappa visiva delle tue librerie.
3. **Cerca** un titolo più tardi e vai dritto al punto.
4. **Condividi** la biblioteca con la famiglia, così tutti vedono la stessa mappa.

## Perché una mappa batte un foglio di calcolo

Un foglio di calcolo può avere una colonna "posizione", ma non rispecchia i tuoi mobili
reali, non ti mostra uno scaffale a colpo d'occhio e non sopravvive alla manutenzione a mano.
Una mappa degli scaffali dedicata tiene allineati layout fisico e catalogo.

## Fallo con Jinbocho

**[Jinbocho](https://github.com/jinbocho)** è un gestionale per la biblioteca di casa
gratuito, source-available e self-hosted, costruito apposta per sapere su quale scaffale è ogni
libro — mappa visiva, scansione ISBN, account famiglia multi-utente ed esportazione CSV/JSON.

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-community-v1.git
cd jinbocho-infrastructure-community-v1
docker compose -f docker/docker-compose.community.yml up -d
```

(Copia prima i file .env di esempio — vedi il **[Manuale Sviluppatori](../developer/02-local-development.md)** per il setup completo.)

Oppure prova prima la **[demo live](https://jinbocho.github.io/jinbocho-demo/)**.

**Vedi anche:** [Come catalogare la biblioteca di casa](come-catalogare-biblioteca-di-casa.md) ·
[Alternativa a Goodreads self-hosted](alternativa-goodreads-self-hosted.md) ·
[Jinbocho vs Libib vs Skoolib](jinbocho-vs-libib-vs-skoolib.md)