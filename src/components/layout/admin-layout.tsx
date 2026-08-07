import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom'
import { useQueryClient } from '@tanstack/react-query'
import { LogOutIcon, PlusIcon } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { supabase } from '@/lib/supabase/client'
import { cn } from '@/lib/utils'

const NAV = [
  { to: '/admin', label: 'Places', end: true },
  { to: '/admin/overview', label: 'Overview', end: false },
  { to: '/admin/codes', label: 'Codes', end: false },
  { to: '/admin/reports', label: 'Reports', end: false },
]

export function AdminLayout() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  async function handleLogout() {
    const { error } = await supabase.auth.signOut()
    if (error) {
      toast.error('Could not sign out.')
      return
    }
    // Wipe cached rows so a different curator never sees the previous session's data.
    queryClient.clear()
    navigate('/admin/login', { replace: true })
  }

  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b">
        <div className="mx-auto flex h-14 w-full max-w-6xl items-center gap-6 px-4">
          <Link to="/admin" className="font-heading font-semibold tracking-tight">
            Michaelin Map
            <span className="ml-2 text-xs font-normal text-muted-foreground">admin</span>
          </Link>

          {/* Scrolls instead of wrapping: the header has to survive a phone. */}
          <nav className="flex items-center gap-1 overflow-x-auto">
            {NAV.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.end}
                className={({ isActive }) =>
                  cn(
                    'rounded-md px-3 py-1.5 text-sm transition-colors',
                    isActive
                      ? 'bg-accent text-accent-foreground'
                      : 'text-muted-foreground hover:text-foreground',
                  )
                }
              >
                {item.label}
              </NavLink>
            ))}
          </nav>

          <div className="ml-auto flex shrink-0 items-center gap-1">
            {/* Capture is the one action worth a permanent button: it happens
                standing on a pavement, not sitting at a desk (ADR-08). */}
            <Button asChild size="sm">
              <Link to="/admin/new">
                <PlusIcon className="size-4" />
                <span className="hidden sm:inline">Add place</span>
              </Link>
            </Button>

            <Button variant="ghost" size="sm" onClick={handleLogout}>
              <LogOutIcon className="size-4" />
              <span className="hidden sm:inline">Sign out</span>
            </Button>
          </div>
        </div>
      </header>

      <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-8">
        <Outlet />
      </main>
    </div>
  )
}
