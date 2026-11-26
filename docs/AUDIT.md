# Audit — "Life of an HTTP Request" overhaul (phases 0-4)

Recorded decisions and content gaps for the single-page redesign. Scope is
PRD phases 0-4 only (audit/setup, layout, scroll scene, interaction layer,
navigation); phases 5-7 (CV/redirect polish, custom cursor/idle/terminal/404
treatment/HTML boot-loader, final cross-browser polish) are deferred.

## Deviations from the PRD (explicitly approved by the user)

1. **Bilingual EN/AR + RTL is kept.** The PRD assumes English-only. The
   existing `AppStrings`/`EnStrings`/`ArStrings` mechanism
   (`lib/core/strings/`) continues to drive all translatable prose. See
   "Locale scope" below for what does and doesn't translate in the new
   design.
2. **The light/dark toggle is kept.** The PRD specifies dark-only for v1.
   `lib/core/tokens.dart`'s `AppColors.light` is an original design (the PRD
   gave no light palette) using the same accent hues as dark, with
   bg/line/text inverted.
3. **Contact form uses the PRD's own `mailto:` fallback**, since no real
   Formspree (or similar) endpoint exists yet. `http` is not added to
   `pubspec.yaml` until a real endpoint is wired up (phase 5+).

## Locale scope — what translates and what doesn't

- Bio, experience, education, skills, languages, nav labels, contact labels:
  translated via the existing `AppStrings` mechanism (unchanged).
- Protocol/status-flavor text (`GET / HTTP/1.1`, `200 OK /projects`,
  `SELECT * FROM experience`, NetButton microcopy like "handshaking…",
  "SYN"/"ACK"): **English-only in both locales** — treated as code/wire
  text, not prose. **User-confirmed.**
- Project titles/summaries/overviews (`lib/data/portfolio_content.dart`):
  English-only in both locales — this matches the app's existing behavior
  (project content was never part of the AR/EN string system even before
  this redesign).
- Certificate titles/issuers (`lib/data/portfolio_content.dart`): kept in
  their original credential language, untranslated — consistent with how
  real certificates/transcripts are represented. **User-confirmed
  (certificate placement question).**
- `PortfolioContent` is therefore a single locale-independent object, not an
  EN/AR pair — none of its source content varies by locale.

## TODO(content) — blocking or deferred content gaps

1. **Fonts.** No JetBrains Mono / Space Grotesk files exist in the repo.
   `lib/core/tokens.dart`'s `AppFonts.display`/`.mono` currently resolve to
   `null` (platform default), satisfying the PRD's "no `google_fonts` at
   runtime" rule without the real typographic look. **User-confirmed**:
   ship this fallback now; swap in real `.ttf` files (JetBrains Mono 400/700,
   Space Grotesk 500/700 — both free/open fonts) later by only editing
   `AppFonts` and adding a pubspec `fonts:` block — no other code changes.
2. **Section 4 (Logic/approach, `#approach`).** No source content exists for
   "3-4 principles on how you design/ship software."
   `PortfolioContent.approachPrinciples` ships 3 explicit placeholder
   entries (`TODO(content): replace with a real principle...`) rather than
   invented opinions. Needs real copy from the user, in both EN and AR once
   supplied (this is prose, not protocol text).
3. **Section 5 (Database/experience, `#experience`).** The PRD implies a
   multi-row timeline; the audited content has exactly one job entry
   (Alessa Industries, 2025–Present). **User-confirmed**: ship as a single
   result row — no invented second row. Revisit if more experience is added
   later.
4. **Project `portfolio-website` overview text**
   (`lib/data/portfolio_content.dart`) describes the pre-overhaul
   architecture (cosmic background, floating sidebar, theme `ThemeExtension`
   tokens) which this very redesign replaces. Ported verbatim per the
   "reuse content, don't invent" rule, but it will read as inaccurate once
   this overhaul ships — ask the user for an updated description afterward.
5. **New UI copy introduced by the redesign** (nav bar item labels if they
   differ from the existing `navHome`/`navAbout`/`navWork`/`navContact`,
   footer/teardown text, any section eyebrow copy beyond the protocol
   labels) should be added to `AppStrings`/`EnStrings`/`ArStrings` with both
   locales filled in as it's written — don't let new bilingual gaps
   accumulate silently.

## Structural decision — certificate placement

The PRD's 8 fixed sections have no dedicated certificates section. All 9
certificates (3 featured degrees/registration + 6 courses/internships) fold
into **Section 1 (`#about`, Network layer)** as a compact list under the
education block. **User-confirmed.**

## Dependency changes (phase 0)

- Added: `web: ^1.1.0` (phase 4's `hash_sync.dart`).
- Removed: `google_fonts`, `web_smooth_scroll`, `responsive_framework`,
  `flutter_svg`, `lottie`, `rive`, `flutter_staggered_grid_view` — all
  confirmed unused by the target architecture (CustomPainter-only scene art,
  hand-rolled scroll/breakpoint logic, no Rive/Lottie/SVG assets anywhere in
  the new file tree).
- Deferred (not installed): `http` — only needed once a real Formspree-style
  endpoint replaces the `mailto:` fallback.
- Kept unchanged: `flutter_animate`, `url_launcher`, `provider`,
  `cupertino_icons`, `flutter_localizations`, `go_router` (routes trimmed to
  `/` + catch-all in phase 1, package itself stays).

## Deletion list (executed at the phase 1 cut-over, not phase 0)

`lib/features/home/home_page.dart`, `lib/features/work/work_page.dart`,
`lib/features/work/project_page.dart`, `lib/features/work/work_card.dart`,
`lib/features/contact/contact_page.dart`, `lib/widgets/cosmic_background.dart`,
`lib/core/planet_theme.dart`, `lib/widgets/planet_dot.dart`,
`lib/widgets/left_sidebar.dart`, `lib/widgets/app_chrome.dart`,
`lib/core/theme.dart`, and the superseded scroll/animation helpers
(`float_on_scroll.dart`, `parallax.dart`, `reveal_on_scroll.dart`,
`magnetic_button.dart`, `loading_skeleton.dart`, `cv_section.dart`,
`centered_content.dart`, `responsive_layout.dart`, `reveal.dart`,
`core/responsive.dart`, `core/assets.dart`).

## Carried forward unchanged

`widgets/opening_splash.dart` (boot-loader sync is a different, deferred
phase-6 mechanism), `core/app_state.dart` controllers (`ThemeController`,
`LocaleController` verbatim; `SidebarController` repurposed to drive the new
nav bar's mobile sheet; `CurrentPageController` deleted once the single-page
shell lands, since multi-page navigation no longer exists), `core/strings/*`,
`go_router` (trimmed), all image/CV assets under `assets/` (including the
misspelled `portfoilo-website` folder and space-containing filenames — not
renamed).
