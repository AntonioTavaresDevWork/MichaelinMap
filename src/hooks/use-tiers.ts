import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import type { Tier } from '@/types'

export const tiersKey = ['tiers'] as const

/**
 * Tiers are editable data, not a code constant (RN-12), so the admin reads them
 * instead of hardcoding four slugs. `applies_to` drives which tiers the editor
 * suggests for a given place type — it never restricts, because the curator is
 * the authority (bible §9.2).
 */
export function useTiers() {
  return useQuery({
    queryKey: tiersKey,
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
}
