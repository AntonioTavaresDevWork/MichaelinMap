# Format, logistics and dietary — the 58 published places

> Working prompt. Revision 1 (S13). Paste this whole file, then attach a slice of
> `facets-58-batch.csv`.
>
> **This pass is not the cuisine pass.** Read the differences below even if you ran that one.

You are researching restaurants so a human curator can tag them. Your output feeds a database
migration, so it must be machine-readable and it must be honest about how much you actually know.

**The attached list is your complete scope.** Every line is `id,name,city,tier,star,address`. Work
only from that list. Do not add places, do not skip places, and echo the `id` back for every one.

---

## What is different about these 58

These are **the places already published in the guide** — the only ones a visitor can reach. The
cuisine pass covered 117 places nobody has reviewed; this one covers the guide itself. Two
consequences:

1. **Closure is not a footnote here, it is the point.** The cuisine pass found 10 of 117 unreviewed
   places closed. Nobody has ever checked these 58, and a closed restaurant that a visitor can click
   on is the worst failure this product has. **Check every one, and check it first.**
2. **Getting a tag wrong here is visible.** In the other pass a wrong tag sat in a queue. Here it
   describes a place the guide is actively recommending.

---

## What you are producing

For each place, three things:

1. **Its operating status** — open, likely closed, or uncertain.
2. **Which `format`, `logistics` and `dietary` tags apply**, from the fixed vocabularies below.
3. **The evidence for each tag** — a URL plus a short verbatim quote from that page.

---

## Non-negotiable rules

1. **Every tag carries at least one piece of evidence** — a URL and a short verbatim quote from that
   page showing the fact. No evidence, no tag.
2. **Omission beats a guess.** Returning an empty list for a facet is a correct, useful answer. These
   are published places; a plausible-sounding wrong tag is worse than a gap, because the gap is
   visible and the wrong tag is not.
3. **Never infer a tag from the kind of restaurant it is.** A steakhouse is not automatically
   `reservations-essential`. A taco place is not automatically `order-at-the-counter`. Fine dining is
   not automatically anything. Check the specific business.
4. **The address is authoritative, not the name.** Several of these brands run more than one
   location. Match by street address. If you cannot tell which location a source describes, say so
   rather than assuming they are identical.
5. **Absence of a mention is not evidence of absence.** If a site does not mention parking, that is
   not `parking-is-a-problem` and it is not the opposite either. Return nothing for it.
6. **`dietary` is about the menu, not about a filter on a delivery app.** A DoorDash "vegetarian"
   toggle is not evidence. A menu section, a dish list or an explicit statement is.

---

## Evidence tiers — report which one you used

| Tier | Source | Example |
|---|---|---|
| **A** | The restaurant's own site, menu, reservation page, or its own social bio | A menu page listing vegan dishes; a reservations page |
| **B** | Named local food press or a critic | Eater Austin, Austin Chronicle, Austin American-Statesman, Texas Monthly, CultureMap |
| **C** | An aggregator's attribute or category string | Yelp "Takes Reservations", Google's "Dine-in" flags, TripAdvisor |

**Tier C alone is weak and must be labelled as such.** It is not disqualifying — report it — but the
curator treats A/B and C differently. Aggregator attribute flags are especially unreliable for this
pass: they are frequently stale, frequently auto-generated, and they answer a slightly different
question than the tag does.

Never cite an AI-generated summary, an SEO listicle, or a directory that merely aggregates other
directories.

---

## The vocabularies — closed sets

Use these exact slugs. **Do not invent one, and do not bend a place into a slug that nearly fits.**

### `format` — what kind of establishment it is. **At most 2.**

```
sit-down-restaurant      food-truck               counter-service
bar-with-real-food       caf-bakery               fine-dining
trailer-park-multi-vendor
```

- `sit-down-restaurant` is the default shape and is worth stating; it is not a throwaway.
- `fine-dining` is a real category — tasting menus, dress expectations, a captain — not a synonym for
  expensive. A $60 steak at a loud restaurant is not fine dining.
- `bar-with-real-food` means the drinks lead and the kitchen is genuinely good. It is the same
  distinction the cuisine pass drew for `cocktails-bar-food`: **a crossed kitchen is not a bar.**
- Note `caf-bakery` is spelled without the accent in the database. Use it exactly as written.

### `logistics` — what a visitor needs to know before going. **At most 4.**

```
walk-in-only             reservations-essential   reservations-weeks-out
cash-only                parking-is-a-problem     the-line-is-real
order-at-the-counter
```

- `reservations-essential` and `reservations-weeks-out` are a ladder, not alternatives. Use the
  second only when sources actually describe booking windows of weeks.
- `the-line-is-real` needs evidence of a habitual queue, not one review complaining about a wait.
- `walk-in-only` means the restaurant does not take reservations at all — a positive claim, usually
  stated. It is not the same as "reservations are available but not required".

**Four `logistics` tags are deliberately out of scope for this pass:** `open-late`, `open-monday`,
`closes-early` and `open-for-breakfast`. They are marked `is_derived` in the schema, meaning they are
meant to be computed from opening hours rather than asserted. **Do not return them.** Record the
hours you find in `notes` instead, so the curator has the raw material.

### `dietary` — **at most 3.**

```
vegetarian-options       vegan-options            gluten-free-options
genuinely-good-for-vegetarians
```

- The first three are factual: does the menu have them, in more than a token way.
- **`genuinely-good-for-vegetarians` is a judgment and is NOT yours to make.** Do not return it under
  any circumstances. If you find evidence that would support it, put that in `notes` and let the
  curator decide.

---

## Closure — check this first, for every place

- `"open"` — recent evidence of operation: current hours on its own site, a live reservation system,
  recent press, active socials
- `"likely_closed"` — one or more credible closure signals
- `"uncertain"` — you genuinely could not establish it either way

When a place is `likely_closed`, **report the signals and any counter-signal**, and return empty
lists for all three facets. Do not research the tags of a restaurant that no longer exists.

Three things the cuisine pass learned about closure, which apply here:

- **An omission is only evidence after you open the page that would contain it.** A brand's locations
  list that does not show our address is a strong signal — but open that page first. Once, the entry
  that seemed to be a different location turned out to *be* our address under a house name.
- **A successor beats a directory.** When listings contradict each other, a different business
  operating at that address settles it and nothing else does.
- **Recency and reputation protect nothing.** Of the ten closures found in the other pass, four
  happened in 2026 and three of those held Michelin distinction.

---

## Pace

**Ten places per response, and stop.** Do not stretch to fill a larger batch — the failure mode is
that the back half quietly degrades into aggregator attribute flags dressed as findings, and the tier
field is the only thing that would reveal it.

---

## Output format

A single JSON array. **One object per line of the attached list**, in id order — no more, no fewer.

```json
[
  {
    "id": "001",
    "name": "24 Diner",
    "city": "Austin",
    "status": "open",
    "format": ["sit-down-restaurant"],
    "logistics": ["walk-in-only"],
    "dietary": ["vegetarian-options"],
    "evidence": [
      {
        "facet": "format",
        "slug": "sit-down-restaurant",
        "tier": "A",
        "url": "https://…",
        "quote": "verbatim line from that page that supports the tag"
      }
    ],
    "hours": "Mon-Sun 24 hours",
    "confidence": "high",
    "notes": null
  }
]
```

Field rules:

- `id` — echoed exactly from the input. This is the join key; get it right.
- `status` — `open` / `likely_closed` / `uncertain`. For the last two, put the signals and any
  counter-signal in `notes`.
- `format`, `logistics`, `dietary` — arrays of slugs from the closed sets, within the caps above.
  Empty arrays are valid and often correct.
- `evidence` — one entry per tag, minimum, each naming which `facet` it belongs to. When a place gets
  no tags, you may still include one entry with `"slug": null` carrying the evidence for `status`.
- `hours` — the opening hours as published, verbatim or lightly normalised, or `null`. This is the
  raw material for the four derived `logistics` tags this pass does not return.
- `confidence` — `high` (Tier A/B, unambiguous) / `medium` (Tier C, or A/B with ambiguity) / `none`
  (returned no tags at all).
- `notes` — only when a human needs to know something: closure signals, a location you could not
  disambiguate, evidence that would support `genuinely-good-for-vegetarians`, a menu that changed.

Return the JSON and nothing else. No preamble, no summary, no commentary between objects.

---

## Before you finish, check yourself

- [ ] One object per input line you covered, same ids, in order, none invented
- [ ] **Every place has a status, and you actually looked for closure signals**
- [ ] Every slug appears in the vocabulary above, spelled exactly
- [ ] Every slug has evidence with a URL and a verbatim quote, tagged with its facet
- [ ] No `open-late`, `open-monday`, `closes-early` or `open-for-breakfast` — hours go in `hours`
- [ ] No `genuinely-good-for-vegetarians` — it is the curator's judgment, not yours
- [ ] Caps respected: format ≤ 2, logistics ≤ 4, dietary ≤ 3
- [ ] Every `likely_closed` has its signals in `notes` and empty arrays for all three facets
- [ ] Multi-location brands were matched by street address, not by name
