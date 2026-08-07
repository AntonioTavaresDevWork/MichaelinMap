import { useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import { slugify } from '@/lib/utils'
import type { Place, PlaceTag, Tag, Tier } from '@/types'

/**
 * The public read path.
 *
 * RLS already limits an anonymous caller to published rows, admin-only tags and
 * assignments on published places — these queries would return the same thing
 * without any predicate. The explicit `status` filter is here for the reader,
 * not the database: it makes the intent legible at the call site.
 */
export function usePublishedPlaces() {
  return useQuery({
    queryKey: ['public', 'places'],
    queryFn: async (): Promise<Place[]> => {
      const { data, error } = await supabase
        .from('places')
        .select('*')
        .eq('status', 'published')
        .order('name')

      if (error) throw error
      return data ?? []
    },
  })
}

export function usePublicVocabulary() {
  const tags = useQuery({
    queryKey: ['public', 'tags'],
    queryFn: async (): Promise<Tag[]> => {
      const { data, error } = await supabase.from('tags').select('*').eq('active', true)
      if (error) throw error
      return data ?? []
    },
  })

  const placeTags = useQuery({
    queryKey: ['public', 'place-tags'],
    queryFn: async (): Promise<PlaceTag[]> => {
      const { data, error } = await supabase.from('place_tags').select('*')
      if (error) throw error
      return data ?? []
    },
  })

  const tiers = useQuery({
    queryKey: ['public', 'tiers'],
    queryFn: async (): Promise<Tier[]> => {
      const { data, error } = await supabase
        .from('tiers')
        .select('*')
        .eq('active', true)
        .order('sort_order')

      if (error) throw error
      return data ?? []
    },
  })

  return { tags, placeTags, tiers }
}

export interface CityEntry {
  name: string
  slug: string
  count: number
}

/**
 * Cities as peers, never ranked by importance (DP-02).
 *
 * A city with one place sits in the same list as Austin with hundreds; the
 * count is shown so nobody clicks into a single pin expecting a guide. Sorted
 * by size only so the list is predictable, alphabetical within equal counts.
 */
export function useCities(places: Place[] | undefined): CityEntry[] {
  return useMemo(() => {
    const counts = new Map<string, number>()
    for (const place of places ?? []) {
      if (!place.city) continue
      counts.set(place.city, (counts.get(place.city) ?? 0) + 1)
    }

    return [...counts.entries()]
      .map(([name, count]) => ({ name, slug: slugify(name), count }))
      .sort((a, b) => b.count - a.count || a.name.localeCompare(b.name))
  }, [places])
}

/** Tags a visitor may see on a place, in facet order, admin-only already excluded by RLS. */
export function usePlaceTagLabels(
  placeId: string | undefined,
  tags: Tag[] | undefined,
  placeTags: PlaceTag[] | undefined,
): Tag[] {
  return useMemo(() => {
    if (!placeId || !tags || !placeTags) return []
    const byId = new Map(tags.map((tag) => [tag.id, tag]))

    return placeTags
      .filter((pt) => pt.place_id === placeId)
      .map((pt) => byId.get(pt.tag_id))
      .filter((tag): tag is Tag => Boolean(tag))
      .sort((a, b) => a.facet.localeCompare(b.facet) || a.sort_order - b.sort_order)
  }, [placeId, tags, placeTags])
}
