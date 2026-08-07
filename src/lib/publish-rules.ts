import type { Place, PlaceType } from '@/types'

export interface PublishIssue {
  /** `block` stops the promotion; `warn` is surfaced but the curator decides. */
  level: 'block' | 'warn'
  message: string
}

/** Types where a cuisine tag is the difference between findable and buried. */
const FOOD_TYPES: PlaceType[] = ['restaurant', 'bar', 'food_truck', 'dessert']

/**
 * What has to be true before a place goes public.
 *
 * Validation applies at promotion, never at insert (RN-08) — the 511 imported
 * rows arrived with no tier, no tags and sometimes no type, and enforcing this
 * earlier would have made the import impossible.
 *
 * Blocks are things the guide cannot be correct without. Warnings are things
 * the curator is allowed to knowingly accept: he is the authority, and a
 * blocker he disagrees with would just teach him to work around the admin.
 */
export function publishIssues(
  place: Pick<Place, 'city' | 'place_type' | 'price_band' | 'visited' | 'tier' | 'starred'>,
  cuisineTagCount: number,
): PublishIssue[] {
  const issues: PublishIssue[] = []

  // RN-09, and a database constraint besides. Without a city the place cannot
  // sit behind any city gate, so nobody would ever reach it.
  if (!place.city) {
    issues.push({ level: 'block', message: 'A published place needs a city.' })
  }

  // RN-10. `unclassified` is the absence of a type, so the type facet leads
  // nowhere: the place would only be reachable by browsing an entire city.
  if (place.place_type === 'unclassified') {
    issues.push({
      level: 'block',
      message: 'Give it a place type first — “unclassified” is not a facet anyone can filter by.',
    })
  }

  // RN-01 / RN-02 are enforced by database constraints, but failing here gives
  // a sentence instead of a constraint violation.
  if (!place.visited && place.tier) {
    issues.push({ level: 'block', message: 'A place you have not visited cannot carry a tier.' })
  }
  if (!place.visited && place.starred) {
    issues.push({ level: 'block', message: 'A place you have not visited cannot be starred.' })
  }

  // RN-10 again, softer. A restaurant with no cuisine and no price is reachable
  // only by city and type — technically findable, practically buried.
  if (FOOD_TYPES.includes(place.place_type) && cuisineTagCount === 0 && !place.price_band) {
    issues.push({
      level: 'warn',
      message: 'No cuisine tag and no price band. It will only surface by city and type.',
    })
  }

  return issues
}

export function canPublish(issues: PublishIssue[]): boolean {
  return !issues.some((issue) => issue.level === 'block')
}
