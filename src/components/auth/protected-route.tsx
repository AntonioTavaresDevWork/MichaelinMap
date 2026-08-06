import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { Loader2Icon } from 'lucide-react'
import { useSession } from '@/hooks/use-session'

/**
 * Gate for /admin. Only checks that someone is signed in — whether that
 * account may actually write is decided by RLS through the `curators` table,
 * not here. The client is never the authority.
 */
export function ProtectedRoute() {
  const { session, loading } = useSession()
  const location = useLocation()

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Loader2Icon className="size-5 animate-spin text-muted-foreground" />
      </div>
    )
  }

  if (!session) {
    return <Navigate to="/admin/login" replace state={{ from: location.pathname }} />
  }

  return <Outlet />
}
