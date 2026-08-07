import { useMemo, useState, type FormEvent } from 'react'
import { PlusIcon, SearchIcon, Trash2Icon } from 'lucide-react'
import { toast } from 'sonner'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { GuideFilterPanel } from '@/components/public/guide-filter-panel'
import { useCodes, useCreateCode, useDeleteCode, useUpdateCode, type CodeDraft } from '@/hooks/use-codes'
import { usePlaces } from '@/hooks/use-places'
import { usePlaceTags, useTags } from '@/hooks/use-tags'
import { useTiers } from '@/hooks/use-tiers'
import { filtersToPreset, presetToFilters } from '@/lib/code-effects'
import {
  buildFacetGroups,
  buildGuideIndex,
  EMPTY_FILTERS,
  toggleFacetValue,
  type FacetKey,
  type GuideFilters,
} from '@/lib/guide-filters'
import { cn, formatDate, mapRpcError } from '@/lib/utils'
import { MAP_STYLE_TOKENS, type Code, type PinStyle } from '@/types'

/**
 * Codes — one per person Michael shows the guide to.
 *
 * This is the feature that most directly serves the demonstration context
 * (bible §1.1): the guide arriving already wearing something made for you.
 * Everything here is data, so a new code needs no developer (PRD §9.7).
 */
export function CodesPage() {
  const codes = useCodes()
  const [editing, setEditing] = useState<Code | 'new' | null>(null)

  return (
    <div>
      <div className="flex items-center gap-4">
        <div className="flex-1">
          <h1 className="font-heading text-2xl font-semibold tracking-tight">Codes</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            A code restyles the guide, pre-picks a filter and highlights places. It never hides
            anything from anyone without it.
          </p>
        </div>

        <Button onClick={() => setEditing('new')}>
          <PlusIcon className="size-4" />
          New code
        </Button>
      </div>

      {codes.isLoading && (
        <div className="mt-8 flex flex-col gap-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-20 w-full" />
          ))}
        </div>
      )}

      {codes.data?.length === 0 && (
        <div className="mt-8 rounded-lg border border-dashed px-6 py-12 text-center">
          <p className="font-heading text-lg">No codes yet.</p>
          <p className="mt-2 text-sm text-muted-foreground">
            Make one the next time you show someone the guide.
          </p>
        </div>
      )}

      <ul className="mt-8 divide-y rounded-lg border">
        {(codes.data ?? []).map((code) => (
          <li key={code.id}>
            <button
              type="button"
              onClick={() => setEditing(code)}
              className="flex w-full flex-col gap-1 px-5 py-4 text-left transition-colors hover:bg-accent/50"
            >
              <div className="flex flex-wrap items-center gap-2">
                <span className="font-heading text-lg tracking-[0.15em]">{code.code}</span>
                {!code.active && <Badge variant="outline">Off</Badge>}
                {code.theme?.primary && (
                  <span
                    aria-hidden
                    className="size-4 rounded-full border"
                    style={{ backgroundColor: code.theme.primary }}
                  />
                )}
                {(code.highlighted_places?.length ?? 0) > 0 && (
                  <Badge variant="secondary">
                    {code.highlighted_places?.length} highlighted
                  </Badge>
                )}
                {code.preset_filter && <Badge variant="secondary">Preset filter</Badge>}
              </div>

              {code.label && <p className="text-sm">{code.label}</p>}
              {code.message && (
                <p className="text-sm text-muted-foreground">“{code.message}”</p>
              )}

              {(code.starts_at || code.ends_at) && (
                <p className="text-xs text-muted-foreground">
                  {code.starts_at ? formatDate(code.starts_at) : 'Any time'} —{' '}
                  {code.ends_at ? formatDate(code.ends_at) : 'no end'}
                </p>
              )}
            </button>
          </li>
        ))}
      </ul>

      {editing && (
        <CodeEditor
          code={editing === 'new' ? null : editing}
          onClose={() => setEditing(null)}
        />
      )}
    </div>
  )
}

// ---------------------------------------------------------------------------
// Editor
// ---------------------------------------------------------------------------

const NO_STYLE = '__default__'

interface FormState {
  code: string
  label: string
  message: string
  primary: string
  background: string
  mapStyle: string
  pinColor: string
  pinHighlight: string
  pinShape: PinStyle['shape'] | ''
  startsAt: string
  endsAt: string
  active: boolean
}

/** timestamptz → the `YYYY-MM-DD` an `<input type="date">` speaks. */
function toDateInput(value: string | null): string {
  if (!value) return ''
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return ''

  return [
    date.getFullYear(),
    String(date.getMonth() + 1).padStart(2, '0'),
    String(date.getDate()).padStart(2, '0'),
  ].join('-')
}

/**
 * A date the curator picked means the whole of that day, in his own timezone.
 * Ending at UTC midnight would switch a code off halfway through the day it
 * was meant to cover.
 */
function fromDateInput(value: string, edge: 'start' | 'end'): string | null {
  if (!value) return null
  const date = new Date(`${value}T${edge === 'start' ? '00:00:00' : '23:59:59'}`)
  return Number.isNaN(date.getTime()) ? null : date.toISOString()
}

function initialForm(code: Code | null): FormState {
  return {
    code: code?.code ?? '',
    label: code?.label ?? '',
    message: code?.message ?? '',
    primary: code?.theme?.primary ?? '',
    background: code?.theme?.background ?? '',
    mapStyle: code?.theme?.mapStyle ?? NO_STYLE,
    pinColor: code?.pin_style?.color ?? '',
    pinHighlight: code?.pin_style?.highlightColor ?? '',
    pinShape: code?.pin_style?.shape ?? '',
    startsAt: toDateInput(code?.starts_at ?? null),
    endsAt: toDateInput(code?.ends_at ?? null),
    active: code?.active ?? true,
  }
}

function CodeEditor({ code, onClose }: { code: Code | null; onClose: () => void }) {
  const create = useCreateCode()
  const update = useUpdateCode()
  const remove = useDeleteCode()

  const places = usePlaces()
  const tags = useTags()
  const placeTags = usePlaceTags()
  const tiers = useTiers()

  const [form, setForm] = useState<FormState>(() => initialForm(code))
  const [filters, setFilters] = useState<GuideFilters>(
    () => presetToFilters(code?.preset_filter) ?? EMPTY_FILTERS,
  )
  const [highlights, setHighlights] = useState<string[]>(code?.highlighted_places ?? [])
  const [search, setSearch] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [panelOpen, setPanelOpen] = useState(false)

  const set = <K extends keyof FormState>(key: K, value: FormState[K]) =>
    setForm((current) => ({ ...current, [key]: value }))

  /** Only published places can be highlighted or filtered — a visitor sees no others. */
  const published = useMemo(
    () => (places.data ?? []).filter((place) => place.status === 'published'),
    [places.data],
  )

  const index = useMemo(
    () => buildGuideIndex(placeTags.data, tags.data),
    [placeTags.data, tags.data],
  )

  /**
   * The preset is built with the visitor's own panel, over every published
   * place rather than one city. Same component, same counts, same rules — so
   * what the curator sees here is what the code will do out there.
   */
  const facetGroups = useMemo(
    () =>
      buildFacetGroups({
        places: published,
        filters,
        index,
        tiers: tiers.data,
        tags: tags.data,
      }),
    [published, filters, index, tiers.data, tags.data],
  )

  const matches = useMemo(() => {
    const needle = search.trim().toLowerCase()
    if (!needle) return published.filter((place) => highlights.includes(place.id))

    return published
      .filter((place) => place.name.toLowerCase().includes(needle))
      .slice(0, 40)
  }, [published, search, highlights])

  function toggleHighlight(placeId: string) {
    setHighlights((current) =>
      current.includes(placeId)
        ? current.filter((id) => id !== placeId)
        : [...current, placeId],
    )
  }

  async function handleSubmit(event: FormEvent) {
    event.preventDefault()
    setError(null)

    const normalised = form.code.trim().toUpperCase()
    if (!/^[A-Z0-9]{3,24}$/.test(normalised)) {
      setError('A code is 3 to 24 letters and numbers.')
      return
    }

    const startsAt = fromDateInput(form.startsAt, 'start')
    const endsAt = fromDateInput(form.endsAt, 'end')
    if (startsAt && endsAt && startsAt >= endsAt) {
      setError('The end date has to come after the start date.')
      return
    }

    const theme = {
      ...(form.primary ? { primary: form.primary } : {}),
      ...(form.background ? { background: form.background } : {}),
      ...(form.mapStyle !== NO_STYLE ? { mapStyle: form.mapStyle } : {}),
    }

    const pinStyle: PinStyle = {
      ...(form.pinColor ? { color: form.pinColor } : {}),
      ...(form.pinHighlight ? { highlightColor: form.pinHighlight } : {}),
      ...(form.pinShape ? { shape: form.pinShape } : {}),
    }

    const draft: CodeDraft = {
      code: normalised,
      label: form.label.trim() || null,
      message: form.message.trim() || null,
      theme: Object.keys(theme).length ? theme : null,
      pin_style: Object.keys(pinStyle).length ? pinStyle : null,
      preset_filter: filtersToPreset(filters),
      highlighted_places: highlights.length ? highlights : null,
      starts_at: startsAt,
      ends_at: endsAt,
      active: form.active,
    }

    try {
      if (code) await update.mutateAsync({ id: code.id, patch: draft })
      else await create.mutateAsync(draft)

      toast.success(code ? 'Code saved.' : 'Code created.')
      onClose()
    } catch (cause) {
      setError(mapRpcError(cause))
    }
  }

  async function handleDelete() {
    if (!code) return

    try {
      await remove.mutateAsync(code.id)
      toast.success('Code deleted.')
      onClose()
    } catch (cause) {
      setError(mapRpcError(cause))
    }
  }

  const busy = create.isPending || update.isPending || remove.isPending

  return (
    <Dialog open onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>{code ? `Edit ${code.code}` : 'New code'}</DialogTitle>
          <DialogDescription>
            Every field is optional except the code itself. Leave a section empty and the guide
            keeps its own look.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          <section className="flex flex-col gap-3">
            <div className="grid gap-3 sm:grid-cols-[200px_1fr]">
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="code">Code</Label>
                <Input
                  id="code"
                  value={form.code}
                  maxLength={24}
                  onChange={(event) => set('code', event.target.value.toUpperCase())}
                  className="font-heading tracking-[0.15em] uppercase"
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <Label htmlFor="label">Who it is for</Label>
                <Input
                  id="label"
                  value={form.label}
                  placeholder="Sarah, October visit"
                  onChange={(event) => set('label', event.target.value)}
                />
              </div>
            </div>

            <div className="flex flex-col gap-1.5">
              <Label htmlFor="message">Message</Label>
              <Textarea
                id="message"
                rows={2}
                value={form.message}
                placeholder="You found it."
                onChange={(event) => set('message', event.target.value)}
              />
              <p className="text-xs text-muted-foreground">
                Shown in a band above the guide. This is the part they remember.
              </p>
            </div>
          </section>

          <section className="flex flex-col gap-3 border-t pt-5">
            <h2 className="font-heading text-sm uppercase tracking-wide text-muted-foreground">
              Look
            </h2>

            <div className="grid gap-3 sm:grid-cols-2">
              <ColorField
                id="primary"
                label="Accent colour"
                value={form.primary}
                onChange={(value) => set('primary', value)}
              />
              <ColorField
                id="background"
                label="Background"
                value={form.background}
                onChange={(value) => set('background', value)}
                hint="A dark one flips the whole guide dark."
              />
            </div>

            <div className="flex flex-col gap-1.5">
              <Label htmlFor="mapStyle">Map style</Label>
              <Select value={form.mapStyle} onValueChange={(value) => set('mapStyle', value)}>
                <SelectTrigger id="mapStyle" className="sm:w-64">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value={NO_STYLE}>House style</SelectItem>
                  {MAP_STYLE_TOKENS.map((token) => (
                    <SelectItem key={token} value={token}>
                      {token}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="grid gap-3 sm:grid-cols-3">
              <ColorField
                id="pinColor"
                label="Pin colour"
                value={form.pinColor}
                onChange={(value) => set('pinColor', value)}
              />
              <ColorField
                id="pinHighlight"
                label="Highlight ring"
                value={form.pinHighlight}
                onChange={(value) => set('pinHighlight', value)}
              />

              <div className="flex flex-col gap-1.5">
                <Label htmlFor="pinShape">Pin shape</Label>
                <Select
                  value={form.pinShape || NO_STYLE}
                  onValueChange={(value) =>
                    set('pinShape', value === NO_STYLE ? '' : (value as PinStyle['shape']))
                  }
                >
                  <SelectTrigger id="pinShape">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={NO_STYLE}>Round</SelectItem>
                    <SelectItem value="square">Square</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <p className="text-xs text-muted-foreground">
              A pin colour repaints every pin. The rating colours only survive where you leave it
              blank — a code decorates the guide, it does not restate the verdict.
            </p>
          </section>

          <section className="flex flex-col gap-3 border-t pt-5">
            <h2 className="font-heading text-sm uppercase tracking-wide text-muted-foreground">
              Filter it starts on
            </h2>

            <GuideFilterPanel
              groups={facetGroups}
              filters={filters}
              resultCount={published.length}
              onToggle={(facet: FacetKey, value: string) =>
                setFilters((current) => toggleFacetValue(current, facet, value))
              }
              onClear={() => setFilters(EMPTY_FILTERS)}
              open={panelOpen}
              onOpenChange={setPanelOpen}
            />

            <p className="text-xs text-muted-foreground">
              The guide opens with these already ticked, and they can be cleared like any other
              filter. Nothing is hidden from anyone.
            </p>
          </section>

          <section className="flex flex-col gap-3 border-t pt-5">
            <h2 className="font-heading text-sm uppercase tracking-wide text-muted-foreground">
              Highlights
            </h2>

            <div className="relative">
              <SearchIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                value={search}
                onChange={(event) => setSearch(event.target.value)}
                placeholder="Search published places"
                className="pl-9"
              />
            </div>

            {matches.length === 0 && (
              <p className="text-sm text-muted-foreground">
                {search ? 'Nothing by that name.' : 'Search to pick a few places to float.'}
              </p>
            )}

            <ul className="flex flex-col gap-1">
              {matches.map((place) => {
                const picked = highlights.includes(place.id)
                return (
                  <li key={place.id}>
                    <button
                      type="button"
                      onClick={() => toggleHighlight(place.id)}
                      className={cn(
                        'flex w-full items-center gap-2 rounded-md border px-3 py-2 text-left text-sm transition-colors',
                        picked ? 'border-foreground bg-accent' : 'hover:bg-accent/50',
                      )}
                    >
                      <span className="flex-1">{place.name}</span>
                      <span className="text-xs text-muted-foreground">{place.city}</span>
                      {picked && <Badge variant="secondary">Picked</Badge>}
                    </button>
                  </li>
                )
              })}
            </ul>
          </section>

          <section className="flex flex-col gap-3 border-t pt-5">
            <h2 className="font-heading text-sm uppercase tracking-wide text-muted-foreground">
              When it works
            </h2>

            <div className="grid gap-3 sm:grid-cols-2">
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="startsAt">From</Label>
                <Input
                  id="startsAt"
                  type="date"
                  value={form.startsAt}
                  onChange={(event) => set('startsAt', event.target.value)}
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <Label htmlFor="endsAt">Until</Label>
                <Input
                  id="endsAt"
                  type="date"
                  value={form.endsAt}
                  onChange={(event) => set('endsAt', event.target.value)}
                />
              </div>
            </div>

            <label className="flex items-center gap-3 text-sm">
              <Switch checked={form.active} onCheckedChange={(value) => set('active', value)} />
              Active
            </label>
          </section>

          {error && <p className="text-sm text-destructive">{error}</p>}

          <div className="flex flex-wrap items-center gap-2 border-t pt-5">
            <Button type="submit" disabled={busy}>
              {busy ? 'Saving…' : code ? 'Save' : 'Create code'}
            </Button>

            <Button type="button" variant="outline" onClick={onClose} disabled={busy}>
              Cancel
            </Button>

            {code && (
              <Button
                type="button"
                variant="ghost"
                className="ml-auto text-destructive"
                disabled={busy}
                onClick={handleDelete}
              >
                <Trash2Icon className="size-4" />
                Delete
              </Button>
            )}
          </div>
        </form>
      </DialogContent>
    </Dialog>
  )
}

interface ColorFieldProps {
  id: string
  label: string
  value: string
  hint?: string
  onChange: (value: string) => void
}

/**
 * A native colour input plus the hex beside it.
 *
 * The swatch is for picking, the text is for pasting one someone sent you —
 * and the empty string is a real value here, meaning "leave the guide alone".
 */
function ColorField({ id, label, value, hint, onChange }: ColorFieldProps) {
  return (
    <div className="flex flex-col gap-1.5">
      <Label htmlFor={id}>{label}</Label>

      <div className="flex items-center gap-2">
        <input
          id={id}
          type="color"
          value={value || '#000000'}
          onChange={(event) => onChange(event.target.value)}
          className="size-9 shrink-0 cursor-pointer rounded-md border bg-background"
        />
        <Input
          value={value}
          placeholder="None"
          onChange={(event) => onChange(event.target.value)}
          aria-label={`${label} hex`}
        />
        {value && (
          <Button type="button" variant="ghost" size="sm" onClick={() => onChange('')}>
            Clear
          </Button>
        )}
      </div>

      {hint && <p className="text-xs text-muted-foreground">{hint}</p>}
    </div>
  )
}
