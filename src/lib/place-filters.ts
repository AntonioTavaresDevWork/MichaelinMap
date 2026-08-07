import type { Place, PlaceStatus, PlaceTag, PlaceType, Tag } from '@/types'

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
}

export const DEFAULT_FILTERS: PlaceFilters = {
  q: '',
  status: 'all',
  type: 'all',
  tier: 'all',
  city: 'all',
  starred: 'all',
  flag: 'all',
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
}

export function buildTagIndex(placeTags: PlaceTag[], tags: Tag[]): TagIndex {
  const byPlace = new Map<string, PlaceTag[]>()
  for (const pt of placeTags) {
    const list = byPlace.get(pt.place_id)
    if (list) list.push(pt)
    else byPlace.set(pt.place_id, [pt])
  }

  const cuisineTagIds = new Set(tags.filter((t) => t.facet === 'cuisine').map((t) => t.id))

  return { byPlace, cuisineTagIds }
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

export function applyFilters(
  places: Place[],
  filters: PlaceFilters,
  index: TagIndex,
): Place[] {
  const needle = filters.q.trim().toLowerCase()

  return places.filter((place) => {
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
  })
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
