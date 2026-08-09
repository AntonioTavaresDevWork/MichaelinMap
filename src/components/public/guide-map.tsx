import { useEffect, useRef, useState } from 'react'
import {
  LngLatBounds,
  Map as MapLibreMap,
  Marker,
  NavigationControl,
} from 'maplibre-gl'
import 'maplibre-gl/dist/maplibre-gl.css'
import { DEFAULT_MAP_STYLE_URL } from '@/lib/code-effects'
import type { Place, PinStyle } from '@/types'

/**
 * Tiles come from OpenFreeMap: free, no key, no quota (the ADR-06 logic — the
 * guide should not depend on a billed API). MapLibre was chosen precisely
 * because the style can be swapped at runtime, which is what a code does.
 */

interface Props {
  places: Place[]
  selectedId: string | null
  onSelect: (placeId: string | null) => void
  /** Set by the active code; falls back to the house style. */
  styleUrl?: string
  pinStyle?: PinStyle | null
  /** Place ids a code singles out. They keep a ring so they read at a glance. */
  highlighted?: Set<string>
}

/** A pin says where. The colour says how much the curator rates it. */
function markerElement(
  place: Place,
  selected: boolean,
  highlighted: boolean,
  pinStyle: PinStyle | null | undefined,
): HTMLElement {
  const el = document.createElement('button')
  el.type = 'button'
  el.setAttribute('aria-label', place.name)

  el.className = [
    'grid place-items-center border-2 border-background shadow-sm transition-transform',
    pinStyle?.shape === 'square' ? 'rounded-sm' : 'rounded-full',
    selected ? 'size-6 ring-2 ring-foreground' : highlighted ? 'size-5' : 'size-4',
  ].join(' ')

  // A code may repaint the pins, but only wholesale. The judgment colouring
  // below is the default and stays the default: a code decorates the guide, it
  // does not get to invent a per-place verdict.
  const custom = (highlighted ? pinStyle?.highlightColor : null) ?? pinStyle?.color

  if (custom) {
    el.style.backgroundColor = custom
  } else if (place.starred) {
    el.classList.add('bg-verdict')
  } else if (place.tier === 'destination' || place.tier === 'experience') {
    el.classList.add('bg-foreground')
  } else {
    el.classList.add('bg-muted-foreground')
  }

  if (highlighted) {
    // A ring rather than a different colour, so a highlighted place still shows
    // its tier — the code adds emphasis without overwriting the verdict.
    // Deliberately a fixed colour, not the code's `--primary`.
    //
    // Deriving it from the theme looked tidier and was wrong twice: a curator
    // who sets the accent and the pin to the same hex — the natural thing to do
    // — got a pin ringed in its own colour, silently erasing the one emphasis
    // RN-21 allows a code. And reading it back through `getComputedStyle` inside
    // the marker loop forced a style recalc per pin on every tap.
    el.style.boxShadow = `0 0 0 3px ${pinStyle?.highlightColor ?? 'rgb(245 158 11 / 0.55)'}`
  }

  if (place.starred) {
    el.innerHTML =
      '<svg viewBox="0 0 24 24" fill="white" class="size-2.5"><path d="M12 2l2.9 6.3 6.8.8-5 4.7 1.3 6.8L12 17.3 6 20.6l1.3-6.8-5-4.7 6.8-.8z"/></svg>'
  }

  return el
}

export function GuideMap({
  places,
  selectedId,
  onSelect,
  styleUrl = DEFAULT_MAP_STYLE_URL,
  pinStyle = null,
  highlighted,
}: Props) {
  const container = useRef<HTMLDivElement>(null)
  const map = useRef<MapLibreMap | null>(null)
  const markers = useRef(new globalThis.Map<string, Marker>())
  const fittedFor = useRef<string | null>(null)
  const [loaded, setLoaded] = useState(false)
  const [failure, setFailure] = useState<string | null>(null)

  // Read once, so a code arriving later swaps the style instead of rebuilding
  // the whole map — and so a visitor who already has one starts on it.
  const initialStyle = useRef(styleUrl)

  useEffect(() => {
    if (!container.current) return

    const markerStore = markers.current
    const node = container.current

    const instance = new MapLibreMap({
      container: node,
      style: initialStyle.current,
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

  /**
   * Swap the basemap when the code changes it.
   *
   * Markers are DOM overlays, not style layers, so they survive this untouched
   * — which is the whole reason ADR-05 picked MapLibre over an embed.
   */
  useEffect(() => {
    const instance = map.current
    if (!instance || !loaded) return
    if (styleUrl === initialStyle.current) return

    initialStyle.current = styleUrl
    instance.setStyle(styleUrl)
  }, [styleUrl, loaded])

  // Markers follow the list. When the filter narrows the list, the map narrows
  // with it — one filter state, never two (see CLAUDE.md).
  useEffect(() => {
    const instance = map.current
    if (!instance) return

    markers.current.forEach((marker) => marker.remove())
    markers.current.clear()

    for (const place of places) {
      if (place.lat == null || place.lng == null) continue

      const element = markerElement(
        place,
        place.id === selectedId,
        Boolean(highlighted?.has(place.id)),
        pinStyle,
      )

      const marker = new Marker({ element })
        .setLngLat([Number(place.lng), Number(place.lat)])
        .addTo(instance)

      marker.getElement().addEventListener('click', (event) => {
        event.stopPropagation()
        onSelect(place.id)
      })

      markers.current.set(place.id, marker)
    }
  }, [places, selectedId, onSelect, pinStyle, highlighted])

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
