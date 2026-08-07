import { useEffect, useRef, useState } from 'react'
import {
  config as maplibreConfig,
  LngLatBounds,
  Map as MapLibreMap,
  Marker,
  NavigationControl,
} from 'maplibre-gl'
import 'maplibre-gl/dist/maplibre-gl.css'
// `?worker&url` bundles the worker — resolving its own imports — and returns
// the URL. Plain `?url` copies the file verbatim, and it would arrive still
// importing `./maplibre-gl-shared.mjs`, which nothing emits next to it.
import maplibreWorkerUrl from 'maplibre-gl/dist/maplibre-gl-worker.mjs?worker&url'
import type { Place } from '@/types'

/**
 * Point MapLibre at its own worker, explicitly.
 *
 * MapLibre v6 builds the worker path at runtime by concatenating a string and
 * resolving it against `import.meta.url`. No bundler can see through that, so
 * Rollup never emits the file and the URL points at an asset that does not
 * exist. The worker is what fetches and decodes vector tiles, so without it the
 * map draws its background colour and nothing else — no error, no failed
 * request. `config.WORKER_URL` is the supported way out.
 */
maplibreConfig.WORKER_URL = maplibreWorkerUrl

/**
 * OpenFreeMap: free, no key, no quota (ADR-06 logic — the guide should not
 * depend on a billed API). MapLibre was chosen precisely because the style can
 * be swapped at runtime, which is what the Codes feature needs in F-05.
 */
const STYLE_URL = 'https://tiles.openfreemap.org/styles/liberty'

interface Props {
  places: Place[]
  selectedId: string | null
  onSelect: (placeId: string | null) => void
}

/** A pin says where. The colour says how much the curator rates it. */
function markerElement(place: Place, selected: boolean): HTMLElement {
  const el = document.createElement('button')
  el.type = 'button'
  el.setAttribute('aria-label', place.name)
  el.className = [
    'grid place-items-center rounded-full border-2 shadow-sm transition-transform',
    selected ? 'size-6 border-background ring-2 ring-foreground' : 'size-4 border-background',
    place.starred
      ? 'bg-amber-500'
      : place.tier === 'destination' || place.tier === 'experience'
        ? 'bg-foreground'
        : 'bg-muted-foreground',
  ].join(' ')

  if (place.starred) {
    el.innerHTML =
      '<svg viewBox="0 0 24 24" fill="white" class="size-2.5"><path d="M12 2l2.9 6.3 6.8.8-5 4.7 1.3 6.8L12 17.3 6 20.6l1.3-6.8-5-4.7 6.8-.8z"/></svg>'
  }

  return el
}

export function GuideMap({ places, selectedId, onSelect }: Props) {
  const container = useRef<HTMLDivElement>(null)
  const map = useRef<MapLibreMap | null>(null)
  const markers = useRef(new globalThis.Map<string, Marker>())
  const fittedFor = useRef<string | null>(null)
  const [loaded, setLoaded] = useState(false)
  const [failure, setFailure] = useState<string | null>(null)

  useEffect(() => {
    if (!container.current) return

    const markerStore = markers.current
    const node = container.current

    const instance = new MapLibreMap({
      container: node,
      style: STYLE_URL,
      center: [-97.74, 30.27],
      zoom: 10,
      attributionControl: { compact: true },
    })

    instance.addControl(new NavigationControl({ showCompass: false }), 'top-right')

    instance.on('load', () => {
      instance.resize()
      setLoaded(true)
    })

    instance.on('error', (event) => {
      const message = event?.error?.message ?? 'Unknown map error'
      console.error('[GuideMap]', message, event)
      setFailure(message)
    })

    // Height comes from a vh unit and a sticky wrapper, both of which settle
    // after the first paint and change again on rotate or resize.
    const observer = new ResizeObserver(() => instance.resize())
    observer.observe(node)

    map.current = instance

    return () => {
      observer.disconnect()
      markerStore.forEach((marker) => marker.remove())
      markerStore.clear()
      instance.remove()
      map.current = null
      setLoaded(false)
    }
  }, [])

  // Markers follow the list. When F-04 narrows the list, the map narrows with
  // it — one filter state, never two (see CLAUDE.md).
  useEffect(() => {
    const instance = map.current
    if (!instance) return

    markers.current.forEach((marker) => marker.remove())
    markers.current.clear()

    for (const place of places) {
      if (place.lat == null || place.lng == null) continue

      const marker = new Marker({ element: markerElement(place, place.id === selectedId) })
        .setLngLat([Number(place.lng), Number(place.lat)])
        .addTo(instance)

      marker.getElement().addEventListener('click', (event) => {
        event.stopPropagation()
        onSelect(place.id)
      })

      markers.current.set(place.id, marker)
    }
  }, [places, selectedId, onSelect])

  /**
   * Fit the view only once the style is loaded and the container has real size.
   *
   * WHY both conditions: fitBounds against a zero-width container computes a
   * degenerate zoom, and the map then never works out which tiles it needs —
   * it just sits there, correctly sized, requesting nothing. Resizing later
   * fixes the canvas but does not recompute the camera, so the bad view sticks.
   */
  useEffect(() => {
    const instance = map.current
    if (!instance || !loaded) return

    const key = places.map((p) => p.id).join(',')
    if (fittedFor.current === key) return

    const withCoords = places.filter((p) => p.lat != null && p.lng != null)
    if (withCoords.length === 0) return
    if (instance.getContainer().clientWidth === 0) return

    const bounds = new LngLatBounds()
    for (const place of withCoords) {
      bounds.extend([Number(place.lng), Number(place.lat)])
    }

    instance.fitBounds(bounds, {
      padding: 48,
      maxZoom: withCoords.length === 1 ? 15 : 14,
      duration: 0,
    })

    fittedFor.current = key
  }, [places, loaded])

  // Clicking the water clears the selection, so the list goes back to whole.
  useEffect(() => {
    const instance = map.current
    if (!instance) return

    const clear = () => onSelect(null)
    instance.on('click', clear)
    return () => {
      instance.off('click', clear)
    }
  }, [onSelect])

  // Bring the chosen place into view when the selection came from the list.
  useEffect(() => {
    const instance = map.current
    if (!instance || !loaded || !selectedId) return

    const place = places.find((p) => p.id === selectedId)
    if (!place || place.lat == null || place.lng == null) return

    instance.easeTo({ center: [Number(place.lng), Number(place.lat)], duration: 400 })
  }, [selectedId, places, loaded])

  return (
    <div className="relative size-full">
      <div ref={container} className="size-full" />

      {failure && (
        <div className="absolute inset-x-0 bottom-0 bg-background/95 px-3 py-2 text-xs text-destructive">
          Map failed to load: {failure}
        </div>
      )}
    </div>
  )
}
