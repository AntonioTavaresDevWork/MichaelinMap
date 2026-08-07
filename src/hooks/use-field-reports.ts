import { useCallback, useMemo, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import type { AnswerValue } from '@/lib/field-reports'
import type { FieldReportAggregate, Question } from '@/types'

/**
 * The visitor's side of field reports.
 *
 * Everything a visitor writes goes through `rpc_submit_field_report()` — there
 * is no INSERT policy on the table and `anon` has no INSERT grant either, so
 * the RPC is not a convenience wrapper, it is the only door (RN-23). It derives
 * the status, caps free text at 40 characters and rate-limits by session.
 */

const SESSION_KEY = 'mm.session'
const ANSWERED_KEY = 'mm.answered'

function readStorage(key: string): string | null {
  try {
    return globalThis.localStorage?.getItem(key) ?? null
  } catch {
    // Private browsing throws. A guide that cannot remember still works.
    return null
  }
}

function writeStorage(key: string, value: string): void {
  try {
    globalThis.localStorage?.setItem(key, value)
  } catch {
    /* see readStorage */
  }
}

/**
 * A stable opaque id for this browser.
 *
 * It carries no identity and is never shown — the server only uses it to stop
 * one bored visitor answering the same question twice and to hold the hourly
 * rate limit. Losing it costs nothing but a second chance to answer.
 */
export function sessionHash(): string {
  const existing = readStorage(SESSION_KEY)
  if (existing) return existing

  const fresh = globalThis.crypto?.randomUUID?.() ?? `s-${Date.now()}-${Math.random().toString(36).slice(2)}`
  writeStorage(SESSION_KEY, fresh)
  return fresh
}

function answeredKey(placeId: string, questionId: string): string {
  return `${placeId}:${questionId}`
}

function readAnswered(): string[] {
  const raw = readStorage(ANSWERED_KEY)
  if (!raw) return []

  try {
    const parsed: unknown = JSON.parse(raw)
    return Array.isArray(parsed) ? parsed.filter((v): v is string => typeof v === 'string') : []
  } catch {
    return []
  }
}

/**
 * What this browser had already answered *when the page opened*.
 *
 * The server knows too — it rejects a duplicate — but the visitor cannot read
 * it back: their own pending answers are invisible under RLS, which only
 * publishes `status = 'published'`. So the form asks locally before asking the
 * server, and a cleared browser simply gets rejected instead of confused.
 *
 * WHY the answer is a snapshot rather than live state: the panel drops answered
 * questions from the list, so a reactive predicate would unmount a question the
 * instant it was answered and take its receipt down with it. Answering during
 * this visit has to leave the card standing long enough to read what happened
 * to it; only a previous visit hides the question outright.
 */
export function useAnsweredQuestions() {
  const [atOpen] = useState<string[]>(readAnswered)

  const remember = useCallback((placeId: string, questionId: string) => {
    const next = [...new Set([...readAnswered(), answeredKey(placeId, questionId)])]
    writeStorage(ANSWERED_KEY, JSON.stringify(next))
  }, [])

  const answeredBefore = useCallback(
    (placeId: string, questionId: string) => atOpen.includes(answeredKey(placeId, questionId)),
    [atOpen],
  )

  return { answeredBefore, remember }
}

export function useQuestions() {
  return useQuery({
    queryKey: ['public', 'questions'],
    queryFn: async (): Promise<Question[]> => {
      const { data, error } = await supabase.from('questions').select('*').eq('active', true)
      if (error) throw error
      return data ?? []
    },
    // The 38 questions change about never. No point re-fetching per place.
    staleTime: 15 * 60 * 1000,
  })
}

/** Published aggregates for one place. The view itself withholds anything under n=5. */
export function usePlaceAggregates(placeId: string | undefined) {
  return useQuery({
    queryKey: ['public', 'aggregates', placeId],
    enabled: Boolean(placeId),
    queryFn: async (): Promise<FieldReportAggregate[]> => {
      const { data, error } = await supabase
        .from('field_report_aggregates')
        .select('*')
        .eq('place_id', placeId)

      if (error) throw error
      return data ?? []
    },
  })
}

/**
 * How many published answers each question has for this place.
 *
 * Not the aggregate — that stays sealed until five (RN-25). This is only the
 * counter that keeps a place from reading as untouched, which is the whole
 * reason the curator seeds the first answers (bible §10).
 */
export function usePlaceReportCounts(placeId: string | undefined) {
  const query = useQuery({
    queryKey: ['public', 'report-counts', placeId],
    enabled: Boolean(placeId),
    queryFn: async (): Promise<string[]> => {
      const { data, error } = await supabase
        .from('field_reports')
        .select('question_id')
        .eq('place_id', placeId)
        .eq('status', 'published')

      if (error) throw error
      return (data ?? []).map((row) => row.question_id as string)
    },
  })

  const counts = useMemo(() => {
    const map = new Map<string, number>()
    for (const questionId of query.data ?? []) {
      map.set(questionId, (map.get(questionId) ?? 0) + 1)
    }
    return map
  }, [query.data])

  return { ...query, counts }
}

const SUBMIT_ERRORS: Record<string, string> = {
  invalid_answer: 'That answer did not come through. Try again.',
  place_not_available: 'This place is not taking reports right now.',
  question_not_available: 'That question has been retired.',
  rate_limited: 'That is a lot of reports for one hour. Come back later.',
  already_answered: 'You have already answered that one here.',
}

export interface SubmitFieldReportInput {
  placeId: string
  questionId: string
  value: AnswerValue
  judgment?: string | null
}

export function useSubmitFieldReport() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ placeId, questionId, value, judgment }: SubmitFieldReportInput) => {
      const { data, error } = await supabase.rpc('rpc_submit_field_report', {
        p_place_id: placeId,
        p_question_id: questionId,
        p_answer: { value },
        p_judgment: judgment ?? null,
        p_session_hash: sessionHash(),
      })

      if (error) throw error

      const result = (data ?? {}) as { ok?: boolean; error?: string; status?: string }
      if (!result.ok) {
        throw new Error(SUBMIT_ERRORS[result.error ?? ''] ?? 'That did not go through.')
      }

      return result.status === 'pending' ? 'pending' : 'published'
    },
    onSuccess: (_status, variables) => {
      void queryClient.invalidateQueries({ queryKey: ['public', 'aggregates', variables.placeId] })
      void queryClient.invalidateQueries({ queryKey: ['public', 'report-counts', variables.placeId] })
    },
  })
}
