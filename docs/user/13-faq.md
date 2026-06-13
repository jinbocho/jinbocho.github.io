# Frequently Asked Questions

---

## Getting Started

### Is Jinbocho free?

Yes. Jinbocho is open-source software licensed under CC BY-NC-ND 4.0-or-later.
You can self-host it for free. The public hosted version (if available) runs on
Render and Neon free tiers, which means it may have cold-start delays but costs nothing.

---

### Do I need to install anything?

No. Jinbocho is a web application. Open it in any modern browser on your phone,
tablet, or computer. No app installation is required.

---

### Can multiple family members use the same library?

Yes — that is the core use case. One family account can have multiple users
with different roles (Admin, Editor, Viewer). All members share the same
book collection. See **[User Management](09-user-management.md)**.

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

The fix applies only to your copy — it does not affect other families' libraries.

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

## Barcode Scanning

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

No personal data or book lists are shared. Only ISBNs go to external services.

---

### Can I delete my account?

Contact your family Admin to remove your user account from the family.
Full account and family deletion is not yet available through the UI —
contact the person who manages your Jinbocho instance for assistance.

---

## Sharing and Collaboration

### Can I share a specific book's page with someone outside my family?

Not currently. Jinbocho is a private family library — all content requires
login to view. Public sharing is not available.

---

### Can two separate families share a library?

No. Each family account is isolated. Books in one family are not visible
to members of another family.

---

### What happens if I leave a family?

An Admin removes you from the family. You lose access to the library
immediately. You can create your own family account with a new registration.

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

Yes. Jinbocho is open-source (CC BY-NC-ND 4.0-or-later) and can be self-hosted
with Docker Compose. See the **[Developer Manual](../developer/index.md)** for full instructions.
