import { useEffect } from 'react'
import { XIcon } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useActiveCode } from '@/lib/code-context'
import { applyCodeTheme, clearCodeTheme } from '@/lib/code-effects'

/**
 * Paints the active code over the palette, and takes it off on the way out.
 *
 * Mounted inside the public layout rather than the provider, so the admin is
 * never wearing someone's code: leaving the guide unmounts this and the theme
 * goes with it. The curator needs a neutral surface to judge against.
 */
export function CodeThemeEffect() {
  const { code } = useActiveCode()
  const theme = code?.theme ?? null

  useEffect(() => {
    applyCodeTheme(theme)
    return () => clearCodeTheme()
  }, [theme])

  return null
}

/**
 * The band that says a code is on, and the way back out of it.
 *
 * A transformation with no exit is a trap. This is also the only place the
 * curator's message reaches the visitor, which is the whole point of the
 * feature (bible §1.1) — so the message leads and the machinery follows.
 */
export function CodeBanner() {
  const { code, clear } = useActiveCode()
  if (!code) return null

  const headline = code.message ?? code.label
  if (!headline && !code.label) return null

  return (
    <div className="border-b bg-primary/10">
      <div className="mx-auto flex w-full max-w-6xl items-center gap-3 px-4 py-2.5">
        <div className="flex-1 text-sm">
          {headline && <span className="font-heading">{headline}</span>}
          {code.label && headline !== code.label && (
            <span className="ml-2 text-muted-foreground">{code.label}</span>
          )}
        </div>

        <Button variant="ghost" size="sm" onClick={clear} className="-mr-2 shrink-0">
          <XIcon className="size-4" />
          <span className="hidden sm:inline">Back to normal</span>
        </Button>
      </div>
    </div>
  )
}
