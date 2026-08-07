import { useCallback, useState } from 'react'
import { Link } from 'react-router-dom'
import { DicesIcon, MapPinIcon, StarIcon } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { spinRoulette } from '@/lib/roulette'
import type { Place } from '@/types'

interface Props {
  /** The filtered result, never the whole city — a spin obeys the filters. */
  places: Place[]
  tierLabel: (slug: string) => string | null
  onLocate: (placeId: string) => void
}

export function RouletteButton({ places, tierLabel, onLocate }: Props) {
  const [landed, setLanded] = useState<Place | null>(null)

  const spin = useCallback(() => {
    setLanded((previous) => spinRoulette(places, { excludeId: previous?.id ?? null }))
  }, [places])

  // Two places is the floor: below that there is no decision left to make, and
  // a die that always rolls the same number is worse than no die.
  if (places.length < 2) return null

  const tier = landed?.tier ? tierLabel(landed.tier) : null

  return (
    <>
      <Button variant="outline" size="sm" onClick={spin}>
        <DicesIcon className="size-4" />
        Just pick for me
      </Button>

      <Dialog open={landed !== null} onOpenChange={(open) => !open && setLanded(null)}>
        <DialogContent>
          {landed && (
            <>
              <DialogHeader>
                <DialogDescription>Fine. Go here.</DialogDescription>
                <DialogTitle className="flex flex-wrap items-center gap-2 text-xl">
                  {landed.name}
                  {landed.starred && (
                    <StarIcon className="size-5 fill-current text-amber-500" aria-label="Top pick" />
                  )}
                </DialogTitle>
              </DialogHeader>

              <div className="flex flex-wrap items-center gap-2">
                {tier && <Badge variant="secondary">{tier}</Badge>}
                <Badge variant="outline">{landed.place_type.replace('_', ' ')}</Badge>
                {landed.area && <Badge variant="outline">{landed.area}</Badge>}
              </div>

              {landed.the_dish && <p className="font-heading text-base">Order the {landed.the_dish}.</p>}

              {!landed.the_dish && landed.curator_note && (
                <p className="text-sm text-muted-foreground">{landed.curator_note}</p>
              )}

              <div className="flex flex-wrap gap-2">
                <Button asChild size="sm">
                  <Link to={`/place/${landed.slug}`}>Take me there</Link>
                </Button>

                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    onLocate(landed.id)
                    setLanded(null)
                  }}
                >
                  <MapPinIcon className="size-4" />
                  On the map
                </Button>

                <Button variant="ghost" size="sm" onClick={spin}>
                  <DicesIcon className="size-4" />
                  Again
                </Button>
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>
    </>
  )
}
