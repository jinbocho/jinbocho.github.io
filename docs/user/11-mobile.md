# Mobile Experience

Jinbocho is a web application that works on any modern smartphone or tablet
without installation. Open it in your mobile browser and it adapts to your screen.

---

## No App to Install

Jinbocho runs in your browser. On mobile, open your preferred browser
and navigate to your Jinbocho URL:

- **iOS** — Safari, Chrome, or Firefox
- **Android** — Chrome, Firefox, or Samsung Internet

!!! tip "Add to Home Screen"
    Jinbocho is a regular web app — there is no installable PWA (no app
    manifest, no offline support). You can still add a shortcut to your
    home screen for quick access:

    **iOS (Safari)**: Tap the Share icon → **Add to Home Screen** → **Add**

    **Android (Chrome)**: Tap the menu → **Add to Home screen** → **Add**

    This creates a bookmark-style shortcut. Whether it opens full-screen
    or with the browser's address bar visible depends on your browser and
    OS — it is not guaranteed to be chrome-free like a real installed app.

---

## Mobile Layout

Below the desktop breakpoint (768px), Jinbocho switches to a **mobile layout**:
a slim top bar replaces the full sidebar, and navigation moves into a
slide-in drawer.

```
┌─────────────────────────────┐
│  ☰   Jinbocho          ⏻   │  ← Top bar (menu, logout)
├─────────────────────────────┤
│                             │
│  [Book card]                │
│  The Name of the Wind       │
│  Patrick Rothfuss · 🟡      │
│                             │
│  [Book card]                │
│  Il deserto dei Tartari     │
│  Dino Buzzati · 🟢          │
│                             │
│  [Book card]                │
│  …                          │
│                             │
└─────────────────────────────┘
```

Tapping `☰` slides in a drawer with the full navigation: Home, Books,
Wishlist, On Loan, Locations, Stats, Users (admins only), and Settings — the
same items shown in the sidebar on desktop.

---

## ISBN Scanning on Mobile

The barcode scanner works best on mobile because smartphone cameras
have autofocus and a good macro lens.

### Using the back camera

1. Tap **Add Book** (`+` button)
2. Select **Scan ISBN**
3. Allow camera access when prompted
4. Jinbocho uses the **rear camera** automatically on mobile
5. Point the camera at the barcode

```
             📱
         ┌───────┐
         │ 📷 ←──┼── rear camera
         │       │
         │       │
         └───────┘
              │
              ↓ (15–25 cm)
    ══════════════════
    ▐▌▐▌▐▌▐▌▐▌▐▌▐▌▐▌  ← barcode
    ══════════════════
```

- Hold the phone **above** the book, not at an angle
- Keep the barcode fully inside the camera view
- Tap the screen to focus if the image is blurry

See **[ISBN Scanning](07-isbn-scanning.md)** for complete guidance.

---

## Touch Gestures

| Gesture | Action |
|---------|--------|
| Tap a book card | Open book detail |
| Tap the status badge | Change reading status |
| Tap `☰` | Open the navigation drawer |

---

## Location Picker on Mobile

The location picker is a set of four cascading dropdowns — Room, Bookcase,
Section, Shelf — that stack into a single column on narrow screens:

1. Tap **Add Book** → **Scan** or **Manual**
2. In the form, tap the **Room** dropdown and pick one
3. The **Bookcase** dropdown unlocks and fills with that room's bookcases
4. Repeat for **Section** and **Shelf** — each unlocks once its parent is chosen
5. Leave any level unselected if you don't want to be that specific

---

## Mobile Performance Tips

### Slow loading on first visit

Jinbocho uses **TanStack Query** to cache API responses in memory.
The first time you open a page, it loads from the server.
Subsequent visits within the same session are instant (cached).

If the app feels slow on the first open, it may be due to
Render free-tier cold starts. See **[FAQ → Cold starts](13-faq.md#why-is-the-app-slow-on-first-open)**.

### Low memory devices

If the app becomes unresponsive after extended use, close and reopen the browser tab.
This clears the in-memory cache and frees up RAM.

---

## Offline Support

Jinbocho currently **requires an internet connection** to function.
There is no offline mode — all data is stored on the server.

If you lose connectivity while scanning:

- The camera still decodes the barcode
- The ISBN lookup fails (no internet → no metadata)
- The book cannot be saved until the connection is restored

---

## Responsive Breakpoints

Navigation and the book grid switch independently, at different widths:

| Screen width | Navigation | Book grid columns |
|-------------|------------|--------------------|
| < 640 px | Top bar + drawer (`☰`) | 1 column |
| 640 – 767 px | Top bar + drawer (`☰`) | 2 columns |
| 768 – 1023 px | Full sidebar | 2 columns |
| ≥ 1024 px | Full sidebar | 4 columns |
