// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import react from '@astrojs/react';

// https://astro.build/config
export default defineConfig({
  site: 'https://sgrove.github.io',
  base: '/riseos',
  output: 'static',
  vite: {
    plugins: [tailwindcss()]
  },
  integrations: [react()],
  markdown: {
    shikiConfig: {
      // Zen-compatible dark theme
      theme: 'github-dark',
      // Enable word wrap to prevent horizontal scrolling
      wrap: true,
    },
  },
});
