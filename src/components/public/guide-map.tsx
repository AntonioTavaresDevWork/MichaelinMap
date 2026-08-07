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
 * resolving it against `import.meta.url`:
 *
 *   new URL(`./maplibre-gl-worker.mjs`, import.meta.url)
 *
 * No bundler can see through that, so Rollup never emits the file and the URL
 * ends up pointing at `/assets/maplibre-gl-worker.mjs`, which does not exist.
 * The worker request then hangs, and since the worker is what fetches and
 * decodes vector tiles, the map renders its background colour and nothing else
 * — no error, no failed request, just a blank canvas with the markers floating
 * on top. `config.WORKER_URL` is the supported way out.
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
  const ready = useRef(false)
  const [failure, setFailure] = useState<string | null>(null)

  // One map per mount. StrictMode runs effects twice in development, so the
  // cleanup has to fully dispose or the second run leaves an orphan canvas.
  useEffect(() => {
    if (!container.current) return

    // Captured for the cleanup: by the time it runs, `markers.current` may
    // already point somewhere else.
    const markerStore = markers.current

    const instance = new MapLibreMap({
      container: container.current,
      style: STYLE_URL,
      center: [-97.74, 30.27],
      zoom: 10,
      attributionControl: { compact: true },
    })

    instance.addControl(new NavigationControl({ showCompass: false }), 'top-right')

    instance.on('load', () => {
      ready.current = true
      // The container is often laid out after the map is constructed — inside a
      // lazy boundary especially. Without this the canvas keeps whatever size it
      // had at construction, which is how a map ends up grey and empty.
      instance.resize()
    })

    // A failing style or tile source is otherwise silent: the map just sits
    // there grey. Surface it instead of making someone open devtools.
    instance.on('error', (event) => {
      const message = event?.error?.message ?? 'Unknown map error'
      console.error('[GuideMap]', message, event)
      setFailure(message)
    })

    // Height comes from a vh unit and a sticky wrapper, both of which settle
    // after the first paint and change again on rotate or resize.
    const observer = new ResizeObserver(() => instance.resize())
    observer.observe(container.current)

    map.current = instance

    return () => {
      observer.disconnect()
      ready.current = false
      markerStore.forEach((marker) => marker.remove())
      markerStore.clear()
      instance.remove()
      map.current = null
    }
  }, [])

  // Markers follow the list. When F-04 narrows the list, the map narrows with
  // it — one filter state, never two (see CLAUDE.md).
  useEffect(() => {
    const instance = map.current
    if (!instance) return

    markers.current.forEach((marker) => marker.remove())
    markers.current.clear()

    const bounds = new LngLatBounds()
    let plotted = 0

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
      bounds.extend([Number(place.lng), Number(place.lat)])
      plotted += 1
    }

    if (plotted > 0) {
      instance.fitBounds(bounds, {
        padding: 48,
        maxZoom: plotted === 1 ? 15 : 14,
        duration: 0,
      })
    }
  }, [places, selectedId, onSelect])

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
    if (!instance || !selectedId) return

    const place = places.find((p) => p.id === selectedId)
    if (!place || place.lat == null || place.lng == null) return

    instance.easeTo({
      center: [Number(place.lng), Number(place.lat)],
      duration: 400,
    })
  }, [selectedId, places])

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
