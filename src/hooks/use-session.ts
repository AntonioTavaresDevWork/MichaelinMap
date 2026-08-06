import { useEffect, useState } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase/client'

interface SessionState {
  session: Session | null
  loading: boolean
}

/**
 * Source of truth for who is signed in.
 *
 * Guards must wait for `loading` to settle: the first render has no session
 * yet even when one exists in storage, and redirecting on that render would
 * bounce a signed-in curator back to the login screen.
 */
export function useSession(): SessionState {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let active = true

    supabase.auth.getSession().then(({ data }) => {
      if (!active) return
      setSession(data.session)
      setLoading(false)
    })

    const { data: subscription } = supabase.auth.onAuthStateChange((_event, next) => {
      setSession(next)
      setLoading(false)
    })

    return () => {
      active = false
      subscription.subscription.unsubscribe()
    }
  }, [])

  return { session, loading }
}
