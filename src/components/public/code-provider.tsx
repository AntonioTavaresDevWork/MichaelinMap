import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { useSearchParams } from 'react-router-dom'
import { supabase } from '@/lib/supabase/client'
import { ActiveCodeContext, useActiveCode, type ActiveCodeState } from '@/lib/code-context'
import type { RedeemedCode } from '@/types'

/**
 * Holds the code a visitor has entered.
 *
 * The code itself is remembered locally so it survives a reload — Michael hands
 * one to a person, not to a browsing session. What is *not* remembered is its
 * effect: every load re-asks the server, so switching a code off in the admin
 * takes hold on the next page view rather than living forever in whatever
 * localStorage happens to hold (RN-20 — the server is the only authority on
 * whether a code is live).
 */
const STORAGE_KEY = 'mm.code'

/** The RPC answers `{ok: false}` and nothing else on every failure — no oracle. */
function readRedeemed(payload: unknown): RedeemedCode | null {
  if (typeof payload !== 'object' || payload === null) return null

  const row = payload as Record<string, unknown>
  if (row.ok !== true || typeof row.code !== 'string') return null

  return {
    code: row.code,
    label: typeof row.label === 'string' ? row.label : null,
    message: typeof row.message === 'string' ? row.message : null,
    theme: (row.theme as RedeemedCode['theme']) ?? null,
    pin_style: (row.pin_style as RedeemedCode['pin_style']) ?? null,
    preset_filter: (row.preset_filter as RedeemedCode['preset_filter']) ?? null,
    highlighted_places: Array.isArray(row.highlighted_places)
      ? row.highlighted_places.filter((id): id is string => typeof id === 'string')
      : [],
  }
}

function readStoredCode(): string | null {
  try {
    return globalThis.localStorage?.getItem(STORAGE_KEY) ?? null
  } catch {
    // Private browsing and locked-down settings both throw here. A guide that
    // cannot remember a code still works; one that crashes does not.
    return null
  }
}

function writeStoredCode(value: string | null): void {
  try {
    if (value) globalThis.localStorage?.setItem(STORAGE_KEY, value)
    else globalThis.localStorage?.removeItem(STORAGE_KEY)
  } catch {
    /* see readStoredCode */
  }
}

export function CodeProvider({ children }: { children: ReactNode }) {
  const [code, setCode] = useState<RedeemedCode | null>(null)

  const redeem = useCallback(async (raw: string): Promise<boolean> => {
    const candidate = raw.trim().toUpperCase()
    if (!candidate) return false

    const { data, error } = await supabase.rpc('rpc_redeem_code', { p_code: candidate })
    if (error) return false

    const redeemed = readRedeemed(data)
    if (!redeemed) return false

    setCode(redeemed)
    writeStoredCode(redeemed.code)
    return true
  }, [])

  const clear = useCallback(() => {
    setCode(null)
    writeStoredCode(null)
  }, [])

  // Re-validate whatever was remembered, rather than trusting it.
  useEffect(() => {
    const stored = readStoredCode()
    if (!stored) return

    let active = true
    void redeem(stored).then((ok) => {
      if (active && !ok) writeStoredCode(null)
    })

    return () => {
      active = false
    }
  }, [redeem])

  const value = useMemo<ActiveCodeState>(() => ({ code, redeem, clear }), [code, redeem, clear])

  return (
    <ActiveCodeContext.Provider value={value}>
      <CodeFromUrl />
      {children}
    </ActiveCodeContext.Provider>
  )
}

/**
 * Accepts `?code=XXXX` and immediately takes it back out of the address bar.
 *
 * WHY it cannot stay: the guide rebuilds the query string from scratch whenever
 * a filter changes (`filtersToParams`), so a code parked there would vanish on
 * the visitor's first click and reappear on the next share — worse than not
 * supporting it. Redeeming and stripping keeps a link Michael can text to
 * someone while leaving the URL to the filters that own it (RN-19).
 */
function CodeFromUrl() {
  const [searchParams, setSearchParams] = useSearchParams()
  const { redeem } = useActiveCode()
  const handled = useRef<string | null>(null)

  const fromUrl = searchParams.get('code')

  useEffect(() => {
    if (!fromUrl || handled.current === fromUrl) return
    handled.current = fromUrl

    const next = new URLSearchParams(searchParams)
    next.delete('code')
    setSearchParams(next, { replace: true })

    void redeem(fromUrl)
  }, [fromUrl, redeem, searchParams, setSearchParams])

  return null
}
