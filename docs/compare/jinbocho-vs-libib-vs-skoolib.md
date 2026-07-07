---
title: Jinbocho vs Libib vs Skoolib — which home library app fits you?
description: A factual comparison of Jinbocho, Libib, and Skoolib for cataloging a home book collection — hosting model, free-tier limits, and physical shelf mapping.
---

# Jinbocho vs Libib vs Skoolib

Libib and Skoolib are both solid, purpose-built cataloging apps — this isn't a
"they're bad, we're good" page. They're cloud services built to work well out of
the box for a wide range of collection sizes, including small institutions. Jinbocho
solves a narrower problem — a single home library, self-hosted — and trades their
convenience for full data ownership and no per-item ceilings.

## How they compare

| | Libib | Skoolib | **Jinbocho** |
|---|:---:|:---:|:---:|
| Hosting | Cloud only | Cloud only | **Self-hosted** |
| Free tier | 5,000 items | 500 books | **No item limit** (your own database) |
| Physical shelf/room mapping | ❌ | Virtual bookshelf (single level) | **✅ Four levels** (Room → Bookcase → Section → Shelf) |
| Multi-user on the free tier | ❌ (paid add-on) | ✅ | **✅** |
| ISBN barcode scanning | ✅ | ✅ | **✅** |
| Source-available / inspectable code | ❌ | ❌ | **✅** |

Feature sets and pricing change — this table reflects what was publicly documented
on Libib's and Skoolib's own sites at the time of writing. Check their current
plans before deciding.

## Libib — best for multi-collection cataloging

Libib is built to catalog more than books (board games, movies, music, video games
too) across up to 100 collections, with a generous 5,000-item free tier. It's a
good fit if you want a polished, zero-maintenance cloud tool and don't need to know
which physical shelf something is on. Its multi-user features are aimed at
organizations — paid Pro and Ultimate plans, not free family sharing.

## Skoolib — best for small institutional libraries

Skoolib grew out of a school library tool, and it shows in the feature set: patron
lending, circulation stats, and multi-user roles built for a librarian managing
patrons, not a household sharing a bookcase. Its 500-book free tier and virtual
bookshelf view make it usable for a home library, but the product is optimized for
a different job.

## Jinbocho — best for a self-hosted family library

Jinbocho doesn't compete on collection breadth or institutional features. It does
one thing: map your actual rooms, bookcases, sections, and shelves, run on
infrastructure you control, with no account to lock you in and no item count that
triggers a paywall. If your family wants to share one physical library and you're
comfortable running a Docker container, that's the trade Jinbocho is built around.

## Try it in one command

```bash
git clone https://github.com/jinbocho/jinbocho-infrastructure-community-v1.git
cd jinbocho-infrastructure-community-v1
docker compose -f docker/docker-compose.community.yml up -d
```

(Copy the example env files first — see the **[Developer Manual](../developer/02-local-development.md)** for the full setup.)

Or try the **[live demo](https://jinbocho.github.io/jinbocho-demo/)** first.

**See also:** [A self-hosted Goodreads alternative](goodreads-self-hosted-alternative.md) ·
[How to catalog your home library](catalog-your-home-library.md) ·
[Track which shelf a book is on](track-which-shelf-a-book-is-on.md)
