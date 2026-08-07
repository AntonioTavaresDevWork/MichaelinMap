import { useMemo } from 'react'
import { Separator } from '@/components/ui/separator'
import { Skeleton } from '@/components/ui/skeleton'
import {
  formatAggregateValue,
  formatSampleSize,
  MIN_AGGREGATE_N,
  sampleQuestions,
} from '@/lib/field-reports'
import {
  sessionHash,
  useAnsweredQuestions,
  usePlaceAggregates,
  usePlaceReportCounts,
  useQuestions,
} from '@/hooks/use-field-reports'
import { FieldReportQuestion } from '@/components/public/field-report-form'
import type { FieldReportAggregate, Place } from '@/types'

/**
 * Field reports, at the bottom of the page and never above the verdict.
 *
 * The questions cannot ask whether the place was good (RN-22) — that axis
 * belongs to the curator alone, and putting an ambient-temperature readout
 * anywhere near his call would flatten one into the other. Down here it reads
 * as what it is: a straight-faced instrument panel bolted to the end of an
 * opinion.
 */
export function FieldReportPanel({ place }: { place: Place }) {
  const questions = useQuestions()
  const aggregates = usePlaceAggregates(place.id)
  const { counts, isLoading: countsLoading } = usePlaceReportCounts(place.id)
  const { answeredBefore, remember } = useAnsweredQuestions()

  // Seeded on place + browser: stable across renders and reloads, different for
  // the next person through the door. See sampleQuestions.
  const asked = useMemo(
    () => sampleQuestions(questions.data ?? [], `${place.id}:${sessionHash()}`),
    [questions.data, place.id],
  )

  const unanswered = asked.filter((question) => !answeredBefore(place.id, question.id))
  const published = aggregates.data ?? []

  if (questions.isLoading || countsLoading) {
    return (
      <>
        <Separator className="my-8" />
        <Skeleton className="h-32 w-full" />
      </>
    )
  }

  return (
    <section className="mt-4">
      <Separator className="my-8" />

      <h2 className="font-heading text-lg font-semibold tracking-tight">Field reports</h2>
      <p className="mt-1 max-w-prose text-sm text-muted-foreground">
        Measurements taken by people who were here. None of them say whether the place is any good —
        that is Michael&rsquo;s job, and he has already done it above.
      </p>

      {published.length > 0 && (
        <div className="mt-6 divide-y rounded-lg border">
          {published.map((row) => (
            <AggregateRow key={row.question_id} row={row} />
          ))}
        </div>
      )}

      {unanswered.length > 0 && (
        <div className="mt-6 flex flex-col gap-3">
          {published.length === 0 && (
            <p className="text-sm text-muted-foreground">
              Nothing is on the record here yet. A figure is published once {MIN_AGGREGATE_N} people
              have answered the same question.
            </p>
          )}

          {unanswered.map((question) => (
            <FieldReportQuestion
              key={question.id}
              placeId={place.id}
              question={question}
              count={counts.get(question.id) ?? 0}
              onAnswered={(questionId) => remember(place.id, questionId)}
            />
          ))}
        </div>
      )}

      {unanswered.length === 0 && (
        <p className="mt-6 text-sm text-muted-foreground">
          You have answered everything this place asked you. Try another one.
        </p>
      )}
    </section>
  )
}

/**
 * A published figure, rendered with a straight face.
 *
 * The comedy is in the seriousness — a mean ceiling height in hands, reported
 * to one decimal place with its sample size, is funnier than any wording could
 * make it (bible §10). So: no adjectives, no exclamation, tabular numerals.
 */
function AggregateRow({ row }: { row: FieldReportAggregate }) {
  const isColour = row.input_type === 'color'

  return (
    <div className="flex items-center justify-between gap-4 px-4 py-3">
      <span className="text-sm leading-snug">{row.prompt}</span>

      <span className="flex shrink-0 items-center gap-2 text-right">
        {isColour && row.modal_value && (
          <span
            className="size-4 rounded-sm border"
            style={{ backgroundColor: row.modal_value }}
            aria-hidden
          />
        )}
        <span className="font-mono text-sm tabular-nums">
          {formatAggregateValue(row)}
          {row.unit_label && ` ${row.unit_label}`}
        </span>
        <span className="w-14 text-right font-mono text-xs text-muted-foreground tabular-nums">
          {formatSampleSize(row.n)}
        </span>
      </span>
    </div>
  )
}
