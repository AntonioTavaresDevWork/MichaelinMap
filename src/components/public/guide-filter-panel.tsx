import { SlidersHorizontalIcon, StarIcon, XIcon } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { cn, formatNumber } from '@/lib/utils'
import type { FacetGroup, FacetKey, GuideFilters } from '@/lib/guide-filters'
import { countActiveFilters } from '@/lib/guide-filters'

interface Props {
  groups: FacetGroup[]
  filters: GuideFilters
  resultCount: number
  onToggle: (facet: FacetKey, value: string) => void
  onClear: () => void
  /** Drives the collapsed state on a phone, where the panel would eat the list. */
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function GuideFilterPanel({
  groups,
  filters,
  resultCount,
  onToggle,
  onClear,
  open,
  onOpenChange,
}: Props) {
  const active = countActiveFilters(filters)

  // Nothing to filter on is a real state today: a city may be published before
  // it is tagged. Rendering an empty shell would only advertise the absence.
  if (!groups.length) return null

  return (
    <div className="rounded-lg border">
      <div className="flex items-center gap-3 px-4 py-3">
        <button
          type="button"
          onClick={() => onOpenChange(!open)}
          className="flex flex-1 items-center gap-2 text-left text-sm font-medium lg:cursor-default"
          aria-expanded={open}
          aria-controls="guide-facets"
        >
          <SlidersHorizontalIcon className="size-4 shrink-0 text-muted-foreground" />
          Refine
          {active > 0 && (
            <Badge variant="secondary" className="ml-1">
              {formatNumber(active)}
            </Badge>
          )}
        </button>

        <span className="text-sm text-muted-foreground">
          {formatNumber(resultCount)} {resultCount === 1 ? 'place' : 'places'}
        </span>

        {active > 0 && (
          <Button variant="ghost" size="sm" onClick={onClear} className="-mr-2">
            <XIcon className="size-4" />
            Clear
          </Button>
        )}
      </div>

      <div
        id="guide-facets"
        className={cn('border-t px-4 py-4', open ? 'block' : 'hidden lg:block')}
      >
        <div className="flex flex-col gap-5">
          {groups.map((group) => (
            <fieldset key={group.key}>
              <legend className="mb-2 font-heading text-xs uppercase tracking-wide text-muted-foreground">
                {group.title}
              </legend>

              <div className="flex flex-wrap gap-2">
                {group.options.map((option) => (
                  <button
                    key={option.value}
                    type="button"
                    role="checkbox"
                    aria-checked={option.selected}
                    disabled={option.disabled}
                    onClick={() => onToggle(group.key, option.value)}
                    className={cn(
                      'inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-sm transition-colors',
                      'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                      option.selected
                        ? 'border-foreground bg-foreground text-background'
                        : 'hover:bg-accent',
                      // Disabled, never hidden (RN-17): a greyed-out option
                      // teaches the shape of the guide. Removing it would make
                      // the panel silently change size as you click.
                      option.disabled && 'cursor-not-allowed opacity-40 hover:bg-transparent',
                    )}
                  >
                    {group.key === 'star' && (
                      <StarIcon
                        className={cn(
                          'size-3.5',
                          option.selected ? 'fill-current' : 'fill-amber-500 text-amber-500',
                        )}
                      />
                    )}
                    {option.label}
                    <span
                      className={cn(
                        'text-xs tabular-nums',
                        option.selected ? 'text-background/70' : 'text-muted-foreground',
                      )}
                    >
                      {formatNumber(option.count)}
                    </span>
                  </button>
                ))}
              </div>
            </fieldset>
          ))}
        </div>
      </div>
    </div>
  )
}
