import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/packages': 'http://192.168.64.2:3001',
      '/install':  'http://192.168.64.2:3001',
      '/installed':'http://192.168.64.2:3001',
    }
  }
})
