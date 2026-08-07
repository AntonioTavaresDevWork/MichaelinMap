import { slugify } from '@/lib/utils'
import type { Place, PlaceTag, PlaceType, Tag, TagFacet } from '@/types'

/**
 * The public faceted filter.
 *
 * Two rules shape everything here:
 *
 *   OR inside a facet, AND between facets (RN-16). Tacos + BBQ shows both;
 *   adding East Austin narrows to tacos and BBQ in East Austin.
 *
 *   Every option carries a live count, and an option that would return zero is
 *   disabled rather than hidden (RN-17) — the visitor learns the shape of the
 *   guide from what is greyed out.
 *
 * The URL is the source of truth (RN-19), and each facet is its own parameter:
 *
 *   ?type=restaurant&star=1&cuisine=tacos,bbq
 *
 * That mirrors RN-16 in the address bar — commas are the OR, separate keys are
 * the AND — and it sidesteps a real ambiguity: tag slugs are unique per facet,
 * not globally (`tags` is UNIQUE (facet, slug)), so a bare list of slugs could
 * not be resolved back to tags.
 *
 * **The visitor cannot filter by tier.** Removed by Edu's call in S08: the
 * guide no longer presents Destination / Experience / Fair / Cool as a rating
 * system a visitor navigates by. The tier itself is untouched — it still labels
 * each place in the list and on its own page, still orders the list, and the
 * curator still assigns it. What is gone is the *facet*, and with it the `tier`
 * URL parameter: a filter with no control on screen would narrow the guide
 * invisibly, which is the exact failure RN-27 exists to prevent.
 */

export const TAG_FACETS: TagFacet[] = [
  'cuisine',
  'format',
  'occasion',
  'vibe',
  'logistics',
  'dietary',
  'character',
]

/** Structural facets, kept apart from tag facets because they read off columns. */
export type StructuralFacetKey = 'type' | 'area' | 'star'
export type FacetKey = StructuralFacetKey | TagFacet

export interface GuideFilters {
  type: PlaceType[]
  /** Slugified area names, so the URL stays readable. */
  area: string[]
  star: boolean
  /** Facet → tag slugs. Absent key means the facet is not filtered. */
  tags: Partial<Record<TagFacet, string[]>>
}

export const EMPTY_FILTERS: GuideFilters = {
  type: [],
  area: [],
  star: false,
  tags: {},
}

/**
 * Areas only appear where density justifies them (RN-18). Below this, a city
 * renders no area control at all rather than a control with two options —
 * the hierarchy degrades in silence (bible §8).
 */
export const AREA_MIN_PLACES = 15

const PLACE_TYPE_LABELS: Record<PlaceType, string> = {
  restaurant: 'Restaurant',
  bar: 'Bar',
  food_truck: 'Food truck',
  dessert: 'Dessert',
  winery: 'Winery',
  hotel: 'Hotel',
  grocery: 'Grocery',
  shop: 'Shop',
  outdoors: 'Outdoors',
  unclassified: 'Unclassified',
}

export function placeTypeLabel(type: PlaceType): string {
  return PLACE_TYPE_LABELS[type] ?? type
}

const FACET_TITLES: Record<FacetKey, string> = {
  type: 'Type',
  area: 'Area',
  star: 'Top picks',
  cuisine: 'Cuisine',
  format: 'Format',
  occasion: 'Occasion',
  vibe: 'Vibe',
  logistics: 'Practical',
  dietary: 'Dietary',
  character: 'Character',
}

// ---------------------------------------------------------------------------
// URL round trip
// ---------------------------------------------------------------------------

function readList(params: URLSearchParams, key: string): string[] {
  const raw = params.get(key)
  if (!raw) return []
  return raw
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean)
}

export function filtersToParams(filters: GuideFilters): URLSearchParams {
  const params = new URLSearchParams()

  if (filters.type.length) params.set('type', filters.type.join(','))
  if (filters.area.length) params.set('area', filters.area.join(','))
  if (filters.star) params.set('star', '1')

  for (const facet of TAG_FACETS) {
    const selected = filters.tags[facet]
    if (selected?.length) params.set(facet, selected.join(','))
  }

  return params
}

export function filtersFromParams(params: URLSearchParams): GuideFilters {
  const tags: Partial<Record<TagFacet, string[]>> = {}
  for (const facet of TAG_FACETS) {
    const selected = readList(params, facet)
    if (selected.length) tags[facet] = selected
  }

  return {
    // A stale `?tier=` from a link shared before S08 is simply ignored here.
    type: readList(params, 'type') as PlaceType[],
    area: readList(params, 'area'),
    star: params.get('star') === '1',
    tags,
  }
}

export function hasActiveFilters(filters: GuideFilters): boolean {
  return (
    filters.type.length > 0 ||
    filters.area.length > 0 ||
    filters.star ||
    TAG_FACETS.some((facet) => (filters.tags[facet]?.length ?? 0) > 0)
  )
}

export function countActiveFilters(filters: GuideFilters): number {
  return (
    filters.type.length +
    filters.area.length +
    (filters.star ? 1 : 0) +
    TAG_FACETS.reduce((total, facet) => total + (filters.tags[facet]?.length ?? 0), 0)
  )
}

/** Immutable toggle of one option, so callers never mutate filter state in place. */
export function toggleFacetValue(
  filters: GuideFilters,
  facet: FacetKey,
  value: string,
): GuideFilters {
  if (facet === 'star') return { ...filters, star: !filters.star }

  if (facet === 'type' || facet === 'area') {
    const current = filters[facet] as string[]
    const next = current.includes(value)
      ? current.filter((entry) => entry !== value)
      : [...current, value]
    return { ...filters, [facet]: next }
  }

  const current = filters.tags[facet] ?? []
  const next = current.includes(value)
    ? current.filter((entry) => entry !== value)
    : [...current, value]

  const tags = { ...filters.tags }
  if (next.length) tags[facet] = next
  else delete tags[facet]

  return { ...filters, tags }
}

// ---------------------------------------------------------------------------
// Matching
// ---------------------------------------------------------------------------

export interface GuideIndex {
  /** place id → `facet:slug` tokens the visitor is allowed to see. */
  tokens: Map<string, Set<string>>
}

export function buildGuideIndex(
  placeTags: PlaceTag[] | undefined,
  tags: Tag[] | undefined,
): GuideIndex {
  const byId = new Map((tags ?? []).map((tag) => [tag.id, tag]))
  const tokens = new Map<string, Set<string>>()

  for (const assignment of placeTags ?? []) {
    const tag = byId.get(assignment.tag_id)

    // RLS already withholds inactive and admin-only tags from a visitor. The
    // check is repeated because RN-14 admits no exception on any surface, and
    // a filter that leaks `Hype trap` would leak it as a *count*, silently.
    if (!tag || !tag.active || tag.admin_only) continue

    let set = tokens.get(assignment.place_id)
    if (!set) {
      set = new Set<string>()
      tokens.set(assignment.place_id, set)
    }
    set.add(`${tag.facet}:${tag.slug}`)
  }

  return { tokens }
}

type Predicate = (place: Place) => boolean

/** The predicate for one facet, or null when that facet is not filtering. */
function predicateFor(
  facet: FacetKey,
  filters: GuideFilters,
  index: GuideIndex,
): Predicate | null {
  switch (facet) {
    case 'star':
      return filters.star ? (place) => place.starred : null

    case 'type':
      return filters.type.length ? (place) => filters.type.includes(place.place_type) : null

    case 'area':
      return filters.area.length
        ? (place) => place.area !== null && filters.area.includes(slugify(place.area))
        : null

    default: {
      const selected = filters.tags[facet] ?? []
      if (!selected.length) return null

      return (place) => {
        const set = index.tokens.get(place.id)
        if (!set) return false
        return selected.some((slug) => set.has(`${facet}:${slug}`))
      }
    }
  }
}

const ALL_FACETS: FacetKey[] = ['type', 'area', 'star', ...TAG_FACETS]

/**
 * Places matching every active facet.
 *
 * `except` drops one facet from the conjunction — that is what makes a count
 * live: the number beside "Tacos" is how many places you would get if you added
 * tacos to what is already selected, not how many exist in the city.
 */
export function applyGuideFilters(
  places: Place[],
  filters: GuideFilters,
  index: GuideIndex,
  except?: FacetKey,
): Place[] {
  const predicates = ALL_FACETS.filter((facet) => facet !== except)
    .map((facet) => predicateFor(facet, filters, index))
    .filter((predicate): predicate is Predicate => predicate !== null)

  if (!predicates.length) return places
  return places.filter((place) => predicates.every((predicate) => predicate(place)))
}

// ---------------------------------------------------------------------------
// Facet construction
// ---------------------------------------------------------------------------

export interface FacetOption {
  value: string
  label: string
  count: number
  selected: boolean
  /** Zero results under the current selection. Rendered greyed out, not removed. */
  disabled: boolean
}

export interface FacetGroup {
  key: FacetKey
  title: string
  options: FacetOption[]
  /** A star is one switch, not a list — the panel renders it differently. */
  single: boolean
}

interface BuildArgs {
  /** Every published place in the city, before any facet is applied. */
  places: Place[]
  filters: GuideFilters
  index: GuideIndex
  tags: Tag[] | undefined
}

/**
 * The facets worth showing, in reading order.
 *
 * A facet whose options are all absent from the data is not built at all. This
 * is not RN-17 being bent — that rule governs an *option* inside a facet, and
 * it still holds. An entire facet with nothing behind it is the case bible §8
 * already settled for areas: degrade in silence rather than render an empty
 * control. It matters right now, because six of the seven tag facets have no
 * assignments yet; they will appear on their own as the curator tags, with no
 * deploy, which is the point of tags being data (RN-13).
 */
export function buildFacetGroups({
  places,
  filters,
  index,
  tags,
}: BuildArgs): FacetGroup[] {
  const groups: FacetGroup[] = []

  const countWith = (facet: FacetKey, predicate: Predicate): number => {
    const base = applyGuideFilters(places, filters, index, facet)
    return base.filter(predicate).length
  }

  const push = (key: FacetKey, options: FacetOption[], single = false) => {
    if (!options.length) return
    groups.push({ key, title: FACET_TITLES[key], options, single })
  }

  // Star — the honour that crosses tiers (RN-03), so it stands on its own.
  const starCount = countWith('star', (place) => place.starred)
  if (places.some((place) => place.starred)) {
    push(
      'star',
      [
        {
          value: '1',
          label: 'Top picks only',
          count: starCount,
          selected: filters.star,
          disabled: starCount === 0 && !filters.star,
        },
      ],
      true,
    )
  }

  // No tier facet. The star above is the only quality signal the visitor
  // filters by — which is already how the eight untiered place types have
  // always worked (RN-05), now applied to restaurants and bars as well.

  // Type — the second gate (bible §7).
  const typeCounts = new Map<PlaceType, number>()
  for (const place of places) {
    typeCounts.set(place.place_type, (typeCounts.get(place.place_type) ?? 0) + 1)
  }
  push(
    'type',
    [...typeCounts.keys()]
      .sort((a, b) => placeTypeLabel(a).localeCompare(placeTypeLabel(b)))
      .map((type) => {
        const count = countWith('type', (place) => place.place_type === type)
        return {
          value: type,
          label: placeTypeLabel(type),
          count,
          selected: filters.type.includes(type),
          disabled: count === 0 && !filters.type.includes(type),
        }
      }),
  )

  // Area — only where the city is dense enough to have neighbourhoods (RN-18).
  if (places.length >= AREA_MIN_PLACES) {
    const areaNames = new Map<string, string>()
    for (const place of places) {
      if (place.area) areaNames.set(slugify(place.area), place.area)
    }

    push(
      'area',
      [...areaNames.entries()]
        .sort((a, b) => a[1].localeCompare(b[1]))
        .map(([slug, label]) => {
          const count = countWith(
            'area',
            (place) => place.area !== null && slugify(place.area) === slug,
          )
          return {
            value: slug,
            label,
            count,
            selected: filters.area.includes(slug),
            disabled: count === 0 && !filters.area.includes(slug),
          }
        }),
    )
  }

  // Tag facets — built only from tags actually assigned in this city.
  const assignedTokens = new Set<string>()
  for (const place of places) {
    const set = index.tokens.get(place.id)
    if (set) for (const token of set) assignedTokens.add(token)
  }

  for (const facet of TAG_FACETS) {
    const facetTags = (tags ?? [])
      .filter((tag) => tag.facet === facet && assignedTokens.has(`${facet}:${tag.slug}`))
      .sort((a, b) => a.sort_order - b.sort_order || a.label.localeCompare(b.label))

    const selected = filters.tags[facet] ?? []

    push(
      facet,
      facetTags.map((tag) => {
        const count = countWith(facet, (place) =>
          Boolean(index.tokens.get(place.id)?.has(`${facet}:${tag.slug}`)),
        )
        return {
          value: tag.slug,
          label: tag.label,
          count,
          selected: selected.includes(tag.slug),
          disabled: count === 0 && !selected.includes(tag.slug),
        }
      }),
    )
  }

  return groups
}
