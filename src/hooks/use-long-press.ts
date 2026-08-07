import { useEffect, useRef, type MouseEvent } from 'react'

/**
 * Long-press handlers for whatever reveals the code input on a phone.
 *
 * Returned as props rather than as a wrapper component, because the thing being
 * pressed is the logo — a router `Link` that still has to navigate on a normal
 * tap. The click is suppressed only when the press actually fired, so the
 * header keeps working for everyone who is not looking for the secret.
 */
export function useLongPress(onLongPress: () => void, ms = 600) {
  const timer = useRef<number | undefined>(undefined)
  const fired = useRef(false)
  const callback = useRef(onLongPress)

  callback.current = onLongPress

  useEffect(() => () => globalThis.clearTimeout(timer.current), [])

  const start = () => {
    fired.current = false
    globalThis.clearTimeout(timer.current)
    timer.current = globalThis.setTimeout(() => {
      fired.current = true
      callback.current()
    }, ms)
  }

  const cancel = () => globalThis.clearTimeout(timer.current)

  return {
    onPointerDown: start,
    onPointerUp: cancel,
    onPointerLeave: cancel,
    onPointerCancel: cancel,
    onClick: (event: MouseEvent) => {
      if (fired.current) event.preventDefault()
    },
    // Without this, a long press on a link opens the browser's own share sheet
    // over the dialog on every mobile browser.
    onContextMenu: (event: MouseEvent) => event.preventDefault(),
  }
}
