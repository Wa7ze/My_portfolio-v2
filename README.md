# Mazen Matran: portfolio (v2)

Web-native rebuild of the portfolio at https://mazenportfolio.netlify.app/. It uses Vite, React,
TypeScript, Tailwind CSS v4, GSAP (ScrollTrigger, MotionPathPlugin) and Lenis.

```bash
npm install
npm run dev        # local dev server
npm run build      # typecheck + production build → dist/
npm run preview    # serve dist/
npm run lint       # ESLint
npm run format     # Prettier
npm run assets     # regenerate WebP images, icons and cv.pdf from ./legacy
node scripts/og-image.mjs          # regenerate public/og-image.png
node scripts/shoot.mjs <url> <dir> # Playwright screenshots (uses installed Chrome)
```

## Where things live

- **Content:** `src/content/*.ts`. All copy is typed data, in EN and AR. Edit text here, not in components.
- **Design tokens:** `src/styles/theme.css` (the only place colours, type, spacing and so on are defined).
- **Sections:** `src/components/sections/`, one per section. The order and visibility are set in
  `src/content/sections.ts`.
- **Scroll story:** code in `src/story/`. Two docs, read both before story work:
  - [STORY.md](STORY.md) is the story spec (_what_ to build). It is maintained by Mazen; don't rewrite it.
  - [docs/STORY_DEV.md](docs/STORY_DEV.md) covers the plumbing and legacy notes (_how_ to build:
    StoryStage, master timeline, scene contract, and the `?debug` overlay).
- **Hidden terminal:** press `` ` `` or long-press the `<mm/>` logo, then type `help`.

Other docs: [CONTENT_INVENTORY.md](CONTENT_INVENTORY.md) (the parity checklist against the old
Flutter site), [DEPLOY.md](DEPLOY.md) and [CLAUDE.md](CLAUDE.md) (project rules).
