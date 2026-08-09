import { CheckIcon, SlidersHorizontalIcon, StarIcon, XIcon } from 'lucide-react'
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
    <div className="overflow-hidden rounded-lg border bg-card">
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
          <span className="font-mono">{formatNumber(resultCount)}</span>{' '}
          {resultCount === 1 ? 'place' : 'places'}
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
              <legend className="mb-2.5 text-[11px] font-semibold uppercase tracking-[0.11em] text-muted-foreground">
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
                      'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background',
                      // Selected state carries on three channels, not one.
                      //
                      // A lime wash alone was 1.07:1 against the panel and the
                      // label swap was 1.02:1 — a pure hue change at equal
                      // luminance, which disappears completely under
                      // deuteranopia. Colour may reinforce the state; it may not
                      // be the state. Hence the filled ground, the full-strength
                      // border and the check glyph.
                      option.selected
                        ? 'border-brand-ink bg-brand-ink font-medium text-background'
                        : 'hover:bg-muted',
                      // Disabled, never hidden (RN-17): a greyed-out option
                      // teaches the shape of the guide. Removing it would make
                      // the panel silently change size as you click.
                      option.disabled && 'cursor-not-allowed opacity-40 hover:bg-transparent',
                    )}
                  >
                    {option.selected ? (
                      <CheckIcon className="size-3.5 shrink-0" />
                    ) : (
                      group.key === 'star' && (
                        // The star depicts the judgment, so it keeps the verdict
                        // colour — but only while it is not the state indicator.
                        <StarIcon className="size-3.5 shrink-0 fill-verdict text-verdict" />
                      )
                    )}
                    {option.label}
                    <span
                      className={cn(
                        'font-mono text-[11px]',
                        // 70% of the ink failed AA at 11px (3.35:1). The count is
                        // the only part of the chip that is purely a figure.
                        option.selected ? 'text-background/80' : 'text-muted-foreground',
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
