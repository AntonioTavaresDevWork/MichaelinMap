import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import { placesKey } from '@/hooks/use-places'
import type { PlaceTag, Tag, TagFacet } from '@/types'

export const tagsKey = ['tags'] as const
export const placeTagsKey = ['place-tags'] as const

/** Display order of the facets in the editor. Cuisine first — it is the one that matters most. */
export const FACET_ORDER: TagFacet[] = [
  'cuisine',
  'format',
  'occasion',
  'vibe',
  'logistics',
  'dietary',
  'character',
]

export const FACET_LABEL: Record<TagFacet, string> = {
  cuisine: 'Cuisine',
  format: 'Format',
  occasion: 'Occasion',
  vibe: 'Vibe',
  logistics: 'Logistics',
  dietary: 'Dietary',
  character: 'Character',
}

/**
 * The full controlled vocabulary, admin-only tags included.
 *
 * A curator session sees all 94; the public policy hides the admin-only ones
 * (RN-14), so this same query returns 93 to a visitor. Nothing here needs to
 * filter by hand.
 */
export function useTags() {
  return useQuery({
    queryKey: tagsKey,
    queryFn: async (): Promise<Tag[]> => {
      const { data, error } = await supabase
        .from('tags')
        .select('*')
        .order('facet')
        .order('sort_order')

      if (error) throw error
      return data ?? []
    },
  })
}

/** Every assignment, for both the editor and the list's tag-derived filters. */
export function usePlaceTags() {
  return useQuery({
    queryKey: placeTagsKey,
    queryFn: async (): Promise<PlaceTag[]> => {
      const { data, error } = await supabase.from('place_tags').select('*')

      if (error) throw error
      return data ?? []
    },
  })
}

function useTagMutation<TVars, TResult = void>(fn: (vars: TVars) => Promise<TResult>) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: fn,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: placeTagsKey })
      // The list filters on "has no cuisine tag", so it depends on assignments.
      queryClient.invalidateQueries({ queryKey: placesKey })
    },
  })
}

/**
 * RLS does not raise — it disappears rows.
 *
 * An UPDATE the policy blocks matches zero rows and PostgREST answers success.
 * With a stale session (`is_curator()` is false the moment the JWT stops
 * refreshing) a write that changed nothing returns green, and the interface
 * reports a number that never happened. This is the same failure shape S09
 * recorded for a commit that never landed while looking exactly like one that
 * did, so every write here asks for its rows back and counts them.
 */
function assertWritten(rows: unknown[] | null, expected: number): number {
  const written = rows?.length ?? 0

  if (written === 0) {
    throw new Error(
      'Nothing was written — your session may have expired. Sign out, sign back in, and try again.',
    )
  }

  if (written < expected) {
    throw new Error(
      `Only ${written} of ${expected} were written. Reload and check before trying again.`,
    )
  }

  return written
}

/**
 * Assigning always writes `source = 'curator'`.
 *
 * A curator touching a tag is the judgment layer being exercised — the whole
 * point of the admin. `suggested` is written only by the import, never here,
 * which is what keeps the two distinguishable (RN-15).
 */
export function useAssignTag() {
  return useTagMutation(async ({ placeId, tagId }: { placeId: string; tagId: string }) => {
    const { data, error } = await supabase
      .from('place_tags')
      .upsert(
        { place_id: placeId, tag_id: tagId, source: 'curator' },
        { onConflict: 'place_id,tag_id' },
      )
      .select('place_id')

    if (error) throw error
    assertWritten(data, 1)
  })
}

export function useRemoveTag() {
  return useTagMutation(async ({ placeId, tagId }: { placeId: string; tagId: string }) => {
    const { data, error } = await supabase
      .from('place_tags')
      .delete()
      .eq('place_id', placeId)
      .eq('tag_id', tagId)
      .select('place_id')

    if (error) throw error
    assertWritten(data, 1)
  })
}

/**
 * Promotes a machine guess to a curator call, in place.
 *
 * Kept separate from assign so the intent reads clearly at the call site: this
 * is the curator agreeing with the import, not creating something new.
 */
export function useConfirmSuggestion() {
  return useTagMutation(async ({ placeId, tagId }: { placeId: string; tagId: string }) => {
    const { data, error } = await supabase
      .from('place_tags')
      .update({ source: 'curator' })
      .eq('place_id', placeId)
      .eq('tag_id', tagId)
      .select('place_id')

    if (error) throw error
    assertWritten(data, 1)
  })
}

/**
 * Confirms one tag across many places at once.
 *
 * The queue is only workable in batches: a hundred unrelated suggestions is a
 * hundred decisions, while "every place suggested as Tacos" is one decision with
 * one mental model loaded. This is the curator exercising judgment on a group,
 * not a routine writing to the judgment layer on its own.
 *
 * Two guards, both in the statement rather than in the caller. `source` is
 * matched as well as set, so the update is idempotent and can never overwrite a
 * call the curator already made; and it is a single round trip, so a slow
 * connection cannot leave half a batch confirmed.
 */
export function useConfirmSuggestions() {
  return useTagMutation(
    async ({ tagId, placeIds }: { tagId: string; placeIds: string[] }): Promise<number> => {
      if (!placeIds.length) return 0

      const { data, error } = await supabase
        .from('place_tags')
        .update({ source: 'curator' })
        .eq('tag_id', tagId)
        .eq('source', 'suggested')
        .in('place_id', placeIds)
        // `.select()` is what makes the write verifiable: without it PostgREST
        // returns 204 and the caller cannot tell a blocked update from a done one.
        .select('place_id')

      if (error) throw error
      return assertWritten(data, placeIds.length)
    },
  )
}
