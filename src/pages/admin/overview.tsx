import { useMemo } from 'react'
import { Link } from 'react-router-dom'
import { AlertTriangleIcon, SparklesIcon, StarIcon, TagIcon } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { usePlaces } from '@/hooks/use-places'
import { usePlaceTags, useTags } from '@/hooks/use-tags'
import { useTiers } from '@/hooks/use-tiers'
import { buildTagIndex, CONFLICT_MARKER } from '@/lib/place-filters'
import { cn, formatDate, formatNumber, monthsSince } from '@/lib/utils'

/** Past this, a verdict is old enough that the guide should say so. */
const STALE_MONTHS = 18

/** Scarcity target from bible §6.3: the star means nothing if it stops being rare. */
const STAR_TARGET = 0.05

export function OverviewPage() {
  const places = usePlaces()
  const placeTags = usePlaceTags()
  const tags = useTags()
  const tiers = useTiers()

  const index = useMemo(
    () => buildTagIndex(placeTags.data ?? [], tags.data ?? []),
    [placeTags.data, tags.data],
  )

  const stats = useMemo(() => {
    const all = places.data ?? []
    const published = all.filter((p) => p.status === 'published')

    // The launch batch (bible §13.1): stars and destinations are the places
    // friends already ask about, so they go public before the other 453.
    const launch = all.filter((p) => p.starred || p.tier === 'destination')

    const tagged = all.filter((p) => (index.byPlace.get(p.id)?.length ?? 0) > 0)
    const withCuisine = all.filter((p) =>
      (index.byPlace.get(p.id) ?? []).some((pt) => index.cuisineTagIds.has(pt.tag_id)),
    )
    const pendingSuggestions = all.filter((p) =>
      (index.byPlace.get(p.id) ?? []).some((pt) => pt.source === 'suggested'),
    )

    const stale = published
      .map((p) => ({ place: p, months: monthsSince(p.last_visited) }))
      .filter((row) => row.months !== null && row.months >= STALE_MONTHS)
      .sort((a, b) => (b.months ?? 0) - (a.months ?? 0))

    const starRatio = published.length > 0
      ? published.filter((p) => p.starred).length / published.length
      : 0

    return {
      total: all.length,
      published,
      launch,
      launchPublished: launch.filter((p) => p.status === 'published').length,
      tagged: tagged.length,
      withCuisine: withCuisine.length,
      pendingSuggestions: pendingSuggestions.length,
      conflicts: all.filter((p) => p.source_guides?.includes(CONFLICT_MARKER)).length,
      unclassified: all.filter((p) => p.place_type === 'unclassified').length,
      starred: all.filter((p) => p.starred).length,
      starRatio,
      byTier: (tiers.data ?? []).map((tier) => ({
        tier,
        total: all.filter((p) => p.tier === tier.slug).length,
        published: published.filter((p) => p.tier === tier.slug).length,
      })),
      stale,
    }
  }, [places.data, index, tiers.data])

  const loading = places.isLoading || placeTags.isLoading || tags.isLoading

  if (loading) {
    return (
      <div className="grid gap-4 sm:grid-cols-2">
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} className="h-40 w-full" />
        ))}
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="font-heading text-2xl font-semibold tracking-tight">Overview</h1>
        <p className="text-sm text-muted-foreground">
          {formatNumber(stats.published.length)} of {formatNumber(stats.total)} places are public.
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Launch batch</CardTitle>
          <CardDescription>
            Starred places and destinations — the ones people already ask about. Publishing these
            first beats waiting for all {formatNumber(stats.total)}.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-baseline gap-2">
            <span className="font-heading text-3xl font-semibold">{stats.launchPublished}</span>
            <span className="text-muted-foreground">of {stats.launch.length} published</span>
          </div>
          <Bar value={stats.launchPublished} total={stats.launch.length} className="mt-3" />
          <Link
            to="/admin?starred=yes&status=unreviewed"
            className="mt-3 inline-block text-sm underline underline-offset-4 hover:no-underline"
          >
            Open the unreviewed starred places
          </Link>
        </CardContent>
      </Card>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Tier distribution</CardTitle>
            <CardDescription>
              Destination and the star only mean something while they stay scarce.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-3">
            {stats.byTier.map(({ tier, total, published }) => (
              <div key={tier.slug} className="flex items-center gap-3 text-sm">
                <span className="w-28 shrink-0">{tier.label}</span>
                <Bar value={total} total={stats.total} className="flex-1" />
                <span className="w-24 shrink-0 text-right text-muted-foreground">
                  {total} · {published} live
                </span>
              </div>
            ))}

            <div className="mt-2 flex items-center gap-3 border-t pt-3 text-sm">
              <span className="flex w-28 shrink-0 items-center gap-1">
                <StarIcon className="size-3.5 fill-current text-amber-500" />
                Starred
              </span>
              <Bar value={stats.starred} total={stats.total} className="flex-1" />
              <span className="w-24 shrink-0 text-right text-muted-foreground">
                {stats.starred} total
              </span>
            </div>

            <p
              className={cn(
                'text-xs',
                stats.starRatio > STAR_TARGET ? 'text-amber-600' : 'text-muted-foreground',
              )}
            >
              {stats.published.length === 0
                ? 'Nothing published yet, so there is no ratio to watch.'
                : `${(stats.starRatio * 100).toFixed(1)}% of published places are starred. Target is under 5%.`}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Curation progress</CardTitle>
            <CardDescription>
              Tagging is the real bottleneck — not the code.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-3 text-sm">
            <Row
              icon={<TagIcon className="size-4 text-muted-foreground" />}
              label="Have at least one tag"
              value={`${stats.tagged} / ${stats.total}`}
            />
            <Bar value={stats.tagged} total={stats.total} />

            <Row
              icon={<TagIcon className="size-4 text-muted-foreground" />}
              label="Have a cuisine tag"
              value={`${stats.withCuisine} / ${stats.total}`}
            />
            <Bar value={stats.withCuisine} total={stats.total} />

            <Link
              to="/admin?flag=no-cuisine"
              className="text-sm underline underline-offset-4 hover:no-underline"
            >
              Open the places without a cuisine tag
            </Link>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <QueueCard
          icon={<AlertTriangleIcon className="size-4 text-amber-600" />}
          title="Tier conflicts"
          count={stats.conflicts}
          to="/admin?flag=conflict"
          description="Carried a tier while marked not visited. The tier was dropped on import."
        />
        <QueueCard
          icon={<SparklesIcon className="size-4 text-sky-600" />}
          title="Suggested tags"
          count={stats.pendingSuggestions}
          to="/admin?flag=suggested"
          description="Places holding a machine guess you have not confirmed or dropped."
        />
        <QueueCard
          icon={<AlertTriangleIcon className="size-4 text-muted-foreground" />}
          title="No place type"
          count={stats.unclassified}
          to="/admin?type=unclassified"
          description="Cannot be published: “unclassified” is not a facet anyone can filter by."
        />
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Going stale</CardTitle>
          <CardDescription>
            Published places you last visited over {STALE_MONTHS} months ago.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {stats.stale.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              Nothing stale. Once you start filling “last visited”, anything ageing past{' '}
              {STALE_MONTHS} months shows up here.
            </p>
          ) : (
            <ul className="divide-y">
              {stats.stale.slice(0, 10).map(({ place, months }) => (
                <li key={place.id} className="flex items-center justify-between gap-3 py-2 text-sm">
                  <Link to={`/admin/place/${place.slug}`} className="truncate hover:underline">
                    {place.name}
                  </Link>
                  <span className="shrink-0 text-xs text-muted-foreground">
                    {formatDate(place.last_visited)} · {months} months
                  </span>
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>
    </div>
  )
}

function Bar({ value, total, className }: { value: number; total: number; className?: string }) {
  const pct = total > 0 ? Math.round((value / total) * 100) : 0
  return (
    <div
      className={cn('h-2 overflow-hidden rounded-full bg-muted', className)}
      role="progressbar"
      aria-valuenow={pct}
      aria-valuemin={0}
      aria-valuemax={100}
    >
      <div className="h-full rounded-full bg-foreground/70" style={{ width: `${pct}%` }} />
    </div>
  )
}

function Row({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <span className="flex items-center gap-2">
        {icon}
        {label}
      </span>
      <span className="text-muted-foreground">{value}</span>
    </div>
  )
}

function QueueCard({
  icon, title, count, to, description,
}: {
  icon: React.ReactNode
  title: string
  count: number
  to: string
  description: string
}) {
  return (
    <Card>
      <CardHeader className="pb-3">
        <CardTitle className="flex items-center gap-2 text-base">
          {icon}
          {title}
        </CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col gap-2">
        <span className="font-heading text-3xl font-semibold">{count}</span>
        <p className="text-xs text-muted-foreground">{description}</p>
        {count > 0 && (
          <Link to={to} className="text-sm underline underline-offset-4 hover:no-underline">
            Open the list
          </Link>
        )}
      </CardContent>
    </Card>
  )
}
