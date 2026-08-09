import { SearchIcon, XIcon } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { FACET_LABEL } from '@/hooks/use-tags'
import {
  DEFAULT_FILTERS,
  hasActiveFilters,
  tagKey,
  type PlaceFilters,
  type TagOptionGroup,
} from '@/lib/place-filters'
import { formatNumber } from '@/lib/utils'
import type { PlaceStatus, PlaceType, Tier } from '@/types'

const STATUSES: PlaceStatus[] = ['unreviewed', 'published', 'closed', 'hidden']

const TYPES: { value: PlaceType; label: string }[] = [
  { value: 'restaurant', label: 'Restaurant' },
  { value: 'bar', label: 'Bar' },
  { value: 'outdoors', label: 'Outdoors & attraction' },
  { value: 'food_truck', label: 'Food truck' },
  { value: 'dessert', label: 'Dessert' },
  { value: 'grocery', label: 'Grocery' },
  { value: 'hotel', label: 'Hotel' },
  { value: 'winery', label: 'Winery' },
  { value: 'shop', label: 'Shop' },
  { value: 'unclassified', label: 'Unclassified' },
]

const FLAGS: { value: PlaceFilters['flag']; label: string }[] = [
  { value: 'all', label: 'Any' },
  { value: 'conflict', label: 'Tier conflict' },
  { value: 'suggested', label: 'Has suggested tags' },
  { value: 'no-cuisine', label: 'No cuisine tag' },
  { value: 'untagged', label: 'No tags at all' },
  { value: 'unvisited', label: 'Try list' },
]

interface Props {
  filters: PlaceFilters
  onChange: (next: PlaceFilters) => void
  tiers: Tier[]
  cities: { city: string; count: number }[]
  /** Already narrowed to what the other filters leave standing — see tagOptions. */
  tagGroups: TagOptionGroup[]
}

export function PlaceFilterBar({ filters, onChange, tiers, cities, tagGroups }: Props) {
  function set<K extends keyof PlaceFilters>(key: K, value: PlaceFilters[K]) {
    onChange({ ...filters, [key]: value })
  }

  return (
    <div className="flex flex-wrap items-center gap-2">
      <div className="relative min-w-56 flex-1">
        <SearchIcon className="pointer-events-none absolute left-2.5 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          value={filters.q}
          onChange={(event) => set('q', event.target.value)}
          placeholder="Search by name"
          className="pl-8"
          aria-label="Search places by name"
        />
      </div>

      <Select value={filters.status} onValueChange={(v) => set('status', v as PlaceFilters['status'])}>
        <SelectTrigger className="w-36" aria-label="Filter by status">
          <SelectValue placeholder="Status" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Any status</SelectItem>
          {STATUSES.map((status) => (
            <SelectItem key={status} value={status}>
              {status}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      <Select value={filters.type} onValueChange={(v) => set('type', v as PlaceFilters['type'])}>
        <SelectTrigger className="w-44" aria-label="Filter by place type">
          <SelectValue placeholder="Type" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Any type</SelectItem>
          {TYPES.map((type) => (
            <SelectItem key={type.value} value={type.value}>
              {type.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      <Select value={filters.tier} onValueChange={(v) => set('tier', v)}>
        <SelectTrigger className="w-36" aria-label="Filter by tier">
          <SelectValue placeholder="Tier" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Any tier</SelectItem>
          {tiers.map((tier) => (
            <SelectItem key={tier.slug} value={tier.slug}>
              {tier.label}
            </SelectItem>
          ))}
          <SelectItem value="none">No tier</SelectItem>
        </SelectContent>
      </Select>

      <Select value={filters.city} onValueChange={(v) => set('city', v)}>
        <SelectTrigger className="w-48" aria-label="Filter by city">
          <SelectValue placeholder="City" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Any city</SelectItem>
          {cities.map(({ city, count }) => (
            <SelectItem key={city} value={city}>
              {city} ({count})
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      <Select
        value={filters.starred}
        onValueChange={(v) => set('starred', v as PlaceFilters['starred'])}
      >
        <SelectTrigger className="w-32" aria-label="Filter by star">
          <SelectValue placeholder="Star" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Star: any</SelectItem>
          <SelectItem value="yes">Starred</SelectItem>
          <SelectItem value="no">Not starred</SelectItem>
        </SelectContent>
      </Select>

      <Select value={filters.flag} onValueChange={(v) => set('flag', v as PlaceFilters['flag'])}>
        <SelectTrigger className="w-48" aria-label="Filter by review flag">
          <SelectValue placeholder="Needs attention" />
        </SelectTrigger>
        <SelectContent>
          {FLAGS.map((flag) => (
            <SelectItem key={flag.value} value={flag.value}>
              {flag.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      <Select
        value={filters.tag}
        onValueChange={(v) =>
          // Clearing the tag clears its source with it — a lone "suggested"
          // narrowing nothing would be a filter with no visible effect.
          onChange({ ...filters, tag: v, tagSource: v === 'all' ? 'all' : filters.tagSource })
        }
      >
        <SelectTrigger className="w-52" aria-label="Filter by tag">
          <SelectValue placeholder="Tag" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Any tag</SelectItem>
          {tagGroups.map((group) => (
            <SelectGroup key={group.facet}>
              <SelectLabel>{FACET_LABEL[group.facet]}</SelectLabel>
              {group.options.map(({ tag, count }) => (
                // Zero survives only for the currently selected tag, so the
                // control that undoes a filter never disappears under it.
                <SelectItem key={tag.id} value={tagKey(tag)} disabled={count === 0}>
                  {tag.label}
                  <span className="ml-2 font-mono text-[11px] text-muted-foreground">
                    {formatNumber(count)}
                  </span>
                </SelectItem>
              ))}
            </SelectGroup>
          ))}
        </SelectContent>
      </Select>

      <Select
        value={filters.tagSource}
        onValueChange={(v) => set('tagSource', v as PlaceFilters['tagSource'])}
        disabled={filters.tag === 'all'}
      >
        <SelectTrigger className="w-40" aria-label="Filter by who assigned the tag">
          <SelectValue placeholder="Assigned by" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Anyone</SelectItem>
          <SelectItem value="suggested">Suggested</SelectItem>
          <SelectItem value="curator">Confirmed</SelectItem>
        </SelectContent>
      </Select>

      {hasActiveFilters(filters) && (
        <Button variant="ghost" size="sm" onClick={() => onChange(DEFAULT_FILTERS)}>
          <XIcon className="size-4" />
          Clear
        </Button>
      )}
    </div>
  )
}
