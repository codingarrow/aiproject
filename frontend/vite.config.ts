/**
 * vite.config.ts — Vite build config.
 * Proxy /api calls to FastAPI backend in development.
 * Eliminates CORS issues during local development.
 */

import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      // Proxy all API calls to FastAPI backend
      '/getOrder':    { target: 'http://localhost:8000', changeOrigin: true },
      '/getEmployee': { target: 'http://localhost:8000', changeOrigin: true },
      '/getCustomer': { target: 'http://localhost:8000', changeOrigin: true },
      '/getShip':     { target: 'http://localhost:8000', changeOrigin: true },
      '/getDashboard':{ target: 'http://localhost:8000', changeOrigin: true },
      '/ai':          { target: 'http://localhost:8000', changeOrigin: true },
      '/health':      { target: 'http://localhost:8000', changeOrigin: true }
    }
  },
  build: {
    // Split vendor chunks for better caching
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          axios:  ['axios']
        }
      }
    }
  }
})
