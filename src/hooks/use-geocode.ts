import { useEffect, useState } from 'react'
import { useQuery } from '@tanstack/react-query'

export interface GeocodeResult {
  displayName: string
  lat: number
  lng: number
  /** Street address without the city tail, when Nominatim gives enough to build one. */
  address: string | null
  /** Municipality as OSM sees it — our `area`, not necessarily our city gate. */
  locality: string | null
  country: string | null
}

interface NominatimAddress {
  house_number?: string
  road?: string
  neighbourhood?: string
  suburb?: string
  city?: string
  town?: string
  village?: string
  municipality?: string
  country?: string
}

interface NominatimItem {
  display_name: string
  lat: string
  lon: string
  address?: NominatimAddress
}

function toResult(item: NominatimItem): GeocodeResult {
  const a = item.address ?? {}
  const street = [a.house_number, a.road].filter(Boolean).join(' ')

  return {
    displayName: item.display_name,
    lat: Number(item.lat),
    lng: Number(item.lon),
    address: street || null,
    locality: a.city ?? a.town ?? a.village ?? a.municipality ?? a.suburb ?? a.neighbourhood ?? null,
    country: a.country ?? null,
  }
}

/**
 * Debounce, so typing a name does not fire a request per keystroke.
 *
 * Nominatim's usage policy caps this at one request per second and the service
 * is donated infrastructure — 700ms plus React Query's cache keeps us well
 * inside it without any client-side throttle bookkeeping.
 */
function useDebounced(value: string, delay = 700): string {
  const [debounced, setDebounced] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])

  return debounced
}

/** Free-text place lookup. Nominatim needs no key (ADR-06). */
export function useGeocodeSearch(query: string) {
  const debounced = useDebounced(query)
  const enabled = debounced.trim().length >= 4

  return useQuery({
    queryKey: ['geocode', debounced],
    enabled,
    // Results for a given string do not change meaningfully within a session.
    staleTime: 60 * 60 * 1000,
    queryFn: async (): Promise<GeocodeResult[]> => {
      const url = new URL('https://nominatim.openstreetmap.org/search')
      url.searchParams.set('q', debounced.trim())
      url.searchParams.set('format', 'jsonv2')
      url.searchParams.set('addressdetails', '1')
      url.searchParams.set('limit', '6')

      const response = await fetch(url, { headers: { Accept: 'application/json' } })
      if (!response.ok) throw new Error('Address lookup failed.')

      const data: NominatimItem[] = await response.json()
      return data.map(toResult)
    },
  })
}

/** Turns the phone's coordinates into an address, for adding a place while standing in it. */
export async function reverseGeocode(lat: number, lng: number): Promise<GeocodeResult | null> {
  const url = new URL('https://nominatim.openstreetmap.org/reverse')
  url.searchParams.set('lat', String(lat))
  url.searchParams.set('lon', String(lng))
  url.searchParams.set('format', 'jsonv2')
  url.searchParams.set('addressdetails', '1')

  const response = await fetch(url, { headers: { Accept: 'application/json' } })
  if (!response.ok) return null

  const item: NominatimItem = await response.json()
  return item?.lat ? toResult(item) : null
}
