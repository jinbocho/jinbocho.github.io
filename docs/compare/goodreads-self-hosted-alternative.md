---
title: A self-hosted Goodreads alternative for your physical library
description: Jinbocho is a free, source-available, self-hosted alternative to Goodreads and Libib that also maps which shelf each physical book is on.
---

# A self-hosted Goodreads alternative

Goodreads is great for tracking what you've **read** and want to read. But it lives
on someone else's servers, it's built around a social reading feed, and it has no
idea where your physical books actually are. If you want to **own your data** and
**catalog the books on your shelves**, you need a self-hosted alternative.

**[Jinbocho](https://github.com/jinbocho)** is a free, source-available (Jinbocho Source-Available License) home
library manager you run yourself.

## How Jinbocho compares

| | Goodreads | Libib / LibraryThing | **Jinbocho** |
|---|:---:|:---:|:---:|
| Track what you've read | ✅ | ✅ | ✅ |
| Catalog what you own | ❌ | ✅ | ✅ |
| **Which shelf a book is on** | ❌ | ❌ | **✅** |
| Self-hosted / you own the data | ❌ | ❌ | **✅** |
| Multi-user family library | ❌ | partial | **✅** |
| Source-available | ❌ | ❌ | **✅** |
| Export your whole catalog (CSV/JSON) | limited | ✅ | ✅ |

## Why self-host your reading catalog?

- **Your data stays yours.** No account lock-in, no shutdown risk, full CSV/JSON export anytime.
- **It runs on your hardware** — a home server, a NAS, a small VPS, or a Raspberry Pi.
- **Privacy.** Your reading list isn't a social feed or an ad-targeting profile.

## What you get beyond Goodreads

Jinbocho adds the one thing online catalogs can't: a **physical map of your library**.
You model your home as Room → Bookcase → Section → Shelf, scan a book's ISBN, and pin
it to its exact spot. Searching a title tells you the room *and* the shelf.

## Try it in one command

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-community-v1.git
cd jinbocho-infrastructure-community-v1
docker compose -f docker/docker-compose.community.yml up -d
```

(Copy the example env files first — see the **[Developer Manual](../developer/02-local-development.md)** for the full setup.)

Or click around the **[live demo](https://jinbocho.github.io/jinbocho-demo/)** first.

**See also:** [How to catalog your home library](catalog-your-home-library.md) ·
[Track which shelf a book is on](track-which-shelf-a-book-is-on.md) ·
[Jinbocho vs Libib vs Skoolib](jinbocho-vs-libib-vs-skoolib.md)
