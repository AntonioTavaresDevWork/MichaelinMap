import { useMemo, useState } from 'react'
import { CheckIcon, EyeOffIcon, SearchIcon, SparklesIcon, XIcon } from 'lucide-react'
import { toast } from 'sonner'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import {
  FACET_LABEL,
  FACET_ORDER,
  useAssignTag,
  useConfirmSuggestion,
  useRemoveTag,
} from '@/hooks/use-tags'
import { cn, mapRpcError } from '@/lib/utils'
import type { PlaceTag, Tag } from '@/types'

interface Props {
  placeId: string
  tags: Tag[]
  assigned: PlaceTag[]
}

/**
 * Tag assignment — the screen where the guide actually gets made.
 *
 * Tagging 511 places is the project's critical path, so this favours speed over
 * ceremony: one click assigns, one click removes, nothing is behind a dialog.
 * Machine guesses stay visually distinct from the curator's own calls (RN-15)
 * until he confirms them.
 */
export function TagPicker({ placeId, tags, assigned }: Props) {
  const [query, setQuery] = useState('')

  const assignTag = useAssignTag()
  const removeTag = useRemoveTag()
  const confirmSuggestion = useConfirmSuggestion()

  const assignedById = useMemo(
    () => new Map(assigned.map((pt) => [pt.tag_id, pt])),
    [assigned],
  )

  const needle = query.trim().toLowerCase()
  const grouped = useMemo(() => {
    const visible = needle
      ? tags.filter((tag) => tag.label.toLowerCase().includes(needle))
      : tags

    return FACET_ORDER.map((facet) => ({
      facet,
      tags: visible.filter((tag) => tag.facet === facet && tag.active),
    })).filter((group) => group.tags.length > 0)
  }, [tags, needle])

  const suggestedCount = assigned.filter((pt) => pt.source === 'suggested').length

  function onError(error: unknown) {
    toast.error(mapRpcError(error))
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center gap-3">
        <div className="relative flex-1">
          <SearchIcon className="pointer-events-none absolute left-2.5 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Filter tags"
            className="pl-8"
            aria-label="Filter the tag vocabulary"
          />
        </div>
        <span className="shrink-0 text-xs text-muted-foreground">
          {assigned.length} assigned
          {suggestedCount > 0 && ` · ${suggestedCount} suggested`}
        </span>
      </div>

      {suggestedCount > 0 && (
        <p className="rounded-md border border-info/30 bg-info/5 px-3 py-2 text-xs text-muted-foreground">
          <SparklesIcon className="mr-1 inline size-3.5 text-info" />
          Suggested tags came from the import, not from you. Confirm the ones that are right and
          drop the rest — they stay marked until you do.
        </p>
      )}

      {grouped.length === 0 && (
        <p className="text-sm text-muted-foreground">No tag matches “{query}”.</p>
      )}

      {grouped.map((group) => (
        <section key={group.facet} className="flex flex-col gap-2">
          <h3 className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
            {FACET_LABEL[group.facet]}
          </h3>
          <div className="flex flex-wrap gap-1.5">
            {group.tags.map((tag) => {
              const link = assignedById.get(tag.id)
              const isSuggested = link?.source === 'suggested'

              return (
                <div key={tag.id} className="flex items-center">
                  <button
                    type="button"
                    onClick={() =>
                      link
                        ? removeTag.mutate({ placeId, tagId: tag.id }, { onError })
                        : assignTag.mutate({ placeId, tagId: tag.id }, { onError })
                    }
                    className={cn(
                      'inline-flex items-center gap-1 rounded-md border px-2 py-1 text-xs transition-colors',
                      link
                        ? isSuggested
                          ? 'border-info/50 bg-info/10 text-foreground'
                          : 'border-foreground/20 bg-foreground text-background'
                        : 'border-input text-muted-foreground hover:bg-accent hover:text-foreground',
                      isSuggested && 'rounded-r-none border-r-0',
                    )}
                    aria-pressed={Boolean(link)}
                  >
                    {tag.admin_only && (
                      <EyeOffIcon className="size-3" aria-label="Never shown to visitors" />
                    )}
                    {tag.label}
                    {link && !isSuggested && <XIcon className="size-3 opacity-60" />}
                  </button>

                  {isSuggested && (
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      className="h-[26px] rounded-l-none border-info/50 bg-info/10 px-1.5"
                      onClick={() =>
                        confirmSuggestion.mutate({ placeId, tagId: tag.id }, { onError })
                      }
                      aria-label={`Confirm suggested tag ${tag.label}`}
                      title="Confirm this suggestion"
                    >
                      <CheckIcon className="size-3.5" />
                    </Button>
                  )}
                </div>
              )
            })}
          </div>
        </section>
      ))}
    </div>
  )
}
