# CLAUDE.md — Portfolio rebuild (v2)

This repo is a from-scratch rebuild of Mazen's portfolio as a web-native site. The previous site is a
Flutter web app. Every rule below applies in every session.

## Hard rules

- **Never run `git commit` or `git push`** unless the user explicitly says to in that message.
- **Never modify the Flutter source.** The legacy Flutter app is READ-ONLY source material:
  - `./legacy/`: the Flutter files that were in this repo (moved there on 2026-11-27). Gitignored.
  - `../My_portfolio`: the original Flutter repo (remote `Wa7ze/My_portfolio`). It has uncommitted
    WIP scenes; never touch it.
  - To build or run the legacy site, copy `./legacy` to a scratch directory first, so nothing is
    written inside it.
- `./legacy` must stay listed in `.gitignore`.
- Never change Netlify settings. Deploy steps for the user are in `DEPLOY.md`.
- **Use plan mode before writing code** for each new phase or feature.
- Content is ported 1:1 (verbatim) from `CONTENT_INVENTORY.md`. Do not reword, drop or invent content.
  Anything uncertain is marked `[?]` in the inventory and asked about, not guessed.

## Stack

- Vite + React + TypeScript (`strict: true`).
- Tailwind CSS for layout and styling. **All design tokens live in one theme file**
  (colors, type scale, spacing, radii, shadows, blur, z-index); components use tokens, never raw hex.
- GSAP with ScrollTrigger and MotionPathPlugin (installed and registered from the start; used by the
  scroll story).
- Lenis for smooth scrolling, synced with ScrollTrigger:
  `lenis.on('scroll', ScrollTrigger.update)`, Lenis driven by `gsap.ticker`
  (`gsap.ticker.add((t) => lenis.raf(t * 1000))`), and `gsap.ticker.lagSmoothing(0)`.
- ESLint + Prettier.

## Architecture

- `src/content/*.ts` — all site content as typed data (projects, experience, skills, education,
  certificates, links, UI strings, per-locale text). Components never hardcode copy.
- `src/components/sections/` — one component per page section. Semantic HTML (`header`, `nav`,
  `main`, `section`, `footer`), accessible: alt text, visible focus states, keyboard navigation,
  `aria-label` on icon-only links/buttons, respects `prefers-reduced-motion`.
- Assets: copied with the **same filenames** into `src/assets/` (imported, hashed) or `public/`
  (stable URLs: CV PDF, favicon, manifest icons, OG image). Raster images are optimized to WebP;
  originals are kept for the PDF and icons.
- SEO: all legacy meta/OG tags, favicon and manifest ported; plus `sitemap.xml` and `robots.txt`.
- Deploy: same host and domain as the Flutter site (see inventory, "Hosting/deploy").
- Responsive targets: 375px, 768px, 1280px, 1920px.

### Scroll story foundation

**Story docs: two files with different jobs.**

- `STORY.md` (repo root) is the user's **story spec**: _what_ to build. It is owned by the user.
  **Never overwrite, restructure or reformat it.** Put notes in `docs/STORY_DEV.md` instead. It is listed
  in `.prettierignore` so `npm run format` never touches it.
- `docs/STORY_DEV.md` holds the **plumbing and legacy notes**: _how_ to build (StoryStage, master
  timeline, scene contract, debug overlay, legacy Pak/request-path inputs).
- **Rule: before any story work, read `CLAUDE.md`, `STORY.md` and `docs/STORY_DEV.md`, in that order.**
  Where they conflict, `STORY.md` wins on what the story is, and `CLAUDE.md` wins on project rules.

Plumbing summary (details in `docs/STORY_DEV.md`):

- `StoryStage` — fixed, full-viewport layer **behind** all content (`pointer-events: none`,
  z-index below content) holding one full-screen SVG.
- `useStoryProgress` — one master GSAP timeline bound to page scroll via ScrollTrigger
  (`trigger: document.body, start: "top top", end: "bottom bottom", scrub: true`).
- Debug overlay, enabled by `?debug` in the URL: current progress, ScrollTrigger markers, and a
  slider that scrubs the master timeline.
- `src/story/scenes/` — each scene exports its SVG content and a function
  `(tl, range: [start, end]) => void` that adds its tweens to the master timeline at its progress
  range. `scenes/index.ts` registers them.

## Design direction

The content is ported 1:1, but the visual design is new.

- Palette: deep navy background (`#0B1426` → `#16233F`), warm amber accent `#FFB547`,
  cyan/teal electric accent `#3DE0FF`, soft white text. **No pure black, no plain grey.**
- Content sits in readable panels (subtle glass/backdrop blur, soft borders), because the animated
  story plays behind it. Text must stay readable over a busy background (check contrast).
- Clear type scale, generous spacing, subtle film-grain overlay.

## Decisions (user-confirmed, 2026-11-27)

- Live URL: https://mazenportfolio.netlify.app/. The new site takes over the same Netlify site.
- **Dark navy only**: the legacy light theme was dropped.
- **Approach section hidden** (`src/content/approach.ts` → `visible: false`) until the user supplies
  real principles. Its placeholder copy is kept in data.
- Shown although legacy no longer rendered them: Languages, CV preview + download block,
  certificate images, and the "open to opportunities" teaser.
- New `<mm/>` monogram icon set (`scripts/assets.mjs`). The manifest uses the navy palette.
- The Portfolio Website project and the footer "Built with …" line describe the new React/TS/GSAP stack.
- The terminal's `open github|linkedin|cv` actually opens the link (a legacy bug, fixed).
- Pak (the mascot), the request path, layer tints, traceroute and the background grid are **not
  ported**. They belong to the story (spec: `STORY.md`; legacy notes: `docs/STORY_DEV.md`).
- Page title: `Mazen Matran | Portfolio` (no em dash). It is a static `<title>` and is not translated.
- English-only "wire" text (protocol eyebrows, badges, toasts, terminal, 404, teardown) stays
  English in both locales, as on the legacy site. Arabic switches `<html dir="rtl">`. Use logical
  CSS properties (`ms-`, `pe-`, `start-`, …), never left/right.

## Phases

1. Content inventory → `CONTENT_INVENTORY.md`, then stop for review.
2. Build and port (after the inventory is approved).
3. Parity check against the inventory: screenshots, production build, Lighthouse scores.
