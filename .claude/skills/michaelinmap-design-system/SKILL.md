---
name: michaelinmap-design-system
description: The visual system of Michaelin Map — paper ground, the ink stack as the Code surface, the two-colour rule (lime is the interface, amber is the judgment), spacing, radii, typography, states and the anti-slop checklist. Use when writing or reviewing any component, screen or CSS in src/, or when choosing a colour, a surface, a radius or a badge treatment.
---

# Visual System — Michaelin Map

> Instantiated in S10 from `docs/design_system` (Feedback Comunicação), **adapted to this product**.
> The source document is reference material, not law. Where it disagrees with this file, this file
> wins — and the two places it disagrees are recorded below, on purpose.

## Two departures from the source document

The design system in `docs/design_system` was written for the Feedback agency and its SaaS products.
Two of its rules do not apply here, and following them would break this project:

1. **The UI is en-US.** The source (and its `refino-visual` playbook) mandates `1.000,00`,
   `DD/MM/YYYY`, `R$`. This product is `1,000.00`, `MM/DD/YYYY`, `$` — ADR-02, and the guide covers
   Austin. See the `michaelinmap-naming` skill.
2. **This product reserves a second colour the source does not have.** The source has one
   non-negotiable accent (lime). Here lime alone would put the interface and the curator's judgment
   in the same voice, and the judgment has to out-rank the chrome (bible §1.1).

Everything else — the ink neutrals, the 4px grid, radii, motion curves, the anti-slop rules, glass
discipline, mono for data — is adopted as written.

> **Typeface:** the source specifies Inter. This product ships **Geist**
> (`@fontsource-variable/geist`, already installed) and stayed on it — swapping is one package and
> one line in `index.css` and has not been approved. Do not "fix" components to Inter.

## The two-colour rule — the highest rule in this file

| Token | Means | Used by |
|---|---|---|
| `--primary`, `--brand-ink` | **The interface speaking** | Primary action, focus ring, active facet, links, the wordmark, "Picked for you" — anything a code or a filter produced |
| `--verdict`, `--verdict-ink` | **The judgment speaking** | The star, `the_dish`, `curator_note`'s verdict block. **Reserved** |

**Nothing but the judgment layer may use `--verdict*`.** Not a warning, not a highlight, not a
"featured" badge, not a chart series. The star is 22 places out of 511 — the colour is scarce because
what it marks is scarce. A UI primitive is never a judgment, so **no file in `src/components/ui/`
should ever reference a verdict token.**

Corollary: if something on screen is saturated, it means something. Colour is never decoration here.

**But colour may never be the whole message.** The S10 audit rejected a first attempt at this rule:
the selected filter chip was given a lime wash and an olive label, which measured **1.07:1** against
the panel and **1.02:1** against the unselected label — a pure hue swap at identical luminance, gone
entirely under deuteranopia. A state indicator needs a second channel: a fill, a glyph, a weight
change. WCAG 1.4.1 and 1.4.11 are the floor, and this product's own interaction lives here.

## Tokens

Defined in `src/index.css`. **Never hardcode a hex in a component** — if a value is missing, add a
token, do not inline it.

### Paper — `:root`, the product's ground

| Token | Value | Role |
|---|---|---|
| `--background` | `#F2EFE6` | Page. Warm neutral biased toward the accent's olive |
| `--card` | `#FBF9F4` | Card — **lighter** than the page, so it lifts |
| `--secondary` | `#EAE5D8` | Recessed surface: inputs, filled meta pills |
| `--muted` / `--accent` | `#E4DED0` | Hover ground — **one step below `--secondary` on purpose**, or every `hover:bg-muted` on a `bg-secondary` control is a silent no-op |
| `--border` / `--input` | `#DCD5C3` | Hairline |
| `--foreground` | `#1C1A15` | Warm near-black. Never `#000` |
| `--muted-foreground` | `#5A5449` | Secondary text — 7.1:1 on card |
| `--primary` | `#ACDE40` | Brand lime, **as a fill only** |
| `--primary-foreground` | `#12160C` | Ink on lime |
| `--brand-ink` | `#425E12` | Lime **as type** — 6.4:1 on paper |
| `--ring` | `#425E12` | Focus |
| `--verdict` | `#AD7D08` | Judgment **as a shape** (the star) — 3.2:1 on page, 3.5:1 on card |
| `--verdict-ink` | `#8A5E00` | Judgment **as type** — 5.0:1 on paper |
| `--verdict-wash` | `rgb(232 164 0 / 0.14)` | The dish block's ground |

> `--verdict` was `#E8A400` until the S10 audit measured it at **2.05:1** against the card. The star
> is the product's most meaningful mark and was its lowest-contrast one. Gold on cream is the standing
> hazard of this palette: **any new judgment colour has to be measured against `--background`, not
> just `--card`**, because the page is the stricter of the two.

**Why lime splits in two:** `#ACDE40` as text on paper is 3.96:1 and fails AA. As a fill with
`--primary-foreground` on top it passes comfortably. Same colour, two jobs. The same is true of
amber. On the ink surface both collapse back to a single bright value.

### Ink — `.dark`, the Code surface

`.dark` is **not a theme a visitor can toggle.** `src/lib/code-effects.ts` owns the class: it adds it
when a redeemed code carries a dark background and removes it on the way out (RN-28, BL-23). There is
no theme switcher, and adding one means deciding who wins when both speak.

Practical consequences:

- **Keep `dark:` variants in components.** They are not dead code — they are what a dark code looks
  like. A component that drops them will render half-styled the moment someone redeems a dark code.
- On ink: `--background: #0F141B`, `--card: #1A222B`, `--border: #29323B`,
  `--muted-foreground: #A5AEBC`, `--brand-ink` and `--verdict` both go bright (`#ACDE40`, `#F5C518`).
- **Test both.** Toggling `document.documentElement.classList.add('dark')` in the browser is the
  cheapest check and it is how the ink stack was verified in S10.

### Spacing, radii, type

- **4px grid.** `2 / 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96`. No orphan values off the grid.
- `--radius: 0.75rem` (12px) is the card. `radius-md` ≈ button, `radius-sm` ≈ input/small tag,
  `rounded-full` for pills.
- **One family** (`--font-sans`), hierarchy by weight and size. `--font-heading` is aliased to it on
  purpose — that is "família única", not an oversight.
- **`--font-mono` for data**: counts, prices, `n = 5`, addresses, IDs, aggregates. It carries
  `tabular-nums` from `index.css`, so columns of figures line up.
- Large headings take tracking `-0.02em`/`-0.025em`. Body takes none.
- Uppercase labels and eyebrows take `tracking-wider` or `0.1em`, `text-[11px]`, `font-semibold`.

## Component rules

### Surfaces and elevation

Depth is **lightness plus a hairline**, not shadow. Page recedes, card lifts, nested surface recedes
again. Shadow is reserved for things that genuinely float.

> The single most common defect in this codebase before S10: `rounded-lg border` with no background,
> so the "card" inherits the page and reads flat. **A card sets `bg-card`.** If it does not, it is not
> a card, it is a rectangle.

### Glass

Only on surfaces that float above content: dialog panel and overlay, dropdown, popover, select
content, command palette, the scrolled header. `backdrop-blur-md` with a translucent token ground.

**Never on content** — never on a place row, a filter panel, a stat, a table. Glass on content is the
single clearest AI-slop tell.

### Badges

| Variant | Shape | Use |
|---|---|---|
| `tier` | Outline pill, uppercase, tracking, muted fg | The curator's tier. Quiet on purpose — the loud things are the star and the dish |
| `meta` | Filled `secondary` pill, uppercase, tracking | Facts: place type, price band, "On the try list" |
| `picked` | Lime wash + `--brand-ink`, uppercase | Singled out by the active code — the app speaking |
| `secondary` | Filled, **sentence case**, normal weight | Tag labels. A tag is a word, not a state |

Badges never contain icons. Status pills are uppercase; tag labels are not.

### Buttons

- Primary is the lime fill with ink on top. **Hover brightens, never fades.** `hover:bg-primary/80`
  composites the lime against the page and makes the primary action go pale — that was a real defect
  fixed in S10.
- Never change hue on hover. Active: a small scale/translate. Focus-visible: the ring, always
  visible, never removed.
- Colour transitions ~150ms. Do not transition `transform`, `position` or `scale` on hover of large
  surfaces.

### Inputs

Recessed (`bg-secondary`-ish), hairline border, focus ring in `--ring`. Placeholder in
`--muted-foreground`. Character counters below textareas that have a limit — the 40-char field
reports field already does this (RN-24).

### Empty states

Icon (lucide, ~32px, `--muted-foreground`), title, one sentence of explanation, and a next step where
one exists. Never a bare "No results". This product writes its empty states — see `NothingMatches` in
`guide.tsx`, which teaches the AND semantics of RN-16 while making a joke.

## Anti-slop checklist

Anti-slop means **anti-gratuitous**. The technique is not the enemy; the effect with no purpose is.

- [ ] No decorative gradient. No mesh, no blob, no purple-to-blue anything
- [ ] No emoji as an icon — lucide, stroke 1.5
- [ ] No glass on content
- [ ] No hardcoded hex — tokens only
- [ ] No `--verdict*` outside the judgment layer
- [ ] No shadow doing a job that lightness should do
- [ ] Numbers in mono, and aligned
- [ ] Every interactive element has a visible focus state
- [ ] Colour is never the only carrier of meaning (the star has `aria-label`, the tier has text)
- [ ] Uppercase pills for states, sentence case for labels
- [ ] en-US formatting throughout

## What this skill does not decide

- **Map internals.** `guide-map.tsx` framing, sync and marker logic are out of scope for visual work.
  Only the container, the border and the pin palette are re-derived from tokens (ADR-05, BL-29).
- **Copy.** The product's voice is already written and is not a design variable.
- **The judgment itself.** `tier`, `starred`, `the_dish`, `curator_note`, `story`, `last_visited` and
  the `place_tags` assignments are never written by an automated routine, visual work included.
