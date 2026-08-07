import type { Place } from '@/types'

/**
 * Roulette — lands on one place, weighted toward the curator's own verdict.
 *
 * Two rules it must not break:
 *
 *   It spins over the *filtered* result, never the whole city (PRD §9.6). A
 *   visitor who filtered to vegetarian must never be handed a steakhouse.
 *
 *   It is an additive shortcut. Nothing in the guide is reachable only through
 *   it (RN-11) — every place it can land on is already in the list behind it.
 *
 * The weights are deliberately gentle. A `fair` place still comes up often
 * enough to feel like chance rather than a ranked list with extra steps; if
 * the star always won, this would just be "show me the top pick".
 */
export const ROULETTE_WEIGHTS = {
  starred: 6,
  destination: 3,
  experience: 3,
  cool: 2,
  fair: 1,
  untiered: 1,
} as const

export function rouletteWeight(place: Place): number {
  if (place.starred) return ROULETTE_WEIGHTS.starred

  switch (place.tier) {
    case 'destination':
      return ROULETTE_WEIGHTS.destination
    case 'experience':
      return ROULETTE_WEIGHTS.experience
    case 'cool':
      return ROULETTE_WEIGHTS.cool
    case 'fair':
      return ROULETTE_WEIGHTS.fair
    default:
      // Tiers are data (RN-12), so an unknown slug is not an error — a tier the
      // curator adds tomorrow weighs the same as no tier until it is weighted.
      return ROULETTE_WEIGHTS.untiered
  }
}

/**
 * One weighted draw.
 *
 * `excludeId` is what makes "spin again" mean something: landing on the same
 * place twice in a row reads as a broken button, not as chance. It is dropped
 * when it would leave nothing to choose from.
 *
 * `random` is injected so the draw is a pure function of its inputs, which is
 * the only way to test a die roll.
 */
export function spinRoulette(
  places: Place[],
  options: { excludeId?: string | null; random?: () => number } = {},
): Place | null {
  const { excludeId = null, random = Math.random } = options

  const pool = places.filter((place) => place.id !== excludeId)
  const candidates = pool.length ? pool : places
  if (!candidates.length) return null

  const total = candidates.reduce((sum, place) => sum + rouletteWeight(place), 0)
  let ticket = random() * total

  for (const place of candidates) {
    ticket -= rouletteWeight(place)
    if (ticket <= 0) return place
  }

  // Floating-point drift only, but the fallback keeps the return non-null.
  return candidates[candidates.length - 1]
}
