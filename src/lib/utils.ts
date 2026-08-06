import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * Turns a Supabase/Postgres error into something worth showing a human.
 *
 * Raised errors carry a Postgres SQLSTATE; RPCs in this project raise with
 * meaningful codes so the UI can react without string-matching messages.
 */
export function mapRpcError(error: unknown): string {
  if (!error) return 'Something went wrong.'

  if (typeof error === 'object' && error !== null) {
    const err = error as { code?: string; message?: string; details?: string }

    switch (err.code) {
      case '23505':
        return 'That already exists.'
      case '23503':
        return 'That references something which no longer exists.'
      case '23514':
        return 'That breaks a rule of the guide — check tier, star and visited.'
      case '42501':
      case 'PGRST301':
        return 'You are not allowed to do that.'
      case 'P0001':
        return err.message ?? 'Rejected by the server.'
      default:
        break
    }

    if (err.message) return err.message
  }

  return 'Something went wrong.'
}

// The product is en-US. See ADR-02 in the bible — no BR formatting here.
const dateFormatter = new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
})

const monthYearFormatter = new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: 'short',
})

const numberFormatter = new Intl.NumberFormat('en-US')

export function formatDate(value: string | Date | null | undefined): string {
  if (!value) return ''
  const date = typeof value === 'string' ? new Date(value) : value
  return Number.isNaN(date.getTime()) ? '' : dateFormatter.format(date)
}

export function formatMonthYear(value: string | Date | null | undefined): string {
  if (!value) return ''
  const date = typeof value === 'string' ? new Date(value) : value
  return Number.isNaN(date.getTime()) ? '' : monthYearFormatter.format(date)
}

export function formatNumber(value: number | null | undefined): string {
  if (value === null || value === undefined || Number.isNaN(value)) return ''
  return numberFormatter.format(value)
}

/** Staleness is surfaced past ~18 months, so the visitor can weigh it. */
export function monthsSince(value: string | Date | null | undefined): number | null {
  if (!value) return null
  const date = typeof value === 'string' ? new Date(value) : value
  if (Number.isNaN(date.getTime())) return null

  const now = new Date()
  return (
    (now.getFullYear() - date.getFullYear()) * 12 + (now.getMonth() - date.getMonth())
  )
}

/** URL-safe slug, matching the rule used by the import script. */
export function slugify(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}
