# PLAN.md — Michaelin Map Build

Work top to bottom. Each phase has an exit test; do not advance until it passes.

---

## Phase 0 — Foundation

- [ ] Vite + React + TypeScript + Tailwind scaffold
- [ ] Supabase project created; `sql/schema.sql` and `sql/seed.sql` run
- [ ] Env vars wired; typed Supabase client in `src/lib/supabase.ts`
- [ ] Generate DB types (`supabase gen types typescript`)
- [ ] `scripts/import-places.ts` loads the master CSV as `unreviewed`

**Exit:** 511 rows in `places`, 93 in `tags`, 38 in `questions`. Import run is idempotent — running twice does not duplicate.

---

## Phase 1 — Public read

- [ ] City gate: all cities listed with counts, presented as equals, optional "nearest to me"
- [ ] Last city choice remembered in `localStorage`
- [ ] MapLibre map with pins; pin style encodes tier and star
- [ ] List view synced to map; hover highlights pin
- [ ] Place detail: leads with tier, star, dish, curator note — **not** the address
- [ ] Directions hand off to the visitor's own maps app
- [ ] Responsive to 375px; map-first with draggable list sheet on mobile

**Exit:** A stranger opens the link on a phone, picks a city, browses, and reaches directions.

---

## Phase 2 — Filtering

- [ ] Place type filter (second gate — "eating" vs "doing")
- [ ] Faceted panel: cuisine, price, area, occasion, format, vibe, logistics, dietary, tier
- [ ] Area filter hidden entirely for cities under ~15 places
- [ ] Character tags in a visually separated row
- [ ] OR within a facet, AND across facets
- [ ] Live result counts; zero-result options disabled, not hidden
- [ ] Filter state in the URL
- [ ] Custom empty-state copy per impossible combination

**Exit:** All facets filter correctly. AND/OR semantics verified by test.

---

## Phase 3 — Admin

- [ ] Supabase Auth, single curator
- [ ] Place list with status and tier filters
- [ ] Create place via Google Places search-and-confirm; auto-populate address, coords, hours, price
- [ ] **Mobile quick-add screen** — this is the primary capture path, not an afterthought
- [ ] Tag pickers enforcing cardinality rules
- [ ] Tier, star, dish, note, story, last-visited editing
- [ ] Review queue for `unreviewed` places
- [ ] Tier distribution display (drift warning)
- [ ] Staleness list (`last_visited` over 18 months)

**Exit:** Curator adds a fully tagged place from a phone in under 60 seconds.

---

## Phase 4 — Data curation

- [ ] Hydrate all 511 places against Google Places (batched, rate-limited, cached)
- [ ] Reverse-geocode country and city; derive area by polygon for Austin only
- [ ] Resolve the 28 tier-plus-unvisited conflicts
- [ ] Classify the 15 unclassified places
- [ ] Curator works the review queue

**Exit:** Published places all pass validation. Time here is the curator's, not the developer's.

---

## Phase 5 — My Maps sync

- [ ] Scheduled fetch of `maps/d/kml?mid=<MAP_ID>&forcekml=1`
- [ ] KML parse; diff by coordinate and name
- [ ] New entries insert as `unreviewed`
- [ ] Vanished entries flagged, never deleted
- [ ] `sync_runs` logging; manual "sync now" in admin

**Exit test (mandatory):** run a deliberately corrupted sync against a tagged, published place. Tier, star, dish, note, story, last-visited, and tags must all survive untouched.

---

## Phase 6 — Novelty interactions

- [ ] Roulette — weighted toward higher tiers, respects active filters
- [ ] Settle It — head-to-head bracket
- [ ] I'm Hungry Now — open, nearby, ranked, one tap
- [ ] Bad Idea — surfaces character-tagged places

**Exit:** Each works under an active filter set without returning excluded places.

---

## Phase 7 — Codes

- [ ] Admin code management
- [ ] Runtime effects: theme, banner, pin restyle, preset filter, highlights
- [ ] MapLibre style swap on theme change
- [ ] Desktop: type-anywhere listener, no visible field
- [ ] Mobile: long-press logo reveals input
- [ ] Start/end dates and active flag honored

**Exit:** Curator creates a code in admin and activates it live, with no developer involvement.

---

## Phase 8 — Field reports

- [ ] Random draw of 2–3 questions per visit
- [ ] All seven input types rendered
- [ ] Aggregates via `field_report_aggregates`, hidden under n=5
- [ ] Free-text answers insert as `pending`
- [ ] Admin review queue; "dish you would order again" surfaced separately
- [ ] Rate limiting by session hash

**Exit:** Report filed in under 30 seconds. No free-text answer reaches the public site unapproved.

---

## Phase 9 — Polish

- [ ] Empty-state and microcopy pass
- [ ] Mobile performance; map tile budget
- [ ] Cross-browser check
- [ ] Personal shortlist (local only)
- [ ] Rehearse the demo path end to end
