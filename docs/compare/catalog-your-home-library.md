---
title: How to catalog your home library (and find any book in seconds)
description: A practical guide to cataloging a home book collection — by ISBN, by room, by shelf — using free, open-source, self-hosted software.
---

# How to catalog your home library

Once a book collection passes a few hundred volumes, "I'll remember where it is"
stops working. Cataloging your home library means you can answer two questions
instantly: *do I own this?* and *where is it right now?*

This guide shows a simple, durable way to do it — for free.

## 1. Decide what a "location" means in your home

Don't catalog into a flat list. Mirror your real space so search can point you to a
physical spot. A four-level model covers almost any home:

- **Room** — Study, Living room, Bedroom…
- **Bookcase** — the piece of furniture
- **Section** — a column or group of shelves
- **Shelf** — the exact row a book sits on

## 2. Add books by scanning the ISBN

Typing titles by hand is what kills most cataloging projects. Scan the barcode on the
back of the book instead: the ISBN looks up the title, author, cover, and publisher
automatically (Open Library and Google Books are free sources). A book takes a couple
of seconds to add.

## 3. Pin each book to its shelf

As you scan, drop the book onto its Room → Bookcase → Section → Shelf. Now your catalog
isn't just a list — it's a **map**. Later, searching a title returns the room and shelf.

## 4. Keep it usable for the whole household

If more than one person adds or borrows books, you want a shared catalog with separate
users — so "who has the second volume?" has an answer.

## 5. Own your data

Pick a tool that lets you **export everything** (CSV/JSON) and, ideally, that you can
**self-host**. Your catalog should outlive any company.

## A tool that does all of this

**[Jinbocho](https://github.com/jinbocho)** is a free, open-source, self-hosted home
library manager built around exactly this workflow: four-level locations, ISBN scanning,
a visual shelf map, multi-user family accounts, and full export.

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-v1.git
cd jinbocho-infrastructure-v1
docker compose -f docker-compose.ghcr.yml up -d
```

Prefer to look before installing? Open the **[live demo](https://jinbocho.onrender.com)**.

**See also:** [Track which shelf a book is on](track-which-shelf-a-book-is-on.md) ·
[A self-hosted Goodreads alternative](goodreads-self-hosted-alternative.md)
