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

      {/* Persistently translucent, not scroll-triggered: content passes under
          it, which is the one place the design system allows glass to stay on. */}
      <header className="sticky top-0 z-40 border-b bg-card/80 backdrop-blur-md">
        <div className="mx-auto flex h-16 w-full max-w-6xl items-center px-4">
          {/* Desktop types the code into thin air; a phone has no ambient
              keyboard, so long-pressing the logo is the way in (PRD §9.7). */}
          <Link
            to="/"
            className="flex items-center gap-2.5 select-none"
            {...longPress}
          >
            <span
              aria-hidden
              className="grid size-6 place-items-center rounded-md bg-primary text-[13px] font-extrabold text-primary-foreground"
            >
              M
            </span>
            <span className="font-heading text-[17px] font-bold tracking-[-0.02em]">
              Michaelin Map
            </span>
          </Link>
        </div>
      </header>

      <main className="flex-1">
        <Outlet />
      </main>

      <footer className="border-t bg-card">
        <div className="mx-auto w-full max-w-6xl px-4 py-8 text-sm text-muted-foreground">
          One person's opinion, held with confidence.
        </div>
      </footer>

      <CodeEntryDialog open={entryOpen} onOpenChange={setEntryOpen} />
    </div>
  )
}
