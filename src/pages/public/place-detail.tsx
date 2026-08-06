import { useParams } from 'react-router-dom'

/**
 * Leads with tier, star, the dish and the curator's note — never the address.
 * Built in F-03; field reports attach to it in F-06.
 */
export function PlaceDetailPage() {
  const { placeSlug } = useParams<{ placeSlug: string }>()

  return (
    <div className="mx-auto w-full max-w-3xl px-4 py-16">
      <h1 className="font-heading text-2xl font-semibold tracking-tight">{placeSlug}</h1>
      <p className="mt-3 text-sm text-muted-foreground">Place detail arrives in F-03.</p>
    </div>
  )
}
