# Product Requirements Document
## Michaelin Map

**Version:** 1.0
**Date:** 2026-08-05
**Status:** Ready for build
**Supersedes:** all prior PRD drafts

**Companion documents:** Tag Taxonomy & Data Model Specification · Field Reports Specification · Build Plan · `CLAUDE.md` · `PLAN.md` · `sql/schema.sql`

---

## 1. Summary

A public, read-only, globally scoped web guide to places — restaurants, bars, food trucks, shops, hotels, parks and attractions — curated by a single critic. Every entry carries an explicit quality tier and a set of filterable tags describing not just what a place is, but what it is *for*.

The authority model is a Michelin guide, not Yelp: one consistent voice, a scarce opinionated scale, no crowd average, no ratings from strangers. Layered on top is a deliberate streak of personality — joke tags, novelty interactions, a code system that transforms the interface at runtime, and absurdist visitor field reports.

**The curator's judgment is the product.** Everything else is delivery mechanism.

---

## 2. Problem

The curator has accumulated 511 saved places across three countries, organised into nineteen Apple Maps guides. Sharing that is close to useless: a map of pins transmits coordinates and nothing else. The recipient gets hundreds of dots and no way to answer the only question they have, which is *where should I go*.

The value isn't the pins. It's the judgment — which place is worth travelling for, which is famous and disappointing, which single dish justifies an otherwise unremarkable restaurant, which swimming hole is worth the drive in August. None of that survives sharing a link.

Worse, the judgment is *already there* and invisible. The nineteen guides encode a disciplined three-tier restaurant scale, a two-tier bar scale, a scarce top-favourites star, and a not-yet-visited list — all structurally present in the data, none of it legible to anyone but him.

This product makes that judgment transmissible.

---

## 3. Product definition

A single-curator city guide. Global in structure, with depth following wherever the curator spends time — today Austin holds roughly ninety percent of entries, but the architecture treats every city as a peer.

Three things distinguish it from a directory:

**An explicit, scarce scale.** Every visited place carries exactly one tier, and a small fraction carry a star. Scarcity is the whole mechanism; if a third of the list were top-tier, the scale would mean nothing.

**Tags describing purpose, not just category.** Cuisine and price are table stakes. *First date*, *bring your parents*, *hangover triage*, and *air conditioning that actually works* are the reason someone opens this instead of a search engine.

**Deliberate personality.** This is not a minimalist utility that happens to be charming. The novelty layer is a stated requirement, because the product's real payload is the curator's voice.

---

## 4. Users

**Visitors (primary).** People the curator shares the link with. No account, no sign-in. They arrive cold, often on a phone, and need to reach a decision quickly. Two established contexts:

- *Solo deciding.* Someone with an hour to fill. Wants a fast answer, not a browse.
- *Out-of-towners planning a trip.* Someone travelling to a city the curator knows. Wants a plan, not a filter panel. This context drives the Trip Builder requirement.

Group-at-the-table decision-making was explicitly ruled out as a primary context, which lowers the priority of head-to-head comparison features.

**The curator (single).** Adds and edits places, assigns tiers and tags, writes notes, creates codes, reviews field reports. Accesses a private admin area. He is the only person who can write to the guide.

There is no third role. No contributors, no moderators, no submissions.

### 4.1 The demo context

A stated success condition is that showing the guide to a specific person makes that person feel closer to the curator and think well of him. This reframes the product: it is a **personality artifact** whose payload is judgment and voice, with utility as the delivery mechanism — not a utility that happens to be charming.

Consequence for prioritisation: the Codes feature, the Story field, and the curator's written voice matter more than incremental filter sophistication.

---

## 5. Scope

### In scope for v1

- City selection gate, then map and synchronized list per city
- Place type gate distinguishing eating from doing
- Faceted filtering with live counts and custom empty states
- Place detail leading with tier, star, dish and note
- Novelty interactions: Roulette, I'm Hungry Now, Bad Idea, Settle It
- Codes engine — curator-created runtime interface transformations
- Field reports — constrained-input visitor questions with aggregate display
- Trip Builder for multi-day visitors
- Personal shortlist, stored locally
- Admin: authenticated CRUD, mobile quick-add, review queue, tier distribution, staleness list
- One-time bulk load of 511 places
- Google My Maps KML sync for ongoing capture

### Out of scope

| Excluded | Reason |
|---|---|
| Visitor accounts or sign-in | Read-only product; the shortlist lives in local storage |
| Reviews, ratings, star scores, comments, or any input on quality | Single-critic model is the premise. **Scoped exception:** field reports — constrained, non-evaluative, aggregated, structurally incapable of producing a rating |
| Reservations, ordering, delivery | Hand off to the venue or a maps app |
| Native mobile apps | Responsive web is sufficient |
| Curator-uploaded photography | Places API imagery in v1 |
| Re-solving the Apple Maps import | Settled; see §11 |

---

## 6. The judgment model

The core of the product. Reverse-engineered from the curator's own nineteen guides rather than designed, because the guides turned out to encode a consistent system already.

### 6.1 Evidence

Across 511 places, the three restaurant guides — Destination (43), Experience Spots (36), Fair Restaurants (156) — overlap each other by **exactly zero**. Perfect mutual exclusivity across 235 places is not accidental; it is a scale.

Top Faves (22) overlaps all three tiers (8 / 9 / 2) but overlaps the Try List by **zero**. So it is not a fourth tier — it is an honour applied *on top of* a tier, never awarded to a place the curator hasn't visited.

Cool Bars (31) and Fair Bars (46) share exactly one place: a second, parallel two-tier scale for bars.

### 6.2 The model

| Layer | Field | Values | Rule |
|---|---|---|---|
| **Tier** | `tier` | Restaurants: `destination` › `experience` › `fair`. Bars: `cool` › `fair` | Exactly one for visited, rated types. Null otherwise |
| **Star** | `starred` | boolean | Cross-cuts tiers. Currently 22 of 511 (4%). The scarce top honour |
| **Status** | `visited` | boolean | `false` = Try List. Cannot be tiered or starred |

Both constraints are enforced at database level, not merely in application logic. The curator's discipline becomes the schema's guarantee.

### 6.3 Why this replaces earlier proposals

An earlier draft proposed borrowing Michelin's own phrasing — *worth a special journey / a detour / a stop*. The curator's own tiers are better on every axis: they are his words, already consistently applied to 235 places, and adopting them means the migration ships with judgment populated rather than 511 blank fields awaiting his input.

### 6.4 Negative verdicts

The taxonomy retains a *Hype trap* value for famous, crowded, disappointing places. Negative verdicts are what make positive ones credible, and telling someone where **not** to go is a service no rating-average platform performs. Pending curator decision on whether this is public or admin-only.

### 6.5 Scarcity governance

`destination` and `starred` must remain scarce. Admin surfaces a live distribution so drift is visible. Target: starred under 5% of published places.

---

## 7. Place types

The guide is not restaurant-only. Roughly ninety non-food places — parks, caverns, swimming holes, spas, theatres, shops, hotels, groceries — sit alongside the food entries. Outdoors overlaps the food guides by 2 of 65, confirming a genuinely separate domain rather than an edge case.

| Type | Count | Tiered |
|---|---|---|
| Restaurant | 273 | Yes — 3 tiers |
| Bar | 91 | Yes — 2 tiers |
| Outdoors & attraction | 65 | No |
| Food truck | 23 | No |
| Dessert | 16 | No |
| Grocery | 14 | No |
| Hotel | 6 | No |
| Winery | 5 | No |
| Shop | 3 | No |
| Unclassified | 15 | — |

**Place type acts as a second gate** alongside city. "Where should I eat" and "what should I do" are different sessions, and mixing a state park into a restaurant filter result is noise. Untiered types still carry the star, which becomes their primary quality signal.

---

## 8. Geography

Three levels, all derived from coordinates with curator override.

| Level | Cardinality | Role |
|---|---|---|
| Country | Exactly 1 | Grouping only |
| City / metro | Exactly 1 | **The primary gate** |
| Area | 0 or 1 | Neighbourhood; null below density threshold |

**City is a gate, not a filter.** Nobody browses every place on Earth. The visitor chooses a city first and every other facet operates within it. Cities present as equals with entry counts shown; Austin will visibly dominate by volume, but no city is privileged in the interface.

**Areas exist only where density justifies them** — roughly fifteen entries. Austin gets East Austin, Rainey, South Congress and the rest; Oxfordshire's three places get no area filter at all. The hierarchy degrades gracefully rather than rendering empty controls.

Current cities: Austin 466, St. Augustine 15, Jacksonville 8, Los Angeles 4, Oxfordshire 3, Dallas–Fort Worth 3, Fernando de Noronha 2, Waco 2, plus seven singletons.

---

## 9. Feature specifications

### 9.1 City gate

First screen. All cities listed with counts, alphabetical, presented as peers. Optional *nearest to me* shortcut using browser geolocation. Last choice remembered in local storage so returning visitors skip it.

### 9.2 Place type gate

Secondary selection: eating, drinking, or doing. Skippable — a visitor who ignores it sees everything.

### 9.3 Map and list

Split view on desktop: map one side, filtered list the other, hovering a list item highlights its pin. Mobile is map-first with a draggable list sheet.

**One filter state object**, shared by both views. Never two. Filter state serialises to the URL so any view is shareable.

Pin styling encodes tier and star, so the best places are visually distinct without opening anything.

### 9.4 Place detail

Leads with **tier, star, the dish, and the curator's note** — not the address. Hours, price and location are supporting information below.

Where a place has a `story` — why it matters to him personally, as distinct from why it's good — that is given prominence. This field is the highest-leverage element for the demo context in §4.1 and costs one column.

Last-visited date shown when older than roughly eighteen months, so visitors can weigh staleness. Directions hand off to the visitor's own maps app.

### 9.5 Filtering

Facets render as collapsible groups: **cuisine, price, area, occasion, format, vibe, logistics, dietary, tier** — literal first, then situational. Character tags sit in a visually separated row below, signalling they are a different kind of thing.

**OR within a facet, AND across facets.** Selecting Tacos and BBQ shows both; adding East Austin narrows to East Austin tacos and East Austin barbecue.

Every option displays a live result count. Options that would return zero are **disabled, not hidden**, so visitors see what exists without hitting dead ends.

When a combination returns nothing, the empty state gets specific custom copy. This is the highest-value place in the product to be funny, because it is the exact moment a visitor would otherwise leave.

### 9.6 Novelty interactions

| Feature | Behaviour |
|---|---|
| **Roulette** | Lands on one place, weighted toward higher tiers and stars, respecting active filters |
| **I'm Hungry Now** | One tap: open now, near the visitor, ranked by tier |
| **Bad Idea** | Surfaces character-tagged and late-night entries |
| **Settle It** | Two places head to head, bracket until one survives. Lower priority — its group-decision justification was ruled out in §4 |

All must respect active filters. A visitor filtered to vegetarian options must never be handed a steakhouse.

### 9.7 Codes

A curator-defined string that transforms the interface when entered. Each code is a database row with optional, combinable effects: theme colours and map style, banner message, pin restyling, pre-applied filter, highlighted places. Optional start and end dates; an active flag for instant disabling.

**Codes are data, not code.** The curator creates a new one for every person he shows the guide to, forever, without developer involvement. This is the feature that most directly serves §4.1.

**Codes never remove content.** They restyle, reorder, highlight and add messages. They do not hide places from someone without the code.

**Input surface.** Desktop uses a type-anywhere listener with no visible field, which makes it feel like a secret. Mobile reveals a text input on long-press of the logo, since there is no ambient keyboard.

### 9.8 Field reports

Visitors who have been somewhere answer two or three randomly drawn questions carrying no information about quality — food temperature in Fahrenheit, chair colour, distance to the nearest body of water, ceiling height in hands.

The absurdity is load-bearing. Conventional comments would flatten the curator's tier into one opinion among many; questions on an orthogonal axis cannot compete with it. Participation without dilution.

Inputs are constrained — number, colour, slider, choice, yes/no, compound — which also eliminates the moderation burden that normally makes open input unworkable at this scale. Four of thirty-eight questions require short free text because their answer space is unbounded; those are capped at 40 characters, insert as `pending`, and publish only on curator approval.

**The aggregate is the feature**, rendered with deadpan scientific seriousness and hidden below five responses. The curator seeds his own answers so nothing launches at zero.

One question — *the dish you would order again* — is the only place visitor input meaningfully informs curator judgment, and surfaces separately in admin.

Fully specified in the companion Field Reports document.

### 9.9 Trip Builder

For the out-of-towner context. Input: a city and a number of days. Output: a plan with breakfast, lunch and dinner slots plus one or two non-food entries per day, geographically clustered so no day crosses the city twice, tiers mixed, and no two places of the same cuisine back to back.

Output is editable and shareable via encoded URL.

### 9.10 Personal shortlist

Visitors may save places to a local shortlist. Stored in browser local storage — no account, no server-side state. Shareable via encoded URL.

**Architectural note.** Codes, curated lists and the personal shortlist are the same primitive: *a named set of places with an optional note and optional styling*. Implementing a single `Collection` concept yields all three — the curator's are code-activated and themed, the visitor's are local and shareable.

### 9.11 Admin

Single-user authentication. Functions: place CRUD, tag assignment with cardinality enforcement, tier and star assignment, dish/note/story editing, code management, field report review, status management.

**Mobile quick-add is the primary capture path, not an afterthought.** The curator's capture moment is standing outside a venue with his phone. He searches a name, picks from Places API results, and tags it immediately. This must beat opening Google My Maps.

Two data-quality affordances build early:

- **Tier distribution display** — live counts per tier and star, so grade inflation is visible.
- **Staleness list** — places not visited in over eighteen months.

---

## 10. Data model

Full DDL in `sql/schema.sql`. Summary in `CLAUDE.md`. Key tables: `places`, `tags`, `place_tags`, `codes`, `questions`, `field_reports`, `sync_runs`.

Two integrity rules are enforced by database constraint rather than application logic:

- `tier_requires_visit` — an unvisited place cannot carry a tier
- `star_requires_visit` — an unvisited place cannot be starred

Row Level Security restricts public reads to `status = 'published'`. All imported places land as `unreviewed`, so nothing is publicly visible until the curator has reviewed it. An accidental deploy cannot expose the 42 not-yet-visited places as if they were recommendations.

---

## 11. Import and sync

### 11.1 Resolved

The one-time extraction is complete: nineteen Apple Maps guides decoded to CSV, merged to 511 unique places with guide membership preserved as an audit column.

Ongoing capture uses **Google My Maps**, synced via its KML export endpoint (`maps/d/kml?mid=<MAP_ID>&forcekml=1`) — a plain HTTP GET returning structured XML. No headless browser, no third-party converter, no scraping.

### 11.2 Sync is additive, never authoritative

A sync run may insert new places as `unreviewed` and flag places that vanished upstream. It must **never** write to `tier`, `starred`, `the_dish`, `curator_note`, `story`, `last_visited`, or any tag assignment. Places missing upstream are flagged, never auto-deleted.

This is non-negotiable: the judgment layer is the only irreplaceable data in the system.

### 11.3 Rejected approaches

Recorded so they are not re-proposed. Apple provides no export, no guide-reading API, and disallows automated access to its maps domain; an Apple guide link cannot be obtained programmatically; driving third-party converters with a headless browser was rejected after the previous tool in that category shut down mid-2026; Google Maps *saved lists* have no API; Waze and Beli were evaluated and rejected as sources.

---

## 12. Current data state and known issues

511 unique places. Tiers: destination 43, experience 36, fair 198, cool 30. Starred 22. Not visited 42.

**Three issues requiring curator resolution, not silent developer fixes:**

1. **28 conflicts.** Places carrying both a tier and Try List membership — rated somewhere unvisited. Import drops the tier and flags them; each needs the curator to confirm he has been, or agree the tier was aspirational.
2. **15 unclassified.** Thirteen are Try-List-only, saved without categorisation; two are Fernando de Noronha entries, one of which is an airport and probably not a recommendation.
3. **8 singleton cities.** Waco, Seattle, San Diego, Belton, Schertz, Mountain Home, Rochester, Essex Junction. Show as peer cities, fold the Texas ones into a Central Texas bucket, or suppress below a threshold.

---

## 13. Non-functional requirements

**Performance.** Sub-two-second first meaningful paint on a mid-range phone over 4G. Map tiles lazy-loaded; place data paginated per city.

**Cost.** Google Places is billed per request. Hydration happens at creation and on a schedule, **never on page load**. All derived data is stored in Postgres and served from there. MapLibre carries no per-render billing.

**Resilience.** The database is the system of record, not My Maps. Losing the sync endpoint degrades convenience, not data — admin quick-add remains a complete capture path.

**Accessibility.** Keyboard-navigable filters, sufficient contrast in all code themes, and map information available in the list view for screen-reader users.

---

## 14. Design principles

**Personality is a feature; discoverability is the floor.** Three enforcing rules:

1. Every published place is reachable through at least one literal facet — cuisine, city, place type, or price. A place findable only via a character tag is a bug.
2. Novelty interactions are additive shortcuts. Nothing is reachable exclusively through Roulette or a code.
3. Codes never remove content.

**Opinions are scarce or worthless.** Governed by §6.5.

**The decision is the job.** Success is not time on site. Success is a visitor choosing somewhere and leaving.

**Validation applies at promotion, not insert.** Imported and synced places arrive bare. Enforcing full validation on insert would make both impossible.

---

## 15. Success criteria

| Criterion | Target |
|---|---|
| Curator adds a fully tagged place from a phone | Under 60 seconds |
| Cold visitor reaches a decision | Under 2 minutes |
| Curator creates a code unassisted | Under 2 minutes, no developer |
| Starred share of published places | Under 5% |
| Published places reachable by a literal facet | 100% |
| Sync run damaging curated fields | Zero, verified by test |
| Free-text answers published without review | Zero |

---

## 16. Open questions

| # | Question | Blocks |
|---|---|---|
| 1 | Is `destination` genuinely above `experience`? Inferred from trade usage, not confirmed | Public tier labels |
| 2 | Public-facing tier names — the curator may rename all five | Phase 4 |
| 3 | Singleton cities: peers, grouped, or suppressed | Phase 1 |
| 4 | Is *Hype trap* public or admin-only | Phase 2 |
| 5 | Link privacy: public and indexable, or unlisted | Phase 9 |
| 6 | Does the curator want to be visible — face, taste profile, an about page | Copy and tone throughout |
| 7 | Voice notes per place — high personality payload, moderate scope | Deferred decision |

Questions 1 and 2 need the curator, not the developer, and cause rework if deferred past data curation.

---

## 17. Build sequence

Nine phases in `PLAN.md`. Order matters: filtering precedes both the novelty layer and codes, because a code applying a preset filter is meaningless before filters exist.

The mandatory gate is Phase 5's exit test — a deliberately corrupted sync run against a tagged, published place, confirming every curated field survives untouched.
