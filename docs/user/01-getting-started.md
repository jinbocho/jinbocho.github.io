# Getting Started with Jinbocho

Welcome to Jinbocho, your family's home library management system. This guide will help you set up your account and start cataloging your books in minutes.

## What is Jinbocho?

**Jinbocho** is a digital home library management system designed for families. It allows you to:

- **Catalog your physical books** across multiple rooms and bookcases
- **Search and filter** your library instantly
- **Track reading progress** for books you own
- **Organize locations** (rooms → bookcases → shelves)
- **Share with family members** and invite them to collaborate
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

Jinbocho requires an active internet connection. There is currently no offline mode (coming soon).

## Accessing Jinbocho

### Visit the App

Open your browser and navigate to:
```
https://jinbocho.onrender.com
```

Or if your family has a custom domain, use that instead.

### First Visit: Create an Account

When you visit Jinbocho for the first time, you'll see the login screen. Click **"Don't have an account? Register"** to create your family account.

## Creating Your Family Account

### Step 1: Fill in Account Details

You'll see a registration form with:

| Field | Example | Notes |
|-------|---------|-------|
| **Family Name** | "Smith Family" | Name of your household (visible to all members) |
| **Your Name** | "Alice" | Your personal name in the family |
| **Email** | "alice@example.com" | Used for login and password reset |
| **Password** | (hidden) | Minimum 8 characters, case-sensitive |

### Step 2: Create Your Account

Click **"Register"**. The account is created instantly.

**What happens next**:
- You become the **Admin** of your family (full access)
- You can now invite other family members
- Your library is empty (ready to add books)

### Step 3: Log In

After registration, you may be asked to log in again:
1. Enter your email
2. Enter your password
3. Click **"Login"**

**Success!** You're now in your Jinbocho dashboard.

## Your First Look Around

After logging in, you'll see the main dashboard with:

### Navigation Bar

**On desktop**:
- **Logo/Home** — click to return to dashboard
- **Search** — find books by title, author, ISBN
- **Locations** — manage rooms and bookcases
- **Settings** — user preferences and family management

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

### Option 3: From Your Library Export

If you have a previous library backup (CSV or JSON):

1. Go to **Settings** → **"Import Library"** (admin only)
2. Upload your file
3. Review and confirm the import
4. Your books appear instantly

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
1. Add books using scan or manual entry
2. Assign each to a specific shelf
3. See your library fill up!

## Inviting Family Members (Optional)

Only the family admin can invite members.

### To Invite Someone

1. Go to **Settings** → **"Manage Family"**
2. Click **"Invite User"**
3. Enter their email
4. Choose their role:
   - **Admin**: Full access (manage users, locations, settings)
   - **Editor**: Can add/edit books and locations
   - **Viewer**: Read-only (browse books)
5. Click **"Send Invite"**

An email with an invitation link is sent to them. They click the link, set a password, and join your family library.

## Tips for Success

### 📱 Mobile Barcode Scanning
- Hold the book at eye level
- Ensure good lighting
- Keep the barcode centered in the frame
- The scan happens automatically—no button to tap

### 🔍 Using Search
- Search by book title, author, ISBN, or notes
- Use filters to narrow down (room, reading status, language)
- Bookmark frequent searches (future feature)

### 👨‍👩‍👧 Family Collaboration
- Each family member sees the **same library**
- You can see who added each book
- Notes and reading status are personal (not shared by default)

### 📤 Backup Your Data
- Go to **Settings** → **"Export Library"**
- Download CSV or JSON anytime
- Your data is yours—keep a backup offline

## Common Questions

**Q: Is my data safe?**  
A: All data is encrypted in transit (HTTPS). Data is stored on secure cloud servers. See **[FAQ](13-faq.md)** for more details.

**Q: Can I use Jinbocho offline?**  
A: Not yet. Offline mode with sync is planned for 2026.

**Q: Can I share my library with friends (not family)?**  
A: Currently family-only. Friend sharing is planned for a future release.

**Q: How do I change my password?**  
A: Go to **Settings** → **"Account"** → **"Change Password"**.

**Q: How do I leave my family?**  
A: Go to **Settings** → **"Leave Family"**. (Admin cannot leave unless transferring admin to another member.)

## Next Steps

1. ✅ You've created your account
2. 📚 **Next**: Read **[Authentication & Accounts](02-authentication.md)** to understand login, passwords, and sessions
3. 🎯 **Then**: Learn how to **[Manage Your Library](03-managing-library.md)**

Happy cataloging! 📖

---

Need help? Visit **[Troubleshooting](14-troubleshooting.md)** or check the **[FAQ](13-faq.md)**.
