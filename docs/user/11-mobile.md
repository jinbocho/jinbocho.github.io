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
    For a near-app experience, add Jinbocho to your home screen:

    **iOS (Safari)**: Tap the Share icon → **Add to Home Screen** → **Add**

    **Android (Chrome)**: Tap the menu → **Add to Home screen** → **Add**

    The shortcut opens Jinbocho in full-screen mode without browser chrome.

---

## Mobile Layout

On small screens, Jinbocho switches to a **mobile layout**:

```
┌─────────────────────────────┐
│  ☰  Jinbocho          🔍 + │  ← Top bar (menu, search, add)
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
├─────────────────────────────┤
│  🏠    📚    🔍    ⚙️       │  ← Bottom navigation bar
└─────────────────────────────┘
```

The sidebar (visible on desktop) becomes a **hamburger menu** (`☰`) on mobile.

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
| Pull to refresh | Reload the current list |

---

## Location Picker on Mobile

The location picker (room → bookcase → shelf) is optimised for touch:

1. Tap **Add Book** → **Scan** or **Manual**
2. In the form, tap **Choose location**
3. A bottom sheet slides up with the location tree
4. Tap to expand: Room → Bookcase → Section → Shelf
5. Tap the shelf you want
6. The bottom sheet closes and the location is filled in

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

| Screen width | Layout used |
|-------------|-------------|
| < 640 px | Mobile: bottom nav, stacked cards |
| 640 – 1024 px | Tablet: sidebar (collapsible), 2-column grid |
| > 1024 px | Desktop: full sidebar, 3-column grid |
