import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import type { FieldReportStatus, QuestionInputType } from '@/types'

/**
 * The curator's side of field reports.
 *
 * Plain table access, not the RPC: `field_reports_curator_all` already gates
 * every verb behind `is_curator()`, and the RPC exists to constrain visitors,
 * not the person who owns the guide. Approving is the only way a free-text
 * answer ever reaches the public (RN-24).
 */

export const reportQueueKey = ['admin', 'field-reports'] as const

/** A report with the two rows it only ever makes sense beside. */
export interface QueuedReport {
  id: string
  place_id: string
  question_id: string
  answer: { value: unknown }
  judgment: string | null
  status: FieldReportStatus
  session_hash: string | null
  submitted_at: string
  places: { name: string; slug: string | null } | null
  questions: { prompt: string; input_type: QuestionInputType; unit_label: string | null } | null
}

export function useReportQueue() {
  return useQuery({
    queryKey: reportQueueKey,
    queryFn: async (): Promise<QueuedReport[]> => {
      const { data, error } = await supabase
        .from('field_reports')
        .select('*, places(name, slug), questions(prompt, input_type, unit_label)')
        .order('submitted_at', { ascending: false })

      if (error) throw error
      return (data ?? []) as QueuedReport[]
    },
  })
}

export function useModerateReport() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: FieldReportStatus }) => {
      const { error } = await supabase.from('field_reports').update({ status }).eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: reportQueueKey })
      // The public aggregate and its counter both move when a report is approved.
      void queryClient.invalidateQueries({ queryKey: ['public', 'aggregates'] })
      void queryClient.invalidateQueries({ queryKey: ['public', 'report-counts'] })
    },
  })
}

/**
 * Marks an answer as the curator's own.
 *
 * Kept as a literal rather than a per-browser id so seeds stay identifiable
 * forever — `where session_hash = 'curator'` undoes a seeding session, and the
 * visitor-facing duplicate guard has nothing to collide with.
 */
export const CURATOR_SESSION = 'curator'

export interface SeedAnswer {
  placeId: string
  questionId: string
  value: unknown
  judgment?: string | null
}

/**
 * Seeds the curator's own answers so nothing is born at zero (bible §10).
 *
 * Written straight to the table, published on arrival: the review step exists
 * to stand between a stranger's free text and the guide, and the curator is the
 * person that step defers to. He is also the only one who may write these —
 * every value here is an observation somebody actually made in the room.
 */
export function useSeedFieldReports() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (answers: SeedAnswer[]) => {
      if (!answers.length) return 0

      const rows = answers.map((answer) => ({
        place_id: answer.placeId,
        question_id: answer.questionId,
        answer: { value: answer.value },
        judgment: answer.judgment ?? null,
        status: 'published' as const,
        session_hash: CURATOR_SESSION,
      }))

      const { error } = await supabase.from('field_reports').insert(rows)
      if (error) throw error
      return rows.length
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: reportQueueKey })
      void queryClient.invalidateQueries({ queryKey: ['public', 'aggregates'] })
      void queryClient.invalidateQueries({ queryKey: ['public', 'report-counts'] })
    },
  })
}
