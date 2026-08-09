import { useEffect, useMemo, useRef, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { AlertTriangleIcon, ArrowLeftIcon, ExternalLinkIcon, SaveIcon } from 'lucide-react'
import { toast } from 'sonner'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Separator } from '@/components/ui/separator'
import { Skeleton } from '@/components/ui/skeleton'
import { Switch } from '@/components/ui/switch'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { TagPicker } from '@/components/admin/tag-picker'
import { usePlace, useUpdatePlace, type PlaceEdit } from '@/hooks/use-places'
import { usePlaceTags, useTags } from '@/hooks/use-tags'
import { useTiers } from '@/hooks/use-tiers'
import { CONFLICT_MARKER } from '@/lib/place-filters'
import { canPublish, publishIssues } from '@/lib/publish-rules'
import { formatDate, mapRpcError } from '@/lib/utils'
import type { Place, PlaceStatus, PlaceType, PriceBand } from '@/types'

const TYPES: PlaceType[] = [
  'restaurant', 'bar', 'outdoors', 'food_truck', 'dessert',
  'grocery', 'hotel', 'winery', 'shop', 'unclassified',
]
const STATUSES: PlaceStatus[] = ['unreviewed', 'published', 'closed', 'hidden']
const PRICE_BANDS: PriceBand[] = ['$', '$$', '$$$', '$$$$']

const NONE = '__none__'

/** Text inputs work in strings; the database column types are restored on save. */
interface FormState {
  name: string
  place_type: PlaceType
  tier: string
  starred: boolean
  visited: boolean
  status: PlaceStatus
  country: string
  city: string
  area: string
  lat: string
  lng: string
  address: string
  website: string
  price_band: string
  the_dish: string
  curator_note: string
  story: string
  last_visited: string
}

function toForm(place: Place): FormState {
  return {
    name: place.name,
    place_type: place.place_type,
    tier: place.tier ?? NONE,
    starred: place.starred,
    visited: place.visited,
    status: place.status,
    country: place.country ?? '',
    city: place.city ?? '',
    area: place.area ?? '',
    lat: place.lat?.toString() ?? '',
    lng: place.lng?.toString() ?? '',
    address: place.address ?? '',
    website: place.website ?? '',
    price_band: place.price_band ?? NONE,
    the_dish: place.the_dish ?? '',
    curator_note: place.curator_note ?? '',
    story: place.story ?? '',
    last_visited: place.last_visited ?? '',
  }
}

const blank = (value: string) => (value.trim() === '' ? null : value.trim())

/** Only what actually changed is sent — a save should not rewrite untouched judgment. */
function buildPatch(place: Place, form: FormState): PlaceEdit {
  const next: PlaceEdit = {}
  const put = <K extends keyof PlaceEdit>(key: K, value: PlaceEdit[K]) => {
    if (value !== place[key as keyof Place]) next[key] = value
  }

  put('name', form.name.trim())
  put('place_type', form.place_type)
  put('tier', form.tier === NONE ? null : form.tier)
  put('starred', form.starred)
  put('visited', form.visited)
  put('status', form.status)
  put('country', blank(form.country))
  put('city', blank(form.city))
  put('area', blank(form.area))
  put('address', blank(form.address))
  put('website', blank(form.website))
  put('price_band', (form.price_band === NONE ? null : form.price_band) as PriceBand | null)
  put('the_dish', blank(form.the_dish))
  put('curator_note', blank(form.curator_note))
  put('story', blank(form.story))
  put('last_visited', blank(form.last_visited))

  const lat = form.lat.trim() === '' ? null : Number(form.lat)
  const lng = form.lng.trim() === '' ? null : Number(form.lng)
  if (lat !== place.lat && !Number.isNaN(lat)) next.lat = lat
  if (lng !== place.lng && !Number.isNaN(lng)) next.lng = lng

  return next
}

export function PlaceEditorPage() {
  const { slug } = useParams<{ slug: string }>()
  const place = usePlace(slug)
  const tags = useTags()
  const placeTags = usePlaceTags()
  const tiers = useTiers()
  const updatePlace = useUpdatePlace()

  const [form, setForm] = useState<FormState | null>(null)
  const loadedId = useRef<string | null>(null)

  // Seed the form once per place, not on every resolved query.
  //
  // WHY the ref: React Query hands back a new object identity on any refetch,
  // and reseeding from that would silently wipe whatever the curator had typed
  // but not yet saved. The form is reseeded only when a different place opens;
  // a successful save reseeds it explicitly from the row the server returned.
  useEffect(() => {
    if (place.data && loadedId.current !== place.data.id) {
      loadedId.current = place.data.id
      setForm(toForm(place.data))
    }
  }, [place.data])

  const assigned = useMemo(
    () => (placeTags.data ?? []).filter((pt) => pt.place_id === place.data?.id),
    [placeTags.data, place.data?.id],
  )

  const cuisineTagCount = useMemo(() => {
    const cuisineIds = new Set(
      (tags.data ?? []).filter((t) => t.facet === 'cuisine').map((t) => t.id),
    )
    return assigned.filter((pt) => cuisineIds.has(pt.tag_id)).length
  }, [assigned, tags.data])

  const patch = useMemo(
    () => (place.data && form ? buildPatch(place.data, form) : {}),
    [place.data, form],
  )
  const dirty = Object.keys(patch).length > 0

  const issues = useMemo(
    () =>
      form
        ? publishIssues(
            {
              city: blank(form.city),
              place_type: form.place_type,
              price_band: (form.price_band === NONE ? null : form.price_band) as PriceBand | null,
              visited: form.visited,
              tier: form.tier === NONE ? null : form.tier,
              starred: form.starred,
            },
            cuisineTagCount,
          )
        : [],
    [form, cuisineTagCount],
  )

  // Leaving with unsaved judgment on screen is the one loss that cannot be undone.
  useEffect(() => {
    if (!dirty) return
    const warn = (event: BeforeUnloadEvent) => event.preventDefault()
    window.addEventListener('beforeunload', warn)
    return () => window.removeEventListener('beforeunload', warn)
  }, [dirty])

  function set<K extends keyof FormState>(key: K, value: FormState[K]) {
    setForm((current) => (current ? { ...current, [key]: value } : current))
  }

  /** RN-01 and RN-02 as an interaction: dropping the visit drops what it earned. */
  function setVisited(value: boolean) {
    setForm((current) =>
      current
        ? value
          ? { ...current, visited: true }
          : { ...current, visited: false, tier: NONE, starred: false }
        : current,
    )
  }

  function save() {
    if (!place.data || !form) return

    if (form.status === 'published' && !canPublish(issues)) {
      toast.error('Fix what is blocking publication first.')
      return
    }

    updatePlace.mutate(
      { id: place.data.id, patch },
      {
        // Reseed from what the server actually stored, so the form reflects
        // truth (trigger-set updated_at included) and stops reading as dirty.
        onSuccess: (saved) => {
          setForm(toForm(saved))
          toast.success('Saved.')
        },
        onError: (error) => toast.error(mapRpcError(error)),
      },
    )
  }

  if (place.isLoading || !form) {
    return (
      <div className="flex flex-col gap-4">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-64 w-full" />
      </div>
    )
  }

  if (!place.data) {
    return (
      <div className="flex flex-col items-start gap-4">
        <p className="text-sm text-muted-foreground">No place with that slug.</p>
        <Button asChild variant="outline">
          <Link to="/admin">Back to places</Link>
        </Button>
      </div>
    )
  }

  const hasConflict = place.data.source_guides?.includes(CONFLICT_MARKER) ?? false
  const blockers = issues.filter((i) => i.level === 'block')
  const warnings = issues.filter((i) => i.level === 'warn')
  const applicableTiers = (tiers.data ?? []).filter(
    (tier) => tier.applies_to.length === 0 || tier.applies_to.includes(form.place_type),
  )

  return (
    <div className="flex flex-col gap-6 pb-24">
      <div className="flex items-start gap-3">
        <Button asChild variant="ghost" size="sm" className="-ml-2">
          <Link to="/admin">
            <ArrowLeftIcon className="size-4" />
            Places
          </Link>
        </Button>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <h1 className="font-heading text-3xl font-extrabold tracking-[-0.025em]">{place.data.name}</h1>
        <Badge variant={place.data.status === 'published' ? 'default' : 'secondary'}>
          {place.data.status}
        </Badge>
        {place.data.website && (
          <Button asChild variant="ghost" size="sm">
            <a href={place.data.website} target="_blank" rel="noreferrer noopener">
              <ExternalLinkIcon className="size-4" />
              Site
            </a>
          </Button>
        )}
      </div>

      {hasConflict && (
        <p className="rounded-md border border-destructive/40 bg-destructive/5 px-3 py-2 text-sm">
          <AlertTriangleIcon className="mr-1.5 inline size-4 text-destructive" />
          The import found this place carrying a tier while marked “not visited”. The tier was
          dropped. Confirm you have been here, or accept that the tier was aspirational.
        </p>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Classification</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 sm:grid-cols-2">
          <Field label="Name" htmlFor="name">
            <Input id="name" value={form.name} onChange={(e) => set('name', e.target.value)} />
          </Field>

          <Field label="Place type" htmlFor="place_type">
            <Select value={form.place_type} onValueChange={(v) => set('place_type', v as PlaceType)}>
              <SelectTrigger id="place_type"><SelectValue /></SelectTrigger>
              <SelectContent>
                {TYPES.map((type) => (
                  <SelectItem key={type} value={type}>{type.replace('_', ' ')}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>

          <Field label="Status" htmlFor="status">
            <Select value={form.status} onValueChange={(v) => set('status', v as PlaceStatus)}>
              <SelectTrigger id="status"><SelectValue /></SelectTrigger>
              <SelectContent>
                {STATUSES.map((status) => (
                  <SelectItem key={status} value={status}>{status}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>

          <Field label="Price band" htmlFor="price_band" hint="Your call, not a lookup.">
            <Select value={form.price_band} onValueChange={(v) => set('price_band', v)}>
              <SelectTrigger id="price_band"><SelectValue placeholder="Not set" /></SelectTrigger>
              <SelectContent>
                <SelectItem value={NONE}>Not set</SelectItem>
                {PRICE_BANDS.map((band) => (
                  <SelectItem key={band} value={band}>{band}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>
        </CardContent>
      </Card>

      <Card className="border-verdict/40">
        <CardHeader>
          <CardTitle>Judgment</CardTitle>
          <CardDescription>
            The only data here that cannot be reconstructed from anywhere else.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="flex flex-wrap items-center gap-6">
            <label className="flex items-center gap-2 text-sm">
              <Switch checked={form.visited} onCheckedChange={setVisited} />
              Visited
            </label>
            <label className="flex items-center gap-2 text-sm">
              <Switch
                checked={form.starred}
                disabled={!form.visited}
                onCheckedChange={(v) => set('starred', v)}
              />
              Starred
            </label>
          </div>

          <Field
            label="Tier"
            htmlFor="tier"
            hint={
              form.visited
                ? 'Suggested for this place type. You can pick any of them.'
                : 'A place you have not visited cannot carry a tier.'
            }
          >
            <Select
              value={form.tier}
              disabled={!form.visited}
              onValueChange={(v) => set('tier', v)}
            >
              <SelectTrigger id="tier" className="sm:w-64"><SelectValue placeholder="No tier" /></SelectTrigger>
              <SelectContent>
                <SelectItem value={NONE}>No tier</SelectItem>
                {applicableTiers.map((tier) => (
                  <SelectItem key={tier.slug} value={tier.slug}>{tier.label}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>

          <Separator />

          <Field label="The dish" htmlFor="the_dish" hint="The one thing worth ordering.">
            <Input id="the_dish" value={form.the_dish} onChange={(e) => set('the_dish', e.target.value)} />
          </Field>

          <Field label="Curator note" htmlFor="curator_note">
            <Textarea
              id="curator_note"
              rows={3}
              value={form.curator_note}
              onChange={(e) => set('curator_note', e.target.value)}
            />
          </Field>

          <Field label="Story" htmlFor="story" hint="Why this place matters to you.">
            <Textarea
              id="story"
              rows={4}
              value={form.story}
              onChange={(e) => set('story', e.target.value)}
            />
          </Field>

          <Field
            label="Last visited"
            htmlFor="last_visited"
            hint={place.data.last_visited ? `Currently ${formatDate(place.data.last_visited)}` : undefined}
          >
            <Input
              id="last_visited"
              type="date"
              className="sm:w-64"
              value={form.last_visited}
              onChange={(e) => set('last_visited', e.target.value)}
            />
          </Field>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Tags</CardTitle>
        </CardHeader>
        <CardContent>
          <TagPicker placeId={place.data.id} tags={tags.data ?? []} assigned={assigned} />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Geography</CardTitle>
          <CardDescription>City is the gate. Area is the town or neighbourhood inside it.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 sm:grid-cols-2">
          <Field label="City" htmlFor="city"><Input id="city" value={form.city} onChange={(e) => set('city', e.target.value)} /></Field>
          <Field label="Area" htmlFor="area"><Input id="area" value={form.area} onChange={(e) => set('area', e.target.value)} /></Field>
          <Field label="Country" htmlFor="country"><Input id="country" value={form.country} onChange={(e) => set('country', e.target.value)} /></Field>
          <Field label="Website" htmlFor="website"><Input id="website" value={form.website} onChange={(e) => set('website', e.target.value)} /></Field>
          <Field label="Address" htmlFor="address" className="sm:col-span-2">
            <Input id="address" value={form.address} onChange={(e) => set('address', e.target.value)} />
          </Field>
          <Field label="Latitude" htmlFor="lat"><Input id="lat" value={form.lat} onChange={(e) => set('lat', e.target.value)} /></Field>
          <Field label="Longitude" htmlFor="lng"><Input id="lng" value={form.lng} onChange={(e) => set('lng', e.target.value)} /></Field>
        </CardContent>
      </Card>

      <div className="fixed inset-x-0 bottom-0 border-t bg-background/95 backdrop-blur">
        <div className="mx-auto flex w-full max-w-6xl flex-wrap items-center gap-3 px-4 py-3">
          <div className="min-w-0 flex-1 text-xs">
            {blockers.length > 0 && (
              <p className="text-destructive">
                Cannot publish: {blockers.map((i) => i.message).join(' ')}
              </p>
            )}
            {blockers.length === 0 && warnings.length > 0 && (
              <p className="text-muted-foreground">{warnings.map((i) => i.message).join(' ')}</p>
            )}
            {blockers.length === 0 && warnings.length === 0 && (
              <p className="text-muted-foreground">
                {dirty ? 'Unsaved changes.' : 'Everything saved.'}
              </p>
            )}
          </div>

          <Button onClick={save} disabled={!dirty || updatePlace.isPending}>
            <SaveIcon className="size-4" />
            {updatePlace.isPending ? 'Saving…' : 'Save'}
          </Button>
        </div>
      </div>
    </div>
  )
}

function Field({
  label, htmlFor, hint, className, children,
}: {
  label: string
  htmlFor: string
  hint?: string
  className?: string
  children: React.ReactNode
}) {
  return (
    <div className={`flex flex-col gap-1.5 ${className ?? ''}`}>
      <Label htmlFor={htmlFor}>{label}</Label>
      {children}
      {hint && <p className="text-xs text-muted-foreground">{hint}</p>}
    </div>
  )
}
