import { useState } from 'react'
import { CheckIcon } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { cn } from '@/lib/utils'
import {
  isAnswerComplete,
  judgmentOptions,
  MIN_AGGREGATE_N,
  TEXT_ANSWER_MAX,
  type AnswerValue,
} from '@/lib/field-reports'
import { useSubmitFieldReport } from '@/hooks/use-field-reports'
import type { Question } from '@/types'

/**
 * One question, one answer, one receipt.
 *
 * Per-question rather than a single form with one submit: a visitor who only
 * wants to say how many televisions there were should not have to measure the
 * ceiling first. It also keeps a rejected answer from taking the other two down
 * with it.
 */
export function FieldReportQuestion({
  placeId,
  question,
  count,
  onAnswered,
}: {
  placeId: string
  question: Question
  count: number
  onAnswered: (questionId: string) => void
}) {
  const [value, setValue] = useState<AnswerValue>(question.input_type === 'slider' ? 50 : null)
  const [judgment, setJudgment] = useState<string | null>(null)
  const [done, setDone] = useState<'published' | 'pending' | null>(null)
  const submit = useSubmitFieldReport()

  // The tally as it stood before this visitor answered. A successful submit
  // invalidates the count query, so reading the live prop in the receipt would
  // add the new answer to a total that already contains it.
  const [countAtOpen] = useState(count)

  const complete = isAnswerComplete(question, value)

  function handleSubmit() {
    submit.mutate(
      { placeId, questionId: question.id, value, judgment },
      {
        onSuccess: (status) => {
          setDone(status)
          onAnswered(question.id)
        },
        onError: (error: Error) => toast.error(error.message),
      },
    )
  }

  if (done) {
    return (
      <div className="flex items-start gap-2 rounded-lg border border-dashed bg-card px-4 py-3 text-sm text-muted-foreground">
        <CheckIcon className="mt-0.5 size-4 shrink-0" />
        <p>
          {done === 'pending' ? (
            <>Logged for review. Michael reads these before they go up.</>
          ) : (
            <>
              Logged.{' '}
              {countAtOpen + 1 >= MIN_AGGREGATE_N
                ? 'That opens the record for this one.'
                : `${countAtOpen + 1} of ${MIN_AGGREGATE_N} toward a published figure.`}
            </>
          )}
        </p>
      </div>
    )
  }

  return (
    <div className="rounded-lg border bg-card px-5 py-4">
      {/* The prompt is the question itself, not a field label — it keeps the
          body size and colour the default Label would have taken away. */}
      <Label
        htmlFor={`q-${question.id}`}
        className="text-sm font-normal leading-snug text-foreground"
      >
        {question.prompt}
      </Label>

      <div className="mt-3">
        <AnswerInput question={question} value={value} onChange={setValue} />
      </div>

      {question.judgment_prompt && complete && (
        <div className="mt-4 border-t pt-3">
          <p className="text-sm text-muted-foreground">{question.judgment_prompt}</p>
          <div className="mt-2 flex gap-2">
            {judgmentOptions(question.judgment_prompt).map((option) => (
              <Button
                key={option}
                type="button"
                size="sm"
                variant={judgment === option ? 'default' : 'outline'}
                onClick={() => setJudgment(judgment === option ? null : option)}
              >
                {option}
              </Button>
            ))}
          </div>
        </div>
      )}

      <div className="mt-4 flex items-center justify-between gap-3">
        <span className="text-xs text-muted-foreground">
          {count > 0 ? `${count} logged here` : 'Nobody has answered this one yet'}
        </span>
        <Button type="button" size="sm" disabled={!complete || submit.isPending} onClick={handleSubmit}>
          {submit.isPending ? 'Sending…' : 'Log it'}
        </Button>
      </div>
    </div>
  )
}

/**
 * The seven input types (bible §9.6).
 *
 * All of them are bounded on purpose: a restricted input cannot carry a review,
 * which is what keeps a field report from becoming an opinion competing with
 * the curator's (RN-22). `text_short` is the single exception and it is capped
 * and queued.
 *
 * Native `range` and `color` do the work of two components nobody installed —
 * both are keyboard-accessible out of the box and cost no dependency.
 */
export function AnswerInput({
  question,
  value,
  onChange,
}: {
  question: Question
  value: AnswerValue
  onChange: (value: AnswerValue) => void
}) {
  const id = `q-${question.id}`

  switch (question.input_type) {
    case 'number':
    case 'compound':
      return (
        <div className="flex items-center gap-2">
          <Input
            id={id}
            type="number"
            inputMode="numeric"
            className="max-w-32"
            value={typeof value === 'number' ? value : ''}
            onChange={(event) =>
              onChange(event.target.value === '' ? null : Number(event.target.value))
            }
          />
          {question.unit_label && (
            <span className="text-sm text-muted-foreground">{question.unit_label}</span>
          )}
        </div>
      )

    case 'slider': {
      const [low, high] = question.slider_labels ?? ['Less', 'More']
      return (
        <div>
          <input
            id={id}
            type="range"
            min={0}
            max={100}
            step={1}
            value={typeof value === 'number' ? value : 50}
            onChange={(event) => onChange(Number(event.target.value))}
            className="w-full accent-primary"
          />
          <div className="mt-1 flex justify-between text-xs text-muted-foreground">
            <span>{low}</span>
            <span>{high}</span>
          </div>
        </div>
      )
    }

    case 'color':
      return (
        <div className="flex items-center gap-3">
          <input
            id={id}
            type="color"
            value={typeof value === 'string' ? value : '#888888'}
            onChange={(event) => onChange(event.target.value)}
            className="size-10 cursor-pointer rounded-md border bg-transparent"
          />
          <span className="font-mono text-sm text-muted-foreground">
            {typeof value === 'string' ? value.toUpperCase() : 'Pick one'}
          </span>
        </div>
      )

    case 'yes_no':
      return (
        <div className="flex gap-2">
          {[true, false].map((option) => (
            <Button
              key={String(option)}
              type="button"
              size="sm"
              variant={value === option ? 'default' : 'outline'}
              onClick={() => onChange(value === option ? null : option)}
            >
              {option ? 'Yes' : 'No'}
            </Button>
          ))}
        </div>
      )

    case 'single_choice':
      return (
        <div className="flex flex-wrap gap-2">
          {(question.options ?? []).map((option) => (
            <Button
              key={option}
              type="button"
              size="sm"
              variant={value === option ? 'default' : 'outline'}
              onClick={() => onChange(value === option ? null : option)}
            >
              {option}
            </Button>
          ))}
        </div>
      )

    case 'text_short':
      return (
        <div>
          <Input
            id={id}
            maxLength={TEXT_ANSWER_MAX}
            value={typeof value === 'string' ? value : ''}
            onChange={(event) => onChange(event.target.value)}
            placeholder="Keep it short"
          />
          <p
            className={cn(
              'mt-1 text-xs',
              // Hitting the limit is a warning, not a verdict — so it uses the
              // destructive token, never the reserved judgment amber.
              typeof value === 'string' && value.length >= TEXT_ANSWER_MAX
                ? 'text-destructive'
                : 'text-muted-foreground',
            )}
          >
            {typeof value === 'string' ? value.length : 0}/{TEXT_ANSWER_MAX} · goes to Michael before
            it appears
          </p>
        </div>
      )

    default:
      return null
  }
}
