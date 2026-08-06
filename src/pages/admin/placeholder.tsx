import { Card, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

interface PlaceholderProps {
  title: string
  feature: string
  description: string
}

/** Stand-in for admin screens whose feature has not been built yet. */
export function AdminPlaceholder({ title, feature, description }: PlaceholderProps) {
  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-heading text-2xl font-semibold tracking-tight">{title}</h1>
      <Card>
        <CardHeader>
          <CardTitle>Coming in {feature}</CardTitle>
          <CardDescription>{description}</CardDescription>
        </CardHeader>
      </Card>
    </div>
  )
}
