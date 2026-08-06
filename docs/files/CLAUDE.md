# CLAUDE.md — Michaelin Map

Auto-loaded context for Claude Code. Read fully before making changes.

---

## What this is

A public, read-only, globally scoped web guide to places — curated by a single critic. Every entry carries an explicit tier and a set of filterable tags describing not just what a place is, but what it is *for*.

The model is a Michelin guide, not Yelp: authority comes from one consistent voice, not a crowd average. There are no user accounts, no reviews, no star ratings from strangers.

Layered on top is a deliberate streak of personality — joke tags, novelty interactions, a code system that transforms the interface at runtime, and absurdist visitor "field reports."

**The curator's judgment is the product.** Everything else is delivery mechanism. When trading off, protect the judgment layer.

---

## Stack

| Layer | Choice |
|---|---|
| Build | Vite + React + TypeScript |
| Styling | Tailwind |
| Backend | Supabase (Postgres, Auth, Storage) |
| Map | MapLibre GL (`maplibre-gl`) |
| Place data | Google Places API |
| Hosting | Vercel or Netlify |

**MapLibre, not Google's renderer.** Chosen specifically because it swaps map styles at runtime, which the Codes feature depends on. Do not replace it with a Google Maps embed.

---

## Setup order

1. Create the Supabase project.
2. Run `sql/schema.sql` in the SQL editor.
3. Run `sql/seed.sql` (93 tags, 38 questions).
4. Set env vars: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `GOOGLE_PLACES_API_KEY`.
5. Run `scripts/import-places.ts` to load the 511-place master CSV.

The schema already exists. **Do not redesign it.** If a change is genuinely needed, write a migration and say why.

---

## Data model summary

Full DDL in `sql/schema.sql`. The parts that matter:

**`places`** — one row per place. Key fields:
- `place_type` — restaurant, bar, food_truck, dessert, winery, hotel, grocery, shop, outdoors, unclassified
- `tier` — restaurants: `destination` > `experience` > `fair`; bars: `cool` > `fair`
- `starred` — boolean, cross-cuts tiers. 22 of 511. This is the scarce top honor.
- `visited` — false means Try List. Cannot be tiered or starred.
- `status` — unreviewed | published | closed | hidden
- `country` / `city` / `area` — three-level geography
- `the_dish`, `curator_note`, `story`, `last_visited` — **the judgment layer**
- `source_guides` — original Apple guide names, audit only

**`tags` / `place_tags`** — faceted vocabulary: cuisine, format, occasion, vibe, logistics, dietary, character. Controlled lists; free-text tag creation is disabled by design.

**`codes`** — curator-created strings that transform the UI at runtime.

**`questions` / `field_reports`** — the absurdist visitor questions and their answers.

**`sync_runs`** — audit log for My Maps KML sync.

---

## Hard constraints — do not violate

**1. Sync is additive, never authoritative.**
A My Maps KML sync may insert new places as `unreviewed` and flag ones that vanished upstream. It must **never** write to `tier`, `starred`, `the_dish`, `curator_note`, `story`, `last_visited`, or `place_tags`. Those fields exist only here. A bad sync must not be able to destroy them. Places missing upstream are flagged, never auto-deleted.

**2. Discoverability floor.**
Every published place must be reachable through at least one literal facet — cuisine, city, place type, or price. A place findable only via a `character` tag is a bug. Novelty interactions are additive shortcuts; nothing is reachable exclusively through Roulette or a code.

**3. Codes never remove content.**
They restyle, reorder, highlight, and add messages. They do not hide places from someone without the code.

**4. Validation applies at promotion, not insert.**
Synced and imported places arrive `unreviewed` with no tags and no tier. Enforcing full validation on insert makes import and sync impossible. Validate when `status` moves to `published`.

**5. Places API is billed per request.**
Hydrate at creation and on a schedule. **Never on page load.** All derived data is stored locally and served from Postgres.

**6. Tier scarcity.**
`destination` and `starred` must stay scarce or the scale means nothing. Surface the distribution in admin so drift is visible.

**7. Field reports must stay non-evaluative.**
No question may ask whether a place was good, or permit a rating to be derived. That axis belongs to the curator alone. This is what makes visitor input safe here.

**8. Free text is review-gated.**
Only 4 of 38 questions accept text, capped at 40 chars, inserted as `pending`, published only on curator approval. Do not add unbounded text inputs anywhere else.

---

## Explicitly out of scope

- Visitor accounts or sign-in (the app is read-only for the public)
- Reviews, ratings, star scores, comments
- Reservations, ordering, delivery integration
- Native mobile apps
- Re-solving the Apple Maps import problem — see below

---

## Do not re-solve: Apple Maps import

Significant investigation already settled this. Conclusions:

- Apple provides no export, no API for reading user guides, and disallows automated access to `maps.apple.com`.
- An Apple guide link cannot be obtained programmatically — it exists only when the curator taps Share.
- Driving third-party converters with a headless browser was rejected; the previous tool in that category was an unfunded solo project that shut down mid-2026.
- Google Maps *saved lists* have no API. Google **My Maps** does — `https://www.google.com/maps/d/kml?mid=<MAP_ID>&forcekml=1`, a plain HTTP GET returning KML. That is the sync path.

The one-time migration is already done: 511 places extracted to CSV.

---

## Current data state

511 unique places, merged from 19 Apple Maps guides.

| Place type | n | | City | n |
|---|---|---|---|---|
| Restaurant | 273 | | Austin | 466 |
| Bar | 91 | | St. Augustine | 15 |
| Outdoors & attraction | 65 | | Jacksonville | 8 |
| Food truck | 23 | | Los Angeles | 4 |
| Dessert | 16 | | Oxfordshire, DFW | 3 each |
| Grocery/Hotel/Winery/Shop | 28 | | 8 singletons | 1–2 each |
| Unclassified | 15 | | | |

Tiers: destination 43, experience 36, fair 198, cool 30. Starred 22. Not visited 42.

**Known data issues to handle, not silently fix:**
- 28 places carry both a tier and `visited = false`. Import them with the tier **dropped** and flag for curator review; the DB constraint will reject them otherwise.
- 15 unclassified places need a `place_type` before they can be filtered.
- 8 singleton cities (Waco, Seattle, San Diego, Belton, Schertz, Mountain Home, Rochester, Essex Junction) — pending decision on whether to show as peer cities.

---

## Conventions

- TypeScript strict. No `any` without a comment explaining why.
- Database is snake_case; frontend is camelCase. Map at the data-access boundary, not throughout.
- One filter state object, shared by map and list. Never two.
- Filter state serializes to the URL so views are shareable.
- No `localStorage` for anything that belongs in Postgres. The personal shortlist is the one legitimate local-only feature.
- Every derived field records its source (`geo_source`, `price_band_source`) so curator overrides survive re-hydration.

---

## Build order

See `PLAN.md`. Do not jump ahead to the fun layer — Codes and Roulette both depend on filtering working correctly, and a code that applies a preset filter is meaningless before filters exist.

---

## Open questions — ask, do not assume

1. Is `destination` genuinely above `experience`? Inferred from trade usage, not confirmed by the curator.
2. Should singleton cities appear as peers in the city gate?
3. Verdict labels shown to the public — the curator may rename all tiers.
4. Link privacy: public and indexable, or unlisted?
