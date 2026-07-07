# Getting Started with Jinbocho

Welcome to Jinbocho, your home library management system. This guide will help you set up your library and start cataloging your books in minutes.

## What is Jinbocho?

**Jinbocho** is a digital home library management system. It allows you to:

- **Catalog your physical books** across multiple rooms and bookcases
- **Search and filter** your library instantly
- **Track reading progress**, ratings, and personalised AI recommendations for books you own
- **Organize locations** (rooms → bookcases → shelves)
- **Share with other people** and invite them to collaborate on the same library
- **Export and backup** your library data anytime

Whether you have 10 books or 10,000, Jinbocho helps you organize, find, and manage your collection.

## System Requirements

### Browser Requirements

Jinbocho works on any modern web browser:
- **Chrome** (v90+)
- **Firefox** (v88+)
- **Safari** (v14+)
- **Edge** (v90+)

**Recommended**: Latest version of any of the above for best performance.

### Mobile Support

Jinbocho is fully responsive and works on:
- **iPhone/iPad** (iOS 12+, Safari)
- **Android phones/tablets** (Chrome, Firefox)

**Best experience**: Use the latest version of your browser and a stable internet connection.

### Internet Connection

Jinbocho requires an active internet connection. There is currently no offline mode.

## Accessing Jinbocho

### Visit the App

Open your browser and navigate to your Jinbocho instance's URL (for example
`https://jinbocho.onrender.com`, or a custom domain if you self-host).

### First Visit: Create a Library

When you visit Jinbocho for the first time, you'll see the login screen. Click **"Don't have an account? Register"** to create your library.

## Creating Your Library

### Step 1: Fill in Account Details

You'll see a registration form with:

| Field | Example | Notes |
|-------|---------|-------|
| **Library name** | "The Smith Library" | Name of your book collection (visible to everyone you invite) |
| **Your Name** | "Alice" | Your personal name in the library |
| **Email** | "alice@example.com" | Used for login and password reset |
| **Password** | (hidden) | Minimum 8 characters, case-sensitive |
| **Privacy Policy & Terms** | (checkbox) | You must accept the current Privacy Policy and Terms of Service to register |

### Step 2: Create Your Library

Click **"Register"**. The library is created instantly.

**What happens next**:
- You become the **Admin** of your new library (full access)
- You can now invite other people to join it
- Your library is empty (ready to add books)

### Step 3: Log In

After registration, you may be asked to log in again:
1. Enter your email
2. Enter your password
3. Click **"Login"**

**Success!** You're now in your Jinbocho dashboard.

!!! note "Already a member of another library?"
    If the email you registered also belongs to a library someone else invited you
    to, you'll see a **library picker** after login instead of going straight to
    the dashboard. See **[Authentication → Belonging to Multiple Libraries](02-authentication.md#belonging-to-multiple-libraries)**.

## Your First Look Around

After logging in, you'll see the main dashboard with:

### Navigation Bar

**On desktop**:
- **Logo/Home** — click to return to dashboard
- **Search** — find books by title, author, ISBN
- **Locations** — manage rooms and bookcases
- **Settings** — user preferences and library management

**On mobile** (bottom tab bar):
- 🏠 Dashboard
- 🔍 Search
- 📍 Locations
- ➕ Add Book
- ⚙️ Settings

### Dashboard Overview

Your empty library showing:
- **Books total**: 0 (will increase as you add)
- **Rooms**: 0 (create your first room in Settings)
- **Quick action**: "Add Book" button

## Adding Your First Book

### Option 1: Scan ISBN (Fastest)

1. Click **"Add Book"** → **"Scan ISBN"**
2. Allow camera permission when prompted
3. Point your phone/camera at a book's barcode
4. The app automatically recognizes it and looks up metadata
5. Review title, author, cover image
6. Select where in your library the book goes (room → bookcase → shelf)
7. Click **"Save"**

### Option 2: Manual Entry

If a barcode doesn't scan:

1. Click **"Add Book"** → **"Enter Details Manually"**
2. Type title, author, ISBN (optional), publisher, year
3. Upload a cover image if you like
4. Select location in your library
5. Click **"Save"**

### Option 3: Photograph a Whole Shelf

If you already have several books arranged on a shelf and want to add them all
at once, take a single photo instead of scanning book by book — Jinbocho's AI
reads every visible spine and proposes each title for you to confirm. See
**[ISBN Scanning → Shelf Scan](07-isbn-scanning.md#shelf-scan-photograph-a-whole-shelf)**
for the full walkthrough (requires AI to be enabled on your instance).

### Option 4: From a Backup or Goodreads

If you have a previous Jinbocho backup, or an export from Goodreads:

1. Go to **Settings** → **"Backup & restore"** (Jinbocho backup) or **"Library data"** (Goodreads import) — admin/editor only
2. Upload your file
3. Review and confirm the import
4. Your books appear instantly

See **[Export & Import](08-export-import.md)** for details on both.

## Organizing Your Library (First Setup)

Before you add many books, set up your locations:

### Step 1: Create a Room

1. Go to **Locations** (or **Settings** → **"Manage Locations"**)
2. Click **"New Room"**
3. Name it: "Living Room", "Bedroom", "Study", etc.
4. Click **"Create"**

### Step 2: Create a Bookcase

1. Click on your new room
2. Click **"New Bookcase"**
3. Name it: "Main shelf", "Tall bookcase", etc.
4. Choose how many columns (sections) and rows (shelves)
   - Example: 2 columns × 5 shelves for a standard bookshelf
5. Click **"Create"**

### Step 3: Start Adding Books

Now you can:
1. Add books using scan, manual entry, or a whole-shelf photo
2. Assign each to a specific shelf
3. See your library fill up!

## Inviting Other Members (Optional)

Only Admins can invite new members.

### To Invite Someone

1. Go to **Settings → Users**
2. Click **"Invite User"**
3. Start typing the person's name or email — if they already have a Jinbocho account,
   they'll appear in a suggestion list (pick them directly); otherwise, enter their
   email address as free text
4. Choose their role:
   - **Admin**: Full access (manage users, locations, settings)
   - **Editor**: Can add/edit books and locations
   - **Viewer**: Read-only (browse books)
5. Click **"Send Invitation"**

If they don't already have a Jinbocho account, an email with a registration link
is sent to them. If they do, the invitation appears in their **library picker**
next time they log in, where they can accept or decline it — see
**[Authentication → Belonging to Multiple Libraries](02-authentication.md#belonging-to-multiple-libraries)**.

## Tips for Success

### 📱 Mobile Barcode Scanning
- Hold the book at eye level
- Ensure good lighting
- Keep the barcode centered in the frame
- The scan happens automatically—no button to tap

### 🔍 Using Search
- Search by book title, author, ISBN, or notes
- Use filters to narrow down (room, reading status, language)

### 👥 Sharing a Library
- Every member sees the **same library**
- You can see who added each book
- Notes and reading status are personal (not shared by default)
- Each member can hold a different role in different libraries they belong to

### 📤 Backup Your Data
- Go to **Settings** → **"Backup & restore"**
- Download a full backup anytime
- Your data is yours—keep a backup offline

## Common Questions

**Q: Is my data safe?**  
A: All data is encrypted in transit (HTTPS). Data is stored on secure cloud servers. See **[FAQ](13-faq.md)** for more details.

**Q: Can I use Jinbocho offline?**  
A: Not yet.

**Q: Can I share my library with people outside my household?**  
A: Yes — a library isn't limited to family. Invite anyone by email or username, and assign them a role.

**Q: How do I change my password?**  
A: Go to your profile (click your name/avatar) → **"Change Password"**.

**Q: How do I leave a library?**  
A: Ask an Admin of that library to remove you as a member, or suspend/reassign yourself if you are the sole Admin.

## Next Steps

1. ✅ You've created your library
2. 📚 **Next**: Read **[Authentication & Accounts](02-authentication.md)** to understand login, passwords, sessions, and multi-library membership
3. 🎯 **Then**: Learn how to **[Manage Your Library](03-managing-library.md)**

Happy cataloging! 📖

---

Need help? Visit **[Troubleshooting](14-troubleshooting.md)** or check the **[FAQ](13-faq.md)**.
