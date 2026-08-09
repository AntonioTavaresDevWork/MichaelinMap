import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { CheckIcon, SproutIcon, UtensilsIcon, XIcon } from 'lucide-react'
import { toast } from 'sonner'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Skeleton } from '@/components/ui/skeleton'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { AnswerInput } from '@/components/public/field-report-form'
import { useQuestions } from '@/hooks/use-field-reports'
import { usePlaces } from '@/hooks/use-places'
import {
  CURATOR_SESSION,
  useModerateReport,
  useReportQueue,
  useSeedFieldReports,
  type QueuedReport,
} from '@/hooks/use-report-queue'
import { isAnswerComplete, MIN_AGGREGATE_N, type AnswerValue } from '@/lib/field-reports'
import { formatDate, mapRpcError } from '@/lib/utils'

/**
 * The one question whose answer feeds back into the curator's own judgment
 * (bible §10). Everything else is deliberately orthogonal to quality; this one
 * is a stranger telling Michael what to order, so it gets its own colour.
 */
const DISH_PROMPT = 'The dish you would order again'

export function ReportsPage() {
  const reports = useReportQueue()

  const pending = useMemo(
    () => (reports.data ?? []).filter((report) => report.status === 'pending'),
    [reports.data],
  )

  if (reports.isLoading) {
    return <Skeleton className="h-64 w-full" />
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="font-heading text-3xl font-extrabold tracking-[-0.025em]">Field reports</h1>
        <p className="text-sm text-muted-foreground">
          Free text waits for you. Everything else went live on arrival.
        </p>
      </div>

      <Tabs defaultValue="queue">
        <TabsList>
          <TabsTrigger value="queue">
            Review queue
            {pending.length > 0 && (
              <Badge variant="secondary" className="ml-2">
                {pending.length}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="seed">Seed answers</TabsTrigger>
        </TabsList>

        <TabsContent value="queue" className="mt-4">
          <ReviewQueue pending={pending} />
        </TabsContent>

        <TabsContent value="seed" className="mt-4">
          <SeedPanel reports={reports.data ?? []} />
        </TabsContent>
      </Tabs>
    </div>
  )
}

function ReviewQueue({ pending }: { pending: QueuedReport[] }) {
  const moderate = useModerateReport()

  if (!pending.length) {
    return (
      <Card>
        <CardContent className="py-10 text-center text-sm text-muted-foreground">
          Nothing waiting. The four free-text questions land here; the other 34 publish themselves.
        </CardContent>
      </Card>
    )
  }

  function decide(id: string, status: 'published' | 'rejected') {
    moderate.mutate(
      { id, status },
      {
        onSuccess: () => toast.success(status === 'published' ? 'Published.' : 'Rejected.'),
        onError: (error) => toast.error(mapRpcError(error)),
      },
    )
  }

  return (
    <div className="flex flex-col gap-3">
      {pending.map((report) => {
        const isDish = report.questions?.prompt === DISH_PROMPT

        return (
          <Card key={report.id} className={isDish ? 'border-verdict/50' : undefined}>
            <CardHeader className="pb-3">
              <CardTitle className="flex flex-wrap items-center gap-2 text-base">
                {isDish && <UtensilsIcon className="size-4 text-verdict-ink" />}
                {report.places?.slug ? (
                  <Link to={`/admin/place/${report.places.slug}`} className="hover:underline">
                    {report.places.name}
                  </Link>
                ) : (
                  (report.places?.name ?? 'Unknown place')
                )}
                {isDish && (
                  <Badge variant="outline" className="border-verdict/50 text-verdict-ink">
                    Feeds your call
                  </Badge>
                )}
              </CardTitle>
              <CardDescription>
                {report.questions?.prompt} · {formatDate(report.submitted_at)}
              </CardDescription>
            </CardHeader>

            <CardContent className="flex flex-wrap items-center justify-between gap-4">
              <p className="text-base font-semibold">
                &ldquo;{formatAnswer(report.answer?.value)}&rdquo;
                {report.judgment && (
                  <span className="ml-2 text-sm font-normal text-muted-foreground">
                    ({report.judgment})
                  </span>
                )}
              </p>

              <div className="flex gap-2">
                <Button size="sm" disabled={moderate.isPending} onClick={() => decide(report.id, 'published')}>
                  <CheckIcon className="size-4" />
                  Publish
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  disabled={moderate.isPending}
                  onClick={() => decide(report.id, 'rejected')}
                >
                  <XIcon className="size-4" />
                  Reject
                </Button>
              </div>
            </CardContent>
          </Card>
        )
      })}
    </div>
  )
}

/**
 * Where the curator answers his own questions, so a place is not born at zero
 * (bible §10, BL-20).
 *
 * These are observations, which is why they are typed here by the person who
 * was in the room rather than generated: an invented ceiling height would be
 * indistinguishable from a measured one in a panel that reports to one decimal
 * place. Seeds publish immediately — the review step guards against strangers,
 * and this is the person it defers to.
 */
function SeedPanel({ reports }: { reports: QueuedReport[] }) {
  const places = usePlaces()
  const questions = useQuestions()
  const seed = useSeedFieldReports()

  const [placeId, setPlaceId] = useState<string>('')
  const [values, setValues] = useState<Record<string, AnswerValue>>({})
  const [judgments, setJudgments] = useState<Record<string, string | null>>({})

  const published = useMemo(
    () => (places.data ?? []).filter((place) => place.status === 'published'),
    [places.data],
  )

  // Already seeded here, so the same measurement is not filed twice.
  const seeded = useMemo(() => {
    const set = new Set<string>()
    for (const report of reports) {
      if (report.session_hash === CURATOR_SESSION && report.place_id === placeId) {
        set.add(report.question_id)
      }
    }
    return set
  }, [reports, placeId])

  const open = useMemo(
    () =>
      (questions.data ?? [])
        .filter((question) => !seeded.has(question.id))
        .sort((a, b) => a.prompt.localeCompare(b.prompt)),
    [questions.data, seeded],
  )

  const ready = Object.entries(values).filter(([questionId, value]) => {
    const question = (questions.data ?? []).find((q) => q.id === questionId)
    return question ? isAnswerComplete(question, value) : false
  })

  function handleSave() {
    seed.mutate(
      ready.map(([questionId, value]) => ({
        placeId,
        questionId,
        value,
        judgment: judgments[questionId] ?? null,
      })),
      {
        onSuccess: (count) => {
          toast.success(`${count} answer${count === 1 ? '' : 's'} filed.`)
          setValues({})
          setJudgments({})
        },
        onError: (error) => toast.error(mapRpcError(error)),
      },
    )
  }

  if (places.isLoading || questions.isLoading) {
    return <Skeleton className="h-64 w-full" />
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base">
          <SproutIcon className="size-4 text-success" />
          Seed a place
        </CardTitle>
        <CardDescription>
          Your own answers, so nothing is born at zero. They publish on save. A figure still needs{' '}
          {MIN_AGGREGATE_N} answers before the public sees it — this is the first one, not a
          shortcut past the others.
        </CardDescription>
      </CardHeader>

      <CardContent className="flex flex-col gap-5">
        <Select value={placeId} onValueChange={setPlaceId}>
          <SelectTrigger className="max-w-sm">
            <SelectValue placeholder="Pick a published place" />
          </SelectTrigger>
          <SelectContent>
            {published.map((place) => (
              <SelectItem key={place.id} value={place.id}>
                {place.name}
                {place.city ? ` · ${place.city}` : ''}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        {!placeId && (
          <p className="text-sm text-muted-foreground">
            {published.length} places are public. Pick one and answer whatever you actually remember.
          </p>
        )}

        {placeId && (
          <>
            <div className="flex flex-col gap-3">
              {open.map((question) => (
                <div key={question.id} className="rounded-lg border bg-card px-4 py-3">
                  <p className="text-sm leading-snug">{question.prompt}</p>
                  <div className="mt-2">
                    <AnswerInput
                      question={question}
                      value={values[question.id] ?? (question.input_type === 'slider' ? 50 : null)}
                      onChange={(value) =>
                        setValues((current) => ({ ...current, [question.id]: value }))
                      }
                    />
                  </div>

                  {question.judgment_prompt && values[question.id] != null && (
                    <input
                      type="text"
                      value={judgments[question.id] ?? ''}
                      onChange={(event) =>
                        setJudgments((current) => ({
                          ...current,
                          [question.id]: event.target.value || null,
                        }))
                      }
                      placeholder={question.judgment_prompt}
                      maxLength={40}
                      className="mt-2 w-full rounded-md border bg-secondary px-3 py-1.5 text-sm"
                    />
                  )}
                </div>
              ))}

              {open.length === 0 && (
                <p className="text-sm text-muted-foreground">
                  You have seeded every question here.
                </p>
              )}
            </div>

            <div className="flex items-center justify-between gap-3 border-t pt-4">
              <span className="text-sm text-muted-foreground">
                {seeded.size} already seeded here · {ready.length} ready to file
              </span>
              <Button disabled={!ready.length || seed.isPending} onClick={handleSave}>
                {seed.isPending ? 'Filing…' : `File ${ready.length || ''}`.trim()}
              </Button>
            </div>
          </>
        )}
      </CardContent>
    </Card>
  )
}

function formatAnswer(value: unknown): string {
  if (typeof value === 'boolean') return value ? 'Yes' : 'No'
  if (typeof value === 'number') return String(value)
  if (typeof value === 'string') return value
  return '—'
}
