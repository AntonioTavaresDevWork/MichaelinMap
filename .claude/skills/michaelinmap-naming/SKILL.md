---
name: michaelinmap-naming
description: Naming conventions in Michaelin Map. DB snake_case, frontend camelCase, PascalCase components, kebab-case files, en-US number/date/currency formatting. Use when naming a table, column, RPC, component, hook or file, or when formatting numeric/date/currency values in the UI.
---

# Naming Conventions — Michaelin Map

> The examples are **real** objects from this database. If a name cited here no longer exists,
> validate against the live schema through MCP before using it.

## Summary table

| Layer | Convention | Real examples |
|---|---|---|
| DB tables | `snake_case` (plural) | `places`, `tags`, `place_tags`, `field_reports`, `curators` |
| DB columns | `snake_case` | `place_type`, `apple_id`, `source_guides`, `admin_only`, `requires_review` |
| SQL functions/RPCs | `snake_case`, `rpc_` prefix when exposed to the client | `rpc_redeem_code`, `rpc_submit_field_report`, `is_curator`, `touch_updated_at` |
| Frontend TS variables | `camelCase` | `placeId`, `selectedTags`, `cityGate` |
| React components | `PascalCase` | `PlaceCard`, `FilterPanel`, `ProtectedRoute` |
| Hooks | `camelCase` with a `use` prefix | `useSession`, `usePlaces`, `useFilterState` |
| Files (all of them) | `kebab-case` | `place-card.tsx`, `use-session.ts`, `admin-layout.tsx` |
| TS types | `PascalCase` | `Place`, `Tag`, `FieldReport`, `PlaceType` |
| Constants | `UPPER_SNAKE_CASE` | `SEEDED_TIER_SLUGS` |

> ⚠️ A component file is **kebab-case** (`place-card.tsx`), NOT `PlaceCard.tsx`. Common mistake.

## DB ↔ frontend conversion

The Supabase JS client does **not** convert snake_case → camelCase. The conversion, where it exists,
happens **at the data-access boundary** — in the hook — and is not scattered through the components.

**This project's practical rule:** a type populated by a direct `select('*')`, with no explicit
mapping, is named in `snake_case`, exactly like the database. That is what `src/types/index.ts` does:

```typescript
export interface Place {
  place_type: PlaceType   // not placeType — it comes raw from select('*')
  apple_id: string | null
  source_guides: string[] | null
}
```

Declaring `placeType` when the database returns `place_type` results in `undefined` at runtime,
silently.

## en-US format — numbers, dates, currency

**ADR-02: the product is in English and uses en-US formatting.** The guide covers Austin and the
audience is English-speaking. No Brazilian formatting in the UI.

| Type | Format | Example |
|---|---|---|
| Number | Comma thousands, period decimal | `1,234,567.89` |
| Date in UI | `MM/DD/YYYY` | `08/06/2026` |
| Date + time in UI | `MM/DD/YYYY h:mm a` | `08/06/2026 2:30 PM` |
| Date in DB | ISO 8601 TIMESTAMPTZ | `2026-08-06T17:30:00Z` |
| Currency | `$` prefix, 2 decimals | `$1,234.56` |
| Price band | `$` to `$$$$` | `$$` |

Use `Intl.NumberFormat('en-US', …)` and `Intl.DateTimeFormat('en-US', …)`. The formatters already
exist in `src/lib/utils.ts` — use those before writing another one.

> **Language by surface:** UI, tags, questions, error messages and copy in **English**. Everything
> written into this repository — bible, STATUS, BACKLOG, code comments, variable names — in
> **English** too, since the ADR-02 amendment in S09. The conversation with Edu stays in PT-BR.

## Semantic prefixes

| Prefix | Use | Example in this project |
|---|---|---|
| `rpc_` | SQL function exposed to the client through `supabase.rpc()` | `rpc_redeem_code` |
| `is_` | Boolean function | `is_curator` |
| `touch_` | Trigger function that stamps a timestamp | `touch_updated_at` |
| `use` | React hook | `useSession` |

Wise* template prefixes that **do not apply here**: `has_` (there are no capabilities),
`get_user_company_id` and the like (there is no multi-tenancy — ADR-01).

## Domain vocabulary — use the right terms

Confusing these terms produces bugs and confuses Michael:

| Term | What it is | What it is NOT |
|---|---|---|
| **tier** | `destination`, `experience`, `fair`, `cool`. Editable data, not a constant | Not the star |
| **starred** | An honor that **crosses** the tiers, 22 of 511 | Not one more tier (RN-03) |
| **visited** | `false` = Try List | Not `status` |
| **status** | `unreviewed \| published \| closed \| hidden` | Not a soft delete through `deleted_at` (ADR-03) |
| **facet** | A grouping of tags: `cuisine`, `vibe`, `character`… | Not the tag |
| **area** | The municipality or neighborhood inside the gate city | Not the city |

## Anti-patterns — do not do this

- ❌ Brazilian formatting in the UI: `1.234,56`, `22/05/2026`, `R$` — violates ADR-02
- ❌ Mixing languages in one identifier: `lugarName` (pick `placeName`)
- ❌ Camel-casing an entire acronym: `bbqTag` ✅, `bBQTag` ❌
- ❌ Inconsistent plurals: a DB table is always plural (`places`), a component singular (`PlaceCard`)
- ❌ Manual formatting: `value.toFixed(2)` for currency — use `Intl.NumberFormat`
- ❌ Inventing `company_id` or any tenant column — it does not exist (ADR-01)
