import { useEffect, useState, type FormEvent } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { useActiveCode } from '@/lib/code-context'

/**
 * The two ways in, both from PRD §9.7.
 *
 * Desktop listens for typing with no field on screen, which is what makes a
 * code feel like a secret rather than a coupon box. A phone has no ambient
 * keyboard, so there the logo has to be long-pressed to reveal an input.
 */

/** Long enough that no real word triggers a lookup, short enough for `VIP`. */
const MIN_CODE_LENGTH = 3
const MAX_CODE_LENGTH = 24

/** Typing pauses, then we ask. Fast enough to feel instant, slow enough to be one request. */
const ATTEMPT_AFTER_MS = 600
const FORGET_AFTER_MS = 2500

function isTypingSomewhereElse(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) return false
  if (target.isContentEditable) return true

  const tag = target.tagName
  return tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT'
}

export function CodeListener() {
  const { redeem } = useActiveCode()

  useEffect(() => {
    let buffer = ''
    let attemptTimer: number | undefined
    let forgetTimer: number | undefined

    const handleKey = (event: KeyboardEvent) => {
      // A shortcut is not a code, and neither is anything typed into a field.
      if (event.ctrlKey || event.metaKey || event.altKey) return
      if (isTypingSomewhereElse(event.target)) return
      if (event.key.length !== 1 || !/[a-z0-9]/i.test(event.key)) return

      buffer = (buffer + event.key).toUpperCase().slice(-MAX_CODE_LENGTH)

      globalThis.clearTimeout(attemptTimer)
      globalThis.clearTimeout(forgetTimer)

      if (buffer.length >= MIN_CODE_LENGTH) {
        const candidate = buffer
        attemptTimer = globalThis.setTimeout(() => {
          // Silent on failure by design: the visitor never asked a question, so
          // there is nothing to answer. Random typing must not produce errors.
          void redeem(candidate).then((ok) => {
            if (ok) buffer = ''
          })
        }, ATTEMPT_AFTER_MS)
      }

      forgetTimer = globalThis.setTimeout(() => {
        buffer = ''
      }, FORGET_AFTER_MS)
    }

    globalThis.addEventListener('keydown', handleKey)

    return () => {
      globalThis.removeEventListener('keydown', handleKey)
      globalThis.clearTimeout(attemptTimer)
      globalThis.clearTimeout(forgetTimer)
    }
  }, [redeem])

  return null
}

interface DialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function CodeEntryDialog({ open, onOpenChange }: DialogProps) {
  const { redeem } = useActiveCode()
  const [value, setValue] = useState('')
  const [rejected, setRejected] = useState(false)
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    if (!open) {
      setValue('')
      setRejected(false)
    }
  }, [open])

  async function handleSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return

    setBusy(true)
    setRejected(false)

    const ok = await redeem(value)
    setBusy(false)

    if (ok) onOpenChange(false)
    else setRejected(true)
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Got a code?</DialogTitle>
          <DialogDescription>
            Michael hands these out one at a time. If you have one, this is where it goes.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="flex flex-col gap-3">
          <Input
            autoFocus
            value={value}
            maxLength={MAX_CODE_LENGTH}
            onChange={(event) => setValue(event.target.value.toUpperCase())}
            placeholder="CODE"
            aria-label="Code"
            aria-invalid={rejected}
            className="font-heading tracking-[0.2em] uppercase"
          />

          {/* Identical for wrong, expired and switched-off — the input must not
              become the oracle the RPC refuses to be (RN-20). */}
          {rejected && <p className="text-sm text-destructive">That one does nothing.</p>}

          <Button type="submit" disabled={busy || value.trim().length < MIN_CODE_LENGTH}>
            {busy ? 'Checking…' : 'Use it'}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  )
}
