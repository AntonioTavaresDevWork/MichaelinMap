import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'

export function NotFoundPage() {
  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col items-start px-4 py-24">
      <h1 className="font-heading text-4xl font-extrabold tracking-[-0.025em]">
        Not on the list.
      </h1>
      <p className="mt-4 text-[17px] text-muted-foreground">
        Which, around here, is a kind of verdict.
      </p>
      <Button asChild className="mt-8">
        <Link to="/">Back to the guide</Link>
      </Button>
    </div>
  )
}
