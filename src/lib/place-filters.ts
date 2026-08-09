import type { Place, PlaceStatus, PlaceTag, PlaceType, Tag, TagFacet } from '@/types'

export type FlagFilter = 'all' | 'conflict' | 'no-cuisine' | 'untagged' | 'unvisited' | 'suggested'

export interface PlaceFilters {
  q: string
  status: PlaceStatus | 'all'
  type: PlaceType | 'all'
  /** A tier slug, `none` for places without one, or `all`. */
  tier: string
  city: string
  starred: 'all' | 'yes' | 'no'
  flag: FlagFilter
  /**
   * One tag, keyed `facet:slug`, or `all`.
   *
   * The compound key mirrors the table's `UNIQUE (facet, slug)` rather than
   * relying on slugs being unique on their own — they happen to be today, and
   * the schema does not promise it.
   */
  tag: string
  /** Narrows the tag above to a machine guess or a curator call. */
  tagSource: 'all' | 'suggested' | 'curator'
}

export const DEFAULT_FILTERS: PlaceFilters = {
  q: '',
  status: 'all',
  type: 'all',
  tier: 'all',
  city: 'all',
  starred: 'all',
  flag: 'all',
  tag: 'all',
  tagSource: 'all',
}

/** The `facet:slug` key a tag is addressed by in the filter and the URL. */
export function tagKey(tag: Pick<Tag, 'facet' | 'slug'>): string {
  return `${tag.facet}:${tag.slug}`
}

/** Marker the F-01 import wrote for the 28 places that carried a tier while unvisited. */
export const CONFLICT_MARKER = 'CONFLICT:TIER+UNVISITED'

/**
 * URL is the single source of truth for the filter, so any admin view is a link
 * you can send or bookmark. Defaults are omitted to keep the address readable.
 */
export function filtersToParams(filters: PlaceFilters): URLSearchParams {
  const params = new URLSearchParams()
  for (const [key, value] of Object.entries(filters)) {
    const fallback = DEFAULT_FILTERS[key as keyof PlaceFilters]
    if (value && value !== fallback) params.set(key, String(value))
  }
  return params
}

export function filtersFromParams(params: URLSearchParams): PlaceFilters {
  return {
    q: params.get('q') ?? DEFAULT_FILTERS.q,
    status: (params.get('status') as PlaceFilters['status']) ?? DEFAULT_FILTERS.status,
    type: (params.get('type') as PlaceFilters['type']) ?? DEFAULT_FILTERS.type,
    tier: params.get('tier') ?? DEFAULT_FILTERS.tier,
    city: params.get('city') ?? DEFAULT_FILTERS.city,
    starred: (params.get('starred') as PlaceFilters['starred']) ?? DEFAULT_FILTERS.starred,
    flag: (params.get('flag') as FlagFilter) ?? DEFAULT_FILTERS.flag,
    tag: params.get('tag') ?? DEFAULT_FILTERS.tag,
    tagSource:
      (params.get('tagSource') as PlaceFilters['tagSource']) ?? DEFAULT_FILTERS.tagSource,
  }
}

export function hasActiveFilters(filters: PlaceFilters): boolean {
  return (Object.keys(filters) as (keyof PlaceFilters)[]).some(
    (key) => filters[key] !== DEFAULT_FILTERS[key],
  )
}

/** Per-place tag facts, computed once so filtering and rendering share the work. */
export interface TagIndex {
  byPlace: Map<string, PlaceTag[]>
  cuisineTagIds: Set<string>
  /** `facet:slug` → tag id, so the filter can travel as a readable URL. */
  idByKey: Map<string, string>
}

export function buildTagIndex(placeTags: PlaceTag[], tags: Tag[]): TagIndex {
  const byPlace = new Map<string, PlaceTag[]>()
  for (const pt of placeTags) {
    const list = byPlace.get(pt.place_id)
    if (list) list.push(pt)
    else byPlace.set(pt.place_id, [pt])
  }

  const cuisineTagIds = new Set(tags.filter((t) => t.facet === 'cuisine').map((t) => t.id))
  const idByKey = new Map(tags.map((tag) => [tagKey(tag), tag.id]))

  return { byPlace, cuisineTagIds, idByKey }
}

/**
 * The assignment of the filtered tag on a place, if any.
 *
 * Shared by the filter and the bulk action so both agree on what "this place
 * carries this tag" means — the bulk bar counts exactly the rows it will write.
 */
export function assignmentFor(
  place: Place,
  filters: PlaceFilters,
  index: TagIndex,
): PlaceTag | null {
  if (filters.tag === 'all') return null

  const tagId = index.idByKey.get(filters.tag)
  if (!tagId) return null

  return (index.byPlace.get(place.id) ?? []).find((pt) => pt.tag_id === tagId) ?? null
}

function matchesFlag(place: Place, flag: FlagFilter, index: TagIndex): boolean {
  const assigned = index.byPlace.get(place.id) ?? []

  switch (flag) {
    case 'conflict':
      return place.source_guides?.includes(CONFLICT_MARKER) ?? false
    case 'no-cuisine':
      return !assigned.some((pt) => index.cuisineTagIds.has(pt.tag_id))
    case 'untagged':
      return assigned.length === 0
    case 'unvisited':
      return !place.visited
    case 'suggested':
      return assigned.some((pt) => pt.source === 'suggested')
    default:
      return true
  }
}

/**
 * Everything except the tag filter.
 *
 * Split out because the tag options need counts computed against the *other*
 * facets — counting against the tag filter itself would zero out every sibling
 * the moment one is picked.
 */
function matchesExceptTag(place: Place, filters: PlaceFilters, index: TagIndex): boolean {
  const needle = filters.q.trim().toLowerCase()

  if (needle && !place.name.toLowerCase().includes(needle)) return false
  if (filters.status !== 'all' && place.status !== filters.status) return false
  if (filters.type !== 'all' && place.place_type !== filters.type) return false

  if (filters.tier !== 'all') {
    if (filters.tier === 'none' ? place.tier !== null : place.tier !== filters.tier) return false
  }

  if (filters.city !== 'all' && place.city !== filters.city) return false
  if (filters.starred === 'yes' && !place.starred) return false
  if (filters.starred === 'no' && place.starred) return false
  if (!matchesFlag(place, filters.flag, index)) return false

  return true
}

export function applyFilters(
  places: Place[],
  filters: PlaceFilters,
  index: TagIndex,
): Place[] {
  return places.filter((place) => {
    if (!matchesExceptTag(place, filters, index)) return false

    if (filters.tag !== 'all') {
      // An unresolvable key returns nothing rather than everything: a stale
      // bookmark should show an empty list, not silently drop the filter and
      // look like the whole guide matched.
      if (!index.idByKey.has(filters.tag)) return false

      const assignment = assignmentFor(place, filters, index)
      if (!assignment) return false
      if (filters.tagSource !== 'all' && assignment.source !== filters.tagSource) return false
    }

    return true
  })
}

export interface TagOption {
  tag: Tag
  count: number
}

export interface TagOptionGroup {
  facet: TagFacet
  options: TagOption[]
}

/**
 * The tags worth offering, given everything else the curator has already
 * narrowed to.
 *
 * This is RN-26 and RN-17 borrowed from the public panel and pointed at the
 * admin: a facet with nothing behind it is not rendered, and an option that
 * would return zero is disabled rather than hidden. The list therefore narrows
 * itself when a place type is chosen — filtering to Restaurant stops offering
 * tags no restaurant carries — without anybody hardcoding which facets "belong"
 * to which type. That map would be a guess, and it would rot as tagging grows;
 * this grows with it instead.
 *
 * Counts respect `tagSource`, so narrowing to Suggested shows how much of each
 * tag is still a machine guess — which is the number the bulk bar acts on.
 */
export function tagOptions(
  places: Place[],
  filters: PlaceFilters,
  index: TagIndex,
  tags: Tag[],
  facetOrder: TagFacet[],
): TagOptionGroup[] {
  const pool = places.filter((place) => matchesExceptTag(place, filters, index))

  const counts = new Map<string, number>()
  for (const place of pool) {
    for (const pt of index.byPlace.get(place.id) ?? []) {
      if (filters.tagSource !== 'all' && pt.source !== filters.tagSource) continue
      counts.set(pt.tag_id, (counts.get(pt.tag_id) ?? 0) + 1)
    }
  }

  return facetOrder
    .map((facet) => ({
      facet,
      options: tags
        .filter((tag) => tag.facet === facet && tag.active)
        .map((tag) => ({ tag, count: counts.get(tag.id) ?? 0 }))
        // A tag nothing carries is noise in a 94-item list. The selected one
        // always survives, or picking it would erase the control that undoes it.
        .filter((option) => option.count > 0 || tagKey(option.tag) === filters.tag),
    }))
    .filter((group) => group.options.length > 0)
}

/** Cities present in the data, most populated first — mirrors the public city gate. */
export function cityOptions(places: Place[]): { city: string; count: number }[] {
  const counts = new Map<string, number>()
  for (const place of places) {
    if (!place.city) continue
    counts.set(place.city, (counts.get(place.city) ?? 0) + 1)
  }
  return [...counts.entries()]
    .map(([city, count]) => ({ city, count }))
    .sort((a, b) => b.count - a.count || a.city.localeCompare(b.city))
}
