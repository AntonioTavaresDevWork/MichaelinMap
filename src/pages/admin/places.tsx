import { useMemo, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { AlertTriangleIcon, CheckIcon, SparklesIcon, StarIcon } from 'lucide-react'
import { toast } from 'sonner'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Skeleton } from '@/components/ui/skeleton'
import { PlaceFilterBar } from '@/components/admin/place-filter-bar'
import { usePlaces } from '@/hooks/use-places'
import { useConfirmSuggestions, usePlaceTags, useTags } from '@/hooks/use-tags'
import { useTiers } from '@/hooks/use-tiers'
import {
  applyFilters,
  assignmentFor,
  buildTagIndex,
  CONFLICT_MARKER,
  cityOptions,
  filtersFromParams,
  filtersToParams,
  tagKey,
  type PlaceFilters,
} from '@/lib/place-filters'
import { formatNumber } from '@/lib/utils'
import type { Place, PlaceStatus, Tag } from '@/types'

const STATUS_VARIANT: Record<PlaceStatus, 'default' | 'secondary' | 'outline' | 'destructive'> = {
  published: 'default',
  unreviewed: 'secondary',
  hidden: 'outline',
  closed: 'destructive',
}

export function PlacesPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const filters = useMemo(() => filtersFromParams(searchParams), [searchParams])

  const places = usePlaces()
  const placeTags = usePlaceTags()
  const tags = useTags()
  const tiers = useTiers()

  const index = useMemo(
    () => buildTagIndex(placeTags.data ?? [], tags.data ?? []),
    [placeTags.data, tags.data],
  )

  const visible = useMemo(
    () => applyFilters(places.data ?? [], filters, index),
    [places.data, filters, index],
  )

  const cities = useMemo(() => cityOptions(places.data ?? []), [places.data])
  const tierLabel = useMemo(
    () => new Map((tiers.data ?? []).map((tier) => [tier.slug, tier.label])),
    [tiers.data],
  )

  function updateFilters(next: PlaceFilters) {
    // replace, not push: typing in the search box should not fill the history.
    setSearchParams(filtersToParams(next), { replace: true })
  }

  const loading = places.isLoading || placeTags.isLoading || tags.isLoading
  const error = places.error ?? placeTags.error ?? tags.error

  return (
    <div className="flex flex-col gap-5">
      <div className="flex items-end justify-between gap-4">
        <div>
          <h1 className="font-heading text-3xl font-extrabold tracking-[-0.025em]">Places</h1>
          <p className="text-sm text-muted-foreground">
            {loading
              ? 'Loading…'
              : `${formatNumber(visible.length)} of ${formatNumber(places.data?.length ?? 0)}`}
          </p>
        </div>
      </div>

      <PlaceFilterBar
        filters={filters}
        onChange={updateFilters}
        tiers={tiers.data ?? []}
        cities={cities}
        tags={tags.data ?? []}
      />

      <BulkConfirmBar
        filters={filters}
        visible={visible}
        index={index}
        tags={tags.data ?? []}
      />

      {error && (
        <p className="rounded-md border border-destructive/40 bg-destructive/5 p-4 text-sm text-destructive">
          Could not load places. {error.message}
        </p>
      )}

      {loading && (
        <div className="flex flex-col gap-2">
          {Array.from({ length: 8 }).map((_, i) => (
            <Skeleton key={i} className="h-14 w-full" />
          ))}
        </div>
      )}

      {!loading && !error && visible.length === 0 && (
        <p className="rounded-md border border-dashed bg-card p-8 text-center text-sm text-muted-foreground">
          Nothing matches that combination.
        </p>
      )}

      {!loading && visible.length > 0 && (
        <ul className="divide-y overflow-hidden rounded-lg border bg-card">
          {visible.map((place) => (
            <PlaceRow
              key={place.id}
              place={place}
              tierLabel={tierLabel.get(place.tier ?? '') ?? place.tier}
              tagCount={index.byPlace.get(place.id)?.length ?? 0}
              suggestedCount={
                index.byPlace.get(place.id)?.filter((pt) => pt.source === 'suggested').length ?? 0
              }
            />
          ))}
        </ul>
      )}
    </div>
  )
}

/**
 * Confirm one tag across the filtered places, in one go.
 *
 * Deliberately asymmetric: you confirm in bulk, you reject one at a time. A
 * well-generated batch is mostly right, so approving wholesale is the win — and
 * rejecting *deletes* the row, where confirming only moves `source`. The few
 * wrong ones are worth opening individually.
 */
function BulkConfirmBar({
  filters,
  visible,
  index,
  tags,
}: {
  filters: PlaceFilters
  visible: Place[]
  index: ReturnType<typeof buildTagIndex>
  tags: Tag[]
}) {
  const [open, setOpen] = useState(false)
  const confirm = useConfirmSuggestions()

  const tag = useMemo(
    () => tags.find((t) => tagKey(t) === filters.tag) ?? null,
    [tags, filters.tag],
  )

  // Exactly the rows the statement will write — the count on the button and the
  // rows updated come from the same predicate, so the number is never a guess.
  const pendingIds = useMemo(
    () =>
      visible
        .filter((place) => assignmentFor(place, filters, index)?.source === 'suggested')
        .map((place) => place.id),
    [visible, filters, index],
  )

  if (!tag || pendingIds.length === 0) return null

  function run() {
    if (!tag) return

    confirm.mutate(
      { tagId: tag.id, placeIds: pendingIds },
      {
        onSuccess: () => {
          setOpen(false)
          toast.success(
            `${tag.label} confirmed on ${pendingIds.length} place${pendingIds.length === 1 ? '' : 's'}.`,
          )
        },
        onError: (error: Error) => toast.error(error.message),
      },
    )
  }

  return (
    <>
      <div className="flex flex-wrap items-center gap-3 rounded-lg border border-info/30 bg-info/5 px-4 py-3">
        <SparklesIcon className="size-4 shrink-0 text-info" />
        <p className="flex-1 text-sm">
          <span className="font-mono">{formatNumber(pendingIds.length)}</span> of these are still a
          machine guess at <span className="font-medium">{tag.label}</span>.
        </p>
        <Button size="sm" onClick={() => setOpen(true)} disabled={confirm.isPending}>
          <CheckIcon className="size-4" />
          Confirm on all {formatNumber(pendingIds.length)}
        </Button>
      </div>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Confirm {tag.label}?</DialogTitle>
            <DialogDescription>
              This turns the suggestion into your call on {formatNumber(pendingIds.length)} place
              {pendingIds.length === 1 ? '' : 's'}, and they become visible to visitors. Places
              where you already confirmed this tag are left alone.
            </DialogDescription>
          </DialogHeader>

          <div className="flex flex-wrap justify-end gap-2">
            <Button variant="outline" size="sm" onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button size="sm" onClick={run} disabled={confirm.isPending}>
              {confirm.isPending ? 'Confirming…' : `Confirm ${formatNumber(pendingIds.length)}`}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </>
  )
}

interface RowProps {
  place: Place
  tierLabel: string | null
  tagCount: number
  suggestedCount: number
}

function PlaceRow({ place, tierLabel, tagCount, suggestedCount }: RowProps) {
  const hasConflict = place.source_guides?.includes(CONFLICT_MARKER) ?? false

  return (
    <li>
      <Link
        to={`/admin/place/${place.slug}`}
        className="flex items-center gap-3 px-4 py-3 transition-colors hover:bg-muted"
      >
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <span className="truncate font-medium">{place.name}</span>
            {place.starred && (
              <StarIcon className="size-4 shrink-0 fill-current text-verdict" aria-label="Starred" />
            )}
            {hasConflict && (
              <AlertTriangleIcon
                className="size-4 shrink-0 text-destructive"
                aria-label="Tier conflict from import"
              />
            )}
            {suggestedCount > 0 && (
              <SparklesIcon
                className="size-4 shrink-0 text-info"
                aria-label={`${suggestedCount} suggested tags awaiting review`}
              />
            )}
          </div>
          <p className="truncate text-xs text-muted-foreground">
            {[place.city, place.area, place.place_type.replace('_', ' ')]
              .filter(Boolean)
              .join(' · ')}
          </p>
        </div>

        <span className="shrink-0 text-xs text-muted-foreground">
          {tagCount === 0 ? 'no tags' : `${tagCount} tag${tagCount === 1 ? '' : 's'}`}
        </span>

        {tierLabel && (
          <Badge variant="outline" className="shrink-0">
            {tierLabel}
          </Badge>
        )}

        {!place.visited && (
          <Badge variant="outline" className="shrink-0">
            Try list
          </Badge>
        )}

        <Badge variant={STATUS_VARIANT[place.status]} className="shrink-0">
          {place.status}
        </Badge>
      </Link>
    </li>
  )
}
