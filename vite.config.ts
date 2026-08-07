import path from 'node:path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(import.meta.dirname, './src'),
    },
  },
  server: {
    // Vite binds `localhost` to IPv6 only on this machine, so 127.0.0.1 refuses
    // and anything resolving localhost to IPv4 fails. Listening on every
    // interface also makes the phone able to reach it, which quick-add needs.
    host: true,
  },
})
