import { defineConfig } from 'astro/config';
import tailwind from "@astrojs/tailwind";
import sitemap from "@astrojs/sitemap";

export default defineConfig({
  // Your root domain
  site: 'https://youcancode.net',
  // The subfolder for this specific project
  base: '/artist-demo-site/',
  // Keeping the integrations the template needs to look good
  integrations: [tailwind(), sitemap()],
});
