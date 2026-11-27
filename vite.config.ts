import { resolve } from 'node:path';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

// Two HTML entries: the single-page site and a static 404 page. Netlify serves
// dist/404.html with a real 404 status for any unmatched path (no SPA catch-all).
export default defineConfig({
  plugins: [react(), tailwindcss()],
  // Multi-page app: no SPA fallback, so `vite preview` 404s unknown paths like Netlify does.
  appType: 'mpa',
  build: {
    target: 'es2022',
    rollupOptions: {
      input: {
        main: resolve(import.meta.dirname, 'index.html'),
        notFound: resolve(import.meta.dirname, '404.html'),
      },
    },
  },
});
