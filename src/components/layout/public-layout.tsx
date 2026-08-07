import { useState } from 'react'
import { Link, Outlet } from 'react-router-dom'
import { CodeBanner, CodeThemeEffect } from '@/components/public/code-banner'
import { CodeEntryDialog, CodeListener } from '@/components/public/code-entry'
import { useLongPress } from '@/hooks/use-long-press'

export function PublicLayout() {
  const [entryOpen, setEntryOpen] = useState(false)
  const longPress = useLongPress(() => setEntryOpen(true))

  return (
    <div className="flex min-h-screen flex-col">
      {/* Scoped to the public side: the admin never wears a visitor's code. */}
      <CodeThemeEffect />
      <CodeListener />

      <CodeBanner />

      <header className="border-b">
        <div className="mx-auto flex h-14 w-full max-w-6xl items-center px-4">
          {/* Desktop types the code into thin air; a phone has no ambient
              keyboard, so long-pressing the logo is the way in (PRD §9.7). */}
          <Link
            to="/"
            className="font-heading text-lg font-semibold tracking-tight select-none"
            {...longPress}
          >
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

      <CodeEntryDialog open={entryOpen} onOpenChange={setEntryOpen} />
    </div>
  )
}
