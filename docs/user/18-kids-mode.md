# Kids Mode

Kids Mode turns Jinbocho into a tool for growing readers in the family, not just cataloguing
what they've read. It's an optional module, independent of the AI module — some sub-features
below can *optionally* use AI, and are labelled where that's the case.

## Enabling Kids Mode

!!! info "Admin required"
    Only an Admin can turn Kids Mode on or off, and only if this installation has the Kids
    module enabled — Community doesn't include it, Education and Pro do.

1. Go to **Settings**
2. In the **Kids Mode** section, toggle it on
3. If the toggle is disabled, this installation doesn't have the Kids module enabled —
   contact whoever manages your installation

## Child Accounts

Once Kids Mode is on, Admins and Editors can create a **child account** for each child in
the family:

1. Go to **Settings → Users**
2. Click **Add Child**
3. Enter the child's name, a password, and (for password-reset purposes) a guardian's real
   email — the child's own account email isn't a real deliverable address
4. The child can now log in with the password you set

Child accounts don't see the catalog-management interface at all. They land on a dedicated
**My Reading** page instead.

## What a Child Sees: My Reading

- Log a **reading session** for the book they're currently reading
- Answer a **comprehension quiz** — either manually authored by a parent, or (if the AI
  module is also enabled) auto-generated from the book's content
- Write a **reading journal** entry — an emoji and a short phrase for younger readers, a
  free retelling for older ones, with creative prompts like "imagine a different ending"
- Follow a **reading path** — a themed sequence of books already in the family's collection
- Try a **mystery book** — a parent picks a book and the child gets a hint, not the title
- See the family's shared **reading challenge** progress bar, if one is active

None of this is scored against another reader in the family — there is no leaderboard
between siblings anywhere in Kids Mode, not even at the data level.

## What a Parent Sees: Kids Dashboard

Admins and Editors get a **Parent Dashboard** (main navigation → Kids) with, per child:

- Reading history and current book
- Quiz results, with a detail view of which answers were right or wrong
- Journal entries
- **Dinner questions** — open-ended conversation starters about the book the child is
  reading, generated for the parent only, never shown to the child (requires the AI module)
- Reading badges earned — tied to consistency and habit, never to speed or volume
- The option to mark a book as **abandoned** (normalised, not penalised) or **reread**

### Family Reading Challenges

Any Admin/Editor can start a shared family goal — e.g. "1000 minutes read together this
summer" — with a single shared progress bar. There's deliberately no per-member breakdown
shown anywhere, so no version of the interface can turn a cooperative challenge into an
implicit ranking.

### Shared Reading (ages 0-5)

For children too young to read independently, a parent logs the session after reading aloud
together. Recognition for consistency goes to the *parent*, not the child — the child has no
active role in the software at this age.

## Age Bands

Kids Mode adapts what it shows based on the child's age, derived automatically from their
birth year (only the year is collected, to minimise the personal data held on a minor):

| Age | Experience |
|---|---|
| 0-5 | Parent reads aloud and logs the session; no active role for the child yet |
| 6-8 | First independent reading; emoji + short phrase instead of a written journal |
| 9-12 | Full autonomy; journal uses free retelling |
| 13+ | No childish visuals; badges are a plain factual list; private family-only reviews |

## Why It's Built This Way

Kids Mode has no leaderboards, no speed rewards, and no penalty for abandoning a book — on
purpose. See **[The philosophy behind Kids Mode](https://jinbocho.github.io/manuals/philosophy/kids-mode/)**
for the reasoning and the four ideas it's built on.

**See also:** [User Management](09-user-management.md) for roles ·
[Book Presentation & AI](15-book-presentation.md) for how the AI module works elsewhere in Jinbocho
