import { useSession } from '@/hooks/use-session'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

export function DashboardPage() {
  const { session } = useSession()

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="font-heading text-2xl font-semibold tracking-tight">Places</h1>
        <p className="text-sm text-muted-foreground">
          Signed in as {session?.user.email ?? 'unknown'}
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Nothing here yet</CardTitle>
          <CardDescription>
            The place list, editor, tag pickers and mobile quick-add arrive in F-02.
            The database is still empty — schema and the 511 places land in F-01.
          </CardDescription>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground">
          Tier distribution and the staleness list will sit on this screen.
        </CardContent>
      </Card>
    </div>
  )
}
