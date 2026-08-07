import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { CrosshairIcon, Loader2Icon, MapPinIcon, PlusIcon } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useCreatePlace, nextFreeSlug, usePlaces } from '@/hooks/use-places'
import { reverseGeocode, useGeocodeSearch, type GeocodeResult } from '@/hooks/use-geocode'
import { cityOptions } from '@/lib/place-filters'
import { mapRpcError, slugify } from '@/lib/utils'
import type { Place, PlaceType } from '@/types'

const TYPES: PlaceType[] = [
  'restaurant', 'bar', 'outdoors', 'food_truck', 'dessert',
  'grocery', 'hotel', 'winery', 'shop', 'unclassified',
]

const NEW_CITY = '__new__'

/**
 * Quick-add — the capture path.
 *
 * This replaced the My Maps sync entirely (ADR-08), so it has to be the whole
 * way in: name it, pin it, done, standing on the pavement. Everything that
 * needs thought waits for the editor.
 */
export function QuickAddPage() {
  const places = usePlaces()
  const createPlace = useCreatePlace()

  const [name, setName] = useState('')
  const [placeType, setPlaceType] = useState<PlaceType>('restaurant')
  const [visited, setVisited] = useState(false)
  const [addressQuery, setAddressQuery] = useState('')
  const [picked, setPicked] = useState<GeocodeResult | null>(null)
  const [citySelect, setCitySelect] = useState('')
  const [newCity, setNewCity] = useState('')
  const [locating, setLocating] = useState(false)
  const [lastSaved, setLastSaved] = useState<Place | null>(null)

  const search = useGeocodeSearch(picked ? '' : addressQuery)
  const cities = useMemo(() => cityOptions(places.data ?? []), [places.data])
  const takenSlugs = useMemo(
    () => new Set((places.data ?? []).map((p) => p.slug).filter(Boolean) as string[]),
    [places.data],
  )

  const city = citySelect === NEW_CITY ? newCity.trim() : citySelect
  const canSave = name.trim().length > 0 && Boolean(city) && !createPlace.isPending

  function choose(result: GeocodeResult) {
    setPicked(result)
    setAddressQuery(result.displayName)

    // Only prefill the gate when the locality already is one. Otherwise the
    // curator picks it: a place in Lockhart belongs to the Austin gate, and
    // guessing here would quietly fragment the city list.
    const known = cities.find((c) => c.city === result.locality)
    if (known && !citySelect) setCitySelect(known.city)
  }

  async function useMyLocation() {
    if (!navigator.geolocation) {
      toast.error('This browser will not share a location.')
      return
    }

    setLocating(true)
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        try {
          const result = await reverseGeocode(position.coords.latitude, position.coords.longitude)
          if (result) choose(result)
          else toast.error('Could not turn that location into an address.')
        } finally {
          setLocating(false)
        }
      },
      () => {
        setLocating(false)
        toast.error('Location permission denied.')
      },
      { enableHighAccuracy: true, timeout: 10000 },
    )
  }

  function reset() {
    setName('')
    setPlaceType('restaurant')
    setVisited(false)
    setAddressQuery('')
    setPicked(null)
    setNewCity('')
    // The city gate is kept on purpose: adding several places in one outing is
    // the normal case, and they are almost always in the same city.
  }

  function save() {
    const trimmed = name.trim()
    if (!trimmed || !city) return

    createPlace.mutate(
      {
        name: trimmed,
        slug: nextFreeSlug(slugify(trimmed), takenSlugs),
        place_type: placeType,
        city,
        area: picked?.locality && picked.locality !== city ? picked.locality : null,
        country: picked?.country ?? null,
        address: picked?.address ?? (picked?.displayName ?? null),
        lat: picked?.lat ?? null,
        lng: picked?.lng ?? null,
        visited,
      },
      {
        onSuccess: (place) => {
          setLastSaved(place)
          toast.success(`${place.name} captured.`)
          reset()
        },
        onError: (error) => toast.error(mapRpcError(error)),
      },
    )
  }

  return (
    <div className="mx-auto flex max-w-lg flex-col gap-5 pb-28">
      <div>
        <h1 className="font-heading text-2xl font-semibold tracking-tight">Add a place</h1>
        <p className="text-sm text-muted-foreground">
          Catch it now, judge it later. Everything lands unreviewed.
        </p>
      </div>

      {lastSaved && (
        <Card className="border-emerald-500/40 bg-emerald-500/5">
          <CardContent className="flex flex-wrap items-center gap-3 py-4 text-sm">
            <span className="flex-1">
              Saved <strong>{lastSaved.name}</strong>.
            </span>
            <Button asChild variant="outline" size="sm">
              <Link to={`/admin/place/${lastSaved.slug}`}>Open editor</Link>
            </Button>
          </CardContent>
        </Card>
      )}

      <div className="flex flex-col gap-2">
        <Label htmlFor="name">Name</Label>
        <Input
          id="name"
          value={name}
          onChange={(event) => setName(event.target.value)}
          placeholder="What is it called?"
          className="h-12 text-base"
          autoComplete="off"
          autoFocus
        />
      </div>

      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between gap-2">
          <Label htmlFor="address">Where</Label>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={useMyLocation}
            disabled={locating}
          >
            {locating ? (
              <Loader2Icon className="size-4 animate-spin" />
            ) : (
              <CrosshairIcon className="size-4" />
            )}
            Use my location
          </Button>
        </div>

        <Input
          id="address"
          value={addressQuery}
          onChange={(event) => {
            setAddressQuery(event.target.value)
            setPicked(null)
          }}
          placeholder="Search an address or landmark"
          className="h-12 text-base"
          autoComplete="off"
        />

        {search.isFetching && (
          <p className="text-xs text-muted-foreground">Looking it up…</p>
        )}

        {!picked && (search.data?.length ?? 0) > 0 && (
          <ul className="divide-y overflow-hidden rounded-md border">
            {search.data!.map((result) => (
              <li key={`${result.lat},${result.lng}`}>
                <button
                  type="button"
                  onClick={() => choose(result)}
                  className="flex w-full items-start gap-2 px-3 py-2.5 text-left text-sm hover:bg-accent"
                >
                  <MapPinIcon className="mt-0.5 size-4 shrink-0 text-muted-foreground" />
                  <span className="min-w-0">{result.displayName}</span>
                </button>
              </li>
            ))}
          </ul>
        )}

        {picked && (
          <p className="text-xs text-muted-foreground">
            Pinned at {picked.lat.toFixed(5)}, {picked.lng.toFixed(5)}
            {picked.locality ? ` · ${picked.locality}` : ''}
          </p>
        )}

        <p className="text-[11px] text-muted-foreground">
          Search by{' '}
          <a
            href="https://www.openstreetmap.org/copyright"
            target="_blank"
            rel="noreferrer noopener"
            className="underline underline-offset-2"
          >
            OpenStreetMap
          </a>
        </p>
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="city">City gate</Label>
        <Select value={citySelect} onValueChange={setCitySelect}>
          <SelectTrigger id="city" className="h-12 text-base">
            <SelectValue placeholder="Which city does it belong to?" />
          </SelectTrigger>
          <SelectContent>
            {cities.map(({ city: name, count }) => (
              <SelectItem key={name} value={name}>
                {name} ({count})
              </SelectItem>
            ))}
            <SelectItem value={NEW_CITY}>Somewhere new…</SelectItem>
          </SelectContent>
        </Select>

        {citySelect === NEW_CITY && (
          <Input
            value={newCity}
            onChange={(event) => setNewCity(event.target.value)}
            placeholder="New city name"
            className="h-12 text-base"
          />
        )}

        <p className="text-xs text-muted-foreground">
          The gate is the metro, not the town. A place in Lockhart belongs to Austin.
        </p>
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="type">Type</Label>
        <Select value={placeType} onValueChange={(v) => setPlaceType(v as PlaceType)}>
          <SelectTrigger id="type" className="h-12 text-base">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {TYPES.map((type) => (
              <SelectItem key={type} value={type}>
                {type.replace('_', ' ')}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <label className="flex items-center justify-between gap-3 rounded-md border px-4 py-3">
        <span className="text-sm">
          <span className="font-medium">Already been</span>
          <span className="block text-xs text-muted-foreground">
            Off means it goes on the try list.
          </span>
        </span>
        <Switch checked={visited} onCheckedChange={setVisited} />
      </label>

      <div className="fixed inset-x-0 bottom-0 border-t bg-background/95 backdrop-blur">
        <div className="mx-auto w-full max-w-lg px-4 py-3">
          <Button onClick={save} disabled={!canSave} className="h-12 w-full text-base">
            <PlusIcon className="size-5" />
            {createPlace.isPending ? 'Saving…' : 'Add place'}
          </Button>
        </div>
      </div>
    </div>
  )
}
