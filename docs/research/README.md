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
| `cuisine-117-prompt.md` | The prompt the pass was run against. Revision 3 — vocabulary now 45 slugs |
| `cuisine-117-results.json` | **All 117 results**, one object per place, ids in order |
| `facets-58-batch.csv` | Scope of a **second, paused pass**: the 58 published places. See below |
| `facets-58-prompt.md` | Its prompt — format, logistics and dietary, plus a closure check |
| `facets-58-results.json` | **10 of 58 done, then paused deliberately.** See *The paused facets pass* |

## Results

| | |
|---|---|
| Places researched | **117** |
| Open | **106** |
| **Open places carrying a cuisine tag** | **106 — all of them** |
| `no_slug_fits` — no honest slug exists | **0** |
| Closed | **10** |
| Uncertain | **1** |
| Vocabulary slugs | **45**, up from 38 |

> **RN-32 is satisfied for this batch: every open place has at least one filterable cuisine tag.**
> That took a vocabulary extension of seven slugs, approved in S13 — see *Closing the coverage gap*
> below. Before it, 17 of the 106 had no honest tag at all.

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

Two migrations, in this order, **both needing a session with the Supabase MCP loaded**:

1. **`20260810120000_extend_cuisine_vocabulary.sql` — written, not applied.** Adds the seven slugs.
   Nothing else can go first: 17 of the assignments below reference tags that do not exist yet.
2. **The 106 tagged places become one migration**, inserting `place_tags` with
   `source = 'suggested'`, resolving places and tags by natural key. Everything enters invisible to
   visitors under RN-31 and becomes visible only when the curator confirms it in the admin.

And one thing that is **not** a migration:

3. **The 10 closures and 1 uncertain must not ride along.** They are `status` changes to the judgment
   layer and belong to the curator — `BL-44`.

### The four re-runs (S13) — all resolved

The S11 batch left four rows that could not migrate as written. All four were re-run:

- **`006 Anthem`** was `cocktails-bar-food`. The re-run confirmed the kitchen is crossed **and found
  the label the restaurant uses for it** — its own tagline is "A Tex-Asian Pub For The People" and
  its own copy calls the menu borderless. No slug carries that, so it was later relaxed onto
  `new-american` for coverage.
- **`009 Bar Toti`** was `cocktails-bar-food`, and its own words settle it: "a lively neighborhood
  bistro inspired by the bar cultures of Spain, France and Mexico." A bistro, not a bar, with three
  countries at once — the exact case the slug is not for. Relaxed onto `modern-european`.
- **`008 Aris`** rested on two aggregator category strings, one of them an OpenTable page whose URL
  reads `iris-austin`. **The restaurant has its own site**, and one sentence there carries both slugs
  under rule 7: "a modern Mediterranean steakhouse … dry-aged prime cuts, Mediterranean-inspired
  dishes". Now Tier A twice. **The Iris alarm was probably false** — search results label that
  OpenTable URL as Aris, so it looks like a legacy slug rather than another business. Unverified and
  now moot.
- **`012 Bellissima`** was re-checked and **deliberately left as it was.** Every route to the
  restaurant's own words is closed to this fetcher — site, about page, menu page, Toast ordering page
  and Yelp listing all 403. Independent sources corroborate the claim, so the slug is not in doubt;
  only the tier is, and it stays B/medium rather than being quietly upgraded on second-hand text.

### Still needing a decision before migrating

- **`090 Santa Catarina`** — tagged `tex-mex` **against** its own site's claim of "interior Mexico".
  Deliberate, and flagged so it can be flipped.
- **`012 Bellissima`** — not blocking, but one browser visit from a human settles it for good.

## The ten closures, and the one in doubt

**Ten of 117 are closed and one cannot be established.** That is roughly 9% of a backlog assembled
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

## Closing the coverage gap — the seven slugs of S13

The pass was built to prefer a visible hole over a tag that reads precise and is not. That discipline
is right for accuracy and it produced a specific failure: **17 of the 106 open places could not be
given a single honest cuisine tag.** Not because the researcher could not identify them — because
nothing in the 38-slug vocabulary described them.

RN-32 says every food place should carry at least one filterable cuisine tag. Seventeen permanent
holes is that rule failing in the data, so Edu approved **seven additions**, chosen as the smallest
set that closes the gap completely:

| New slug | Unlocks | Which places |
|---|---|---|
| **`american`** | **4** | `035` Finley's · `057` Lou's · `066` Millie's On Main · `098` Sundancer Grill |
| **`mexican`** | **2** | `061` Ma'CoCo · `112` VERDAD |
| `cajun-creole` | 1 | `114` Vic & Al's |
| `georgian` | 1 | `014` Bread Boat |
| `sandwiches` | 1 | `065` Meat & Bread |
| `wine-bar` | 1 | `036` Flo's Wine Bar & Bottle Shop |
| `brewery` | 1 | `078` Old Gregg Brewing Company |

**`american` matters most, and not because of the count.** The vocabulary had no plain American entry
— only `new-american`, a chef-driven category, and `southern-comfort`. So every ordinary American
restaurant either fell through the gap or was pushed into `new-american`, **which the pass used 18
times in 117 places**, more than any other slug and 60% more than the next. One slug was doing duty
for a whole cuisine while the places it did not fit vanished entirely.

**The other six of the seventeen needed no new slug.** They were re-tagged onto existing ones by
relaxing from "most precise" to "true but broad", which is recorded in each row:

- `004 Alpine Haus` → `german`. Not a relaxation at all — the slug was added in S11 on the strength
  of this very place and the row simply never got updated.
- `018 Captain Pete's` → `seafood` · `031 Dos Olivos` → `spanish` · `050 Knotty Deck` and
  `006 Anthem` → `new-american` · `009 Bar Toti` → `modern-european`

Each is true and none is exact. The precise reading survives in the row's own notes, so nothing was
lost — only made findable.

### What was deliberately not added

- **`northern-michigan`**, which would have been exact for `066 Millie's On Main` — whitefish, Yooper
  pasties, olive burger — and rests on **one instance in 117 places.** It goes to `american`, with
  the specific truth preserved in the record.
- **`latin-american`**, which `DP-11` records as a boundary judgment that stays Michael's.

### The honest cost

**Three of the seven are formats, not cuisines.** `wine-bar`, `brewery` and `sandwiches` describe
what kind of place it is rather than where the food comes from. Those three businesses have no
cuisine to name, and a visitor filtering the facet would still expect to find them — but it means the
cuisine facet now mixes two kinds of claim. **That is the same objection `BL-42` raises about
`cocktails-bar-food`, knowingly extended rather than accidentally repeated.** It was approved with
that stated.

The migration is written and **not applied**: `20260810120000_extend_cuisine_vocabulary.sql`, with a
rollback that refuses to run if any of the seven is already in use. No MCP was available in S13, so
it was never validated against the live schema — gate G2 is the one built to catch that.

## `BL-42` can now be closed by example

The backlog records `cocktails-bar-food` as a format claim living in the cuisine facet that attracts
whatever the vocabulary cannot describe. The pass produced enough evidence to settle it.

**Five uses in 117 places, and all five are correct** — all drinks-first by the venue's own account:

- `068 Murray's Tavern` — "a newly designed cocktail tavern"; the menu is built around two of the
  owner's grandmother's cocktails
- `083 Péché` — Austin's first absinthe bar; the owner set out to build a cocktail bar and chose
  absinthe to stand apart
- `094 Sidecar` — a basement cocktail club in a historic inn, evenings only, deliberately short menu
- `105 Tiki Tatsu-Ya` — a 21+ immersive tiki bar where the drinks are the entire proposition
- `109 Uchibā` — tagged `japanese` **and** `cocktails-bar-food`, which shows the slug can coexist
  with a cuisine instead of replacing one

**The two known misuses are gone.** `006 Anthem` and `009 Bar Toti` were re-run in S13; both turned
out to be crossed kitchens rather than bars, and both now carry a cuisine tag instead.

If the meaning gets written down, these are the examples to write it from.


## The paused facets pass — 10 of 58, stopped on evidence

A second pass was started in S13 over **the 58 published places** — the only ones a visitor can reach
— targeting the three facets that have 1, 0 and 0 assignments in the entire database: `format`,
`logistics` and `dietary`. It was **paused after ten places, deliberately**, and the reason is the
result:

| Facet | Filled |
|---|---|
| `format` | 9 of 10 |
| `logistics` | **1 of 10** |
| `dietary` | **1 of 10** |

**`logistics` and `dietary` are not researchable from the open web at scale**, and the reason is
structural rather than effort: restaurants do not publish "cash only", "the line is real" or
"parking is a problem" — those are things you learn by going, which is precisely why the facets are
empty in the database. Aggregator dietary flags are auto-generated and frequently wrong, which is why
the prompt excludes them as evidence in the first place.

`format` filled 9 of 10, but **almost every answer was `sit-down-restaurant`.** A facet where 90% of
the guide shares one value does not help anyone filter.

### What the ten places did produce

**`009 Chez L'Amour` is closed — and it is published in the guide right now.** St. Augustine's own
tourism site titles the page "Permanently Closed"; Yelp agrees as of March 2026. A visitor opening
St. Augustine today can click through to a restaurant that does not exist. **One closure in ten is
the same rate as the unreviewed set** (10 in 117), which projects to roughly six of the 58.

Two facts were also found that the vocabulary cannot express, both exactly what a visitor would want:
**`005 BOA Steakhouse` enforces a dress code and is valet-only at $13**, and there is no slug for
either.

### The recommendation this leaves

**Restart it as a closure sweep, not a facet pass.** Keep the 58, keep the frozen batch file, and
collect: operating status (the part that is working), opening hours (the raw material the four
`is_derived` logistics tags need and have never had — `places` has no hours column), and the
publishable half of `vibe` — patio, rooftop, dog-friendly, live music, counter seating — which
restaurants advertise, unlike logistics. `logistics` and `dietary` become opportunistic.

The scope file is frozen and checksummed the same way the cuisine batch was:

```
58 rows · 5e13fc48abfcc828ee55f25b2221b57b
```

Derived offline from `docs/files/`'s master CSV as `(starred OR tier = destination) AND no conflict`,
and it reconciles three ways: 58 total, the exact city split recorded in STATUS (Austin 52, St.
Augustine 3, LA 1, Mountain Home 1, Oxfordshire 1), and 307 tiered rows in the CSV minus the 28
documented tier conflicts = the 279 the database holds.

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
