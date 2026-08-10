# Cuisine research — 117 Austin-area restaurants

> Working prompt for the external research model. Revision 2 (S11): the vocabulary gained `german`,
> and `cocktails-bar-food` was closed off as a crossed-kitchen fallback. Paste this whole file, then
> attach a slice of `cuisine-117-batch.csv`.

You are researching restaurants so a human curator can tag them. Your output feeds a database
migration, so it must be machine-readable and it must be honest about how much you actually know.

**The attached list is your complete scope.** Every line is `id,name,address`. Work only from that
list. Do not add places, do not skip places, and echo the `id` back for every one.

---

## What you are producing

For each place: **which cuisine slug(s) describe it**, from a fixed vocabulary, **plus the evidence
that supports each slug** — and a flag if the place looks closed.

---

## Non-negotiable rules

1. **Never infer cuisine from the name.** "Casa Bianca" is not evidence of Italian. "Bar Toti" is not
   evidence of anything. A name is a hypothesis to check, never a finding.
2. **Omission beats a guess.** Returning `cuisine: []` with `confidence: "none"` is a correct,
   useful answer. A plausible-sounding wrong tag is worse than a gap, because the gap is visible and
   the wrong tag is not.
3. **Every slug carries at least one piece of evidence** — a URL plus a short verbatim quote from
   that page showing what the place actually serves. No evidence, no slug.
4. **The address is authoritative, not the name.** Seven brands in this list have two locations:
   *54th Street, Jack Allen's Kitchen, Ling Wu, The Grove Wine Bar & Kitchen, Dos Olivos Market,
   District Kitchen(+ Cocktails), Ma'coco / Ma'CoCo*. Research each id separately and match by
   street address. If you cannot tell which location a source describes, say so rather than
   assuming they are identical.
   **Check that the page you are quoting is the business in the list.** A directory URL whose slug
   does not match the name is a different business until proven otherwise — that is how an OpenTable
   page for *Iris* nearly became evidence for *Aris* in revision 1.
5. **Many of these are not in Austin proper.** The list includes San Marcos, New Braunfels,
   Fredericksburg, Buda, Round Rock, Cedar Park, Wimberley, Bee Cave, Bastrop, Elgin, Pflugerville,
   Lakeway, Volente, Spicewood, Florence and Point Venture. Searching "<name> Austin" will find the
   wrong business or nothing. Search the city in the address.
6. **Two slugs maximum**, most specific first. Add a second only when it genuinely helps someone
   filter — not to hedge. If `sushi` fits, you do not also need `japanese` unless the place is
   meaningfully both.
7. **One source can support two slugs.** If a single sentence establishes both, cite it twice rather
   than hunting a weaker second source to fill the second row.

---

## Evidence tiers — report which one you used

| Tier | Source | Example |
|---|---|---|
| **A** | The restaurant's own site, menu, or its own social bio | A menu PDF listing the dishes |
| **B** | Named local food press or a critic | Eater Austin, Austin Chronicle, Austin American-Statesman, Texas Monthly |
| **C** | An aggregator's category string | Yelp "Italian", OpenTable "Seafood", TripAdvisor, Google's category |

**Tier C alone is weak evidence and must be labelled as such.** It is not disqualifying — report it —
but the curator treats A/B and C differently. In the first batch, 6 of 15 tags rested on a Yelp
category string and that was only discoverable because the tier was recorded. Prefer A, then B.

Never cite an AI-generated summary, an SEO listicle, or a directory that merely aggregates other
directories.

---

## The vocabulary — 45 slugs, closed set

Use these exact slugs. **Do not invent one, and do not bend a place into a slug that nearly fits.**

```
bbq                 tex-mex             tacos               interior-mexican
mexican             southern-comfort    cajun-creole        american
burgers             sandwiches          pizza               italian
steakhouse          seafood             new-american        japanese
sushi               ramen               korean              chinese
thai                vietnamese          indian              middle-eastern
mediterranean       ethiopian           caribbean           vegetarian-forward
breakfast-diner     bakery-pastry       coffee              cocktails-bar-food
wine-bar            brewery             british             french
german              georgian            spanish             portuguese
greek               turkish             brazilian           peruvian
modern-european
```

Three slugs that get misapplied, so read these carefully:

- **`breakfast-diner`** means the place's *primary identity* is breakfast, brunch or diner service.
  It does not mean "serves breakfast" or "has a brunch on Sunday." Most restaurants that open at
  11am are not this.
- **`new-american`** is a real category (seasonal, chef-driven, not tied to one national cuisine),
  not a fallback for "I could not tell." If you could not tell, return no slug.
- **`cocktails-bar-food`** is a claim about *what kind of place it is*: you go for the drinks and the
  food comes along. It is **not** the slug for a kitchen that spans several cuisines. A restaurant
  that calls itself a bistro is not this, however many countries its menu borrows from.

**A crossed kitchen is `no_slug_fits: true`, not a catch-all slug.** When a place deliberately spans
cuisines and no single slug is honest, say so and propose the label you would have used. That is a
wanted output — it feeds the decision about extending the vocabulary, which is exactly how `german`
was added after Alpine Haus, Friedhelm's Bavarian Inn and Krause's Cafe all hit the same wall.

---

## Closure is a first-class output, not a footnote

These places were collected from map albums that are several years old and have never been reviewed.
Some are certainly closed. **Check whether each one is still operating**, and report it.

- `"open"` — recent evidence of operation (recent reviews, current hours, active site or socials)
- `"likely_closed"` — one or more credible closure signals
- `"uncertain"` — you genuinely could not establish it either way

When a place is `likely_closed`, **report the closure signals and any counter-signal**, and return
`cuisine: []`. Do not research the menu of a restaurant that no longer exists.

A counter-signal matters as much as the signal: in the first batch a place had three independent
closure reports *and* a live official website, and that contradiction was the useful finding.

---

## Pace

**Ten places per response, and stop.** Do not stretch to fill a larger batch — the failure mode is
that the back half quietly degrades into aggregator category strings dressed as findings, and the
tier field is the only thing that would reveal it. If the attached slice is larger than you can do
at Tier A/B, do ten, say where you stopped, and wait.

---

## Output format

A single JSON array. **One object per line of the attached list**, in id order — no more, no fewer.
The ids are drawn from a 117-place set, so they may not start at `001` or run contiguously; use the
ids you were actually given.

```json
[
  {
    "id": "001",
    "name": "54th Street",
    "address_city": "San Marcos",
    "status": "open",
    "cuisine": ["burgers"],
    "evidence": [
      {
        "slug": "burgers",
        "tier": "A",
        "url": "https://…",
        "quote": "verbatim line from that page that supports the slug"
      }
    ],
    "no_slug_fits": false,
    "suggested_label": null,
    "confidence": "high",
    "notes": null
  }
]
```

Field rules:

- `id` — echoed exactly from the input. This is the join key; get it right.
- `status` — one of `open` / `likely_closed` / `uncertain`. For the last two, put the signals and
  any counter-signal in `notes`.
- `cuisine` — 0 to 2 slugs from the closed set, most specific first. Empty array is valid.
- `evidence` — one entry per slug, minimum. `quote` is verbatim from the page at `url`, short. When
  the place gets no slug, you may still include one entry with `"slug": null` carrying the evidence
  for `status` or for `no_slug_fits`.
- `confidence` — `high` (tier A/B, unambiguous) / `medium` (tier C, or A/B with some ambiguity) /
  `none` (returned no slug).
- `notes` — only when there is something a human needs to know: closure signals, a location you
  could not disambiguate, a menu that changed, a name that no longer matches the business.

Return the JSON and nothing else. No preamble, no summary, no commentary between objects.

---

## Before you finish, check yourself

- [ ] One object per input line you covered, same ids, in order, none invented
- [ ] Every slug appears in the 38-item list above, spelled exactly
- [ ] Every slug has evidence with a URL and a verbatim quote
- [ ] No slug rests only on the restaurant's name
- [ ] Every cited page is demonstrably the business in the list, not a similarly-named one
- [ ] The seven two-location brands were researched per address, not merged
- [ ] Every `likely_closed` has its signals in `notes` and an empty `cuisine`
- [ ] Every `no_slug_fits: true` has a `suggested_label` and a reason
- [ ] `cocktails-bar-food` was used only for bar-first places, never as a crossed-kitchen fallback
