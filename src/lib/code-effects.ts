import { filtersFromParams, filtersToParams, type GuideFilters } from '@/lib/guide-filters'
import type { CodeTheme, PresetFilter } from '@/types'

/**
 * What a code does to the interface.
 *
 * Codes restyle, reorder, highlight and add a message. They never remove
 * content (RN-21) — nothing here hides a place from someone who has no code,
 * and the one effect that narrows the view (the preset filter) lands in the
 * normal filter panel, selected and clearable like any other choice.
 */

// ---------------------------------------------------------------------------
// Map style
// ---------------------------------------------------------------------------

const MAP_STYLE_URLS: Record<string, string> = {
  default: 'https://tiles.openfreemap.org/styles/liberty',
  bright: 'https://tiles.openfreemap.org/styles/bright',
  minimal: 'https://tiles.openfreemap.org/styles/positron',
  dark: 'https://tiles.openfreemap.org/styles/dark',
  slate: 'https://tiles.openfreemap.org/styles/fiord',
}

export const DEFAULT_MAP_STYLE_URL = MAP_STYLE_URLS.default

/**
 * A token the curator typed years ago must never break the map. An unknown
 * value — the seeded `DEMO` row carries `amber`, which was never a style —
 * falls back to the default instead of handing MapLibre a bad URL.
 */
export function mapStyleUrl(token: string | null | undefined): string {
  if (!token) return DEFAULT_MAP_STYLE_URL
  return MAP_STYLE_URLS[token] ?? DEFAULT_MAP_STYLE_URL
}

// ---------------------------------------------------------------------------
// Colour
// ---------------------------------------------------------------------------

/** `#abc` or `#aabbcc` → [r, g, b] in 0-255. Anything else is not ours to read. */
function parseHex(value: string | undefined | null): [number, number, number] | null {
  if (!value) return null

  const hex = value.trim().replace(/^#/, '')
  const full =
    hex.length === 3
      ? hex
          .split('')
          .map((char) => char + char)
          .join('')
      : hex

  if (!/^[0-9a-f]{6}$/i.test(full)) return null

  return [
    Number.parseInt(full.slice(0, 2), 16),
    Number.parseInt(full.slice(2, 4), 16),
    Number.parseInt(full.slice(4, 6), 16),
  ]
}

/** WCAG relative luminance, 0 (black) to 1 (white). Null when not a hex colour. */
export function relativeLuminance(value: string | undefined | null): number | null {
  const rgb = parseHex(value)
  if (!rgb) return null

  const [r, g, b] = rgb.map((channel) => {
    const c = channel / 255
    return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4
  })

  return 0.2126 * r + 0.7152 * g + 0.0722 * b
}

export function isDarkColor(value: string | undefined | null): boolean {
  const luminance = relativeLuminance(value)
  return luminance !== null && luminance < 0.45
}

const NEAR_BLACK = '#0a0a0a'
const NEAR_WHITE = '#fafafa'

/**
 * Readable text on a given background.
 *
 * The curator picks one colour and gets contrast for free. Without this a code
 * with a pale primary would render white-on-yellow buttons, which is the
 * accessibility hole BL-19 names for code themes — cheaper to close here than
 * to police in every component.
 */
export function contrastOn(value: string | undefined | null): string {
  return isDarkColor(value) ? NEAR_WHITE : NEAR_BLACK
}

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

/**
 * The design tokens a code is allowed to move.
 *
 * Every shadcn component in the app reads these, so overriding them restyles
 * the whole interface without touching a single component. The list is kept
 * short on purpose: broad strokes belong to the code, fine detail does not.
 */
const MANAGED_PROPERTIES = [
  '--primary',
  '--primary-foreground',
  '--ring',
  '--background',
  '--foreground',
  '--card',
  '--card-foreground',
  '--popover',
  '--popover-foreground',
] as const

export function clearCodeTheme(): void {
  const root = document.documentElement
  for (const property of MANAGED_PROPERTIES) root.style.removeProperty(property)
  root.classList.remove('dark')
}

/**
 * Paint the code over the default palette.
 *
 * A dark background also flips the `dark` class, because a single overridden
 * `--background` would leave borders, muted text and accents on their light
 * values — the page would be dark with pale-grey seams everywhere. Nothing
 * else in the app owns that class today (BL-23: there is no theme switcher),
 * so the code can take it.
 */
export function applyCodeTheme(theme: CodeTheme | null | undefined): void {
  clearCodeTheme()
  if (!theme) return

  const root = document.documentElement
  const set = (property: string, value: string) => root.style.setProperty(property, value)

  if (theme.background && isDarkColor(theme.background)) root.classList.add('dark')

  if (theme.background) {
    set('--background', theme.background)
    set('--card', theme.background)
    set('--popover', theme.background)
  }

  const foreground = theme.foreground ?? (theme.background ? contrastOn(theme.background) : null)
  if (foreground) {
    set('--foreground', foreground)
    set('--card-foreground', foreground)
    set('--popover-foreground', foreground)
  }

  if (theme.primary) {
    set('--primary', theme.primary)
    set('--primary-foreground', contrastOn(theme.primary))
    set('--ring', theme.primary)
  }
}

// ---------------------------------------------------------------------------
// Preset filter
// ---------------------------------------------------------------------------

/** The stored preset, read back through the same parser the URL uses (RN-19). */
export function presetToFilters(preset: PresetFilter | null | undefined): GuideFilters | null {
  if (!preset) return null

  const params = new URLSearchParams()
  for (const [key, value] of Object.entries(preset)) {
    if (typeof value === 'string' && value) params.set(key, value)
  }

  if (![...params.keys()].length) return null
  return filtersFromParams(params)
}

/** The admin builds a preset with the guide's own serialiser, never by hand. */
export function filtersToPreset(filters: GuideFilters): PresetFilter | null {
  const params = filtersToParams(filters)
  const preset: PresetFilter = {}
  for (const [key, value] of params.entries()) preset[key] = value

  return Object.keys(preset).length ? preset : null
}
