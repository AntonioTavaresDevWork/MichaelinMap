import { lazy, Suspense, useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { Link, useParams, useSearchParams } from 'react-router-dom'
import { ArrowLeftIcon, MapPinIcon, StarIcon } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { GuideFilterPanel } from '@/components/public/guide-filter-panel'
import { usePublicVocabulary, usePublishedPlaces } from '@/hooks/use-public-guide'
import {
  applyGuideFilters,
  buildFacetGroups,
  buildGuideIndex,
  EMPTY_FILTERS,
  filtersFromParams,
  filtersToParams,
  hasActiveFilters,
  toggleFacetValue,
  type FacetKey,
} from '@/lib/guide-filters'
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
  const { tiers, tags, placeTags } = usePublicVocabulary()

  // One selection, shared by map and list. Never two (see CLAUDE.md) — and the
  // filter below follows the same discipline: it lives in the URL, and both the
  // list and the map read the one result of applying it.
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [panelOpen, setPanelOpen] = useState(false)
  const rowRefs = useRef(new globalThis.Map<string, HTMLLIElement>())

  const [searchParams, setSearchParams] = useSearchParams()
  const filters = useMemo(() => filtersFromParams(searchParams), [searchParams])

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

  const index = useMemo(
    () => buildGuideIndex(placeTags.data, tags.data),
    [placeTags.data, tags.data],
  )

  const visible = useMemo(
    () => applyGuideFilters(inCity, filters, index),
    [inCity, filters, index],
  )

  const facetGroups = useMemo(
    () => buildFacetGroups({ places: inCity, filters, index, tiers: tiers.data, tags: tags.data }),
    [inCity, filters, index, tiers.data, tags.data],
  )

  const setFilters = useCallback(
    (next: typeof filters) => {
      // Replace rather than push: the back button should leave the city, not
      // walk back through every checkbox. The URL stays shareable either way
      // (RN-19).
      setSearchParams(filtersToParams(next), { replace: true })
    },
    [setSearchParams],
  )

  const toggle = useCallback(
    (facet: FacetKey, value: string) => setFilters(toggleFacetValue(filters, facet, value)),
    [filters, setFilters],
  )

  const clear = useCallback(() => setFilters(EMPTY_FILTERS), [setFilters])

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
      { title: 'Eat & drink', places: visible.filter((p) => EAT_AND_DRINK.includes(p.place_type)).sort(rank) },
      { title: 'Everything else', places: visible.filter((p) => !EAT_AND_DRINK.includes(p.place_type)).sort(rank) },
    ].filter((section) => section.places.length > 0)
  }, [visible, tierOrder])

  const select = useCallback((placeId: string | null) => setSelectedId(placeId), [])

  // A pin tapped on the map has to find its row, or the sync only works one way.
  useEffect(() => {
    if (!selectedId) return
    rowRefs.current.get(selectedId)?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }, [selectedId])

  // A selection that the filter just excluded would leave the map highlighting
  // a pin with no row beside it — one state, so it has to stay coherent.
  useEffect(() => {
    if (selectedId && !visible.some((place) => place.id === selectedId)) setSelectedId(null)
  }, [visible, selectedId])

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
          <div className="mb-6">
            <GuideFilterPanel
              groups={facetGroups}
              filters={filters}
              resultCount={visible.length}
              onToggle={toggle}
              onClear={clear}
              open={panelOpen}
              onOpenChange={setPanelOpen}
            />
          </div>

          {visible.length === 0 && (
            <NothingMatches filtered={hasActiveFilters(filters)} onClear={clear} />
          )}

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
              <GuideMap places={visible} selectedId={selectedId} onSelect={select} />
            </Suspense>
          </div>
        </div>
      </div>
    </div>
  )
}

/**
 * The impossible combination (BL-18).
 *
 * This is the exact moment a visitor would leave, so it is worth writing rather
 * than shrugging with "no results". The joke also does the teaching: it explains
 * why adding a filter narrows instead of widens (RN-16), which is the one thing
 * a faceted panel never makes obvious on its own.
 */
function NothingMatches({ filtered, onClear }: { filtered: boolean; onClear: () => void }) {
  if (!filtered) {
    return (
      <div className="rounded-lg border border-dashed px-6 py-12 text-center">
        <p className="font-heading text-lg">Nothing here yet.</p>
        <p className="mt-2 text-sm text-muted-foreground">
          This city is on the map but not yet written up.
        </p>
      </div>
    )
  }

  return (
    <div className="rounded-lg border border-dashed px-6 py-12 text-center">
      <p className="font-heading text-lg">Nothing is all of those things.</p>
      <p className="mx-auto mt-2 max-w-sm text-sm text-muted-foreground">
        Michael has opinions, not miracles. Every filter you add is one more thing that has to be
        true at the same time — let go of one and the guide comes back.
      </p>
      <Button variant="outline" size="sm" className="mt-5" onClick={onClear}>
        Clear filters
      </Button>
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
