import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { Toaster } from '@/components/ui/sonner'
import { ProtectedRoute } from '@/components/auth/protected-route'
import { PublicLayout } from '@/components/layout/public-layout'
import { AdminLayout } from '@/components/layout/admin-layout'
import { CodeProvider } from '@/components/public/code-provider'
import { CityGatePage } from '@/pages/public/city-gate'
import { GuidePage } from '@/pages/public/guide'
import { PlaceDetailPage } from '@/pages/public/place-detail'
import { LoginPage } from '@/pages/admin/login'
import { PlacesPage } from '@/pages/admin/places'
import { PlaceEditorPage } from '@/pages/admin/place-editor'
import { OverviewPage } from '@/pages/admin/overview'
import { QuickAddPage } from '@/pages/admin/quick-add'
import { CodesPage } from '@/pages/admin/codes'
import { NotFoundPage } from '@/pages/not-found'

export default function App() {
  return (
    <BrowserRouter>
      {/* Inside the router because a code can arrive as `?code=` and has to be
          taken back out of the URL; above the routes because it outlives any
          single page. Its visual effects are scoped to the public layout. */}
      <CodeProvider>
        <Routes>
          <Route element={<PublicLayout />}>
            <Route index element={<CityGatePage />} />
            <Route path="city/:citySlug" element={<GuidePage />} />
            <Route path="place/:placeSlug" element={<PlaceDetailPage />} />
            <Route path="*" element={<NotFoundPage />} />
          </Route>

          <Route path="/admin/login" element={<LoginPage />} />

          <Route element={<ProtectedRoute />}>
            <Route path="/admin" element={<AdminLayout />}>
              <Route index element={<PlacesPage />} />
              <Route path="place/:slug" element={<PlaceEditorPage />} />
              <Route path="overview" element={<OverviewPage />} />
              <Route path="new" element={<QuickAddPage />} />
              <Route path="codes" element={<CodesPage />} />
              <Route path="*" element={<Navigate to="/admin" replace />} />
            </Route>
          </Route>
        </Routes>
      </CodeProvider>

      <Toaster richColors position="top-right" />
    </BrowserRouter>
  )
}
