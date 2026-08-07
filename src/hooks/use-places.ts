import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import type { Place } from '@/types'

export const placesKey = ['places'] as const
export const placeKey = (slug: string) => ['place', slug] as const

/**
 * Every place, in one request.
 *
 * 511 rows is small enough that paging buys nothing and costs a lot: filtering
 * and live counts both become trivial once the whole set is in memory. Revisit
 * if the guide ever grows by an order of magnitude.
 */
export function usePlaces() {
  return useQuery({
    queryKey: placesKey,
    queryFn: async (): Promise<Place[]> => {
      const { data, error } = await supabase
        .from('places')
        .select('*')
        .order('name')

      if (error) throw error
      return data ?? []
    },
  })
}

export function usePlace(slug: string | undefined) {
  return useQuery({
    queryKey: placeKey(slug ?? ''),
    enabled: Boolean(slug),
    queryFn: async (): Promise<Place | null> => {
      const { data, error } = await supabase
        .from('places')
        .select('*')
        .eq('slug', slug!)
        .maybeSingle()

      if (error) throw error
      return data
    },
  })
}

/**
 * Fields a curator may edit. `id`, `slug`, `apple_id`, `source_guides` and the
 * timestamps are deliberately absent: they are provenance, not judgment, and
 * nothing in the admin should rewrite them.
 */
export type PlaceEdit = Partial<
  Pick<
    Place,
    | 'name'
    | 'place_type'
    | 'tier'
    | 'starred'
    | 'visited'
    | 'status'
    | 'country'
    | 'city'
    | 'area'
    | 'lat'
    | 'lng'
    | 'address'
    | 'website'
    | 'price_band'
    | 'the_dish'
    | 'curator_note'
    | 'story'
    | 'last_visited'
  >
>

/**
 * Everything quick-add is allowed to set.
 *
 * No tier, no star, no dish, no note: capture is not judgment. A place caught
 * on the street arrives as a pin with a name, and the verdict comes later in
 * the editor, once he has actually eaten there.
 */
export interface NewPlace {
  name: string
  slug: string
  place_type: Place['place_type']
  city: string | null
  area: string | null
  country: string | null
  address: string | null
  lat: number | null
  lng: number | null
  visited: boolean
}

/** First free slug for a name, disambiguating homonyms the way the import did. */
export function nextFreeSlug(base: string, taken: Set<string>): string {
  if (!taken.has(base)) return base
  let n = 2
  while (taken.has(`${base}-${n}`)) n += 1
  return `${base}-${n}`
}

export function useCreatePlace() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (place: NewPlace): Promise<Place> => {
      const { data: auth } = await supabase.auth.getUser()

      const { data, error } = await supabase
        .from('places')
        // status defaults to `unreviewed` (RN-07) and is deliberately not sent:
        // nothing captured on the street is public until it has been reviewed.
        .insert({ ...place, source: 'manual', updated_by: auth.user?.id ?? null })
        .select('*')
        .single()

      if (error) throw error
      return data as Place
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: placesKey }),
  })
}

export function useUpdatePlace() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, patch }: { id: string; patch: PlaceEdit }) => {
      // Stamps who touched the row last. With a single shared curator account
      // this records "a curator did it", not which person — see bible §4.
      const { data: auth } = await supabase.auth.getUser()

      const { data, error } = await supabase
        .from('places')
        .update({ ...patch, updated_by: auth.user?.id ?? null })
        .eq('id', id)
        .select('*')
        .single()

      if (error) throw error
      return data as Place
    },
    onSuccess: (place) => {
      // The list carries every field the editor can change, so it goes stale
      // on any save. Both keys are invalidated, never just the detail.
      queryClient.invalidateQueries({ queryKey: placesKey })
      if (place.slug) {
        queryClient.invalidateQueries({ queryKey: placeKey(place.slug) })
      }
    },
  })
}
