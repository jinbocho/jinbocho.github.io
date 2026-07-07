# Export & Backup

Jinbocho gives you two separate tools, for two different jobs:

| Tool | Where | What it's for |
|------|-------|----------------|
| **Export books (CSV/JSON)** | Settings → Export books, or the export menu on the Books page | A lightweight, books-only list for spreadsheets or quick analysis. **Not a restore format.** |
| **Backup & restore** | Settings → Backup & restore | A complete, restorable snapshot of your whole library — locations, books, loans, reading history and the member roster. Use it to move to a new database without losing anything. |
| **Goodreads import** | Settings → Library data | Bring in an existing Goodreads export as a starting point, instead of adding books one by one. |

This page covers both, plus how to restore from a backup.

---

## Exporting Your Library (CSV/JSON)

Jinbocho supports two lightweight export formats:

| Format | Best for |
|--------|----------|
| **CSV** | Spreadsheets, Excel, Google Sheets, plain text editing |
| **JSON** | Scripting, technical users, quick structured exports |

### How to Export

1. Open **Settings** (gear icon in the sidebar)
2. Under **Export books (CSV/JSON)**, choose your format: **CSV** or **JSON**
3. Click the download button — your browser saves the file immediately

The export button is also available directly on the **Books** page via the export menu in the top-right corner.

!!! note "Not a restore format"
    This export only contains your owned books and where they're shelved. It does
    not include loans, per-member reading history, or the member roster,
    and there is no matching "import CSV" feature. For anything you might need to
    restore later, use **Backup & restore** below instead.

---

## CSV Export

The exported CSV has one row per owned book copy.

### CSV columns

| Column | Description | Example |
|--------|-------------|----------|
| `id` | Internal ID of the owned copy | `c3f1a2b4` |
| `isbn` | ISBN-13 of the bibliographic record | `9788845292613` |
| `title` | Book title | `Il deserto dei Tartari` |
| `author` | Author(s), comma-separated | `Dino Buzzati` |
| `publisher` | Publisher name | `Mondadori` |
| `published_date` | Publication year or date | `1940` |
| `language` | Language code | `it` |
| `page_count` | Number of pages | `256` |
| `room` | Room name | `Living Room` |
| `bookcase` | Bookcase name | `IKEA Billy` |
| `section` | Section name (if any) | `Left column` |
| `shelf` | Shelf name | `Shelf 2` |
| `position` | Position number on shelf | `3` |
| `reading_status` | Current status | `finished` |
| `added_at` | When the copy was added (ISO 8601) | `2026-01-15T18:30:00Z` |

### Example CSV

```csv
id,isbn,title,author,publisher,published_date,language,page_count,room,bookcase,section,shelf,position,reading_status,added_at
c3f1a2b4,9788845292613,Il deserto dei Tartari,Dino Buzzati,Mondadori,1940,it,256,Living Room,IKEA Billy,Left column,Shelf 2,3,finished,2026-01-15T18:30:00Z
a7e9c123,9780261103573,The Fellowship of the Ring,J.R.R. Tolkien,HarperCollins,1954,en,432,Study,Corner shelf,,Shelf 1,1,want_to_read,2026-02-03T10:00:00Z
```

!!! tip "Open in Excel or Google Sheets"
    The CSV uses UTF-8 encoding and comma separators. If special characters
    (accents, non-Latin scripts) appear broken in Excel, import it by
    specifying UTF-8 encoding:
    **Data → From Text/CSV → File origin: 65001 Unicode (UTF-8)**.

---

## JSON Export

The JSON export is a full structured backup, preserving all data including
nested location objects.

### JSON structure

```json
{
  "exported_at": "2026-06-11T20:00:00Z",
  "library_id": "lib_abc123",
  "books": [
    {
      "id": "c3f1a2b4",
      "bibliographic_record": {
        "isbn": "9788845292613",
        "title": "Il deserto dei Tartari",
        "author": "Dino Buzzati",
        "publisher": "Mondadori",
        "published_date": "1940",
        "language": "it",
        "page_count": 256,
        "description": "..."
      },
      "location": {
        "room": "Living Room",
        "bookcase": "IKEA Billy",
        "section": "Left column",
        "shelf": "Shelf 2",
        "position": 3
      },
      "reading_status": "finished",
      "added_at": "2026-01-15T18:30:00Z"
    }
  ]
}
```

---

## Backup & Restore

For a complete, restorable backup of your whole library, use **Backup &
restore** in Settings — not the CSV/JSON book export above.

### What's included

A full backup contains everything:

- The library and its member roster (names, emails, roles)
- Rooms, bookcases, sections and shelves
- Every owned book and its bibliographic record
- Loans (active and past)
- Per-member reading history ("reads")

### How to back up

1. Open **Settings** (gear icon in the sidebar)
2. Under **Backup & restore**, click **Download full backup**
3. Your browser downloads a single JSON file (`jinbocho-backup-YYYY-MM-DD.json`)

**Recommended backup schedule**: once a month, download a full backup and
keep it in a cloud storage folder (Google Drive, Dropbox, iCloud).

### How to restore

1. Open **Settings** → **Backup & restore**
2. Click **Restore from backup** and select a previously downloaded backup file
3. Review the confirmation dialog: it shows the library name, when the backup
   was exported, and counts of members, rooms, books and loans it contains
4. Click **Restore** to confirm

!!! tip "Restoring merges, it doesn't overwrite"
    Restoring a backup merges it into your *current* library rather than
    replacing it: rooms, bookcases, books and members already present are
    recognized and reused, so nothing gets duplicated — even if you restore
    the same file twice. This also makes it safe to use a backup to migrate
    your library to a new Jinbocho instance.

If a member was removed after the backup was taken but is still
referenced in it (e.g. they used to own or read a book), restoring recreates
them with their original name and email so that history isn't lost.

If the restore fails partway through, Jinbocho tells you which step failed
(member roster or library data) so you know whether it's safe to simply try
again.

For adding individual books instead of restoring a backup, see:

- **[ISBN Scanning](07-isbn-scanning.md)** — the fastest method for physical books
- **[ISBN manual entry](03-managing-library.md#method-2-enter-an-isbn-manually)** — type or paste an ISBN
- **[Manual entry](03-managing-library.md#method-3-manual-entry)** — for books without ISBN

---

## Importing from Goodreads

If you're moving from Goodreads, you don't have to re-enter your list by hand.

1. In Goodreads, export your library (**My Books → Import/Export → Export Library**) to get a CSV file
2. In Jinbocho, open **Settings → Library data** (Admin or Editor only)
3. Click **Import from Goodreads** and upload the CSV
4. Review the results — Jinbocho looks up each ISBN and adds a bibliographic
   record and an owned copy for every match
5. Assign locations afterwards, since Goodreads exports don't know about your
   rooms and shelves

!!! note "Matching is best-effort"
    Books without a usable ISBN in the Goodreads export, or that Open Library
    and Google Books don't recognise, won't be imported automatically — add
    those manually afterwards.

---

## Reading Status Values

When reviewing exports, these are the valid `reading_status` values:

| Value | Meaning |
|-------|---------|
| `want_to_read` | In your to-read pile |
| `reading` | Currently reading |
| `finished` | Completed |
