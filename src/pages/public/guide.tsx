import { lazy, Suspense, useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { ArrowLeftIcon, MapPinIcon, StarIcon } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { usePublicVocabulary, usePublishedPlaces } from '@/hooks/use-public-guide'
import { cn, formatNumber, slugify } from '@/lib/utils'
import type { Place, PlaceType } from '@/types'

/**
 * Place type is the second gate (bible §7): "where I eat" and "what I do" are
 * different questions, and a state park in a restaurant list is noise.
 */
const EAT_AND_DRINK: PlaceType[] = ['restaurant', 'bar', 'food_truck', 'dessert', 'winery']

/**
 * MapLibre is around a megabyte — more than the rest of the app put together.
 * Loading it only here keeps the city gate and the place detail light, and the
 * list is already usable while the map is still arriving.
 */
const GuideMap = lazy(() =>
  import('@/components/public/guide-map').then((m) => ({ default: m.GuideMap })),
)

export function GuidePage() {
  const { citySlug } = useParams<{ citySlug: string }>()
  const places = usePublishedPlaces()
  const { tiers } = usePublicVocabulary()

  // One selection, shared by map and list. Never two (see CLAUDE.md); the same
  // discipline the filter state will follow in F-04.
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const rowRefs = useRef(new globalThis.Map<string, HTMLLIElement>())

  const cityName = useMemo(
    () => (places.data ?? []).find((p) => p.city && slugify(p.city) === citySlug)?.city ?? null,
    [places.data, citySlug],
  )

  const tierOrder = useMemo(
    () => new globalThis.Map((tiers.data ?? []).map((tier, i) => [tier.slug, i])),
    [tiers.data],
  )
  const tierLabel = useMemo(
    () => new globalThis.Map((tiers.data ?? []).map((tier) => [tier.slug, tier.label])),
    [tiers.data],
  )

  const inCity = useMemo(
    () => (places.data ?? []).filter((p) => p.city === cityName),
    [places.data, cityName],
  )

  const sections = useMemo(() => {
    /** Star first, then tier order, then name. The star crosses tiers (RN-03). */
    const rank = (a: Place, b: Place) => {
      if (a.starred !== b.starred) return a.starred ? -1 : 1
      const ta = a.tier ? (tierOrder.get(a.tier) ?? 99) : 99
      const tb = b.tier ? (tierOrder.get(b.tier) ?? 99) : 99
      if (ta !== tb) return ta - tb
      return a.name.localeCompare(b.name)
    }

    return [
      { title: 'Eat & drink', places: inCity.filter((p) => EAT_AND_DRINK.includes(p.place_type)).sort(rank) },
      { title: 'Everything else', places: inCity.filter((p) => !EAT_AND_DRINK.includes(p.place_type)).sort(rank) },
    ].filter((section) => section.places.length > 0)
  }, [inCity, tierOrder])

  const select = useCallback((placeId: string | null) => setSelectedId(placeId), [])

  // A pin tapped on the map has to find its row, or the sync only works one way.
  useEffect(() => {
    if (!selectedId) return
    rowRefs.current.get(selectedId)?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }, [selectedId])

  if (places.isLoading) {
    return (
      <div className="mx-auto w-full max-w-6xl px-4 py-12">
        <Skeleton className="h-9 w-48" />
        <div className="mt-8 flex flex-col gap-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-24 w-full" />
          ))}
        </div>
      </div>
    )
  }

  if (!cityName) {
    return (
      <div className="mx-auto w-full max-w-3xl px-4 py-16">
        <h1 className="font-heading text-2xl font-semibold tracking-tight">Nothing here</h1>
        <p className="mt-3 text-muted-foreground">
          No published places in that city — at least not yet.
        </p>
        <Link to="/" className="mt-6 inline-flex items-center gap-2 text-sm underline underline-offset-4">
          <ArrowLeftIcon className="size-4" />
          Pick another city
        </Link>
      </div>
    )
  }

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-8">
      <Link
        to="/"
        className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground"
      >
        <ArrowLeftIcon className="size-4" />
        All cities
      </Link>

      <h1 className="mt-4 font-heading text-3xl font-semibold tracking-tight">{cityName}</h1>
      <p className="mt-2 text-sm text-muted-foreground">
        {formatNumber(inCity.length)} {inCity.length === 1 ? 'place' : 'places'}
      </p>

      <div className="mt-6 grid gap-6 lg:grid-cols-[1fr_minmax(0,420px)]">
        <div className="order-2 lg:order-1">
          {sections.map((section) => (
            <section key={section.title} className="mb-8">
              <h2 className="font-heading text-sm uppercase tracking-wide text-muted-foreground">
                {section.title}
              </h2>
              <ul className="mt-3 divide-y rounded-lg border">
                {section.places.map((place) => (
                  <PlaceLine
                    key={place.id}
                    place={place}
                    tierLabel={place.tier ? tierLabel.get(place.tier) ?? place.tier : null}
                    selected={place.id === selectedId}
                    onLocate={() => select(place.id)}
                    registerRef={(node) => {
                      if (node) rowRefs.current.set(place.id, node)
                      else rowRefs.current.delete(place.id)
                    }}
                  />
                ))}
              </ul>
            </section>
          ))}
        </div>

        {/* Sticky beside the list on a desktop, a fixed band above it on a phone. */}
        <div className="order-1 lg:order-2">
          <div className="h-[45vh] overflow-hidden rounded-lg border lg:sticky lg:top-6 lg:h-[calc(100vh-8rem)]">
            <Suspense fallback={<Skeleton className="size-full rounded-none" />}>
              <GuideMap places={inCity} selectedId={selectedId} onSelect={select} />
            </Suspense>
          </div>
        </div>
      </div>
    </div>
  )
}

interface LineProps {
  place: Place
  tierLabel: string | null
  selected: boolean
  onLocate: () => void
  registerRef: (node: HTMLLIElement | null) => void
}

function PlaceLine({ place, tierLabel, selected, onLocate, registerRef }: LineProps) {
  return (
    <li
      ref={registerRef}
      className={cn('flex items-stretch transition-colors', selected && 'bg-accent')}
    >
      <Link to={`/place/${place.slug}`} className="flex flex-1 flex-col gap-1 px-5 py-4 hover:bg-accent/50">
        <div className="flex items-center gap-2">
          <span className="font-heading text-lg">{place.name}</span>
          {place.starred && (
            <StarIcon className="size-4 shrink-0 fill-current text-amber-500" aria-label="Top pick" />
          )}
          {tierLabel && <Badge variant="secondary" className="shrink-0">{tierLabel}</Badge>}
        </div>

        {/* The dish leads when it exists — it is the reason to go, and the
            address is never the headline. */}
        {place.the_dish && <p className="text-sm">Order the {place.the_dish}.</p>}

        {!place.the_dish && place.curator_note && (
          <p className="line-clamp-2 text-sm text-muted-foreground">{place.curator_note}</p>
        )}

        <p className="text-xs text-muted-foreground">
          {[place.area, place.place_type.replace('_', ' '), place.price_band]
            .filter(Boolean)
            .join(' · ')}
        </p>
      </Link>

      <button
        type="button"
        onClick={onLocate}
        className="shrink-0 px-4 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
        aria-label={`Show ${place.name} on the map`}
        aria-pressed={selected}
      >
        <MapPinIcon className="size-4" />
      </button>
    </li>
  )
}
