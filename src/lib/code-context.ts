import { createContext, useContext } from 'react'
import type { RedeemedCode } from '@/types'

export interface ActiveCodeState {
  code: RedeemedCode | null
  /** Resolves true when the server accepted the code. Callers decide how loud to be. */
  redeem: (raw: string) => Promise<boolean>
  clear: () => void
}

/**
 * No code, and redeeming does nothing. Only reached outside the provider, which
 * no route does today — a default beats a throw here, because a missing
 * decoration should never take the guide down with it.
 */
export const ActiveCodeContext = createContext<ActiveCodeState>({
  code: null,
  redeem: async () => false,
  clear: () => {},
})

export function useActiveCode(): ActiveCodeState {
  return useContext(ActiveCodeContext)
}
