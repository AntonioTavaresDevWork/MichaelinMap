import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { Slot } from "radix-ui"

import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "group/badge inline-flex h-5 w-fit shrink-0 items-center justify-center gap-1 overflow-hidden rounded-4xl border border-transparent px-2 py-0.5 text-xs font-medium whitespace-nowrap transition-all focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&>svg]:pointer-events-none [&>svg]:size-3!",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground [a]:hover:bg-primary/80",
        secondary:
          "bg-secondary text-secondary-foreground [a]:hover:bg-secondary/80",
        destructive:
          "bg-destructive/10 text-destructive focus-visible:ring-destructive/20 dark:bg-destructive/20 dark:focus-visible:ring-destructive/40 [a]:hover:bg-destructive/20",
        outline:
          "border-border text-foreground [a]:hover:bg-muted [a]:hover:text-muted-foreground",
        ghost:
          "hover:bg-muted hover:text-muted-foreground dark:hover:bg-muted/50",
        link: "text-primary underline-offset-4 hover:underline",

        /**
         * The tier — the curator's verdict, worn quietly.
         *
         * An outline rather than a fill, because the loud thing in a row has to
         * be the star and the dish. Uppercase with tracking is what separates a
         * status pill from a tag label, which is why `secondary` stays sentence
         * case: tag labels are a list of words, not a set of states.
         */
        tier: "h-[22px] border-border/80 px-2.5 text-[11px] font-semibold tracking-wider uppercase text-muted-foreground",

        /**
         * Singled out by the active code — the interface speaking, not Michael.
         * Lime, so it never reads as a verdict (see index.css, the two-colour
         * rule).
         */
        picked:
          "h-[22px] border-primary/30 bg-primary/15 px-2.5 text-[11px] font-semibold tracking-wider uppercase text-brand-ink",

        /**
         * Facts about the place — type, price band, try-list state.
         *
         * Filled rather than outlined, so the eye reads it as a fact and the
         * outlined `tier` beside it as the verdict. Tags keep `secondary` and
         * stay sentence case: a tag is a word, not a state.
         */
        meta: "h-[22px] bg-secondary px-2.5 text-[11px] font-semibold tracking-wider uppercase text-muted-foreground",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

function Badge({
  className,
  variant = "default",
  asChild = false,
  ...props
}: React.ComponentProps<"span"> &
  VariantProps<typeof badgeVariants> & { asChild?: boolean }) {
  const Comp = asChild ? Slot.Root : "span"

  return (
    <Comp
      data-slot="badge"
      data-variant={variant}
      className={cn(badgeVariants({ variant }), className)}
      {...props}
    />
  )
}

export { Badge, badgeVariants }
