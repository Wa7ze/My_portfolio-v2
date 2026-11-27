# STORY.md: "Life of a Request"

A scroll-driven story playing in the BACKGROUND of the portfolio site.
It follows a request from idea to shipped product.
Every character is Pak: a headless body per role, and Pak's head travels between them.
The mascot Pak plays ALL characters: the client, the ops person at the server, and the developer.
Wherever this spec says "me" or "my head", it means Pak in his developer role (Pak's head on the
developer body), not a separate character.

This file is the STORY SPEC (what the story is). Implementation notes, the plumbing reference and the
legacy story inputs live in docs/STORY_DEV.md: read both before working on a scene.

## Rules
- Never run git commit or push unless I explicitly tell you to.
- Never overwrite or restructure this file. Put implementation notes in docs/STORY_DEV.md.
- Before writing code, enter plan mode and show me the plan for the scenes.
- Build all sections as placeholders, then stop for my review. We refine them one section at a time.

## Architecture (mandatory)
- Use the existing StoryStage (fixed full-viewport layer behind content), master timeline,
  ?debug overlay and scenes/ registry.
- Each section's tweens are added to the master timeline at its progress range
  (timeline duration normalized to 1, position = section start).
- Every animated property is driven ONLY by the scrubbed timeline, so scrolling backwards
  rewinds everything perfectly.
- Exception: the intro (Section 0, part A) is its own time-based timeline on load. Scroll is locked
  with lenis.stop() during the intro and released with lenis.start(); any scroll attempt skips to
  the end of the intro.
- Idle micro-motion (breathing, blinking LEDs, screen flicker) uses separate looping tweens,
  independent of scroll.
- Scenes are SVG components, one file per section, sharing one viewBox with
  preserveAspectRatio="xMidYMid slice". Each scene has 3 parallax groups
  (background, midground, foreground).
- Animate only transforms and opacity. Use SVG glow filters sparingly (prefer pre-blurred glow shapes).
  Target 60fps on a mid-range laptop and phone.
- Respect prefers-reduced-motion with gsap.matchMedia: show static key frames instead.
- Adding or replacing a section = one scene file + one entry in the scene map.

## Pak's head: the core loop
- The head always follows this cycle: BODY > LINE > BODY > LINE ... smoothly, across every section.
  At the end of each section the head lifts out of its current body, flies up to the guiding line,
  travels along it, then leaves the line and lands on the body in the next section.
- The guiding line: one continuous SVG `<path id="guide-line">` spanning the whole story.
  Reuse the visual style of the legacy request path (docs/STORY_DEV.md): dashed ahead of Pak,
  solid and glowing on the part already travelled. The head travels along it with MotionPathPlugin
  (path: "#guide-line", align, autoRotate with a small max tilt, start/end values per segment).
- Accessories belong to the role, not the head: glasses appear when the head lands on a client body
  and disappear when it leaves. The tie is part of the client body.
- Landings get squash-and-stretch and a small settle bounce. Take-offs get anticipation (a small dip first).

## Flying objects: swerve motion
- The electric shock (Section 0), the signal (Section 1) and the zip file (Section 4 to 5)
  do NOT follow the guiding line, and draw NO path or trail line.
- Utility `swervePath(source, target, seed)`: generates a path string from a seeded PRNG
  (e.g. mulberry32) with perpendicular left/right offsets whose amplitude tapers to 0 at both ends,
  so objects leave and land exactly on their points.
- These objects use MotionPathPlugin on that generated path, which is NEVER rendered.
- Fixed seed per object: the motion looks random but is identical every time and replays exactly
  on reverse scroll.

## Art direction (placeholders must still look intentional)
- Style: flat vector illustration with depth. Rounded shapes, soft gradients, no pure black, no plain grey.
- Palette: deep navy night background (#0B1426 to #16233F), warm amber key light from the bulb (#FFB547),
  cyan/teal electric accents (#3DE0FF), soft white highlights. Subtle film grain overlay.
- Lighting: every scene has a light source with soft glows and contact shadows.
- Motion: anticipation, overshoot and follow-through (back.out, power3.inOut). Nothing linear.
  This overrides the `ease: 'none'` advice in the scene template: positions on the master timeline
  map to scroll, but each individual tween inside a section uses a real ease.
- Pak's head is the legacy Pak mascot: port legacy/lib/scene/pak/pak_painter.dart to an SVG
  component (PakHead) with the same look. It must support accessories (glasses) and effects
  (exclamation mark pop, nod, talking, happy/satisfied expression). Reuse the legacy moods where they
  fit (e.g. traveling, fast squash and stretch while on the line).
- Legacy WIP scenes in ../My_portfolio (hero_desk_scene.dart, server_room_scene.dart,
  dev_desk_scene.dart) are references for Sections 0 to 2: port their ideas, but this spec wins
  wherever they differ.
- The site content must stay readable on top of the story at every progress value.
- Interactive moods (dizzy on rate limit, sleeping on idle, waving on external links, etc.) are NOT
  part of this pass. They can be layered onto the story Pak later.

## Scene map

### Section 0: "The idea" (intro + progress 0.00 to 0.12)
A. On load (time-based, ~3s, skippable by scrolling):
- Black screen, a bulb flickers off/on then lights up gradually; amber glow blooms outward.
- Camera zooms out: the bulb is floating above the CLIENT's head.
- Client: headless body wearing a tie, sitting at a desk with ONE monitor.
  Pak's head is on the body, wearing glasses.
- As the zoom finishes, the site content fades/slides in on top.

B. On scroll:
- Pak's head lifts out of the client body and flies up to the guiding line.
- An electric shock leaves the client's monitor and swerves (swerve motion) to a satellite.
- Ends with the shock reaching the satellite and the head travelling on the line.

### Section 1: "Received" (0.12 to 0.28)
- A server room: one server with 4 ports whose LEDs blink green.
- The signal leaves the satellite and swerves to the server; the ports flash on arrival.
- A headless body (no accessories) stands next to the server holding a laptop.
- Pak's head leaves the line and lands on the body, an exclamation mark pops from the head, the head nods.
- Continuing to scroll: the head lifts out and returns to the line.

### Section 2: "Development" (0.28 to 0.44)
- A desk with 2 monitors and a white PC case sitting on the desk.
- A headless body in a t-shirt and shorts sits at the desk: one hand on the keyboard,
  the other hand on its head, scratching.
- Pak's head leaves the line and lands on that body.
- Continuing to scroll: the head lifts out and returns to the line.

### Section 3: "The update" (0.44 to 0.62)
- A room identical to Section 2 (reuse its scene: desk, 2 monitors, white PC case, developer body).
  This is "me".
- My head leaves the line and lands on the developer body.
- Monitor 1: a video meeting. The client is on the call: Pak's head with glasses and the tie visible.
  This meeting head STAYS on the screen; it never flies.
- Monitor 2: a mockup landing page (placeholder layout: navbar, hero block, button, cards).
- A talking cloud pops in above the client on the meeting screen (larger),
  and a smaller talking cloud pops in above my head. Both pop with scale overshoot.
- Continuing to scroll: only MY head lifts out and returns to the line.

### Section 4: "Ship it" (0.62 to 0.80)
- My head leaves the line and lands on the developer body at the desk, finishing the request.
- A big button on the desk: the button IS the word "SHIP" in red (no separate button shape).
- My hand presses down on the word itself; the word squishes slightly while pressed
  (e.g. scaleY ~0.85, scaleX ~1.05, then a small rebound).
- A zip file icon launches from the button and swerves toward Section 5.
- Continuing to scroll: my head lifts out and returns to the line.

### Section 5: "Delivered" (0.80 to 1.00)
- The client at his computer: same client as Section 0 (headless body with tie, one monitor).
- Pak's head leaves the line and lands on the client body; the glasses appear.
- The zip file swerves in and lands on the client's computer screen.
- An animated expression of satisfaction plays on the client's face
  (swap to pak_head_happy.png if provided; otherwise animate a smile overlay plus a small happy bounce).
- The final frame holds at progress 1.0. The end.

## Verify before handing back
- Run the site and capture screenshots of the intro mid-way and at progress
  0.0, 0.06, 0.12, 0.20, 0.28, 0.36, 0.44, 0.53, 0.62, 0.71, 0.80, 0.90, 1.0.
- Scrub the ?debug overlay slider forward and backward through every section transition, with
  ScrollTrigger markers on, and confirm the head is never in two places (except the meeting head
  in Section 3), never pops, and the swerving objects replay identically.
- Critique each screenshot against this spec and the art direction. Fix issues,
  then show me the final screenshots.
