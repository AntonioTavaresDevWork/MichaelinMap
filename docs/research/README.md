# `docs/research/` — the cuisine research pass

**Complete. All 117 places researched** — ids 001–010 in S11, 011–117 in S12.

The pass fills the RN-32 gap: every food place should carry at least one filterable `cuisine` tag,
and most unreviewed ones carry none. Nothing here has been applied to the database yet.

This directory is **working state, not reference material**. `docs/files/` is the frozen origin
material from Claude Web; this is the record of a job.

## Files

| File | What it is |
|---|---|
| `cuisine-117-batch.csv` | The scope: 117 places that are `restaurant` + `unreviewed` + `city = 'Austin'` with **no** cuisine tag. `id,name,address` |
| `cuisine-117-prompt.md` | The prompt the pass was run against. Revision 2 |
| `cuisine-117-results.json` | **All 117 results**, one object per place, ids in order |

## Results

| | |
|---|---|
| Places researched | **117** |
| Taggable | **91** |
| `no_slug_fits` — no honest slug exists | **15** |
| Closed | **10** |
| Uncertain | **1** |
| Evidence rows | 103 Tier A · 37 Tier B · 13 Tier C |
| Confidence | 70 high · 21 medium · 26 none |
| Vocabulary slugs actually used | **28 of 38** |

Most-used slugs: `new-american` 18 · `italian` 11 · `pizza` 9 · `southern-comfort` 7 ·
`cocktails-bar-food` 7 · `sushi` 7 · `burgers` 5 · `japanese` 5.

## Do not regenerate the CSV

`id` is the join key between the research output and the database, and it is nothing but the row's
position in this file. Re-cutting it after any place gains a cuisine tag returns a **smaller set with
different ids**, silently re-pointing every result at the wrong restaurant.

Verified against the database by checksum when it was cut:

```
117 rows · 241adf8ea2bf6c2b2e147adc94e39757
```

That hash is over `md5(name || ' — ' || address)` per row, whitespace collapsed, aggregated in hash
order. Order by the hash and not by name — Postgres sorts by collation and Python by code point, so
a text ordering produces different hashes from identical data.

## What happens next

1. **The 91 taggable places become one migration**, inserting `place_tags` with
   `source = 'suggested'`, resolving places and tags by natural key. Everything enters invisible to
   visitors under RN-31 and becomes visible only when Michael confirms it in the admin.
2. **The 10 closures and 1 uncertain are not tags and must not ride along in that migration.**
   They are `status` changes to the judgment layer and belong to the curator.
3. **The vocabulary gaps are Michael's call under RN-13.** Nothing here invents a slug.

### Rows that need a decision before they migrate

- **`012 Bellissima`** — weakest evidence of the 117; `bellissimatx.com` returns 403 to every fetch,
  so the only quote is a Community Impact headline. One look from a normal browser resolves it.
- **`090 Santa Catarina`** — tagged `tex-mex` **against** its own site's claim of "interior Mexico".
  Deliberate, and flagged so it can be flipped.
- **`006 Anthem` and `009 Bar Toti`** (from S11) still need re-running — both used
  `cocktails-bar-food` as a crossed-kitchen fallback, which revision 2 of the prompt now forbids.
  Useful context found in S12: **Bar Toti and `034 Este` are sister restaurants sharing 2113 Manor
  Rd**, which explains why its menu read as crossed.
- **`008 Aris`** (from S11) — drop the second evidence row, which cites an OpenTable page for
  *Iris*, a different business.

## The ten closures, and the one in doubt

**Nine of 117 are closed and one cannot be established.** That is roughly 9% of a backlog assembled
from map albums over several years.

| id | Place | When | How it was established |
|---|---|---|---|
| `021` | Chapulín Cantina | 28 Feb 2026 | CultureMap + KXAN; site's DNS gone |
| `113` | Vespaio | 28 Feb 2026 | **Same event as `021`** — sister restaurants, 1610/1612 S Congress |
| `030` | Dos Olivos Market (290) | 5 Apr 2026 | Community Impact; brand site now lists only Buda + Harlingen |
| `033` | **El Naranjo** | 18 Jul 2026 | **Corrected after being recorded open — see below** |
| `041` | Grizzelda's | ~mid-2026 | Yelp CLOSED + site replaced by a hosting placeholder |
| `077` | **Olamaie** | 19 Jul 2026 | KUT, CultureMap, Texas Monthly. **Held a Michelin star** |
| `080` | Otoko | ~30 May 2026 | Tock; ten years of omakase ended |
| `081` | PastaBar | 28 Feb 2026 | CultureMap + Hoodline. Michelin-listed |
| `092` | Shack 512 | — | **A successor**: Stumpy's Lakeside Grill now at that marina |
| `104` | The Local | Jan 2026 | Community Impact; **Phoebe's Diner taking the suite** |
| `060` | Ma'coco (E Austin) | ? | **Unresolved.** Yelp says CLOSED, the brand site still lists it |

**Four closed in 2026 and three of those were Michelin-distinguished.** This is the strongest
argument yet for the closure sweep over the 58 **published** places that S10 recommended when Gina's
on Congress (`DP-10`) turned up by accident — those 58 come from the same albums and a visitor can
actually reach them.

Two closures were settled by a **successor** rather than by an absence, which turned out to be the
most reliable signal available: a different business in the building is unambiguous where directories
contradict each other.

## The correction: `033 El Naranjo`

The row was first written `open` / `interior-mexican` / confidence **high**. It was wrong — El Naranjo
closed 18 July 2026 after fifteen years, covered by four outlets, with a farewell letter from the
restaurant.

**How it happened.** The restaurant's own site and Texas Highways both blocked fetches, so the row
leaned on a May 2025 Resy piece for the cuisine and **no closure search was run for that record at
all**. The prompt makes closure a first-class output; that row treated it as a by-product of
researching a menu. It surfaced only by accident, from a KUT article about `077 Olamaie` that listed
El Naranjo among 2026's closures.

**Two things changed afterwards.** Every subsequent search included closure terms explicitly, and
**every row resting on a blocked site now says so in its own notes** (`012`, `050`, `084`, `097`).

The row was rewritten in place by a script asserting every other row stayed byte-identical.

**What was lost with it:** `033` was the pass's cleanest use of `interior-mexican` — regional Oaxacan
cooking by a James Beard Best Chef: Texas. The slug ends the pass with **one** defensible instance in
117 places (`063 Manuels`), which strengthens what `DP-11` already says about it.

## The vocabulary gaps — 15 places, 14 distinct labels

This is the pass's main finding and it is **not** a tagging result. Each label below is a place the
researcher refused to guess at rather than a place it failed to identify.

| Gap | ids | Note |
|---|---|---|
| `german` ✅ | `004` | **Answered in S11.** Alpine Haus, plus `038` Friedhelm's and `051` Krause's, all now tagged |
| `cajun-creole` | `114` | **The best candidate to answer next** — see below |
| `waterfront-bar-grill` | `018`, `098` | Two Lake Travis restaurants, same shape |
| `all-day-american` | `057` | |
| `bar-and-grill` | `035` | |
| `hotel-bar-grill` | `050` | |
| `modern-mexican` | `112` | |
| `baja-mexican` | `061` | |
| `wine-bar` | `036` | |
| `brewery-taproom` | `078` | |
| `sandwich-shop` | `065` | |
| `spanish-texan-market` | `031` | |
| `georgian` | `014` | |
| `northern-michigan` | `066` | A Northern Michigan restaurant in Elgin, Texas — whitefish, Yooper pasties |

They cluster into three:

**1. There is no plain `american`.** Four of the fifteen (`035`, `050`, `057`, plus the two
waterfront rows) are ordinary American places — a bar in a 1940s bungalow, a rotisserie-and-sandwich
counter, two lake restaurants. The only American entries are `new-american`, which is a chef-driven
category none of them is, and `southern-comfort`, which their menus are not. **The same fact from the
other end: `new-american` was used 18 times, more than any other slug and 60% more than the next.** A
slug meant for one style is doing duty for a whole cuisine while the places it does not fit fall
through entirely.

`067 Muck & Fuss` is the control: also a bar with a kitchen, and `burgers` lands cleanly because its
food has an identity. **The gap is not "bars" — it is "ordinary American".**

**2. The Mexican side is as broken as the American side.** Three records had no honest slug
(`060`, `061`, `112`) because the vocabulary offers only `tex-mex`, `tacos` and `interior-mexican`
— nothing for Baja/California-style, nothing for modern pan-Mexican, and no plain `mexican`.
Meanwhile `interior-mexican` is being claimed by places it does not describe: **`090 Santa Catarina`
advertises "the vibrant flavors of interior Mexico" and serves Tex-Mex staples.** And it would have
been actively *wrong* three times — `034 Este` (coastal), `111 Veracruz Fonda` (Gulf state),
`060 Ma'coco` (Baja) — each saved only because another slug happened to fit. This is `DP-11`
documented from four directions.

**3. `cajun-creole` is a single missing cuisine, and it is exactly the `german` case.** `114 Vic & Al's`
is a self-described family-style Cajun restaurant — gumbo, étouffée, po'boys — with nothing to take.
`southern-comfort` was refused on principle: the vocabulary already separates `tex-mex` from
`interior-mexican`, so it plainly cares about regional precision, and folding Louisiana into the
American South throws that away. The gap surfaced twice — `093 Shore Raw Bar` also draws on Louisiana
and was saved only because `seafood` carries its identity. **`german` was added on three instances
and resolved all three. This is the same shape.**

## `BL-42` can now be closed by example

The backlog records `cocktails-bar-food` as a format claim living in the cuisine facet that attracts
whatever the vocabulary cannot describe. The pass produced enough evidence to settle it.

**Four correct uses**, all drinks-first by the venue's own account:

- `068 Murray's Tavern` — "a newly designed cocktail tavern"; the menu is built around two of the
  owner's grandmother's cocktails
- `083 Péché` — Austin's first absinthe bar; the owner set out to build a cocktail bar and chose
  absinthe to stand apart
- `094 Sidecar` — a basement cocktail club in a historic inn, evenings only, deliberately short menu
- `105 Tiki Tatsu-Ya` — a 21+ immersive tiki bar where the drinks are the entire proposition

**One that shows it can coexist with a cuisine rather than replace one:** `109 Uchibā`, tagged
`japanese` + `cocktails-bar-food`, whose own sentence reads "a cocktail bar and restaurant inspired
by the casual energy of a Japanese izakaya."

**Two misuses, both from S11 and both already flagged for re-running:** `006 Anthem` and
`009 Bar Toti`, where the slug was reached for as a crossed-kitchen fallback.

If the meaning gets written down, these are the examples to write it from.

## Defects found in our own records

Not tags, and worth fixing regardless of what happens to the research:

- **`064 Mattie's` has the wrong address.** Our record says 901 W Live Oak St; the restaurant's own
  site and every source say **811**. The migration joins by name, so nothing breaks.
- **`103 The Kimberly`** — our record says 200 W 7th St; the restaurant says 200 W 6th St Suite 100
  with entrance and valet on W 7th. Both describe one building.
- **The `Ma'coco` pair is a name-join hazard.** `060` is `Ma'coco` with a straight apostrophe; `061`
  is `Ma’CoCo` with a curly one and different casing. A grep for one does not find the other — which
  is how the pair was nearly missed.
- **`101 The Grove` needs its address decoded**: the CSV says `6317 RM-2244`, the brand says
  `6317 Bee Cave Road`. RM 2244 *is* Bee Cave Road.

## Address coincidences to know before anything joins on location

- `009 Bar Toti` and `034 Este` — 2113 Manor Rd. Sister restaurants sharing a garden
- `021 Chapulín Cantina` and `113 Vespaio` — 1610/1612 S Congress. One closure, two records
- `076 Oh K-Dog` and `091 Sazan` — 6929 Airport Blvd, units 133 and 146. A food hall
- `067 Muck & Fuss` and `094 Sidecar` — 295 E San Antonio St. Unit 101 and the inn's basement
- `012 Bellissima` and Oasthouse's **closed** north location — 8300 N FM 620, different units
- `036 Flo's` serves `003 Allday`'s pizza as a separate operation sharing the room
- `055 Ling Wu (The Grove)` and `112 VERDAD` — both in the Grove development

## Method notes worth keeping

- **An omission is only evidence after you open the page that would contain it.** `065 Meat & Bread`
  was nearly recorded closed because the brand's locations list showed one Austin entry named "North
  Shore" and not our address — until that page turned out to *be* 360 Nueces. The identical pattern
  did establish the `030` closure. Open the page.
- **A successor beats a directory.** Where listings contradicted each other (`092`, `104`), a
  different business operating in the building settled it immediately.
- **Tier C recorded honestly is worth more than Tier A assumed.** `053 Ling Kitchen` is a
  Michelin-recognised ten-course Chinese tasting menu with one seating a night; **Yelp files it under
  Diners.**
- **Two-location brands earn rule 4 repeatedly.** Three times one address was dead and the other
  alive (`017` vs Cafe Blue Downtown, `030` vs `031`, `074` vs Oasthouse north), and once a closure
  nearly propagated to a live sibling (`041 Grizzelda's` vs `048 Jacoby's`, same owner, across the
  street).

## What this pass may not do

Nothing here writes to the judgment layer. Everything it produces enters as `source = 'suggested'`,
invisible to a visitor under RN-31, and becomes visible only when the curator confirms it in the
admin. The pipeline proposes; the confirmation is a human act.

**The closures are the exception and they are not this pass's to apply.** A `status = 'closed'` is a
statement about a real business, and ten of them at once is a change to what the guide claims — that
is Michael's, not a migration's.
