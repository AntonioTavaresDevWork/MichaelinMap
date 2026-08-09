import { useEffect, useState } from "react"
import { Toaster as Sonner, type ToasterProps } from "sonner"
import {
  CircleCheckIcon,
  InfoIcon,
  TriangleAlertIcon,
  OctagonXIcon,
  Loader2Icon,
} from "lucide-react"

/**
 * Follows the Code, not the operating system.
 *
 * The shadcn generator wires this to next-themes; this is a Vite SPA with no
 * theme provider. The inline `style` below covers the plain toast, but `App.tsx`
 * passes `richColors`, and sonner draws success/error backgrounds from its own
 * `--success-bg` / `--error-bg`, which exist only under its `data-sonner-theme`
 * attribute. So the prop has to be right, and neither `"system"` (the OS, which
 * knows nothing about this product) nor a pinned `"light"` (which would float a
 * pale card over the ink surface) is right.
 *
 * `.dark` is owned by code-effects.ts, so watching that class is exactly the
 * signal: a visitor on a dark Code who fails a submission gets a dark toast.
 */
function useCodeSurface(): 'light' | 'dark' {
  const [surface, setSurface] = useState<'light' | 'dark'>(() =>
    document.documentElement.classList.contains('dark') ? 'dark' : 'light',
  )

  useEffect(() => {
    const root = document.documentElement
    const observer = new MutationObserver(() =>
      setSurface(root.classList.contains('dark') ? 'dark' : 'light'),
    )
    observer.observe(root, { attributes: true, attributeFilter: ['class'] })
    return () => observer.disconnect()
  }, [])

  return surface
}

const Toaster = ({ ...props }: ToasterProps) => {
  const surface = useCodeSurface()

  return (
    <Sonner
      theme={surface}
      className="toaster group"
      icons={{
        success: <CircleCheckIcon className="size-4" />,
        info: <InfoIcon className="size-4" />,
        warning: <TriangleAlertIcon className="size-4" />,
        error: <OctagonXIcon className="size-4" />,
        loading: <Loader2Icon className="size-4 animate-spin" />,
      }}
      style={
        {
          "--normal-bg": "var(--popover)",
          "--normal-text": "var(--popover-foreground)",
          "--normal-border": "var(--border)",
          "--border-radius": "var(--radius)",
        } as React.CSSProperties
      }
      toastOptions={{
        classNames: {
          toast: "cn-toast",
        },
      }}
      {...props}
    />
  )
}

export { Toaster }
