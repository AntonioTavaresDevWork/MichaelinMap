import { Link, Outlet } from 'react-router-dom'

export function PublicLayout() {
  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b">
        <div className="mx-auto flex h-14 w-full max-w-6xl items-center px-4">
          {/* Long-pressing the logo reveals the code input on mobile (F-05). */}
          <Link to="/" className="font-heading text-lg font-semibold tracking-tight">
            Michaelin Map
          </Link>
        </div>
      </header>

      <main className="flex-1">
        <Outlet />
      </main>

      <footer className="border-t">
        <div className="mx-auto w-full max-w-6xl px-4 py-6 text-sm text-muted-foreground">
          One person's opinion, held with confidence.
        </div>
      </footer>
    </div>
  )
}
