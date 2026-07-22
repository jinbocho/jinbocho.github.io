# Frequently Asked Questions

---

## Getting Started

### Is Jinbocho free?

Yes. Jinbocho is source-available software licensed under the Jinbocho Source-Available
License (free for personal, non-commercial use). You can self-host it for free. The public
hosted version (if available) runs on Render and Neon free tiers, which means it may have
cold-start delays but costs nothing.

---

### Do I need to install anything?

No. Jinbocho is a web application. Open it in any modern browser on your phone,
tablet, or computer. No app installation is required.

---

### Can multiple people use the same library?

Yes — that is the core use case. One library can have multiple members
with different roles (Admin, Editor, Viewer). All members share the same
book collection. See **[User Management](09-user-management.md)**.

---

### Can I belong to more than one library?

Yes. The same account can be a member of several libraries at once — for
example your own plus a friend's or partner's — and can hold a different role
in each. If you belong to more than one, you'll see a **library picker** after
login to choose which one to enter, and can switch between them later from the
header. Libraries themselves stay isolated: belonging to two libraries doesn't
merge their books or members. See
**[Authentication → Belonging to Multiple Libraries](02-authentication.md#belonging-to-multiple-libraries)**.

---

### How many books can I store?

There is no hard limit in the application. The practical limit depends on
your database storage. On Neon's free tier, the database limit is 0.5 GB —
that is enough for tens of thousands of books with metadata.

---

## Books and Metadata

### The book I scanned has wrong information. What do I do?

1. Open the book's detail page
2. Click **Edit** (pencil icon)
3. Correct the title, author, or any other field
4. Click **Save Changes**

The fix applies only to your copy — it does not affect other libraries.

---

### The ISBN lookup returned no results. What now?

Click **Add Manually** on the "not found" screen.
Fill in the title and author yourself. This is normal for:

- Very old books (pre-1970)
- Limited regional editions
- Self-published books
- Books not indexed by Open Library or Google Books

---

### Can I add the same book more than once?

Yes. If you own two physical copies of the same book (e.g. one in the living room, one in the bedroom), add the ISBN twice and place each copy in a different location.

---

### I added a book to the wrong shelf. Can I move it?

Yes. Open the book → **Change Location** → select the correct room, bookcase, and shelf → **Confirm Move**.
The move is logged in the audit history.

---

### The book cover is missing or wrong. How do I fix it?

1. Find a direct image URL for the cover (e.g. from the publisher's website or Open Library)
2. Open the book → **Edit**
3. Paste the URL in the **Cover URL** field
4. Save

The cover is loaded from the URL you provide, not uploaded.

---

### Can I import my existing Goodreads library?

Yes — an Admin or Editor can import a Goodreads CSV export from
**Settings → Library data**. See **[Export & Import → Importing from Goodreads](08-export-import.md#importing-from-goodreads)**.

---

## Barcode Scanning and Shelf Scan

### The scanner won't open. What's wrong?

The most common cause is that camera permission was denied.

- **Browser bar**: look for a camera icon in the address bar and click **Allow**
- **iOS**: Settings → Safari → Camera → Allow
- **Android**: Settings → Apps → your browser → Permissions → Camera → Allow

---

### The scanner keeps scanning without detecting anything.

Try:
1. More light — move near a window or turn on a lamp
2. Steady the phone — rest your elbow on a surface
3. Different distance — try 15–20 cm from the barcode
4. Clean the lens with a soft cloth

If nothing works, type the ISBN manually using **Enter ISBN**.

---

### Does scanning work without an internet connection?

The camera decodes the barcode without internet. But the ISBN lookup
(fetching title and author) requires an internet connection.
If you're offline, the scan still reads the ISBN — but you'll need
to add the metadata manually or wait until you're online.

---

### Why don't I see a "Scan a whole shelf" option?

Shelf Scan only shows up when your instance's AI module is enabled **and**
configured with a vision-capable model. If either is missing, the option is
hidden — ask your administrator, or use regular ISBN scanning instead. See
**[ISBN Scanning → Shelf Scan](07-isbn-scanning.md#shelf-scan-photograph-a-whole-shelf)**.

---

## Performance

### Why is the app slow on first open?

The app is hosted on Render's free tier, which puts services to sleep after
15 minutes of inactivity. The first request wakes them up, which takes
20–60 seconds.

After that, everything is fast. This is a tradeoff of the free hosting tier.
If you need instant response always, upgrade to Render Starter ($7/month per service).

---

### The app was fast before and now it's slow again.

The services have gone back to sleep (no activity for 15+ minutes).
The next interaction will wake them up. This is normal on the free tier.

---

## Privacy and Data

### Where is my data stored?

Your data is stored in PostgreSQL databases hosted on [Neon](https://neon.tech).
Neon's servers are in the US by default. If data residency matters to you,
self-host Jinbocho on your own infrastructure.

---

### Does Jinbocho send my data to anyone?

When you scan or enter an ISBN, Jinbocho queries:
- **Open Library** (openlibrary.org) — sends only the ISBN number
- **Google Books** (googleapis.com) — sends only the ISBN number

If AI features are enabled on your instance (Shelf Scan, Book Presentation,
Recommendations), your library's configured AI provider also receives the
relevant book photo/metadata to process those requests. No personal data or
book lists are shared with Open Library or Google Books beyond the ISBN.

---

### Can I get a copy of my personal data (GDPR-style export)?

There's no self-service "export my data" button for individual members yet.
Ask your library's Admin to download a
**[full backup](08-export-import.md#backup-restore)** (which includes the
member roster, books, loans and reading history), or contact
**support@jinbocho.eu** directly.

---

### Can I delete my account?

Account deletion is **Admin-only and deletes the whole library**, not just one
person's account — there's currently no way for a non-Admin to self-delete
just their own account. Ask an Admin to remove you as a member instead if you
just want to leave, or see
**[Authentication → Deleting a Library](02-authentication.md#deleting-a-library)**
if you're an Admin and want to delete everything.

---

## Sharing and Collaboration

### Can I share a specific book's page with someone outside my library?

Not currently. Jinbocho requires login to view any content. Public sharing is not available.

---

### Can two separate libraries share book data?

No. Each library's books, locations and loans are isolated from every other
library, even if the same person is a member of both (see
**[Can I belong to more than one library?](#can-i-belong-to-more-than-one-library)** above).

---

### What happens if I leave a library?

An Admin removes you (or suspends you temporarily) from that library. You lose
access to it immediately, but your account and any other libraries you belong
to are unaffected. You can also register your own new library at any time.

---

## Technical

### What browsers are supported?

| Browser | Version | Support |
|---------|---------|----------|
| Chrome | 110+ | ✅ Full |
| Firefox | 110+ | ✅ Full |
| Safari | 16+ | ✅ Full |
| Edge | 110+ | ✅ Full |
| Samsung Internet | 22+ | ✅ Full |
| IE | Any | ❌ Not supported |

---

### Can I self-host Jinbocho?

Yes. Jinbocho is source-available (Jinbocho Source-Available License) and can be self-hosted
with Docker Compose. See the **[Developer Manual](../developer/index.md)** for full instructions.
