# Prestiti

Tieni traccia dei libri che hai prestato — a un familiare o a chiunque al di fuori
del nucleo familiare — così niente resta dimenticato sullo scaffale di qualcun altro.

---

## Cosa registra un prestito

Un prestito registra tre informazioni su una copia fisica:

| Campo | Descrizione |
|-------|-------------|
| **Nome del richiedente** | Testo libero — il nome di un familiare, un amico, un collega, chiunque |
| **Prestato il** | Registrato automaticamente quando presti il libro |
| **Data di restituzione** | Opzionale — impostala se vuoi un promemoria di quando il libro dovrebbe tornare |

Un libro può essere in prestito a **un solo richiedente alla volta**. Non puoi
prestare una copia già in prestito finché non viene segnata come restituita.

!!! info "Chi può prestare e ricevere in restituzione i libri"
    Prestare e segnare come restituiti i libri richiede il ruolo **Admin** o **Editor**.
    I **Viewer** possono vedere chi ha attualmente un libro, ma non possono
    prestarlo né segnarlo come restituito.

---

## Prestare un libro

1. Apri la pagina di dettaglio del libro
2. Scorri fino alla sezione **Prestiti**
3. Inserisci il **nome del richiedente** (obbligatorio)
4. Opzionalmente scegli una **data di restituzione**
5. Clicca **Presta**

Il libro mostra immediatamente un badge ambra "in prestito a …" in cima alla sua
pagina di dettaglio, e un'icona 📤 accanto al nome del richiedente ovunque venga mostrato il prestito.

---

## Segnare un libro come restituito

Dalla stessa sezione **Prestiti** nella pagina di dettaglio del libro — oppure dalla
pagina dedicata **In prestito** (vedi sotto) — clicca **Segna come restituito**.

Il prestito viene chiuso (la data di restituzione viene registrata automaticamente) e il libro torna
disponibile per essere prestato di nuovo.

---

## La pagina "In prestito"

La pagina **In prestito** elenca tutti i libri attualmente prestati in tutta la
biblioteca di famiglia, indipendentemente da chi li ha prestati o in quale stanza vivono di solito.

```
In prestito — 3 libri attualmente fuori
🔴 1 in ritardo

📤 The Name of the Wind          → Marco            dal 2026-05-02   scade 2026-05-20 · IN RITARDO
📤 Il barone rampante            → Nonna Lucia       dal 2026-06-10   scade 2026-06-25
📤 Sapiens                       → Un collega        dal 2026-06-15   (nessuna scadenza)
```

Usa questa pagina quando vuoi una panoramica unica di "cosa è fuori" invece
di controllare ogni libro singolarmente.

### Ricerca e filtri

- **Campo di ricerca** — filtra per nome del richiedente o titolo del libro
- **Filtro per stato** — mostra solo i prestiti che sono:

| Stato | Significato |
|--------|-------------|
| 🔴 **In ritardo** | Scaduto rispetto alla data di restituzione |
| 🟠 **In scadenza** | In scadenza nei prossimi 7 giorni |
| ⚪ **Regolare** | Scadenza oltre 7 giorni, o nessuna scadenza impostata |

I prestiti senza data di restituzione non vengono mai segnalati come in ritardo o in scadenza — compaiono solo
sotto **Regolare**.

---

## Cronologia prestiti

La pagina di dettaglio di ogni libro mantiene anche una **cronologia** dei prestiti passati
(chi l'ha preso in prestito e quando è stato restituito), sotto la sezione del prestito attivo. Questa è separata
dalla [cronologia di lettura](10-reading-progress.md) — un prestito traccia *dove si trova la copia
fisica*, non chi l'ha letta o quando.

!!! tip "Prestiti vs. Letture"
    Prestare un libro a qualcuno non lo segna automaticamente come letto da quella persona.
    Se vuoi anche tracciare chi in famiglia ha effettivamente *letto* quella
    copia, vedi [Progressi di lettura](10-reading-progress.md#chi-ha-letto-questo-libro-letture-di-famiglia).
