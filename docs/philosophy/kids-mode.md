---
title: The philosophy behind Kids Mode
description: Why Jinbocho's Kids Mode has no leaderboards, no speed rewards, and no guilt for abandoning a book — and the four ideas it's built on.
---

# The philosophy behind Kids Mode

Most apps that get children to read borrow the playbook of a game: points, streaks, badges,
leaderboards. It works, in the short run — and it can quietly teach a child that reading is
something you do for the reward, not for itself.

Jinbocho's **Kids Mode** was built to avoid that trap on purpose. It's a small, deliberately
unambitious module inside a home library manager: reading sessions, a personal journal,
optional quizzes, family challenges. What makes it different isn't the feature list — it's
what we refused to build.

## How it compares to a typical reading-gamification app

| | Typical reading app | **Jinbocho Kids Mode** |
|---|:---:|:---:|
| Points / streak counters | ✅ | ❌ |
| Leaderboard between siblings | ✅ (often) | **❌ — not even in the underlying data** |
| Reward tied to reading speed or volume | ✅ | ❌ |
| Abandoning a book flagged as incomplete/failed | ✅ (usually) | **❌ — normalized: "even great readers do it"** |
| Rereading flagged as a duplicate | ✅ (usually) | **❌ — shown positively, as "reread"** |
| Same interface for a 5-year-old and a 14-year-old | ✅ (often) | **❌ — four age bands, a different experience each** |
| Comprehension checked only via multiple-choice quiz | ✅ | ❌ — free retelling and creative prompts come first |
| Works without an AI/LLM subscription | varies | **✅ — Kids Mode never requires the AI module** |

## What we deliberately didn't build

- No leaderboard between siblings, anywhere, in any feature.
- No reward tied to reading speed, or to how many books a child has read compared with another reader in the family.
- No visible or implicit negative consequence for abandoning a book.
- Shared reading sessions — a parent reading aloud to a 0-5 year old — are kept strictly separate from the badges a child earns for their own independent reading. Mixing the two was a real bug in an early version of the software; we fixed it because it violated the first principle below.
- For ages 0-5, the entire quiz and written-journal area is hidden. Asking a child who can't read yet to answer a quiz makes no sense.

## The four ideas it's built on

**Intrinsic motivation, not scores.** Edward Deci and Richard Ryan's self-determination theory
documents the *overjustification effect*: add an external reward to something a person already
does for its own sake, and their intrinsic motivation for it tends to weaken. The classic
example is children who drew spontaneously for fun, were then promised a reward for drawing,
and afterwards drew *less* than before. Reading, for a child who discovers it, is exactly this
kind of activity. So every recognition in Kids Mode is tied to a child's own consistency and
curiosity — never to speed, volume, or comparison with another reader. A badge should say
"you built a habit," never "you won."

**The reader's rights, after Daniel Pennac.** In *Comme un roman* (1992), Pennac lists a
reader's "imprescriptible rights" — including the right not to finish a book, the right to
reread, the right to skip pages. Most reading software, even for adults, quietly violates
these rights: it logs an abandoned book as a failure, treats a reread as a duplicate to clean
up, nudges toward completion with progress bars and notifications. Kids Mode does the
opposite, and makes that choice visible to the child, not just baked into the backend.

**Reading as a trigger for imagination, after Gianni Rodari.** *Grammatica della fantasia*
(1973) argues that stories exist to spark invention, not just comprehension or memorization.
A multiple-choice quiz measures a narrow slice of what happens when a child reads, and risks
teaching them that reading exists to pass a test. That's why Kids Mode's reading journal
favors free retelling and creative prompts — "imagine a different ending" — over quizzes,
which stay optional and secondary, never the main event.

**The parent as an ally, after Nati per Leggere.** Italy's national reading-aloud program
(backed by pediatricians, libraries and child health centers) holds that for the youngest
children, what matters is the ritual and its regularity, not any measure of performance. So
for ages 0-5, the software's "protagonist" is the parent who reads aloud — recognition goes
to *them*, for keeping the habit — not the child, who has no active role yet at that age.

## Four ages, four different experiences

| Age band | What changes |
|---|---|
| 0-5 | The parent reads aloud and logs the session; the child has no active role yet |
| 6-8 | First independent reading; an emoji and a short phrase stand in for a written journal; play is central |
| 9-12 | Full autonomy; comprehension shown through the child's own retelling; a reader identity starts forming |
| 13+ | No childish elements left; family-only privacy; room for personal critical opinions |

## An honest note

We're not pedagogy experts — we're parents and readers who built this from what we could find
in Deci & Ryan, Pennac, Rodari and Nati per Leggere, and we're actively seeking an external,
qualified review of it. If something here reads as naive, or if a feature crosses a line we
didn't notice, we'd genuinely like to hear about it.

## Try it

Kids Mode ships in the **[Education and Pro plans](https://jinbocho.github.io/pricing/#education)**
— Education adds it without the AI module, Pro adds it alongside the AI features. See the
**[User Manual](../user/index.md)** for how to turn it on and use it day to day.

**See also:** [Pricing](https://jinbocho.github.io/pricing/) · [User Manual](../user/index.md)
