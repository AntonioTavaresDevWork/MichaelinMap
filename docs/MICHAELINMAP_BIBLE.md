# Michaelin Map — Project Bible

**Version:** 2.9 | **Date:** 2026-08-08 | **Author:** Edu Mello
**Project status:** 🟢 **All seven MVP features are closed.** Working admin, navigable public side,
faceted filter, Codes, Roulette and field reports, with 58 published places. The critical path is now
entirely human: the curator's voice and the tagging (§13.1)

> Source of truth for Michaelin Map. The CLI reads this file at the boot of every session.
> Derived from PRD v1.0 produced in Claude Web (`docs/files/2026-08-05-michaelin-map-prd.md`),
> with the scope reduction and the technical corrections agreed in Session 02.
>
> **Language:** this document, and everything else written into this repository, is in English —
> see ADR-02, amended in S09. The product has always been in English.

## Changelog

| Version | Date | What changed |
|---|---|---|
| 2.9 | 2026-08-08 | **ADR-02 amended: the internal documentation moved from Portuguese to English**, by Edu's decision, because a handover to someone who may not read Portuguese became likely. This bible, STATUS, BACKLOG, `CLAUDE.md`, the skills, the agents and the boot prompts were translated. Also fixed: the header still read v2.6 while the changelog had already recorded 2.7 and 2.8 |
| 2.8 | 2026-08-07 | **New RN-31** (§14.3): a `suggested` tag appears on no public surface until the curator confirms it. §12 records the fact that motivated it — all 145 assignments are the machine's and none is Michael's |
| 2.7 | 2026-08-07 | **The rating facet left the public filter** by Edu's decision (S08). **New RN-30** (§14.4). The tier still exists in full — it labels the place in the list and in the detail view, orders the list, colors the pin and belongs to the curator; what left is the navigation axis and the `tier` URL parameter. §6 gains the distinction between judgment and navigation axis |
| 2.6 | 2026-08-07 | F-06 applied (S08) without touching the schema — **the MVP closed**. **New RN-29** (§14.6): the follow-up question (`judgment_prompt`) is a closed choice, never free text. §10 gains how the curator's seeding works in practice |
| 2.5 | 2026-08-07 | F-05 applied (S07) without touching the schema. **New RN-27 and RN-28** (§14.5): a code's preset seeds the panel once and never overwrites the URL; the redemption is revalidated on the server on every load. §13 gains the note that F-01 had already delivered the whole table |
| 2.4 | 2026-08-07 | F-04 applied (S06). **New RN-26** (§14.4): a facet with no populated option is not rendered |
| 2.3 | 2026-08-07 | F-02 and F-03 applied (S05), recorded in S06. Tile source settled: **OpenFreeMap** (§2, ADR-05). §13 gains a status column. Dedicated review-queue screen cut (§13). Publication state in §12 |
| 2.2 | 2026-08-06 | Curation moves to **a single account** (§4, §9.4, §11). Consequence: `updated_by` does not identify a person |
| 2.1 | 2026-08-06 | F-01 applied (S04). Count correction: there are **4** tiers, not 5 (§9.2). The CSV's `Town` becomes `area` (§8). ADR-06 amended: `price_band` is not pre-suggested |
| 2.0.1 | 2026-08-06 | Factual correction: local folder path in §3 (S03). No change to scope, schema or rules |
| 2.0 | 2026-08-06 | Bible filled in from the PRD. MVP scope closed (7 features). Cuts: Google Places API, My Maps sync, Trip Builder, novelty interactions except Roulette, SEO/indexing. Schema corrected (8 tables). Authorization model defined (curator allowlist). |
| 1.0 | — | Empty Wise* template |

---

## 1. Overview

**What it is:** a guide to places — restaurants, bars, food trucks, shops, hotels, parks and attractions — curated by a single person. Every entry carries an explicit quality verdict and a set of tags describing not only what the place *is*, but what it *is for*.

**Context:** a personal project with no commercial purpose. Michael is a friend of Edu's who goes to a lot of places and is constantly asked for recommendations. Michaelin Map is where he shares those experiences with his close circle.

**The problem it solves:** Michael accumulated 511 places saved across 19 Apple Maps guides. Sharing that is nearly useless — a map of pins transmits coordinates and nothing else. The value is not in the pins, it is in the judgment: which place is worth the trip, which one is famous and disappointing, which single dish justifies a mediocre restaurant. None of that survives sharing a link.

**MVP focus:** make the judgment transmissible. A visitor opens the link, picks a city, filters by what they need, and reaches a decision.

**What it is NOT:** not a SaaS, not multi-tenant, will not be monetized, will have no customers. Not Yelp — there are no third-party ratings, no average score, no comments, no visitor accounts.

**Long-term vision:** none. The project is finished when Michael is using it and his friends are too.

### 1.1 The demonstration context

A success condition stated in the PRD: showing the guide to a specific person should make that person feel closer to Michael. That repositions the product — it is an **artifact of personality** whose content is judgment and voice, with usefulness serving as the vehicle. It is not a utility that happens to be charming.

Consequence for prioritization: the **Codes**, the **story** field and the curator's written voice matter more than incremental filter sophistication.

---

## 2. Stack

```
Frontend:     React + Vite + TypeScript (SPA, no SSR)
UI:           Tailwind CSS + shadcn/ui
Map:          MapLibre GL 5.x · OpenFreeMap tiles  ← see ADR-05
Forms:        controlled useState, inline validation in onSubmit (no react-hook-form/zod)
Notifications: sonner — <Toaster richColors position="top-right" /> in App.tsx
State:        React Query (server state) · Zustand if UI state needs it
Routing:      React Router DOM
Icons:        lucide-react
Backend/DB:   Supabase (PostgreSQL 17 + Auth)
Server-side:  Supabase Edge Functions (Deno) — only if needed
Geocoding:    Nominatim / OpenStreetMap (free, no key)  ← see ADR-06
Deploy:       Vercel
```

**Outside the stack, by decision:** Google Places API (ADR-06), TanStack Table (a simple list is enough), SSR/pre-rendering (ADR-07).

---

## 3. Repository and infrastructure

```
GitHub:        AntonioTavaresDevWork/MichaelinMap (private) — Edu's account
Local folder:  C:\Users\tomme\OneDrive\Documents\Projects\Michaelin Map
Supabase ID:   woapimgpmlgqqvauckdy
Supabase URL:  https://woapimgpmlgqqvauckdy.supabase.co
Deploy:        Vercel — to be configured after F-03
Indexing:      noindex (unlisted) — see ADR-07
```

> Both the database and the hosting are expected to move to a company organization when the project
> changes hands. The `README.md` handover section documents what travels with the repository and what
> does not — including the fact that auth accounts do not, and that no migration publishes a place.

---

## 4. Users

| Role | Who | Access |
|---|---|---|
| **Visitor** | Michael's friends and acquaintances | Read only, no account, no login. Receives the link (and frequently a Code) directly from Michael |
| **Curator** | Michael. Edu operates from the **same account** when giving support | Login to the admin. **A single account**, on an explicit allowlist. There is no signup |

There is no third role. No contributors, no moderators, no public submissions — with the strict and non-evaluative exception of field reports (§10).

**Single account (decided in S04).** The guide is Michael's; Edu uses his account when needed. A consequence to accept consciously: `places.updated_by` no longer identifies **who** edited — it only records that the edit came from a logged-in curator. Since attribution between the two was never the point (the judgment belongs to one person by design — §1), the cost is low. If curation ever genuinely becomes four-handed, the second account is created and `updated_by` means something again, with no schema change.

---

## 5. Domain model

```
tiers ──< places >── place_tags >── tags
                │
                └──< field_reports >── questions

curators (write allowlist)
codes (interface transformations, independent of places, with optional highlights)
```

- `places` is the central entity. Everything orbits it.
- `tiers` is editable vocabulary, not a code constant (RN-12).
- `codes` references places only through an array of highlights — no rigid FK.

---

## 6. The judgment model

The heart of the product. It was not designed — it was **reverse-engineered from Michael's 19 guides**, which already encoded a consistent system.

### 6.1 The evidence

Across 511 places, the three restaurant guides — Designation (43), Experience Spots (36), Fair Restaurants (156) — overlap **exactly zero**. Perfect mutual exclusivity across 235 places is not an accident: it is a scale.

Michael's Top Faves (22) crosses all three tiers (8/9/2) and has zero overlap with the Try List. So it is not a fourth tier — it is an honor applied *on top of* a tier, and never granted to a place that has not been visited.

Cool Bars (31) and Fair Bars (46) share exactly one place: a second, parallel, two-level scale for bars.

### 6.2 The model

| Layer | Field | Values | Rule |
|---|---|---|---|
| **Tier** | `places.tier` | Restaurants: `destination`, `experience`, `fair` · Bars: `cool`, `fair` | At most one. Null for unrated types and unvisited places |
| **Star** | `places.starred` | boolean | Crosses the tiers. 22 out of 511 (4%). The scarce honor at the top |
| **Visit status** | `places.visited` | boolean | `false` = Try List. Cannot carry a tier or a star |

`destination` and `experience` are **not first and second place** — they are two parallel summits above `fair` (DP-01 resolved: "it makes no difference"). The interface displays them in a fixed order, but the copy never claims one is superior to the other.

> **Judgment is not the same thing as a navigation axis (S08).** The tier remains everything this
> section describes: the curator assigns it, the badge appears in the list row and on the place page,
> the list order obeys it and the pin color reflects it. What it is **no longer** is a facet the
> visitor filters by — see RN-30. The distinction matters because the tier remains irreplaceable as
> data, and nothing in §6 changed.

Both constraints are guaranteed by database constraints, not by application logic. The curator's discipline becomes a schema guarantee.

### 6.3 Scarcity

`destination` and `starred` need to stay scarce, or the scale means nothing. The admin displays the live distribution so that inflation is visible. Target: stars below 5% of published places.

### 6.4 The negative verdict

The taxonomy keeps **Hype trap** for places that are famous, crowded and disappointing. A negative verdict is what makes the positive ones credible. By the curator's decision it is **admin-only** — visible in curation, invisible to the public (RN-14).

---

## 7. Place types

The guide is not only restaurants. Around ninety non-food entries live alongside the rest.

| Type | `place_type` | n | Has a tier |
|---|---|---|---|
| Restaurant | `restaurant` | 273 | Yes — 3 tiers |
| Bar | `bar` | 91 | Yes — 2 tiers |
| Outdoors & attraction | `outdoors` | 65 | No |
| Food truck | `food_truck` | 23 | No |
| Dessert | `dessert` | 16 | No |
| Grocery | `grocery` | 14 | No |
| Hotel | `hotel` | 6 | No |
| Winery | `winery` | 5 | No |
| Shop | `shop` | 3 | No |
| Unclassified | `unclassified` | 15 | — |

**Place type is the second gate**, alongside the city. "Where I eat" and "what I do" are different sections; mixing a state park into the result of a restaurant filter is noise. Types without a tier still carry the star, which becomes their quality signal.

---

## 8. Geography

Three levels, all derived from coordinates with the possibility of a manual override.

| Level | Field | Cardinality | Role |
|---|---|---|---|
| Country | `country` | Exactly 1 | Grouping only |
| City / metro | `city` | Exactly 1 | **The primary gate** |
| Neighborhood / area | `area` | 0 or 1 | Null below the density threshold |

**The city is a gate, not a filter.** Nobody browses every place on the planet. The visitor picks the city first and every other facet operates inside it.

**Areas only exist where density justifies them** — around 15 entries. Austin gets neighborhoods; Oxfordshire, with 3 places, displays no area control at all. The hierarchy degrades silently instead of rendering an empty control.

**Where `area` comes from (F-01):** the CSV's `Town` column carries the real municipality — Lockhart, Dripping Springs, San Marcos, New Braunfels. The import writes `Town` into `area` when it **differs** from the gate city, and null when it repeats. Result: 107 of the 511 places have an area. It is derived geography, not judgment, so it is reversible with an `UPDATE places SET area = NULL`.

**Current cities:** Austin 466, St. Augustine 15, Jacksonville 8, Los Angeles 4, Oxfordshire 3, Dallas-Fort Worth 3, Fernando de Noronha 2, Waco 2, plus eight singletons (London, Belton, Essex Junction, Mountain Home, Rochester, San Diego, Schertz, Seattle).

**Singletons appear as pairs** (DP-02 resolved), with the count visible. No city is privileged in the interface.

---

## 9. Database schema

Eight tables. The detailed SQL lives in `supabase/migrations/`; this section is the quick reference and **documents the corrections made to the PRD's original schema**.

### 9.1 `places`

| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | default `gen_random_uuid()` |
| `name` | text NOT NULL | |
| `slug` | text UNIQUE | generated; disambiguated with a suffix when there is a namesake |
| `place_type` | text NOT NULL | default `unclassified`; CHECK against the §7 list |
| `tier` | text | **FK → `tiers(slug)`** |
| `starred` | boolean NOT NULL | default false |
| `visited` | boolean NOT NULL | default true; `false` = Try List |
| `status` | text NOT NULL | default `unreviewed`; CHECK `unreviewed \| published \| closed \| hidden` |
| `country` / `city` / `area` | text | §8 |
| `lat` / `lng` | numeric(10,7) | |
| `address` | text | |
| `website` | text | manual, optional |
| `price_band` | text | `$` to `$$$$` — **the curator's judgment**, not derived |
| `the_dish` | text | ⚠️ judgment layer |
| `curator_note` | text | ⚠️ judgment layer |
| `story` | text | ⚠️ judgment layer — "why this matters to me" |
| `last_visited` | date | ⚠️ judgment layer |
| `apple_id` | text **UNIQUE** | correction: it had no UNIQUE and the import broke |
| `source_guides` | text[] | names of the original Apple guides, for auditing |
| `source` | text | `apple_csv \| manual` |
| `created_at` / `updated_at` | timestamptz | `updated_at` through a trigger |
| `updated_by` | uuid | FK → `auth.users`; who edited last |

**Constraints:**
- `tier_requires_visit` — an unvisited place cannot have a tier
- `star_requires_visit` — an unvisited place cannot have a star
- `published_needs_city` — a published place needs a city

**Removed from the original schema** (no data source after the Google Places cut): `google_place_id`, `phone`, `hours`, `geo_source`, `price_band_source`, `mymaps_feature_id`, `first_synced_at`, `last_seen_in_sync`.

### 9.2 `tiers` — new

The tier becomes editable data to satisfy DP-03 ("allow renaming the tiers").

| Column | Type | Notes |
|---|---|---|
| `slug` | text PK | stable; the code depends only on this |
| `label` | text NOT NULL | public label, editable in the admin |
| `applies_to` | text[] NOT NULL | place types the admin suggests for this tier |
| `sort_order` | int NOT NULL | display order |
| `active` | boolean NOT NULL | |

Seed: **4 rows** — `destination` and `experience` (`applies_to = {restaurant}`), `fair`
(`{restaurant, bar}`) and `cool` (`{bar}`).

> Correction from v2.1: earlier versions said "5 tiers", counting `fair` twice because it appears in
> both scales in §6.2. Since `slug` is the PK, `fair` is **one** row serving both types — which is
> exactly what `applies_to` being an array is for. It matches `SEEDED_TIER_SLUGS` in
> `src/types/index.ts` and the single `Fair` value in the CSV.

`applies_to` **guides the admin, it does not restrict the database** — the curator is the authority. That accommodates the 4 places that fall outside the pattern in the current data (§12).

### 9.3 `tags` / `place_tags`

A controlled, faceted vocabulary. Creating a tag from free text is disabled by design.

`tags`: `id`, `facet` (`cuisine | format | occasion | vibe | logistics | dietary | character`), `label`, `slug`, `is_derived`, **`admin_only`** (new — RN-14), `sort_order`, `active`. UNIQUE `(facet, slug)`.

`place_tags`: `place_id`, `tag_id` (composite PK), **`source`** (new — `curator | suggested`), `created_at`.

`source = 'suggested'` marks the `cuisine` and `price_band` tags the CLI pre-classifies during the import (ADR-06). The curator sees what came from the machine and what came from him.

Seed: 93 tags (37 cuisine, 14 occasion, 11 vibe, 11 logistics, 9 character, 7 format, 4 dietary) + `Hype trap` in `character` with `admin_only = true`.

### 9.4 `curators`

`user_id` uuid PK → `auth.users` · `name` text · `created_at`.

**One row**, Michael's account, which Edu also uses (§4). Signup disabled in the Supabase project. The schema does not change if there are ever two — it is just a second row.

### 9.5 `codes`

No structural change: `id`, `code` (UNIQUE, uppercase), `label`, `message`, `theme` jsonb, `pin_style` jsonb, `preset_filter` jsonb, `highlighted_places` uuid[], `starts_at`, `ends_at`, `active`, `created_at`.

**RLS correction:** the table loses its public SELECT. See §11 and RN-20.

### 9.6 `questions` / `field_reports`

`questions`: `id`, `prompt`, `input_type` (`number | color | slider | single_choice | yes_no | compound | text_short`), `unit_label`, `options` jsonb, `slider_labels` jsonb, `judgment_prompt`, `requires_review`, `weight`, `active`. Seed: 38 questions.

`field_reports`: `id`, `place_id`, `question_id`, `answer` jsonb, `judgment`, `status` (`published | pending | rejected`), `session_hash`, `submitted_at`.

**RLS correction:** direct INSERT by the public is revoked; the only way in is the `rpc_submit_field_report` RPC (RN-21).

View `field_report_aggregates` — aggregates published answers, hidden below n=5. **Correction:** created with `security_invoker = on`, otherwise the view bypasses RLS.

### 9.7 Indexes

```sql
places(city) where status = 'published'
places(place_type) · places(tier) · places(status) · places(lat, lng)
field_reports(place_id) where status = 'published'
field_reports(session_hash, submitted_at)   -- rate limit
place_tags(tag_id)                          -- reverse filter
```

---

## 10. Field reports

Visitors who have been to a place answer 2 or 3 randomly drawn questions that **carry no information about quality whatsoever** — food temperature in Fahrenheit, the color of the chair, the distance to the nearest body of water, ceiling height measured in hands.

**The absurdity is structural, not decorative.** A conventional comment would flatten the curator's tier into "one more opinion". Questions on an orthogonal axis do not compete with his judgment. Participation without dilution.

- Inputs are **restricted** — number, color, slider, choice, yes/no, compound. That also eliminates the moderation load.
- **4 of the 38 questions** accept free text because the answer space is unbounded. Limited to 40 characters, they enter as `pending` and only go live with the curator's approval.
- **The aggregate is the feature**, rendered with deadpan scientific seriousness and hidden below 5 answers. The curator seeds his own answers so that nothing is born at zero.
- One question — *the dish you would order again* — is the only point at which a visitor's answer informs the curator's judgment, and it appears highlighted in the admin.

**How the draw works (F-06).** The 2-3 questions come from a draw **seeded on place + browser**, not
from `Math.random()`. Being seeded, they do not change under the finger of whoever is answering and
they survive a reload; by varying between people, two who sat at the same table get different
questions — which is what makes an aggregate accumulate instead of everyone answering the same thing.

**How seeding works (F-06, BL-20).** The admin has a surface where the curator answers the questions
himself for a place, and those answers enter **published immediately** — the review queue exists to
keep a stranger's text out of the guide, and the curator is the person that queue answers to. Two
consequences worth writing down: seeding **reveals no aggregate at all** (n=5 is per place × question,
and one person honestly gives one answer), and the values are **typed by someone who was there** —
nothing here is generated, because an invented ceiling height would be indistinguishable from a
measured one on a panel that reports to one decimal place.

---

## 11. Authorization model

| Field | Value |
|---|---|
| **Model** | **Curator allowlist** — neither tenant-scoped nor RBAC. See ADR-01 |
| **Function resolving the caller** | `is_curator()` — `exists (select 1 from curators where user_id = auth.uid())`, STABLE SECURITY DEFINER |
| **Auditing** | No audit table. `places.updated_by` + `updated_at` record *when* — with a single account, not *who* (§4) |
| **Anonymous access** | Reading published content + writing a field report **exclusively through an RPC** |

### RLS per table

| Table | Public SELECT | Writing |
|---|---|---|
| `places` | `status = 'published'` | curator |
| `tiers` | `active = true` | curator |
| `tags` | `active AND NOT admin_only` | curator |
| `place_tags` | only for a published place and a non-admin tag (through EXISTS) | curator |
| `codes` | **none** — only through `rpc_redeem_code()` | curator |
| `questions` | `active = true` | curator |
| `field_reports` | `status = 'published'` | INSERT only through `rpc_submit_field_report()`; the rest curator |
| `curators` | none | curator |

### RPCs exposed to the client

| RPC | What it does |
|---|---|
| `rpc_redeem_code(p_code text)` | Takes a code, returns its effect if it exists, is active and is inside the date window. Returns empty otherwise. Prevents code enumeration |
| `rpc_submit_field_report(...)` | Validates that the place is published and the question active; **derives the status from `questions.requires_review`** (the visitor does not choose); truncates text at 40 characters; applies a rate limit per `session_hash` |

---

## 12. Current state of the data

511 unique places, extracted from 19 Apple Maps guides. Numbers validated line by line against the master CSV.

**Publication state (S05):** 58 `published`, 453 `unreviewed`. The launch batch is the places with a
star or the `destination` tier — Austin 52, St. Augustine 3, Los Angeles 1, Mountain Home 1,
Oxfordshire 1. It was not new judgment: tier and star came from Michael's own guides and the import
simply had not revealed them. Reversible with `UPDATE places SET status = 'unreviewed'`.

> **That batch is not in any migration** (`BL-35`, found in S09). It came from an ad-hoc `UPDATE` and
> lives only in the live database, so a rebuild against an empty project returns 511 unreviewed
> places and a public guide that renders empty while looking healthy. The criterion above is the
> whole recipe; it is worth turning into a versioned migration.

⚠️ **None of the 58 has `the_dish` or `curator_note`.** The guide is populated but mute — it shows the
verdicts, not the voice. Per §1.1, that is what separates an artifact of personality from an organized
list, and it is human work, not CLI work.

Tiers: destination 43, experience 36, fair 198, cool 30. Stars 22. Unvisited 42. Duplicate Apple IDs: zero. Missing coordinates: zero. Namesakes: 9 (disambiguated by slug).

**Three questions that require the curator's decision, not a silent fix by the dev:**

1. **28 conflicts** — places with a tier *and* on the Try List, that is, rated without having been visited. The import drops the tier and flags them; each one needs Michael to confirm he was there or to agree the tier was aspirational.
2. **15 unclassified** — thirteen are exclusive to the Try List, saved without a category; two are in Fernando de Noronha, one of them an airport and probably not a recommendation.
3. **4 outside the tier × type crossing** — Grocery with `fair` (2) and `destination` (1), Bar with `experience` (1), Outdoors with `fair` (1). The database does not block them (§9.2), but the admin flags them.

**The 93 tags are born empty.** The CSV's `Tags` column carries only 5 distinct values (Breakfast & brunch 54, Rooftop 14, Night out 3, Vacation 2, Food truck 1), derived from guide names. Tagging 511 places is the project's real bottleneck — see §13.1.

> **Measured in S08, and it is worse than "bottleneck".** Of the existing assignments, **zero** are
> the curator's — all are `suggested`, produced by machine. Of the 58 published, 11 had some tag and
> **none** has `the_dish`. Only 21 of the 94 tags have ever been used. In other words: the curation
> that §13.1 describes as "running in parallel since F-02" **has not started**. Edu cannot substitute
> for it — he has never been to any of these places; the list is Michael's, and so is the judgment.
>
> This does not invalidate the guide: `tier` and `starred` **are** Michael's judgment, they came from
> his 19 guides, they cover the 58 published places and they carry the list, the order and the map.
> What is missing is the voice — `the_dish` and `curator_note` — and §1.1 says the voice is what
> separates an artifact of personality from an organized list. It is ten sentences of human work, not
> five hundred tags.
>
> **Also in S08, 28 new cuisines entered as `suggested`** (migration `20260807140000`), covering the
> published food places that had none — from 45 without a cuisine down to 17. It is not curation: it
> is an approval queue, invisible to the visitor under RN-31 until Michael confirms it. Total pending
> suggestions: **173**. The remaining 17 are the ones that neither the name nor public knowledge
> resolves, and they are listed in the migration's footer.

---

## 13. MVP scope

Seven features. Strict dependency order: each one only starts with the previous one building clean.

| # | Feature | Delivery | Sessions | Status |
|---|---|---|---|---|
| **F-00** | Foundation | Vite + TS + Tailwind + shadcn/ui, Supabase client, types, routing, layout | ~0.5 | ✅ S02 |
| **F-01** | Schema + data | Corrected schema migration, seed (93 tags, 38 questions, 5 tiers), import of the 511 with `cuisine` and `price_band` pre-suggested | ~1 | ✅ S04 |
| **F-02** | Admin | Login, filtered list, place editor, tag assignment, mobile quick-add, Overview (tier distribution, curation progress, queues, stale entries) | ~2 | ✅ S05 |
| **F-03** | Public | City gate, MapLibre map, synchronized list, place detail | ~2 | ⚠️ S05 — map mute due to `BL-29` |
| **F-04** | Filters | Faceted panel, OR within / AND between facets, live counts, zero option disabled, state in the URL, authored empty state | ~1 | ✅ S06 |
| **F-05** | Codes + Roulette | Complete Codes (theme, map style, pins, pre-applied filter, highlights, type-anywhere on desktop, long-press on mobile) + Roulette | ~2 | ✅ S07 |
| **F-06** | Field reports | 7 input types, draw of 2-3 questions, aggregate at n≥5, free text in a queue, rate limit | ~1.5 | ✅ S08 |

Total estimate: **~10 CLI sessions.** The seven features closed in 7 sessions.

**F-06 did not touch the schema either** — the second feature in a row. F-01 had already delivered
`rpc_submit_field_report()` (derives the status, truncates at 40, limits per session), the
`field_report_aggregates` view with `security_invoker` and its `HAVING count(*) >= 5`, the 38 seeded
questions and the grants in place: `anon` executes the RPC and has **no** INSERT on the table, so
RN-23 is guaranteed at the privilege level, not only by policy.

**F-05 did not touch the schema.** F-01 had already delivered `codes` with the six effect fields
(`theme`, `pin_style`, `preset_filter`, `highlighted_places`, the date window, `active`) and
`rpc_redeem_code()` with `anon` already authorized to execute it. The entire feature is frontend on
top of the existing database — no migration, no new npm dependency, no new shadcn component.

**Scope cut in F-02 (S05):** the dedicated review-queue screen was not built. The three queues — tier
conflicts, suggested tags, places without a type — are cards on the Overview that link to the list
with the filter already applied. A screen of its own would be a fourth way of looking at the same
records, with two places to keep in sync.

### 13.1 Curation runs in parallel

From F-02 onward, Michael starts tagging. This is not a dev phase — it is continuous human work, and it is the project's critical path.

**Launch strategy:** do not wait for all 511. The 22 with a star plus the 43 `destination` already form an excellent guide — they are precisely the ones friends ask about. Publish those ~65 first; the rest arrive as they get tagged.

### 13.2 Out of the MVP

Recorded in `docs/BACKLOG.md`, each with the reason for the cut: Google Places API and hydration, My Maps KML sync, Trip Builder, Settle It, I'm Hungry Now, Bad Idea, local shortlist, SEO and indexing, area by geographic polygon.

---

## 14. Business rules

### 14.1 Judgment

- **RN-01** — An unvisited place (`visited = false`) cannot have a tier. Guaranteed by constraint.
- **RN-02** — An unvisited place cannot have a star. Guaranteed by constraint.
- **RN-03** — The star crosses the tiers; it is not one more tier.
- **RN-04** — `destination` and `experience` are parallel summits, not positions 1 and 2. No product text claims one is superior to the other.
- **RN-05** — Types without a tier (outdoors, food truck, dessert, grocery, hotel, winery, shop) use the star as their only quality signal.
- **RN-06** — The admin displays the tier and star distribution live. Target: stars below 5% of published places.

### 14.2 Publication and discovery

- **RN-07** — Every imported or created place is born `unreviewed`. Only `published` is visible to the public.
- **RN-08** — Validation applies on promotion to `published`, never on insertion. Importing while demanding complete validation is impossible.
- **RN-09** — A published place needs a city. Guaranteed by constraint.
- **RN-10** — Every published place must be reachable through at least one literal facet — cuisine, city, place type or price. A place reachable only through a `character` tag is a bug.
- **RN-11** — Novelty interactions (Roulette) are additive shortcuts. Nothing is reachable exclusively through them.

### 14.3 Vocabulary

- **RN-12** — Tiers are data, not constants. The code depends on `tiers.slug`; the public label (`label`) is editable in the admin without a deploy.
- **RN-13** — Tags have a controlled vocabulary. Creation from free text is disabled.
- **RN-14** — A tag with `admin_only = true` never appears to the public, on any surface: not in the filter, not in the detail view, not in search results. `Hype trap` is the current case.
- **RN-15** — A tag with `source = 'suggested'` is a machine suggestion pending review. The admin distinguishes them visually from the ones the curator assigned.
- **RN-31** — **A `suggested` tag appears on no public surface.** Not as a badge on the place, not as a
  facet, not as a count — until the curator confirms it, turning it into `curator`. RN-15 required
  distinguishing the two **in the admin**, and that always held; what was missing was the other end:
  the visitor had no way to distinguish, so a guess from the import (word matching on the place name)
  reached them with the same authority as a decision by Michael. In a product whose entire value is
  one person's judgment (§1.1), that is not a display detail — it is the difference between the guide
  asserting and the guide guessing. **Accepted consequence:** while curation has not started, the
  public panel shows fewer facets. Preferable to showing more than is known. Recorded in S08, when it
  was found that all 145 existing assignments were `suggested` and all of them visible.

### 14.4 Filtering

- **RN-16** — OR within a facet, AND between facets. Tacos + BBQ shows both; adding East Austin narrows to tacos and BBQ in East Austin.
- **RN-17** — Every filter option displays a live result count. An option that would return zero is **disabled, not hidden**.
- **RN-18** — The area filter only appears in cities with roughly 15 places or more.
- **RN-19** — Filter state serializes into the URL. Any view is shareable.
- **RN-30** — **The visitor does not filter by tier.** There is no rating facet in the panel, and the
  `tier` parameter left the URL along with it — a filter with no control on screen would narrow the
  guide invisibly, which is exactly the failure RN-27 exists to prevent. An old link carrying
  `?tier=` is simply ignored. **The tier itself was not touched:** it still labels the place in the
  list and the detail view, orders the list, colors the pin and is assigned by the curator (§6). The
  star becomes the only *filterable* quality signal, which is how the eight tier-less types always
  worked (RN-05) — now true for restaurants and bars as well. Edu's decision in S08; no schema
  changed, so it is reversible without a migration.
- **RN-26** — **A facet with no populated option is not rendered.** RN-17 governs the *option* inside
  a facet and continues to hold in full; an entire facet with nothing behind it is the case §8 already
  solved for areas — degrade silently instead of rendering an empty control. Desired consequence: the
  panel grows on its own as curation advances, with no deploy, because tags are data and not code
  (RN-13). Recorded in F-04, when six of the seven tag facets had zero assignments.

### 14.5 Codes

- **RN-20** — Codes are never listable. The public has no SELECT on `codes`; validation goes through the RPC, which answers for one specific code.
- **RN-21** — Codes never remove content. They restyle, reorder, highlight and add a message. They never hide a place from someone who does not have the code.
- **RN-27** — **A code's pre-applied filter seeds the panel once and then belongs to the visitor.**
  It arrives selected, counts like any other filter, and leaves through the same *Clear* button. And
  it **never overwrites a filter already present in the URL** — a shared link is somebody's explicit
  choice and beats decoration. It is RN-21 applied to the only code effect that narrows the view:
  without this rule, a preset would be a code hiding places. Recorded in F-05.
- **RN-28** — **A code's redemption is revalidated on the server on every load.** The code typed in is
  remembered locally so it survives a reload — Michael hands a code to a *person*, not to a tab — but
  the effect is never read from what was stored. Switching a code off in the admin takes effect on the
  next visit instead of being stuck in the browser of someone who already used it.

### 14.6 Field reports

- **RN-22** — No question may ask whether the place was good, nor allow a score to be derived. That axis belongs to the curator alone.
- **RN-23** — The answer's status is derived from `questions.requires_review` by the server. The visitor does not choose whether their answer goes live.
- **RN-24** — Free text is limited to 40 characters, enters as `pending` and only publishes with approval. No other unbounded text input exists in the product.
- **RN-25** — Aggregates stay hidden below 5 answers.
- **RN-29** — **The follow-up question (`judgment_prompt`) is a closed choice, never a text field.**
  The `judgment` travels alongside the answer and is published immediately whenever the main question
  does not require review — an open field there would be a second piece of visitor free text, live and
  unmoderated, exactly what RN-24 permits exactly once. Both labels come from the prompt itself, which
  either offers them ("good or bad") or is a yes/no question. Recorded in F-06.

---

## 15. Architecture decisions (ADR)

A record of the deliberate exceptions to the Wise* framework and of the choices that should not be reopened without a new reason.

**ADR-01 — No multi-tenancy.** The framework requires `company_id` and per-company RLS on every table. Here there is a single guide, two curators and no customer. Authorization is a curator allowlist. *Reason: forcing tenancy would be ceremony without function.*

**ADR-02 — Product in English, en-US format.** The framework requires a PT-BR UI and Brazilian formatting. The guide covers Austin, its users are English speakers, and the 93 tags and 38 questions were already written in English. *Reason: the product is not Brazilian.*

> **Amendment of v2.9 (S09, Edu's decision):** the original wording kept internal documentation and
> conversation in Portuguese. **The documentation moved to English** — this bible, STATUS, BACKLOG,
> `CLAUDE.md`, `init.md`, the skills, the agents and the boot prompts. The reason is a new fact: the
> project is being prepared to change hands, and documentation the next maintainer cannot read is
> documentation that does not exist. What stays in Portuguese is the **conversation with Edu**, for
> the obvious reason. The session history in `docs/STATUS.md` was translated, not rewritten — it
> remains the record of what each past session observed.

**ADR-03 — `status` instead of `deleted_at`.** The framework requires soft deletes through `deleted_at`. Here `status` (`unreviewed | published | closed | hidden`) is more expressive and already covers the case. *Reason: a place that closed is different from a place that is hidden, and neither of them is "deleted".*

**ADR-04 — No GANTT, no DOMAIN_QUESTIONS, no per-feature spec, no agent pipeline.** The Wise* framework presupposes a SaaS with a customer and accountability. This project is personal, the PRD already serves as the spec, and the cost of the process would exceed the cost of the code. Kept: versioned migrations, `STATUS.md`, `BACKLOG.md` and this bible. *Reason: proportionality.*

**ADR-05 — MapLibre GL, not Google Maps.** Originally chosen because it swaps map styles at runtime, which the Codes depend on. Also kept because it does not charge per render. *Do not replace it with a Google embed.*

> **Amendment of v2.3 (F-03, S05):** the tile source is **OpenFreeMap** — free and keyless, the same
> logic as ADR-06's refusal to depend on a paid API. The version in use is **5.x**, not 6: v5 ships a
> single file with the worker embedded, whereas v6 builds the worker URL at runtime through string
> concatenation, which no bundler can see and which forced a manual `config.WORKER_URL`. The downgrade
> did **not** fix the rendering — `BL-29` is environmental, not a version problem. Before touching the
> map, read `BL-29` in the backlog: that path has already been walked end to end.

**ADR-06 — No Google Places API.** The original hydrated the 511 places against Places to obtain hours, phone numbers and price band. Cut: hours are solved by the directions button, and **price band is Michael's judgment, not Google's**. Quick-add geocoding uses Nominatim/OSM. *Reason: it eliminates a paid API, a key, a hydration script and an entire NFR, with no relevant loss.*

> **Amendment of v2.1 (F-01, approved by Edu):** the original wording required pre-classifying
> `cuisine` **and** `price_band` as `suggested`. Only `cuisine` was. `price_band` is a column on
> `places`, and §9.1 removed `price_band_source` — there is nowhere to mark that the value is a
> machine guess, so a guess would be indistinguishable from the curator's verdict in a judgment-layer
> field. Without Google Places, the only input would be the place's name. `price_band` is born null;
> a price suggestion, if it ever comes, is an affordance of the admin UI, not data written by the
> import.

**ADR-07 — Unlisted (`noindex`).** The guide is public and password-free, but not indexed by search engines. *Reason: field reports depend on the respondent having been to the place; Codes presuppose personal distribution; and the decision is reversible in minutes in one direction and slow and incomplete in the other.* Reconsider only if Michael asks. Consequence: no SEO work in the MVP.

**ADR-08 — No My Maps sync.** The original synchronized a Google map through KML. Mobile quick-add is already a complete capture path — the PRD itself admits this. *Reason: it was the feature with the highest complexity and the lowest marginal value.* The `sync_runs` table and the sabotage-test gate go with it.

> **Assessed again in S09, at Edu's request, and not reopened.** Two facts settle it. First, the
> places come from **Apple Maps**, not Google My Maps: syncing the latter would read an empty source
> unless Michael keeps one in parallel. Second, KML carries name, coordinates, description and layer,
> and **never** the judgment layer — so a sync brings more pins, and §1 says pins are precisely what
> has no value here. If it is ever built, the cheap version keys on a **link-shared map id** (a plain
> `GET` on the KML endpoint, no OAuth); the version keyed on an **account** has no official API and
> would break on its own. What is worth reconsidering is only the assumption behind the cut — that
> quick-add is a complete capture path — because S08 measured that Michael has not sat down to use
> any of our tools yet.

---

## 16. Pending decisions

| # | Decision | Status | Blocks |
|---|---|---|---|
| DP-01 | `destination` above `experience`? | ✅ Resolved — makes no difference, parallel summits (RN-04) | — |
| DP-02 | Singleton cities: pairs, grouped or suppressed? | ✅ Resolved — display as pairs | — |
| DP-03 | Public names of the tiers | ✅ Resolved — editable in the admin (RN-12) | — |
| DP-04 | `Hype trap` public or admin? | ✅ Resolved — admin-only (RN-14) | — |
| DP-05 | Indexable link? | ✅ Resolved — unlisted (ADR-07) | — |
| DP-06 | Does Michael want to appear — face, taste profile, an "about" page? | 🔴 Open | Copy and tone. Does not block the build |
| DP-07 | Voice notes per place | 🔴 Open | Outside the MVP; a candidate for a future phase |
| DP-08 | The 28 conflicts, 15 unclassified and 4 outside the crossing | 🔴 Open — depends on Michael | Publication of those specific places |

---

## 17. How the CLI uses this document

1. **Session boot:** read `.claude/CLAUDE.md` → this bible → `docs/STATUS.md` → `docs/BACKLOG.md`.
2. **Before writing code:** confirm with Edu which feature is in focus. Never start without confirmation.
3. **Question about behavior:** §14 (business rules).
4. **Question about the schema:** §9 — and confirm against the live database through MCP before writing SQL.
5. **Question about why something is not in the project:** §15 (ADRs) before proposing it again.
6. **On closing a feature:** update `STATUS.md`; anything newly pending goes to `BACKLOG.md`.
7. **The original PRD** (`docs/files/`) is origin material, not source of truth. Where it disagrees with this bible, this bible wins.

> **The judgment layer — `tier`, `starred`, `the_dish`, `curator_note`, `story`, `last_visited` and the tag assignments — is the only irreplaceable data in the system.** Any automated routine writing to those fields needs explicit authorization.
