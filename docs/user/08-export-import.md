# Export & Backup

Back up your library or analyse your collection in a spreadsheet.

---

## Exporting Your Library

Jinbocho supports two export formats:

| Format | Best for |
|--------|----------|
| **CSV** | Spreadsheets, Excel, Google Sheets, plain text editing |
| **JSON** | Full backup, scripting, technical users |

### How to Export

1. Open **Settings** (gear icon in the sidebar)
2. Under **Export Library**, choose your format: **CSV** or **JSON**
3. Click the download button — your browser saves the file immediately

The export button is also available directly on the **Books** page via the export menu in the top-right corner.

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
  "family_id": "fam_abc123",
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

## Backing Up Your Library

For a full backup, export **JSON** format. JSON preserves all data including
location structure and timestamps. CSV is convenient for viewing but may
lose some precision (e.g. timestamps rounded to dates).

**Recommended backup schedule**: once a month, download a JSON export and
keep it in a cloud storage folder (Google Drive, Dropbox, iCloud).

---

## Import (Coming Soon)

Bulk importing books from a CSV or JSON file is not yet available in the
current version. It is planned as a future feature.

In the meantime, books can be added individually via:

- **[ISBN Scanning](07-isbn-scanning.md)** — the fastest method for physical books
- **[ISBN manual entry](03-managing-library.md#method-2-enter-an-isbn-manually)** — type or paste an ISBN
- **[Manual entry](03-managing-library.md#method-3-manual-entry)** — for books without ISBN

---

## Reading Status Values

When reviewing exports, these are the valid `reading_status` values:

| Value | Meaning |
|-------|---------|
| `want_to_read` | In your to-read pile |
| `reading` | Currently reading |
| `finished` | Completed |
