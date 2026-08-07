import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { Toaster } from '@/components/ui/sonner'
import { ProtectedRoute } from '@/components/auth/protected-route'
import { PublicLayout } from '@/components/layout/public-layout'
import { AdminLayout } from '@/components/layout/admin-layout'
import { CityGatePage } from '@/pages/public/city-gate'
import { GuidePage } from '@/pages/public/guide'
import { PlaceDetailPage } from '@/pages/public/place-detail'
import { LoginPage } from '@/pages/admin/login'
import { PlacesPage } from '@/pages/admin/places'
import { PlaceEditorPage } from '@/pages/admin/place-editor'
import { OverviewPage } from '@/pages/admin/overview'
import { AdminPlaceholder } from '@/pages/admin/placeholder'
import { NotFoundPage } from '@/pages/not-found'

export default function App() {
  return (
    <BrowserRouter>
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
            <Route
              path="review"
              element={
                <AdminPlaceholder
                  title="Review queue"
                  feature="F-02"
                  description="Unreviewed places, the 28 tier conflicts and the 15 unclassified entries land here."
                />
              }
            />
            <Route
              path="codes"
              element={
                <AdminPlaceholder
                  title="Codes"
                  feature="F-05"
                  description="Create a code per person: theme, map style, pins, preset filter, highlights and a banner message."
                />
              }
            />
            <Route path="*" element={<Navigate to="/admin" replace />} />
          </Route>
        </Route>
      </Routes>

      <Toaster richColors position="top-right" />
    </BrowserRouter>
  )
}
