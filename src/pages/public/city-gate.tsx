import { Link } from 'react-router-dom'
import { ArrowRightIcon } from 'lucide-react'
import { Skeleton } from '@/components/ui/skeleton'
import { usePublishedPlaces, useCities } from '@/hooks/use-public-guide'
import { formatNumber } from '@/lib/utils'

/**
 * The first screen, and the only gate.
 *
 * Nobody browses every place on earth, so the city is chosen before anything
 * else and every other control operates inside it (bible §8). Cities appear as
 * peers with their counts — a one-place city is not hidden, it is just honest
 * about being one place (DP-02).
 */
export function CityGatePage() {
  const places = usePublishedPlaces()
  const cities = useCities(places.data)

  return (
    <div className="mx-auto w-full max-w-3xl px-4 py-20">
      <h1 className="font-heading text-4xl font-extrabold tracking-[-0.025em] text-balance">
        Where are you?
      </h1>
      <p className="mt-4 max-w-prose text-[17px] leading-relaxed text-muted-foreground">
        Pick a city and everything else follows. Nobody browses every place on earth.
      </p>

      {places.isLoading && (
        <div className="mt-12 flex flex-col gap-2">
          {Array.from({ length: 5 }).map((_, i) => (
            <Skeleton key={i} className="h-16 w-full" />
          ))}
        </div>
      )}

      {places.error && (
        <p className="mt-12 text-sm text-muted-foreground">
          The guide is not loading right now. Try again in a moment.
        </p>
      )}

      {!places.isLoading && !places.error && cities.length === 0 && (
        <div className="mt-12 rounded-lg border border-dashed bg-card p-8">
          <p className="font-semibold">Nothing is public yet.</p>
          <p className="mt-2 max-w-prose text-sm leading-relaxed text-muted-foreground">
            The places exist — they are just still being reviewed. A guide nobody has checked is
            just a list of pins, and that is the thing this is trying not to be.
          </p>
        </div>
      )}

      {cities.length > 0 && (
        <ul className="mt-12 divide-y overflow-hidden rounded-lg border">
          {cities.map((city) => (
            <li key={city.slug}>
              <Link
                to={`/city/${city.slug}`}
                className="flex items-center gap-4 bg-card px-5 py-4 transition-colors hover:bg-muted"
              >
                <span className="flex-1 text-[17px] font-semibold tracking-[-0.01em]">
                  {city.name}
                </span>
                {/* The figure is mono so the column lines up instead of
                    drifting; the noun stays prose, because "Austin 1" read
                    aloud is not a sentence. */}
                <span className="text-[13px] text-muted-foreground">
                  <span className="font-mono">{formatNumber(city.count)}</span>{' '}
                  {city.count === 1 ? 'place' : 'places'}
                </span>
                <ArrowRightIcon className="size-4 text-muted-foreground" />
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
