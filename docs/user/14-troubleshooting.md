# Troubleshooting

Solutions to the most common issues users encounter.

---

## Login and Authentication

### I forgot my password

Use the self-service reset flow: on the login screen, click **"Forgot
Password?"**, enter your email, and follow the link sent to you. See
**[Authentication → Password Reset](02-authentication.md#password-reset)**
for the full walkthrough.

If the reset email never arrives and you're on a self-hosted instance, it's
likely that whoever manages it hasn't configured an email provider (SMTP) —
reset links are written to the auth-service logs instead in that case. Ask
them to check the logs, or to configure SMTP.

---

### I'm stuck on the login page with no error message

Try these in order:

1. **Hard refresh** — `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac) — clears cached JS
2. **Clear cookies** for the Jinbocho site
3. Check if Jinbocho is reachable: open `https://your-jinbocho-url.onrender.com/health` — it should return `{"status":"ok"}`
4. If the health check times out, the server is waking up — wait 30–60 seconds and try again

---

### I log in successfully but I'm sent back to the login page

Your browser is blocking cookies or localStorage for the site.

- Disable any aggressive privacy extensions for the Jinbocho domain
- Allow cookies for the site in your browser settings
- Try a different browser to confirm

---

### "Session expired" appears frequently

Jinbocho access tokens expire after 30 minutes. The app refreshes them
automatically when you are active. If you see "session expired":

- You may have been inactive for more than 30 minutes with the tab in background
- Simply log in again — your library data is unaffected

---

## Books and Scanning

### I scanned a barcode but nothing happened

1. Make sure camera permission is granted (see **[ISBN Scanning](07-isbn-scanning.md)**)
2. Ensure you are pointing at the **EAN-13 barcode** on the back of the book (the wide barcode above the ISBN number), not a QR code or a smaller barcode
3. Try moving the phone 5 cm closer or further
4. Use **Enter ISBN** as a fallback

---

### A book appears with no title or author

This means the ISBN lookup returned partial metadata. Open the book → **Edit** and fill in the missing fields manually.

---

### I added a book twice by accident

1. Find one of the duplicates in your library
2. Open it → **Delete** → Confirm
3. The other copy is kept

---

### A book disappeared from my library

First, check the search bar (someone may have moved it to a different shelf).
If you cannot find it with search, it may have been deleted by another library member.

Check the audit log on a related book from the same shelf — it may show the deletion.
Deleted books cannot be recovered.

---

## Locations

### I can't delete a room/bookcase/shelf

Locations with books cannot be deleted. Move or delete all books first.

To quickly move all books from one location to another:

1. Browse to the location
2. Select all books (checkbox in the list header)
3. Click **Move selected** → choose the new location

---

### A book is showing in the wrong location

The book's location was probably changed by another library member.
Check the audit log on the book detail page to see who moved it and when.

---

## Performance

### The app is very slow

**Most likely cause**: Render free-tier cold start (see **[FAQ](13-faq.md#why-is-the-app-slow-on-first-open)**).

Wait 30–60 seconds for the services to wake up. The app will be fast afterwards.

---

### The app is slow even after waiting

1. Check your internet connection
2. Try a different browser or device
3. Open DevTools → Network tab → look for failed or very slow requests
4. If many requests are timing out, the Neon database may be auto-suspended — the first query wakes it up, which can take 5–10 seconds

---

### Images (book covers) don't load

Book covers are loaded from Open Library's CDN. If Open Library is having
issues, covers may not appear. This does not affect your book data.

Reload the page in a few minutes. If specific covers are consistently missing,
edit the book and paste a direct cover URL.

---

## Synchronisation and Multiple Devices

### I added a book on my phone but it's not visible on my desktop

Jinbocho updates in real time using TanStack Query. If the book is not visible:

1. Pull to refresh on mobile, or press `F5` on desktop
2. The new book should appear within a few seconds

If it still doesn't appear, log out and back in to force a full data reload.

---

### Two library members edited the same book at the same time

The **last save wins**. There is no conflict resolution. Coordinate with
other library members when editing book metadata.

---

## Still Stuck?

If none of the above solves your problem:

1. Check if the issue is known
2. Open a new issue with:
   - What you tried to do
   - What happened instead
   - Your browser and device
   - Any error message visible on screen
