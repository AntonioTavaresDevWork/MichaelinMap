import { useMemo } from 'react'
import { Link, useParams } from 'react-router-dom'
import { ArrowLeftIcon, MapPinIcon, StarIcon } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { Skeleton } from '@/components/ui/skeleton'
import {
  usePlaceTagLabels,
  usePublicVocabulary,
  usePublishedPlaces,
} from '@/hooks/use-public-guide'
import { formatMonthYear, slugify } from '@/lib/utils'
import type { Place } from '@/types'

/**
 * Leads with the verdict, never the address.
 *
 * A pin transmits coordinates and nothing else — the whole problem this guide
 * exists to solve (bible §1). So the tier, the star, the dish and the note come
 * first; directions are a button at the bottom for when the decision is already
 * made.
 */
export function PlaceDetailPage() {
  const { placeSlug } = useParams<{ placeSlug: string }>()
  const places = usePublishedPlaces()
  const { tags, placeTags, tiers } = usePublicVocabulary()

  const place = useMemo(
    () => (places.data ?? []).find((p) => p.slug === placeSlug) ?? null,
    [places.data, placeSlug],
  )

  const assignedTags = usePlaceTagLabels(place?.id, tags.data, placeTags.data)
  const tierLabel = place?.tier
    ? (tiers.data ?? []).find((t) => t.slug === place.tier)?.label ?? place.tier
    : null

  if (places.isLoading) {
    return (
      <div className="mx-auto w-full max-w-2xl px-4 py-12">
        <Skeleton className="h-10 w-64" />
        <Skeleton className="mt-4 h-24 w-full" />
      </div>
    )
  }

  if (!place) {
    return (
      <div className="mx-auto w-full max-w-2xl px-4 py-16">
        <h1 className="font-heading text-2xl font-semibold tracking-tight">Not here</h1>
        <p className="mt-3 text-muted-foreground">
          That place is not in the guide — or is not public yet.
        </p>
        <Link to="/" className="mt-6 inline-flex items-center gap-2 text-sm underline underline-offset-4">
          <ArrowLeftIcon className="size-4" />
          Back to the cities
        </Link>
      </div>
    )
  }

  return (
    <article className="mx-auto w-full max-w-2xl px-4 py-12">
      {place.city && (
        <Link
          to={`/city/${slugify(place.city)}`}
          className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground"
        >
          <ArrowLeftIcon className="size-4" />
          {place.city}
        </Link>
      )}

      <header className="mt-4 flex flex-col gap-3">
        <div className="flex flex-wrap items-center gap-2">
          <h1 className="font-heading text-3xl font-semibold tracking-tight">{place.name}</h1>
          {place.starred && (
            <StarIcon className="size-6 fill-current text-amber-500" aria-label="Top pick" />
          )}
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {tierLabel && <Badge>{tierLabel}</Badge>}
          <Badge variant="outline">{place.place_type.replace('_', ' ')}</Badge>
          {place.price_band && <Badge variant="outline">{place.price_band}</Badge>}
          {!place.visited && <Badge variant="outline">On the try list</Badge>}
        </div>
      </header>

      {place.the_dish && (
        <p className="mt-8 font-heading text-xl leading-snug">Order the {place.the_dish}.</p>
      )}

      {place.curator_note && (
        <p className="mt-4 max-w-prose leading-relaxed">{place.curator_note}</p>
      )}

      {place.story && (
        <>
          <Separator className="my-8" />
          <p className="max-w-prose leading-relaxed text-muted-foreground">{place.story}</p>
        </>
      )}

      {assignedTags.length > 0 && (
        <div className="mt-8 flex flex-wrap gap-1.5">
          {assignedTags.map((tag) => (
            <Badge key={tag.id} variant="secondary" className="font-normal">
              {tag.label}
            </Badge>
          ))}
        </div>
      )}

      <Separator className="my-8" />

      <footer className="flex flex-col gap-3 text-sm text-muted-foreground">
        {place.address && <p>{place.address}</p>}

        <div className="flex flex-wrap gap-2">
          <DirectionsButton place={place} />
          {place.website && (
            <Button asChild variant="outline" size="sm">
              <a href={place.website} target="_blank" rel="noreferrer noopener">
                Website
              </a>
            </Button>
          )}
        </div>

        {place.last_visited && (
          <p className="text-xs">Last visited {formatMonthYear(place.last_visited)}.</p>
        )}
      </footer>
    </article>
  )
}

/**
 * Opening hours were cut with the Places API (ADR-06) — the maps app knows them
 * and knows whether it is open right now, which is the question anyone actually
 * has when they are standing outside.
 */
function DirectionsButton({ place }: { place: Place }) {
  const target =
    place.lat != null && place.lng != null
      ? `${place.lat},${place.lng}`
      : [place.name, place.address].filter(Boolean).join(' ')

  return (
    <Button asChild size="sm">
      <a
        href={`https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(target)}`}
        target="_blank"
        rel="noreferrer noopener"
      >
        <MapPinIcon className="size-4" />
        Directions
      </a>
    </Button>
  )
}
