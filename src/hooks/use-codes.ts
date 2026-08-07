import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import type { Code } from '@/types'

export const codesKey = ['codes'] as const

/**
 * Codes are data, not code (PRD §9.7).
 *
 * The curator makes a new one for every person he shows the guide to, forever,
 * without a deploy — so this is ordinary CRUD on an ordinary table, and the
 * only reason it is admin-only is the `codes_curator_all` policy. Visitors
 * never read this table at all; they go through `rpc_redeem_code()` (RN-20).
 */
export function useCodes() {
  return useQuery({
    queryKey: codesKey,
    queryFn: async (): Promise<Code[]> => {
      const { data, error } = await supabase
        .from('codes')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      return data ?? []
    },
  })
}

/** Everything the editor writes. `id` and `created_at` belong to the database. */
export type CodeDraft = Omit<Code, 'id' | 'created_at'>

export function useCreateCode() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (draft: CodeDraft): Promise<Code> => {
      const { data, error } = await supabase.from('codes').insert(draft).select('*').single()
      if (error) throw error
      return data as Code
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: codesKey }),
  })
}

export function useUpdateCode() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, patch }: { id: string; patch: Partial<CodeDraft> }): Promise<Code> => {
      const { data, error } = await supabase
        .from('codes')
        .update(patch)
        .eq('id', id)
        .select('*')
        .single()

      if (error) throw error
      return data as Code
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: codesKey }),
  })
}

export function useDeleteCode() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (id: string) => {
      // Always by id. A code is cheap to recreate, and switching `active` off
      // is the usual way to retire one — this is for the ones typed wrong.
      const { error } = await supabase.from('codes').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: codesKey }),
  })
}
