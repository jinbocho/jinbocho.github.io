# Uso su mobile

Jinbocho è ottimizzato per smartphone e tablet. La stessa app che usi sul desktop funziona nel browser del telefono — nessuna installazione richiesta.

---

## Layout mobile

Su schermi piccoli l'interfaccia si adatta automaticamente:

```
┌─────────────────────┐
│  ≡  Jinbocho    🔍  │  ← Top bar con menu hamburger
├─────────────────────┤
│                     │
│   Lista libri       │
│   ┌───────────────┐ │
│   │ 📗 Titolo     │ │
│   │    Autore     │ │
│   │    [stato ▼]  │ │
│   └───────────────┘ │
│                     │
│   ┌───────────────┐ │
│   │ 📘 Titolo     │ │
│   └───────────────┘ │
│                     │
├─────────────────────┤
│  🏠  📚  ⚙️  +     │  ← Tab bar in basso
└─────────────────────┘
```

### Navigazione mobile

- **Hamburger menu** (≡) — apre la barra laterale con le posizioni
- **Tab bar in basso** — accesso rapido a Home, Biblioteca, Impostazioni, Aggiungi
- **Icona lente** (🔍) — apre la ricerca a tutto schermo

---

## Scansione ISBN su mobile

La scansione ISBN è la funzionalità più usata su mobile — è letteralmente pensata per stare davanti alla libreria con il telefono in mano.

### Come scansionare su mobile

1. Tocca il pulsante **"+"** in basso a destra
2. Tocca **"Scansiona ISBN"**
3. Concedi il permesso fotocamera se richiesto
4. Punta la **fotocamera posteriore** verso il codice a barre

!!! tip "Fotocamera posteriore"
    Jinbocho seleziona automaticamente la fotocamera posteriore su mobile, che è
    più precisa di quella anteriore per leggere i codici a barre.

Vedi la guida completa in **[Scansione ISBN](07-isbn-scanning.md)**.

---

## Permessi mobile

| Permesso | Perché serve | Dove dare il permesso |
|----------|-----------|-----------------------|
| **Fotocamera** | Scansione ISBN | Impostazioni → App browser → Fotocamera |

Jinbocho non richiede altri permessi. Non accede a contatti, posizione GPS, galleria foto, o altro.

---

## Browser supportati su mobile

| Browser | iOS | Android | Note |
|---------|-----|---------|------|
| Safari | ✅ | — | Consigliato su iPhone/iPad |
| Chrome | ✅ | ✅ | Consigliato su Android |
| Firefox | ✅ | ✅ | Funziona bene |
| Edge | ✅ | ✅ | Funziona bene |
| Samsung Internet | — | ✅ | Funziona su Galaxy |

!!! warning "Safari su iOS — permessi fotocamera"
    Su iPhone/iPad, concedi il permesso fotocamera da:
    **Impostazioni iPhone → Safari → Fotocamera → Consenti**

---

## Aggiungere all'homescreen (PWA)

Jinbocho può essere aggiunto come icona all'homescreen del tuo telefono, così si apre come un'app vera.

=== "iPhone / iPad (Safari)"
    1. Apri Jinbocho in Safari
    2. Tocca il pulsante **Condividi** (quadrato con freccia su)
    3. Scorri verso il basso e tocca **"Aggiungi alla schermata Home"**
    4. Dai un nome (es. "Jinbocho") e tocca **"Aggiungi"**

=== "Android (Chrome)"
    1. Apri Jinbocho in Chrome
    2. Tocca i **tre puntini** in alto a destra
    3. Tocca **"Aggiungi a schermata Home"** o **"Installa app"**
    4. Tocca **"Aggiungi"**

Una volta aggiunto, l'icona Jinbocho appare nell'homescreen e l'app si apre a schermo intero.

---

## Consigli per l'uso mobile

- **Rotazione**: usa il telefono in verticale per la lista libri, in orizzontale per i dettagli e le tabelle
- **Pinch to zoom**: supportato nelle pagine di dettaglio se il testo è troppo piccolo
- **Ricerca vocale**: puoi usare la dettatura della tastiera nella barra di ricerca
- **Tab browser**: puoi tenere Jinbocho aperto in un tab fisso mentre usi altre app