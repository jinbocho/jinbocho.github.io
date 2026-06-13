# Book Presentation

Every book can show a short **presentation** — a few spoiler-free lines that help you decide
whether to start reading it. You'll find it on the book's detail page, just below the metadata.

---

## Where the text comes from

Jinbocho fills the presentation in three possible ways, each shown with a small badge:

| Source | Badge | How it's produced |
|--------|-------|-------------------|
| Editorial description | **From the publisher** | The description fetched during ISBN lookup — free, no AI required |
| AI generation | **AI-generated** | A short presentation written by an AI model, when your library has AI enabled |
| Manual | **Edited by hand** | Text you wrote or adjusted yourself |

!!! note "It is not the book's real opening lines"
    The "presentation" is a short blurb to help you choose — **not** a verbatim copy of the
    book's actual first page. When AI is used, the model is explicitly instructed never to
    invent plot details, quotes, or endings.

---

## Reading a presentation

1. Open any book's **detail page**.
2. The **Presentation** card sits just below the book's metadata.
3. If a presentation is available, it appears with a small badge showing its source.

The first time you open a book added via ISBN, Jinbocho automatically derives the presentation
from the free editorial description — no action needed.

---

## Generating with AI

If you are an **Admin** or **Editor** and AI is enabled for your library:

1. Open the book detail page.
2. In the **Presentation** card, click **Generate with AI**.
3. A short presentation is generated and saved; the badge switches to **AI-generated**.

!!! info "AI is optional and free to skip"
    If your library has no AI provider configured, the button simply shows
    *"AI generation is not configured"* and nothing else happens — the editorial
    presentation and manual editing keep working. Ask your administrator to enable it
    (see the **Developer Manual → Backend Services → ai-service**); a free provider such
    as Groq, or a local Ollama, works at no cost.

---

## Editing by hand

1. Open the book detail page → **Presentation** card → **Edit**.
2. Write or adjust the text.
3. Click **Save** — the badge switches to **Edited by hand**.

This is handy when the editorial description is missing, too long, or in the wrong language.

---

## Who can do what

| Action | Viewer | Editor | Admin |
|--------|:------:|:------:|:-----:|
| Read the presentation | ✅ | ✅ | ✅ |
| Generate with AI | — | ✅ | ✅ |
| Edit by hand | — | ✅ | ✅ |

---

## Languages

Labels and buttons follow your interface language. AI-generated text follows the book's own
language metadata when available.
