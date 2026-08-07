import { useMemo } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { AlertTriangleIcon, SparklesIcon, StarIcon } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { PlaceFilterBar } from '@/components/admin/place-filter-bar'
import { usePlaces } from '@/hooks/use-places'
import { usePlaceTags, useTags } from '@/hooks/use-tags'
import { useTiers } from '@/hooks/use-tiers'
import {
  applyFilters,
  buildTagIndex,
  CONFLICT_MARKER,
  cityOptions,
  filtersFromParams,
  filtersToParams,
  type PlaceFilters,
} from '@/lib/place-filters'
import { formatNumber } from '@/lib/utils'
import type { Place, PlaceStatus } from '@/types'

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
          <h1 className="font-heading text-2xl font-semibold tracking-tight">Places</h1>
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
        <p className="rounded-md border border-dashed p-8 text-center text-sm text-muted-foreground">
          Nothing matches that combination.
        </p>
      )}

      {!loading && visible.length > 0 && (
        <ul className="divide-y rounded-md border">
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
        className="flex items-center gap-3 px-4 py-3 transition-colors hover:bg-accent/50"
      >
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <span className="truncate font-medium">{place.name}</span>
            {place.starred && (
              <StarIcon className="size-4 shrink-0 fill-current text-amber-500" aria-label="Starred" />
            )}
            {hasConflict && (
              <AlertTriangleIcon
                className="size-4 shrink-0 text-amber-600"
                aria-label="Tier conflict from import"
              />
            )}
            {suggestedCount > 0 && (
              <SparklesIcon
                className="size-4 shrink-0 text-sky-600"
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
