import { useParams } from 'react-router-dom'

/** Map + synchronized list for one city. Built in F-03, filtered in F-04. */
export function GuidePage() {
  const { citySlug } = useParams<{ citySlug: string }>()

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-16">
      <h1 className="font-heading text-2xl font-semibold tracking-tight">{citySlug}</h1>
      <p className="mt-3 text-sm text-muted-foreground">
        Map and list arrive in F-03. Faceted filtering in F-04.
      </p>
    </div>
  )
}
