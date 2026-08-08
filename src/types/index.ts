/**
 * Database types — Michaelin Map
 *
 * Field names are snake_case because these objects are populated by direct
 * `select('*')` queries; supabase-js does not convert casing. See CLAUDE.md.
 *
 * Mirrors the schema documented in docs/MICHAELINMAP_BIBLE.md §9.
 */

export type PlaceType =
  | 'restaurant'
  | 'bar'
  | 'food_truck'
  | 'dessert'
  | 'winery'
  | 'hotel'
  | 'grocery'
  | 'shop'
  | 'outdoors'
  | 'unclassified'

export type PlaceStatus = 'unreviewed' | 'published' | 'closed' | 'hidden'

export type PriceBand = '$' | '$$' | '$$$' | '$$$$'

export type TagFacet =
  | 'cuisine'
  | 'format'
  | 'occasion'
  | 'vibe'
  | 'logistics'
  | 'dietary'
  | 'character'

/** Machine-suggested tags are reviewable; curator-assigned ones are final. */
export type TagSource = 'curator' | 'suggested'

export type QuestionInputType =
  | 'number'
  | 'color'
  | 'slider'
  | 'single_choice'
  | 'yes_no'
  | 'compound'
  | 'text_short'

export type FieldReportStatus = 'published' | 'pending' | 'rejected'

/**
 * Tier is a plain string, not a union: tiers are editable data (RN-12) and the
 * curator may add or rename them without a deploy. Slugs below are the seeded
 * ones and are safe for ordering and pin styling, with a fallback.
 */
export const SEEDED_TIER_SLUGS = ['destination', 'experience', 'fair', 'cool'] as const

export interface Tier {
  slug: string
  label: string
  applies_to: PlaceType[]
  sort_order: number
  active: boolean
}

export interface Place {
  id: string
  name: string
  slug: string | null

  place_type: PlaceType
  tier: string | null
  starred: boolean
  visited: boolean
  status: PlaceStatus

  country: string | null
  city: string | null
  area: string | null
  lat: number | null
  lng: number | null
  address: string | null
  website: string | null
  price_band: PriceBand | null

  // The judgment layer — never written by automated routines. See CLAUDE.md.
  the_dish: string | null
  curator_note: string | null
  story: string | null
  last_visited: string | null

  apple_id: string | null
  source_guides: string[] | null
  source: string | null

  created_at: string
  updated_at: string
  updated_by: string | null
}

export interface Tag {
  id: string
  facet: TagFacet
  label: string
  slug: string
  is_derived: boolean
  /** Never surfaced to visitors, in any view (RN-14). `Hype trap` is the case. */
  admin_only: boolean
  sort_order: number
  active: boolean
}

export interface PlaceTag {
  place_id: string
  tag_id: string
  source: TagSource
  created_at: string
}

export interface Curator {
  user_id: string
  name: string
  created_at: string
}

/**
 * Map style tokens are *our* vocabulary, not the tile provider's.
 *
 * A code stores `dark`, not a URL: the curator picks a mood, and swapping tile
 * providers later stays a one-file change. Unknown values fall back rather than
 * break — see `mapStyleUrl()` in lib/code-effects.ts.
 */
export const MAP_STYLE_TOKENS = ['default', 'bright', 'minimal', 'dark', 'slate'] as const
export type MapStyleToken = (typeof MAP_STYLE_TOKENS)[number]

export interface CodeTheme {
  /** Hex. Everything else in the palette is derived from these. */
  primary?: string
  background?: string
  foreground?: string
  mapStyle?: string
}

export interface PinStyle {
  color?: string
  highlightColor?: string
  shape?: 'dot' | 'square'
}

/**
 * A preset filter is stored exactly as the guide serialises its filters to the
 * URL (RN-19): param → comma-joined values. That way the admin builds one with
 * `filtersToParams()` and the guide reads it back with `filtersFromParams()` —
 * the same two functions the address bar already round-trips through.
 */
export type PresetFilter = Record<string, string>

export interface Code {
  id: string
  code: string
  label: string | null
  message: string | null
  theme: CodeTheme | null
  pin_style: PinStyle | null
  preset_filter: PresetFilter | null
  highlighted_places: string[] | null
  starts_at: string | null
  ends_at: string | null
  active: boolean
  created_at: string
}

/**
 * What `rpc_redeem_code()` hands back — the code minus its bookkeeping.
 *
 * `id`, `active` and the date window never cross the wire: the server has
 * already applied them, and a visitor has no use for the row's identity.
 */
export interface RedeemedCode {
  code: string
  label: string | null
  message: string | null
  theme: CodeTheme | null
  pin_style: PinStyle | null
  preset_filter: PresetFilter | null
  highlighted_places: string[]
}

export interface Question {
  id: string
  prompt: string
  input_type: QuestionInputType
  unit_label: string | null
  options: string[] | null
  slider_labels: [string, string] | null
  judgment_prompt: string | null
  /** Drives the server-derived report status — the visitor never picks it (RN-23). */
  requires_review: boolean
  weight: number
  active: boolean
}

export interface FieldReport {
  id: string
  place_id: string
  question_id: string
  answer: { value: unknown }
  judgment: string | null
  status: FieldReportStatus
  session_hash: string | null
  submitted_at: string
}

/** Aggregated field reports. Hidden below five responses (RN-25). */
export interface FieldReportAggregate {
  place_id: string
  question_id: string
  prompt: string
  input_type: QuestionInputType
  unit_label: string | null
  n: number
  mean_value: number | null
  modal_value: string | null
}
