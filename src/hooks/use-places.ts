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
