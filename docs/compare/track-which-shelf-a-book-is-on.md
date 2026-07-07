---
title: Track which shelf a book is on
description: Stop losing books in your own home. Jinbocho tracks the exact shelf each book sits on — room, bookcase, section, shelf — with a visual map and ISBN scanning.
---

# Track which shelf a book is on

Most book apps tell you *whether* you own a book. Almost none tell you **where it
physically is**. If you've ever stood in front of full bookcases unable to find the
one title you want — or re-bought a book you already owned — this is the missing piece.

## The idea: give every book a physical address

Instead of a flat catalog, model your home the way it's actually laid out:

```
Room  →  Bookcase  →  Section  →  Shelf  →  the book
```

Every book gets a precise location. Searching a title returns its **room and shelf**,
not just "yes, you own it". Lend a book out, and you can mark it as away instead of
hunting for an empty gap.

## How it works in practice

1. **Scan** a book's ISBN with your phone — metadata and cover fill in automatically.
2. **Pin** it to its shelf on a visual map of your bookcases.
3. **Search** any title later and jump straight to its spot.
4. **Share** the library with your family so everyone sees the same map.

## Why a map beats a spreadsheet

A spreadsheet can hold a "location" column, but it won't reflect your real furniture,
won't show you a shelf at a glance, and won't survive being maintained by hand. A purpose-built
shelf map keeps the physical layout and the catalog in sync.

## Do this with Jinbocho

**[Jinbocho](https://github.com/jinbocho)** is a free, source-available, self-hosted home
library manager built specifically to track which shelf each book is on — visual map,
ISBN scanning, multi-user family accounts, and full CSV/JSON export.

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-community-v1.git
cd jinbocho-infrastructure-community-v1
docker compose -f docker/docker-compose.community.yml up -d
```

(Copy the example env files first — see the **[Developer Manual](../developer/02-local-development.md)** for the full setup.)

Or try the **[live demo](https://jinbocho.github.io/jinbocho-demo/)** first.

**See also:** [How to catalog your home library](catalog-your-home-library.md) ·
[A self-hosted Goodreads alternative](goodreads-self-hosted-alternative.md) ·
[Jinbocho vs Libib vs Skoolib](jinbocho-vs-libib-vs-skoolib.md)
