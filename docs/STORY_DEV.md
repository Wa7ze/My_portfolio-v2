# STORY_DEV.md: story plumbing and legacy notes

Status: **plumbing only**. No scenes are registered yet. This file collects what exists and what the
legacy site already established, so the story can be designed next.

> The story **spec** (what to build) is [`STORY.md`](../STORY.md) at the repo root, maintained by Mazen.
> This file is the **how**: plumbing reference and legacy inputs. Read CLAUDE.md, STORY.md and this file
> before any story work.

## How the plumbing works

| Piece           | File                             | Notes                                                                                                                                                                                                                         |
| --------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Stage           | `src/story/StoryStage.tsx`       | Fixed, full viewport, `z-story` (behind content), `pointer-events: none`, `aria-hidden`. One `<svg viewBox="0 0 1920 1080" preserveAspectRatio="xMidYMid slice">`. Each scene's SVG is rendered inside `<g data-scene="id">`. |
| Master timeline | `src/story/useStoryProgress.tsx` | One `gsap.timeline` with a normalized duration of **1**, so a timeline position equals page progress. Bound with `ScrollTrigger.create({ trigger: document.body, start: 'top top', end: 'bottom bottom', scrub: true })`.     |
| Smooth scroll   | `src/lib/smoothScroll.ts`        | Lenis, with `lenis.on('scroll', ScrollTrigger.update)`, driven by `gsap.ticker`, and `lagSmoothing(0)`. Disabled under `prefers-reduced-motion` (native scroll; the timeline still scrubs).                                   |
| Scenes          | `src/story/scenes/`              | `types.ts` defines the `StoryScene` contract. `index.ts` is the registry (empty). `_template.tsx` is a copyable example.                                                                                                      |
| Debug           | `src/story/DebugOverlay.tsx`     | Open the site with `?debug`. It shows live progress, ScrollTrigger markers, and a slider that drives scroll, or with "detach" ticked, scrubs `timeline.progress()` directly.                                                  |

### Adding a scene

1. Copy `scenes/_template.tsx` to `scenes/<name>.tsx`. Prefix all ids/classes with the scene id.
2. Pick a `range: [start, end]` in page progress (0..1). Use `?debug` and the section positions to choose it.
3. In `build(tl, [start, end])`, add tweens at `start` with `duration: end - start`, and use `ease: 'none'` for
   scroll-locked motion.
4. Register it in `scenes/index.ts`.
5. Reduced motion: the timeline still scrubs with scroll. If a scene has large or fast motion, check
   `prefersReducedMotion()` from `src/lib/motion.ts` in `build` and add a calmer variant.

Rules: content panels sit above the stage, so keep high-contrast detail away from the text column, or
dim it with the panel blur in mind. Stick to the palette tokens in `src/styles/theme.css`.

## Page progress map (approximate, 1280×900 desktop, EN)

Use `?debug` to read exact values. The sections in order are: Home → About → Skills → Projects →
Experience → Contact → Footer. (Approach is hidden for now. Turning it on shifts every range after
Projects.)

## Legacy story inputs (from the Flutter site, not ported in Phase 2)

- **Narrative: "Life of an HTTP Request".** Each section is one network layer that the visitor's
  request passes through:
  browser `GET / HTTP/1.1` → network `TLS 1.3 handshake ok` → gateway `ROUTE /skills` →
  API `200 OK /projects` → logic `fn handle(req)` → database `SELECT * FROM experience` →
  response `POST /contact` → teardown `FIN`. The eyebrows are already ported as content.
- **Layer colours (legacy):** browser/network = cyan; gateway/api/logic = violet; database = amber;
  response = green. Map these onto the new palette (cyan `#3DE0FF`, amber `#FFB547`, …).
- **Request path:** a dashed S-curve through one "station" per section in a side gutter (mirrored in
  RTL). The travelled part is solid and glowing, stations fill once reached, and 3 packet dots loop
  along it. A good fit for `MotionPathPlugin`.
- **Pak, the mascot:** a small rounded "packet" with eyes and a header cap that travels the path with
  scroll (eased follow). Legacy painter: `legacy/lib/scene/pak/pak_painter.dart`.
  Moods and their triggers:
  - idle, traveling, fast (squash and stretch when scrolling quickly), encrypted (dashed shell),
    carrying (backpack)
  - lookingAt (eyes follow an empty click), dizzy (429 rate limit), sleeping with "z"s (408 idle
    timeout), startled (connection re-established), waving (external link clicked), bowing (end of
    page), lost with "?" (404)
  - The Phase 2 interaction layer already fires the matching events (badges, toasts, idle, end of
    page). Pak can subscribe to the same hooks later.
- **Background:** a radial glow tinted by the active layer colour (450ms cross-fade) and a 32px grid
  with 0.3× scroll parallax.
- **Traceroute:** on a nav click, a green glowing segment drew along the path from the current
  station to the target.
- **WIP scenes (uncommitted, in `../My_portfolio`):** `hero_desk_scene.dart` (a lightbulb glows above
  the client at a desk with a monitor; Pak's head lifts off to join the path; an electric arc runs
  from the monitor to a satellite), `server_room_scene.dart`, and `dev_desk_scene.dart`.
