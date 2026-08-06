/**
 * The first screen. Cities listed as peers with counts, alphabetical, with an
 * optional "nearest to me" shortcut. Built in F-03; the data lands in F-01.
 */
export function CityGatePage() {
  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-16">
      <h1 className="font-heading text-3xl font-semibold tracking-tight">
        Where are you?
      </h1>
      <p className="mt-3 max-w-prose text-muted-foreground">
        Pick a city and everything else follows. Nobody browses every place on earth.
      </p>
      <p className="mt-8 text-sm text-muted-foreground">
        The city gate arrives in F-03.
      </p>
    </div>
  )
}
