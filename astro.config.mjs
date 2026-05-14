import { defineConfig } from 'astro/config';
import tailwind from "@astrojs/tailwind";
import sitemap from "@astrojs/sitemap";

export default defineConfig({
  site: 'https://youcancode.net',
  base: '/artist-demo-site/',
  integrations: [tailwind(), sitemap()],
});
