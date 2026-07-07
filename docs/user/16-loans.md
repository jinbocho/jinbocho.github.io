# Loans

Keep track of books you've lent out — to another library member or to anyone
outside your library — so nothing gets forgotten on someone else's shelf.

---

## What a Loan Tracks

A loan records these things about a physical copy:

| Field | Description |
|-------|-------------|
| **Borrower name** | Required — either a name you type freely (a friend, a colleague, anyone outside your library), or an existing library member picked from search |
| **Linked member** *(optional)* | If you picked a library member from search instead of typing a name, the loan is linked to their profile |
| **Loaned on** | Recorded automatically when you lend the book |
| **Due date** | Optional — set it if you want a reminder of when the book should come back |

A book can only be on loan to **one borrower at a time**. You can't lend out
a copy that's already on loan until it's marked as returned.

!!! info "Who can lend and return books"
    Lending and returning books requires the **Admin** or **Editor** role.
    **Viewers** can see who currently has a book, but can't lend it out or
    mark it returned.

---

## Lending a Book

1. Open the book's detail page
2. Scroll to the **Loans** section
3. Start typing the borrower's name in the **borrower** field:
    - If it matches a current library member, pick them from the suggestions —
      the loan is linked to their profile and their name becomes clickable
      everywhere the loan is shown
    - Otherwise, just keep typing — it's saved as free text (for someone
      outside your library)
4. Optionally pick a **due date**
5. Click **Lend**

The book immediately shows an amber "on loan to …" badge at the top of its
detail page, and a 📤 icon next to the borrower's name wherever the loan is shown.

---

## Marking a Book as Returned

From the same **Loans** section on the book's detail page — or from the
dedicated **On Loan** page (see below) — click **Mark Returned**.

The loan is closed (return date recorded automatically) and the book becomes
available to lend out again.

---

## The "On Loan" Page

The **On Loan** page lists every book currently lent out across your entire
library, regardless of who lent it or which room it normally lives in.

```
On Loan — 3 books currently out
🔴 1 overdue

📤 The Name of the Wind          → Marco            since 2026-05-02   due 2026-05-20 · OVERDUE
📤 Il barone rampante            → Grandma Lucia     since 2026-06-10   due 2026-06-25
📤 Sapiens                       → A colleague       since 2026-06-15   (no due date)
```

If a borrower is a linked library member, their name is shown as a link —
click it to open their **[profile](09-user-management.md#member-profiles)**.
Names typed as free text (people outside your library) are plain text.

Use this page when you want a single overview of "what's out there" instead
of checking each book individually.

### Searching and Filtering

- **Search box** — filter by borrower name or book title
- **Status filter** — show only loans that are:

| Status | Meaning |
|--------|---------|
| 🔴 **Overdue** | Past the due date |
| 🟠 **Due soon** | Due within the next 7 days |
| ⚪ **Normal** | Due date more than 7 days away, or no due date set |

Loans with no due date are never flagged as overdue or due soon — they only
show up under **Normal**.

---

## Loan History

Each book's detail page also keeps a **history** of past loans (who borrowed
it and when it was returned), below the active loan section. This is separate
from the [reading history](10-reading-progress.md) — a loan tracks *where the
physical copy is*, not who has read it or when.

!!! tip "Loans vs. Reads"
    Lending a book to someone doesn't automatically mark it as read by them.
    If you also want to track who has actually *read* that copy, see
    [Reading Progress](10-reading-progress.md#who-read-this-book-library-reads).
