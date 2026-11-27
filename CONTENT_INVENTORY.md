# Content Inventory: legacy Flutter portfolio

Source of truth for the 1:1 content port. Every item has a checkbox and its source path.

**Phase 3 status (2026-11-27): all items checked against the running production build**
(`npm run build` + `vite preview`). Evidence: `scripts/verify.mjs`, which loads the real content
modules and checks every string in EN and AR against the rendered DOM, every link, every asset and
every interaction listed here (**596/596 checks passed**; log in `screenshots/verify.log`), plus the
side-by-side screenshots in `screenshots/` (see §13).

Legend: `[x]` = verified in the new site · `✎ Changed (decision)` = verified in its changed form ·
`[ ]` + `✗ Not ported` = deliberately left out, with the reason · `✔ Resolved` = former `[?]`.

> **Update 2026-11-27 (Phase 2).** The Flutter files were moved from this repo's root into
> `./legacy/` (gitignored). Every source path below (`lib/…`, `web/…`, `assets/…`) is now relative
> to `legacy/`. The decisions on the `[?]` items are listed in §12.

## 0. Source location and scope

- **Where the source was read from.** Neither `../portfolio-flutter` nor `./legacy` exists. The
  Flutter app is at `../My_portfolio` (remote `Wa7ze/My_portfolio`). **This repo
  (`My_portfolio-v2`) is a clone of it at the same commit `b8f3ec3 Phase 7: polish`**, so its Flutter
  files are byte-identical to the committed legacy source. Paths below are relative to the Flutter
  project root and are valid in either location.
- **Scope = the committed `HEAD` (`b8f3ec3`)**, the version Netlify builds and deploys.
- **Uncommitted work in `../My_portfolio`, not inventoried as content.** It is in-progress illustration
  work only, with no new copy: `lib/scene/hero_desk_scene.dart` (lightbulb, desk, monitor, Pak's head
  lifting off), `lib/scene/server_room_scene.dart`, `lib/scene/dev_desk_scene.dart`,
  `lib/scene/pak/pak_head_painter.dart`, plus edits to `page_shell.dart`, `s0`/`s1`/`s2` that mount
  them. It is noted in §11 as a possible input for the future story.
- **Pre-redesign history.** Before commit `683dedc` (Phase 0 of the "Life of an HTTP Request"
  redesign) the site was multi-page: `/`, `/work`, `/work/:slug`, `/about`, `/contact`. Those routes
  no longer exist. See §2.3 and §10.

---

## 1. Global / site-wide

### 1.1 Document head and SEO (`web/index.html`)
- [x] `<title>`: `Mazen Matran` — ✎ **Changed (decision):** the tab title is `Mazen Matran | Portfolio` (user decision, 2026-11-27; not translated).
- [x] Flutter app title (`MaterialApp.title`, used as the runtime tab title): `Mazen Matran — Portfolio`. `lib/app.dart` — ✔ **Resolved:** superseded; the title is now `Mazen Matran | Portfolio`.
- [x] `meta description`: `Mazen Matran | Software Engineer building with Flutter, Python, and AI.` — ✎ **Changed (decision):** em dash replaced with a pipe (legacy: `Mazen Matran — Software Engineer…`).
- [x] `meta theme-color`: `#0A0E1A` (to be replaced by the new navy token) — ✎ **Changed (decision):** `#0B1426` (new navy).
- [x] `og:title`: `Mazen Matran | Software Engineer` — ✎ **Changed (decision):** em dash replaced with a pipe (legacy: `Mazen Matran — Software Engineer…`).
- [x] `og:description`: `Building innovative solutions with Flutter, Python, and AI.`
- [x] `og:type`: `website`
- [x] **No** `og:image`, `og:url`, `twitter:*` or canonical tag exists — ✔ **Resolved:** added `og:url`, `og:image` (`/og-image.png`, 1200×630), `og:image:alt`, `twitter:card/title/description/image`, `<link rel=canonical>`.
- [x] `meta viewport`: `width=device-width, initial-scale=1`
- [x] `mobile-web-app-capable: yes`, `apple-mobile-web-app-status-bar-style: black`, `apple-mobile-web-app-title: mazen_portfolio` — ✎ **Changed (decision):** `apple-mobile-web-app-title` is now `Mazen Matran`.
- [x] `apple-touch-icon` → `icons/Icon-192.png`
- [x] `link rel=icon` → `favicon.png`
- [x] `link rel=manifest` → `manifest.json`
- [x] `html` has no `lang` attribute (new site will set `lang="en"` / `lang="ar" dir="rtl"`) — ✎ **Changed (decision):** `<html lang dir>` is set and switches to `ar`/`rtl`.
- [x] Hidden crawler/no-JS summary (visually hidden `<main>`): `<h1>Mazen Matran</h1>` + `<p>Software Engineer building with Flutter, Python, and AI.</p>`. This becomes unnecessary because the new site renders real HTML. The text is covered by the hero. — ✎ **Changed (decision):** kept, visually hidden inside `#root` (crawlers see it; replaced on mount without layout shift).
- [x] `<noscript>`: `Mazen Matran | Software Engineer. This site requires JavaScript to run.` — ✎ **Changed (decision):** em dash replaced with a pipe (legacy: `Mazen Matran — Software Engineer…`).
- [x] **Analytics / tracking scripts: none found** (no gtag, GA, Plausible, Umami, pixels).

### 1.2 Web app manifest (`web/manifest.json`)
- [x] `name`: `mazen_portfolio` · `short_name`: `mazen_portfolio` — ✎ **Changed (decision):** `Mazen Matran | Portfolio` / `Mazen Matran`.
- [x] `description`: `A new Flutter project.` — ✔ **Resolved:** replaced by the meta description.
- [x] `start_url`: `.` · `display`: `standalone` · `orientation`: `portrait-primary` · `prefer_related_applications`: `false` — ✎ **Changed (decision):** `start_url` is `/` (same page).
- [x] `background_color` / `theme_color`: `#0175C2` (Flutter default blue) — ✔ **Resolved:** `#0B1426` (navy).
- [x] icons: `icons/Icon-192.png` (192), `icons/Icon-512.png` (512), `icons/Icon-maskable-192.png` (192, maskable), `icons/Icon-maskable-512.png` (512, maskable) — ✎ **Changed (decision):** same filenames, new `<mm/>` monogram artwork (§7.4).

### 1.3 Boot loader (`web/index.html`, inline CSS and JS)
Shown before Flutter starts and removed by `window.bootDone()` (`lib/main.dart`).
- [x] Fake browser window: 3 traffic-light dots (red `#F87171`, yellow `#FB923C`, green `#4ADE80`), an address bar and a status line — ✎ **Changed (decision):** same markup in the new palette (dots `#FF7A85`/`#FFB547`/`#5EF0A8`).
- [x] Address bar types `location.hostname` + path (if not `/`) at 45ms/char, with a blinking caret
- [x] Initial status: `resolving DNS…`
- [x] Status cycle after typing finishes: `resolving DNS…` → `TLS handshake…` → `connecting` + animated `.`/`..`/`...` (260ms tick, step advances every 6 ticks)
- [x] Minimum display 900ms, then a 300ms fade-out and removal — ✎ **Changed (decision):** minimum display cut to 600ms; then a 300ms fade-out.
- [x] Reduced motion: URL appears instantly, caret does not blink, no fade delay — ✎ **Changed (decision):** under reduced motion the loader is skipped entirely (and hidden for no-JS visitors, a legacy bug).
- [x] A React bundle loads in well under a second, so a loader is no longer needed. Keep it as a brand intro (non-blocking, ≤900ms), or drop it? — ✔ **Resolved:** kept as a short brand intro (600ms, skipped under reduced motion).

### 1.4 Language (i18n) and RTL. Arabic exists.
- [x] Two locales: English (`en`, default on every load) and Arabic (`ar`). `lib/core/app_state.dart` `LocaleController`
- [x] **Arabic switches the whole layout to RTL** (Flutter `Directionality`). Gutter, path and latency pill are mirrored. Protocol and code strings stay LTR (`textDirection: TextDirection.ltr`). — ✎ **Changed (decision):** mirroring via `<html dir=rtl>` + logical CSS. The gutter and path no longer exist (§6.9).
- [x] The locale is not persisted: it resets to EN on reload, and the URL does not change.
- [x] **What is translated:** nav labels, hero title/subtitle/CTA, summary, experience, education, skills (group names and some items), certificate section headings, contact title/subtitle/labels, footer, theme-toggle labels. Strings are in `lib/core/strings/en_strings.dart` and `lib/core/strings/ar_strings.dart`. — ✎ **Changed (decision):** theme-toggle labels dropped with the theme; the contact tile labels are now translated (§3.7).
- [x] **What stays English in both locales (by design, `docs/AUDIT.md`):** the name, all protocol/status labels, project titles/summaries/overviews/tags, certificate titles/issuers/dates, the Approach heading and principles, 404 copy, teardown copy, terminal, toasts and badges, `Skip to content`, `<mm/>`.
- [x] Control: `EN` / `AR` pill pair in the nav bar (active pill filled cyan).

### 1.5 Theme
- [ ] Dark (default on every load) and Light themes. The toggle is session-only. `lib/core/app_state.dart` `ThemeController` — ✗ **Not ported:** dark navy only (user decision). The site is always dark.
- [ ] Toggle: icon button (moon `dark_mode_outlined` when dark, sun `light_mode_outlined` when light). Accessible label `Dark mode` / `Light mode` (AR `الوضع الداكن` / `الوضع الفاتح`). `lib/navigation/nav_bar.dart` — ✗ **Not ported:** no theme toggle (user decision).
- [x] **The new design brief is dark navy only.** Keep a light theme (designed in the new palette), or drop the toggle? Dropping it is a content/behavior removal, so I need your OK. — ✔ **Resolved:** light theme dropped (user decision).

### 1.6 Fonts
- [x] **No font files are bundled.** `AppFonts.display`/`mono` = `null` (platform default). JetBrains Mono and Space Grotesk were planned but never added (`lib/core/tokens.dart`, `docs/AUDIT.md`). The new site will pick a new type pairing; nothing needs porting. — ✎ **Changed (decision):** self-hosted Space Grotesk (display), JetBrains Mono (mono) and IBM Plex Sans Arabic (AR), with the Latin files preloaded.

### 1.7 Accessibility features to keep
- [x] "Skip to content" link, first in focus order, visible on focus, jumps past the nav. Text `Skip to content`. `lib/widgets/skip_link.dart`
- [x] Every interactive element is keyboard-reachable (Enter/Space) with a visible cyan focus ring. `lib/interaction/interactive.dart` — ✎ **Changed (decision):** native `<a>`/`<button>` elements; the focus ring is cyan via `:focus-visible`.
- [x] Section headings are marked as headers; decorative layers are excluded from the accessibility tree
- [x] Toasts and error badges are announced to screen readers — ✎ **Changed (decision):** via `role=status` / `role=alert` live regions.
- [x] Text is selectable (`SelectionArea`). `lib/router.dart` — ✎ **Changed (decision):** native HTML text.
- [x] `prefers-reduced-motion` respected everywhere (see §8)

---

## 2. Pages and routes

### 2.1 Current routes (`lib/router.dart`, path URL strategy)
- [x] `/`: the single scrolling page (all sections, §3)
- [x] Any other path: the 404 page (§4) — ✎ **Changed (decision):** now a static `404.html` with a real HTTP 404 status.

### 2.2 In-page anchors (hash sync). `lib/navigation/hash_sync.dart`
- [x] Section ↔ hash: `#home`, `#about`, `#skills`, `#projects`, `#approach`, `#experience`, `#contact` (the footer also maps to `#contact`) — ✎ **Changed (decision):** `#approach` is inactive while Approach is hidden.
- [x] Loading with a hash jumps to that section — ✎ **Changed (decision):** verified. Also re-applied after web fonts load. **Note:** the legacy build did *not* honour the hash on load in my test (§13).
- [x] The hash updates while scrolling (300ms debounce) and on nav clicks, always via `history.replaceState` (no history entries)

### 2.3 Legacy routes from before the redesign. They return 404 today.
- [x] `/work`, `/work/:slug` (`/work/helpdesk-system`, `/work/portfolio-website`, `/work/outfitly-app`, `/work/nutritrack-website`, `/work/clubconnect-website`, `/work/eary-woods-game`), `/about`, `/contact` — ✎ **Changed (decision):** now 301-redirected (`netlify.toml`); config verified; check live after deploy (DEPLOY.md).
- [x] Add Netlify 301 redirects from these to `/#projects`, `/#about` and `/#contact`? This is cheap and protects old links and search results. — ✔ **Resolved:** added: `/work`, `/work/*` → `/#projects`; `/about` → `/#about`; `/contact` → `/#contact`.

---

## 3. The single page: sections in order

Every section has an English-only, LTR "protocol" eyebrow label above its heading.
`lib/sections/section_scaffold.dart`

### 3.0 Persistent chrome
**Nav bar** (`lib/navigation/nav_bar.dart`): fixed top, 64px, translucent and blurred
- [x] Logo text `<mm/>`. Click → scroll to Home. **Long-press → opens the hidden terminal** (§6.6).
- [x] Nav items in order (EN / AR):
  - [x] `Home` / `الرئيسية` → `#home`
  - [x] `About` / `نبذة عني` → `#about`
  - [x] `Skills` / `المهارات` → `#skills`
  - [x] `My Work` / `أعمالي` → `#projects`
  - [ ] `Approach` / `النهج` → `#approach` — ✗ **Not ported:** hidden until real principles exist (user decision).
  - [x] `Experience` / `الخبرة` → `#experience`
  - [x] `Get in touch` / `تواصل معي` → `#contact`
- [x] The active item (from scroll position) is cyan and bold with a 16px underline (150ms). Hovered items brighten.
- [x] Theme toggle (§1.5) and `EN`/`AR` pills (§1.4) — ✎ **Changed (decision):** the theme toggle was dropped; the EN/AR pills are an `aria-pressed` group labelled `Language`/`اللغة`.
- [x] **Mobile (<720px):** a hamburger (`menu` / `close` icon) opens a dropdown sheet with the same 7 items, a divider, then the theme toggle and locale pills. Choosing an item scrolls and closes the sheet. — ✎ **Changed (decision):** the breakpoint is <768px; 6 items (no Approach); no theme toggle; Esc also closes.
- [x] Unused strings exist for the menu button: `Open menu` / `فتح القائمة`, `Close menu` / `إغلاق القائمة`. These will be used as the hamburger's `aria-label`. — ✎ **Changed (decision):** used as the hamburger's `aria-label`.

**Latency counter** (`lib/widgets/latency_counter.dart`): fixed top-end pill (mirrors in RTL)
- [x] Shows `{ms}ms` where ms = `round(12 + scrollProgress × 1368)` (12ms at the top, 1380ms at the bottom) — ✎ **Changed (decision):** the pill sits top-end below the nav on desktop and bottom-end on mobile (legacy was hidden under the nav).
- [x] At page end it freezes and turns green: `Round trip: {x.xx}s`

**Toast host** (`lib/interaction/effects_layer.dart`): bottom-centered pill, 2.2s, green or red border (messages in §6)

### 3.1 Hero, `#home`. `lib/sections/s0_browser_hero.dart`
- [x] Eyebrow: `GET / HTTP/1.1`
- [x] H1: `Mazen Matran` (not translated)
- [x] Title (cyan): EN `Software Engineer` · AR `مهندس برمجيات`
- [x] Subtitle: EN `Building innovative solutions with Flutter, Python, and AI.` · AR `أبني حلولاً مبتكرة باستخدام Flutter وPython والذكاء الاصطناعي.`
- [x] Button 1 (NetButton): EN `See My Work` · AR `شاهد أعمالي`. Scrolls to `#projects`.
- [x] Button 2 (CV download, §6.3): EN `Download Full CV` · AR `تحميل السيرة الذاتية الكاملة` — ✎ **Changed (decision):** plus a third CTA, `Get in touch`/`تواصل معي` → `#contact` (§5), and the `About Me` teaser panel.
- [x] The section is at least full viewport height

### 3.2 About, `#about`. `lib/sections/s1_network_about.dart`
- [x] Eyebrow: `TLS 1.3 handshake ok`
- [x] H2: EN `Professional Summary` · AR `الملخص المهني` — ✎ **Changed (decision):** an `About`/`نبذة عني` heading + subtitle (§5) now leads the section; Professional Summary is its first panel, next to the Languages block.
- [x] Summary body:
  - [x] EN: `Software Engineer with hands-on experience in full-stack development (Python/FastAPI, React, TypeScript, PostgreSQL) and IT support/ERP administration. Built and deployed a production helpdesk and inventory system used daily by ~300 users. Experienced with Odoo ERP customization, REST API development, and end-to-end project delivery from data modeling to UI. Fluent in English and Arabic; advanced Turkish.`
  - [x] AR: `مهندس برمجيات يتمتع بخبرة عملية في تطوير البرمجيات المتكاملة (Full-Stack) باستخدام Python/FastAPI وReact وTypeScript وPostgreSQL، إضافة إلى الدعم الفني وإدارة أنظمة تخطيط موارد المؤسسات (ERP). قام ببناء ونشر نظام إنتاجي لإدارة طلبات الدعم الفني والمخزون يُستخدم يوميًا من قبل نحو 300 مستخدم. لديه خبرة في تخصيص نظام Odoo ERP، وتطوير واجهات REST API، وتسليم المشاريع من مرحلة نمذجة البيانات وحتى واجهة المستخدم. يجيد اللغتين الإنجليزية والعربية بطلاقة، ولديه مستوى متقدم في اللغة التركية.`
- [x] Current-role line (cyan, mono), format `{role} — {company} ({period})`:
  - [x] EN `IT Support Specialist — Alessa Industries — Riyadh, Saudi Arabia (2025 – Present)`
  - [x] AR `أخصائي دعم فني — شركة Alessa Industries — الرياض، المملكة العربية السعودية (2025 – حتى الآن)`
- [x] H2: EN `Education` · AR `التعليم`
- [x] Each education entry is rendered as `{degree} — {field}` / `{school}` / `{gpa} · {period}`:

| # | Field | EN | AR |
|---|---|---|---|
| 1 | degree | `Bachelor's Degree` | `درجة البكالوريوس` |
|   | field | `Software Engineering` | `هندسة البرمجيات` |
|   | school | `Üsküdar University — Istanbul, Turkey` | `جامعة أسكودار — إسطنبول، تركيا` |
|   | gpa | `GPA: 3.65 / 4.0` | `المعدل التراكمي: 3.65 / 4.0` |
|   | period | `2021 – 2025` | `2021 – 2025` |
| 2 | degree | `Minor Degree` | `تخصص فرعي` |
|   | field | `Computer Engineering` | `هندسة الحاسوب` |
|   | school | `Üsküdar University — Istanbul, Turkey` | `جامعة أسكودار — إسطنبول، تركيا` |
|   | gpa | `GPA: 3.00 / 4.0` | `المعدل التراكمي: 3.00 / 4.0` |
|   | period | `2022 – 2025` | `2022 – 2025` |

- [x] Education entry 1. `lib/core/strings/*_strings.dart` `educationEntries`
- [x] Education entry 2
- [x] H2: EN `Certificates & Achievements` · AR `الشهادات والإنجازات`
- [x] Subtitle: EN `Courses, internships, and programs I have completed.` · AR `الدورات والتدريبات والبرامج التي أكملتها.`
- [x] Featured certificates list (cards), then the label EN `Courses & Internships` · AR `الدورات والتدريبات`, then the other certificates
- [x] Verification link label (only on certificates with a URL): EN `Open Verification Link` · AR `فتح رابط التحقق`

**Certificates** (`lib/data/portfolio_content.dart`). Title, issuer and date are not translated. Each card shows title / issuer / date (+ link).

| # | Group | Title | Issuer | Date | Image asset | Verification URL |
|---|---|---|---|---|---|---|
| C1 | featured | `Bachelor's Degree — Software Engineering` | `Üsküdar University — Faculty of Engineering and Natural Sciences` | `Graduated October 24, 2025 · Diploma No. 02-03548` | `certificates/0_bachelors.jpg` | none |
| C2 | featured | `Minor Degree — Computer Engineering` | `Üsküdar University — Faculty of Engineering and Natural Sciences` | `October 31, 2025 · Certificate No. 3603` | `certificates/1_minor.jpg` | none |
| C3 | featured | `Registered Software Engineer` | `Saudi Council of Engineers (SCE) — Membership ID 1245821` | `Valid May 2026 – May 2027` | `certificates/7_sce_registration.jpg` | none |
| C4 | other | `AI Training Hackathon` | `Kanz (HumanityAI)` | `July 15, 2026` | `certificates/2_kanz_hackathon.jpg` | `https://try.ka.nz/certificate/KANZ-ATT-442AA89710?certificate_type=participation&recipient_name=Mazen+Matran&issue_date=July+15%2C+2026&certificate_id=KANZ-ATT-442AA89710` |
| C5 | other | `"Artificial Intelligence with Cloud & Cybersecurity" Internship Program` | `EARTech Information Technology` | `October 8, 2025` | `certificates/3_eartech_coding.jpg` | `https://credsverse.com/credentials/5f6cbab5-3e19-40a4-b003-caf0e029dc17?preview=1` |
| C6 | other | `"Artificial Intelligence with Coding & Cybersecurity" Internship Program` | `EARTech Information Technology` | `September 17, 2025` | `certificates/3_eartech_coding.jpg` | `https://credsverse.com/credentials/21dd3325-670f-4f22-8995-f58b38670e5d?preview=1` |
| C7 | other | `Elements of AI` | `MinnaLearn — Tech Pathways MENA Program (Village Capital × MinnaLearn / University of Helsinki, supported by Google.org)` | `January 2026` | `certificates/4_minnalearn.jpg` | none |
| C8 | other | `Full Stack Development Internship` | `Codveda Technologies` | `November – December 2025` | `certificates/5_codveda.jpg` | none |
| C9 | other | `High Honor Certificate (Yüksek Onur Belgesi)` | `Üsküdar University — awarded for graduating academic distinction` | `2024–2025 Academic Year` | `certificates/6_ueskuedar_honor.jpg` | none |

- [x] C1 · [x] C2 · [x] C3 · [x] C4 · [x] C5 · [x] C6 · [x] C7 · [x] C8 · [x] C9
- [x] **C5 and C6 share the same image** (`3_eartech_coding.jpg`). Is there a separate image for the Cloud & Cybersecurity program, or is one shared image correct? — ✔ **Resolved:** kept as in the source (both use `3_eartech_coding.jpg`).
- [x] **Certificate images are not shown anywhere on the current site** (`imageAsset` is never rendered). The pre-redesign site showed them. Show them in the new site, for example as thumbnails that open a lightbox? I recommend yes. — ✔ **Resolved:** shown as thumbnails that open a lightbox (← → steps through all 9).

### 3.3 Skills, `#skills`. `lib/sections/s2_gateway_skills.dart`
- [x] Eyebrow: `ROUTE /skills`
- [x] H2: EN `Technical Skills` · AR `المهارات التقنية`
- [x] Each group has a route line `ROUTE /{slug}`, where slug = lowercase, spaces→`-`, `&`→`and`. In AR the slug is built from the Arabic group name. Then the group name, then skill chips.

| Group (EN) → route | Group (AR) | Skills EN | Skills AR (only differences noted) |
|---|---|---|---|
| `Languages & Frameworks` → `/languages-and-frameworks` | `لغات البرمجة والأطر` | `Python`, `Django`, `FastAPI`, `PHP (Laravel)`, `Dart (Flutter)`, `C++`, `C#`, `Java`, `TypeScript`, `HTML` | identical |
| `Web & Data` → `/web-and-data` | `الويب والبيانات` | `React`, `REST API Development`, `PostgreSQL`, `MySQL`, `SQLite`, `TensorFlow` | `REST API Development` → `تطوير REST API` |
| `Tools & Platforms` → `/tools-and-platforms` | `الأدوات والمنصات` | `Git`, `GitHub`, `Microsoft Azure`, `Linux`, `Kali Linux`, `Figma`, `Unity`, `Odoo ERP`, `UltraVNC` | identical |
| `Soft Skills` → `/soft-skills` | `المهارات الشخصية` | `Leadership`, `Cross-functional Communication`, `Problem Solving`, `Critical Thinking`, `Time Management`, `Teamwork` | `القيادة`, `التواصل بين الفرق`, `حل المشكلات`, `التفكير النقدي`, `إدارة الوقت`, `العمل الجماعي` |

- [x] Group 1 · [x] Group 2 · [x] Group 3 · [x] Group 4

### 3.4 Projects, `#projects`. `lib/sections/s3_api_projects.dart`, data in `lib/data/portfolio_content.dart`
- [x] Eyebrow: `200 OK /projects`
- [x] H2: EN `My Work` · AR `أعمالي`
- [x] Subtitle: EN `Case studies & selected projects.` · AR `دراسات حالة ومشاريع مختارة.`
- [x] Card layout: header row `GET` (green) + `/projects/{slug}` + expand chevron (clickable, toggles expand) → title → summary → tag chips → *(expanded: overview paragraph + JSON block + gallery strip)* → footer row: link EN `View on GitHub` · AR `عرض على GitHub` + `200 OK · {n}ms`
- [x] Only one card is expanded at a time. Expansion animates its height (500ms). — ✎ **Changed (decision):** the expanded body appears instantly (no height animation); `aria-expanded`/`aria-controls`.
- [x] Expanded JSON block, verbatim format:
  ```
  {
    "slug": "{slug}",
    "stack": ["{tag1}", "{tag2}", …],
    "repo": "{githubUrl}"
  }
  ```
- [x] Gallery: a horizontal strip of 140×96 thumbnails (no lightbox) — ✎ **Changed (decision):** larger thumbnails that open a lightbox; labelled `Project Overview` / `Project Gallery`, plus a `Back to Projects` collapse button (§5). The card also shows the cover image.

**Project entries in display order** (English in both locales):

**P1. `helpdesk-system`**
- [x] Title: `Helpdesk & Inventory Management System`
- [x] Summary: `Production FastAPI + React helpdesk and inventory platform serving ~300 daily users, with ticket approval workflows, device inventory, and activity tracking, built and shipped solo end-to-end.`
- [x] Tags: `Python`, `FastAPI`, `PostgreSQL`, `React`, `TypeScript`
- [x] GitHub: `https://github.com/Wa7ze` — ✔ **Resolved:** kept as the profile URL.
- [x] Response time: `200 OK · 59ms`
- [x] Cover image: `helpdesk-system/2.png` (not rendered currently). Gallery: `helpdesk-system/1.png`, `2.png`, `3.png`, `4.png` — ✎ **Changed (decision):** the cover is now rendered on the card (md+).
- [x] Overview: `An independent, full-stack helpdesk and inventory system used daily by roughly 300 employees at a real company. The backend is built with Python and FastAPI on PostgreSQL, exposing a REST API for ticketing, device/inventory records, and role-based access control, deployed on Render; the frontend is a React + TypeScript SPA deployed on Netlify. The ticketing module supports full approval workflows (create, edit, close, and approve requests), the inventory module tracks devices with bulk Excel import, and an activity log records changes across the system for auditability. This project demonstrates end-to-end ownership of a production system: API design, relational data modeling, authentication, deployment, and a responsive UI — all shipped and actively used, not just a demo.`

**P2. `portfolio-website`**
- [x] Title: `Portfolio Website`
- [x] Summary: `This site: a responsive Flutter web app with a theme system (dark/light), full Arabic/English i18n with RTL support, and choreographed motion built on Flutter's animation and custom-painting APIs.` — ✎ **Changed (decision):** rewritten for the new stack: `This site: a responsive React + TypeScript web app with full Arabic/English i18n and RTL support, smooth scrolling, and a scroll-driven animated story choreographed with GSAP.`
- [x] Tags: `Flutter`, `Dart`, `i18n / RTL`, `Custom Animation`, `Responsive Design` — ✎ **Changed (decision):** `React`, `TypeScript`, `GSAP`, `Tailwind CSS`, `i18n / RTL`.
- [x] GitHub: `https://github.com/Wa7ze/My_portfolio` — ✎ **Changed (decision):** `https://github.com/Wa7ze/My_portfolio-v2`.
- [x] Response time: `200 OK · 138ms` — ✎ **Changed (decision):** verified (the slug is unchanged, so the value is unchanged).
- [x] Cover: `portfoilo-website/image copy 2.png`. Gallery: `portfoilo-website/image.png`, `image copy.png`, `image copy 2.png` (the folder name is misspelled in the source; keep the filenames) — ✎ **Changed (decision):** same filenames, now screenshots of the new site (`scripts/portfolio-shots.mjs`); the Flutter originals stay in `legacy/`.
- [x] Overview: `My portfolio, built entirely in Flutter for web rather than a templated site builder. It implements a shared light/dark ThemeData pair with a custom ThemeExtension for palette tokens, a hand-rolled Arabic/English localization layer that drives Flutter's Directionality so the entire layout mirrors correctly in RTL, a Provider-based state layer for theme/locale/navigation state, and a CustomPainter-driven opening animation. The floating, hamburger-triggered sidebar, staggered scroll-reveal animations, and responsive grid layouts across every page are all hand-built. The project is a practical showcase of Flutter web architecture: state management, custom painting, internationalization, and motion design working together.` — ✎ **Changed (decision):** rewritten for the React/TS/GSAP/Lenis build (see `src/content/projects.ts`).
- [x] **This entry describes the old Flutter site.** Once the new site ships, the summary ("This site: a responsive Flutter web app…"), the tags, the overview, the screenshots and the repo link will all be inaccurate. Options: (a) port it verbatim now and rewrite it later, (b) give me new copy for the React rebuild, (c) keep it as a project about the legacy Flutter site, reworded so it doesn't say "this site". — ✔ **Resolved:** user chose to port it now, updated to describe the new stack.

**P3. `outfitly-app`**
- [x] Title: `Outfitly App`
- [x] Summary: `Cross-platform Flutter wardrobe app with a Django + TensorFlow recommendation backend — my graduation project, covering mobile UI, API integration, and applied ML end-to-end.`
- [x] Tags: `Flutter`, `Django`, `TensorFlow`, `REST API`, `Mobile App`
- [x] GitHub: `https://github.com/Wa7ze/outfitly-3`
- [x] Response time: `200 OK · 174ms`
- [x] Cover: `outfitly-app/1.png`. Gallery: `outfitly-app/1.png`, `2.png`, `3.png` (portrait phone shots, 258×558)
- [x] Overview: `Outfitly is my graduation project: an AI-powered wardrobe companion split cleanly between a Flutter cross-platform client and a Django + TensorFlow backend. The Flutter app handles the digital wardrobe, outfit planner, and social feed, communicating with the backend over a REST API; the backend uses TensorFlow models to analyze clothing items and generate personalized outfit recommendations. Building it meant working across the whole stack — mobile UI/UX in Flutter, API contract design, and integrating a trained ML model into a real product — which is what made it the strongest demonstration of my range as an engineer during my degree.`

**P4. `nutritrack-website`**
- [x] Title: `Nutritrack Website`
- [x] Summary: `Django-based social nutrition tracker (~65% individual contribution) — built the authentication system and validated it with Selenium functional tests and JMeter load tests.`
- [x] Tags: `Python`, `Django`, `SQLite`, `Selenium`, `JMeter`
- [x] GitHub: `https://github.com/Wa7ze/nutritrack`
- [x] Response time: `200 OK · 102ms`
- [x] Cover: `nutritrack-website/1.png`. Gallery: `nutritrack-website/1.png`, `2.png`, `3.png`
- [x] Overview: `NutriTrack is a social nutrition-tracking platform built with Django, HTML, and SQLite, where I owned roughly 65% of the project. My core contribution was the authentication and account system — signup, login, profile management, and follow/unfollow logic — plus the meal-posting and search features that sit on top of it. I also designed and ran the test suite: functional test cases in Selenium to verify user flows end to end, and load/performance testing with Apache JMeter to check the app under concurrent traffic. This project reflects both backend ownership and a QA mindset — building the feature and proving it works under load, not just that it compiles.`

**P5. `clubconnect-website`**
- [x] Title: `ClubConnect Website`
- [x] Summary: `Full-stack member benefits platform — account management, benefit redemption, and an admin-facing backend for a member offers program (ticketing, fuel discounts, parking).`
- [x] Tags: `Full-Stack Web`, `Database Design`, `Member Management`
- [x] GitHub: `https://github.com/Wa7ze/clubconnect`
- [x] Response time: `200 OK · 175ms`
- [x] Cover: `clubconnect-website/1.png`. Gallery: `clubconnect-website/1.png`, `2.png`, `3.png`
- [x] Overview: `ClubConnect is a member-benefits platform that centralizes access to movie ticketing, fuel discounts, parking, and other exclusive offers behind a single member account system. I designed the data model for members and benefit entitlements, built the backend logic for account management and benefit redemption, and implemented the front-end views members use to browse and claim offers. The project's focus was on clean relational data design and a straightforward, reliable user flow — the parts of full-stack development that matter most for a real membership product, rather than a purely visual exercise.`

**P6. `eary-woods-game`**
- [x] Title: `Eary Woods Game`
- [x] Summary: `Unity horror roll-a-ball game — wrote the C# gameplay systems: player movement/physics, enemy AI behavior, and level scripting.`
- [x] Tags: `Unity`, `C#`, `Game AI`, `Physics`
- [x] GitHub: `https://github.com/Wa7ze/eary-woods`
- [x] Response time: `200 OK · 119ms`
- [x] Cover: `eary-woods-game/1.png`. Gallery: `eary-woods-game/1.png`, `2.png`, `3.png` (~2MB PNGs each; WebP conversion will help most here)
- [x] Overview: `Eary Woods is a horror-themed roll-a-ball game built in Unity, where I was responsible for coding most of the core gameplay in C#: physics-driven player movement and input handling, an enemy AI state system that drives chase/patrol behavior to create tension, and scripted level logic and triggers. Beyond gameplay code, I worked on level design adjustments to pace the horror atmosphere correctly. The project is a concrete demonstration of applied game-engine programming — physics, AI state machines, and player-facing game feel — rather than just using pre-built Unity assets.`

- [x] Response time is computed as `40 + (sum of slug char codes % 141)`. The comment says the range is 40–180ms, but two projects compute to 174 and 175. I'll port the formula as-is unless you say otherwise. — ✔ **Resolved:** the formula is ported as-is (174/175ms included).

### 3.5 Approach, `#approach`. `lib/sections/s4_logic_approach.dart`
- [ ] Eyebrow: `fn handle(req)` — ✗ **Not ported:** Approach is hidden (user decision). Kept verbatim in `src/content/approach.ts`; set `visible: true` to show it (nav, hash, terminal follow).
- [ ] H2: `Approach` (hardcoded English, so it does not translate) — ✗ **Not ported:** Approach is hidden (user decision). Kept verbatim in `src/content/approach.ts`; set `visible: true` to show it (nav, hash, terminal follow).
- [ ] Three "call stack" cards. Each has an amber index `#1`, ` #2`, `  #3` (indented by its position), a title and a body: — ✗ **Not ported:** Approach is hidden (user decision). Kept verbatim in `src/content/approach.ts`; set `visible: true` to show it (nav, hash, terminal follow).
  - [ ] `Principle 1`: `TODO(content): replace with a real principle on how you design software.` — ✗ **Not ported:** Approach is hidden (user decision). Kept verbatim in `src/content/approach.ts`; set `visible: true` to show it (nav, hash, terminal follow).
  - [ ] `Principle 2`: `TODO(content): replace with a real principle on how you ship software.` — ✗ **Not ported:** Approach is hidden (user decision). Kept verbatim in `src/content/approach.ts`; set `visible: true` to show it (nav, hash, terminal follow).
  - [ ] `Principle 3`: `TODO(content): replace with a real principle on how you approach engineering tradeoffs.` — ✗ **Not ported:** Approach is hidden (user decision). Kept verbatim in `src/content/approach.ts`; set `visible: true` to show it (nav, hash, terminal follow).
- [x] **The live site shows these placeholders publicly.** Options: (a) port the placeholders verbatim (exact 1:1), (b) you supply 3 real principles (EN and AR), (c) build the section but hide it from nav and page until copy exists. I recommend (c) unless you have copy ready. — ✔ **Resolved:** (c) hidden until real principles are supplied.

### 3.6 Experience, `#experience`. `lib/sections/s5_database_experience.dart`
- [x] Eyebrow: `SELECT * FROM experience`
- [x] H2: EN `Work Experience` · AR `الخبرة العملية`
- [x] One row card: label `row 1` (amber) + period EN `2025 – Present` · AR `2025 – حتى الآن`
- [x] Role: EN `IT Support Specialist` · AR `أخصائي دعم فني`
- [x] Company: EN `Alessa Industries — Riyadh, Saudi Arabia` · AR `شركة Alessa Industries — الرياض، المملكة العربية السعودية`
- [x] Bullets (each prefixed `> ` in amber):
  - [x] EN 1 `Provided first-line IT support to employees using UltraVNC Viewer, resolving hardware, software, and system issues.`
    AR 1 `تقديم الدعم الفني المباشر للموظفين باستخدام برنامج UltraVNC Viewer، وحل مشكلات الأجهزة والبرمجيات والأنظمة.`
  - [x] EN 2 `Handled Helpdesk requests, troubleshooting Windows OS, applications, network connectivity, and printers.`
    AR 2 `التعامل مع طلبات الدعم الفني، واستكشاف أخطاء نظام Windows والتطبيقات والاتصال بالشبكة والطابعات وإصلاحها.`
  - [x] EN 3 `Participated in ERP system setup and migration activities, including master data preparation, validation, and testing across Sales, Purchase, Inventory, and Accounting modules.`
    AR 3 `المشاركة في إعداد وترحيل نظام ERP، بما في ذلك تجهيز البيانات الأساسية والتحقق منها واختبارها عبر وحدات المبيعات والمشتريات والمخزون والمحاسبة.`
  - [x] EN 4 `Developed and maintained custom Odoo modules, handling end-to-end implementation including business logic, data models, and UI views to extend core ERP functionality.`
    AR 4 `تطوير وصيانة وحدات Odoo المخصصة، والإشراف على التنفيذ الكامل بدءًا من منطق الأعمال ونماذج البيانات وحتى واجهات المستخدم لتوسيع وظائف نظام ERP الأساسية.`

### 3.7 Contact, `#contact`. `lib/sections/s6_response_contact.dart`
- [x] Eyebrow: `POST /contact`
- [x] H2: EN `Get In Touch` · AR `تواصل معي`
- [x] Subtitle: EN `I'm always open to discussing new opportunities, collaborations, or just having a chat about technology and coding.` · AR `أنا منفتح دائمًا لمناقشة الفرص الجديدة والتعاون، أو حتى لحديث عام حول التقنية والبرمجة.`
- [x] Primary button (NetButton with a "send" icon): EN `Email` · AR `البريد الإلكتروني`. It opens `mailto:mmazen0132@gmail.com?subject=Hello from Portfolio&body=Hi Mazen,`. If no mail client is available, it shows a red `503 No mail client` badge. — ✎ **Changed (decision):** same `mailto:`. A browser cannot detect a missing mail client, so the `503 No mail client` branch can't trigger on the web (it never did in the Flutter web build either).
- [x] **There is no form.** Contact is a `mailto:` link only; no data is posted anywhere (`docs/AUDIT.md`: "no real Formspree endpoint exists yet"). — ✔ **Resolved:** kept `mailto:` only (1:1).
- [x] Social link tiles (label / value / URL). The labels come from data and are **English in both locales**:

| Label | Value shown | URL |
|---|---|---|
| `Email` | `mmazen0132@gmail.com` | `mailto:mmazen0132@gmail.com` |
| `Phone` | `+966 54 674 8006` | `https://wa.me/966546748006` (opens WhatsApp, not `tel:`) |
| `LinkedIn` | `Mazen Matran` | `https://linkedin.com/in/mazen-matran` |
| `GitHub` | `Wa7ze` | `https://github.com/Wa7ze` |

- [x] Email tile · [x] Phone tile · [x] LinkedIn tile · [x] GitHub tile
- [x] Unused translated labels exist for these tiles: `contactPhoneLabel` `Phone`/`الهاتف`, `contactLinkedinLabel` `LinkedIn`/`لينكدإن`, `contactGithubLabel` `GitHub`/`جيت هاب`. Email uses `contactEmailLabel`. — ✔ **Resolved:** used: the tiles show translated labels in AR.

### 3.8 Footer / teardown (no nav entry; hash `#contact`). `lib/sections/s7_teardown_footer.dart`
- [x] Eyebrow: `FIN`
- [x] TCP-teardown ladder diagram with column labels `client` … `server` and 4 rows that draw in sequence when the end of the page is reached (rows start at 500/880/1260/1640ms, 380ms each, green):
  `FIN →`, `← ACK`, `← FIN`, `ACK →`
- [x] Closing card (fades in at 2100ms): heading `Connection closed.`, body `Thanks for visiting.`, button `Keep-Alive ↻`, which scrolls back to the top over a fixed 1000ms
- [x] `EOF` marker: appears and stretches when you overscroll past the bottom, then springs back
- [x] Copyright: `© {current year} Mazen Matran. All rights reserved.` · AR `© {year} مازن مطران. جميع الحقوق محفوظة.`
- [x] Built-with line: EN `Built with Flutter` · AR `صُنع باستخدام Flutter`. — ✎ **Changed (decision):** EN `Built with React, TypeScript & GSAP` · AR `صُنع باستخدام React وTypeScript وGSAP` (user decision).

---

## 4. 404 page. `lib/pages/not_found_page.dart`
- [ ] Mascot "Pak" in the `lost` mood (a `?` above its head, eyes sweeping, red accent), animated — ✗ **Not ported:** Pak belongs to the story (STORY.md; legacy notes in docs/STORY_DEV.md). The 404 shows a red `?` glyph instead.
- [x] Heading: `404`
- [x] Body: `Packet lost in transit.`
- [x] Mono line (LTR): `GET {requested path} → no route to host`, using the real requested path
- [x] Button (NetButton): `GET /`, which navigates home after 400ms
- [x] Netlify serves `index.html` for unknown paths (status 200) and the client renders the 404. — ✔ **Resolved:** a real 404 status via `dist/404.html` (no SPA catch-all). Verified locally: unknown path → 404; page content verified at `/404.html`.

---

## 5. Strings defined but NOT rendered on the current site

They were rendered by the pre-redesign multi-page site and are still in `lib/core/strings/*`.
"Nothing missing" could reasonably include them. **All of them are now shown (user decision); see each item.**

- [x] **Languages block.** H `Languages` / `اللغات`. Entries: `English` – `Fluent` / `الإنجليزية` – `طلاقة`; `Arabic` – `Fluent` / `العربية` – `طلاقة`; `Turkish` – `Advanced` / `التركية` – `متقدم`. *Recommend: show it in About.* — ✔ **Resolved:** shown in About.
- [x] **CV section.** Title `CV` / `السيرة الذاتية`. Subtitle `Tap the preview to view it full-size, or download the PDF.` / `اضغط على المعاينة لعرضها بالحجم الكامل، أو نزّل ملف PDF.`. Download title `Download My CV` / `تحميل سيرتي الذاتية`. Preview image `assets/images/misc/cv_preview.jpg`. *Recommend: show it, with the preview opening a lightbox and the PDF download.* — ✔ **Resolved:** shown in Contact: preview → lightbox, plus a `Download My CV` button.
- [x] **About teaser.** `About Me` / `نبذة عني`. Body EN: `I'm a software engineer specializing in full-stack development and IT/ERP systems — currently building production tools used by hundreds of people every day. I'm open to full-time, part-time, or traineeship opportunities in web, app, or game development.` AR: `أنا مهندس برمجيات متخصص في تطوير البرمجيات المتكاملة (Full-Stack) وأنظمة تقنية المعلومات وERP، أعمل حاليًا على بناء أدوات إنتاجية يستخدمها المئات يوميًا. أنا منفتح على فرص العمل بدوام كامل أو جزئي أو التدريب في مجالات تطوير الويب والتطبيقات وتطوير الألعاب.` CTA `Read my full story` / `اقرأ قصتي كاملة`. *This contains the "open to opportunities" statement, which is not anywhere else on the site. Recommend: show it in the hero or About.* — ✔ **Resolved:** shown as a hero panel; `Read my full story` → `#about`.
- [x] `heroCtaContact`: `Get in touch` / `تواصل معي`. *Recommend: a second hero CTA → `#contact`.* — ✔ **Resolved:** second hero CTA → `#contact`.
- [x] `aboutPageTitle` `About` / `نبذة عني`, `aboutPageSubtitle` `My background, experience, and skills.` / `خلفيتي المهنية وخبراتي ومهاراتي.` — ✔ **Resolved:** About section heading + subtitle.
- [x] Project page strings: `Back to Projects` / `العودة إلى المشاريع`, `Project Overview` / `نظرة عامة على المشروع`, `Project Gallery` / `معرض الصور`. *Recommend: use the last two as labels inside the expanded project card.* — ✔ **Resolved:** all three are used in the expanded project card.
- [x] `sidebarLanguage`: `Language` / `اللغة`. *Recommend: the aria-label for the EN/AR switch.* — ✔ **Resolved:** the `aria-label` of the EN/AR group.
- [x] (Covered in §3.0 and §3.7) `openMenu`, `closeMenu`, `contactPhoneLabel`, `contactLinkedinLabel`, `contactGithubLabel`
- [x] Unused images: certificate images ×8 (§3.2), project cover `imageUrl` ×6 (§3.4), `misc/cv_preview.jpg` — ✎ **Changed (decision):** all now rendered (certificates, project covers, CV preview).

---

## 6. Interactions and behaviors

### 6.1 Navigation and scroll. `lib/navigation/*`, `lib/scroll/*`
- [x] Nav click: smooth scroll to the section, with duration scaled by distance between 700ms and 1100ms (ease in-out cubic). Reduced motion: 200ms. — ✎ **Changed (decision):** Lenis `scrollTo` with the same 700–1100ms distance scaling + ease-in-out-cubic; reduced motion = instant jump (no Lenis).
- [ ] Traceroute: on nav click, a green glowing segment draws along the request path from the current station to the target (400ms) — ✗ **Not ported:** drawn on the request path, which belongs to the story (STORY.md; legacy notes in docs/STORY_DEV.md).
- [x] Active section = the last section whose top is above scrollY + 40% of the viewport. It drives the nav highlight, hash, background tint and path color. — ✎ **Changed (decision):** same 40% rule; drives the nav highlight + hash (background tint/path colour moved to the story).
- [x] Section reveal: each section fades in and slides up 16px (500ms, ease-out cubic) the first time it is reached
- [x] Bounce at the bottom only (no bounce at the top), which feeds the `EOF` marker — ✎ **Changed (decision):** browsers don't rubber-band like Flutter's physics. Wheel/touch overscroll at the bottom drives the EOF marker with the same spring (verified).
- [x] End-of-page trigger: within 40px of the bottom it fires once (teardown sequence, latency freezes to `Round trip`, Pak bows). It re-arms after you scroll back more than 400px from the bottom. — ✎ **Changed (decision):** verified; "Pak bows" is deferred to the story.

### 6.2 NetButton (all primary buttons). `lib/interaction/net_button.dart`
- [x] Click → "handshaking" state for 300ms (spinner + label, disabled) → action → floating status badge (`200 OK` in green, or e.g. `503 No mail client` in red) that rises and fades over 800ms. Errors are announced to screen readers. Enter/Space work. — ✎ **Changed (decision):** verified with `aria-busy`; the badge is announced via `role=alert` for errors.
- [x] Reduced motion: no handshake delay; the badge fades in place

### 6.3 CV download. `lib/interaction/cv_download_button.dart`
- [x] Downloads `/cv.pdf` with the filename **`Mazen_Matran_CV.pdf`** (via a hidden anchor, synchronously inside the click) — ✎ **Changed (decision):** a real `<a download>`. The same `Mazen_Matran_CV.pdf` filename is verified.
- [x] The button turns into a 4-chunk progress bar (200ms per chunk), then shows `200 OK · cv.pdf` in green for 1.2s, then resets. Outline style, cyan, 180×44.

### 6.4 External links (NetLink). `lib/interaction/net_link.dart`
- [x] The link opens immediately, in a new tab or external app
- [x] A badge pops (`301 Moved Permanently`, or `SMTP 250 OK` for `mailto:`), and a tiny cyan Pak "flyer" arcs to the top-right corner and shrinks. Pak waves. — ✎ **Changed (decision):** the badge is verified; the Pak flyer and wave are deferred to the story.
- [x] Used on: certificate verification links, `View on GitHub`, and the 4 contact tiles

### 6.5 Empty-click effects. `lib/interaction/click_router.dart`, `rate_limiter.dart`, `effects/*`
- [x] Clicking/tapping blank page area (moved less than 8px, held less than 300ms) spawns a cyan "ping": 2 expanding rings + a dot + a floating label. Labels are weighted random: `ping {20–79}ms` (50%), `ICMP echo reply` (25%), `TTL=64` (15%), `404: nothing here` (10%). Max 6 alive at once.
- [ ] Pak looks toward the click point — ✗ **Not ported:** Pak belongs to the story (STORY.md; legacy notes in docs/STORY_DEV.md).
- [x] Rate limit: more than 8 empty clicks within 2.5s → red badge `429 Too Many Requests`, Pak goes dizzy (1.6s), toast `429 Too Many Requests — slow down a little` — ✎ **Changed (decision):** badge + toast verified; Pak dizzy is deferred to the story.
- [x] Reduced motion: label only, no rings — ✎ **Changed (decision):** implemented (rings not rendered under reduced motion); checked in code, not in an automated test.

### 6.6 Hidden terminal. `lib/widgets/terminal_launcher.dart`, `terminal_overlay.dart` (lazy-loaded)
- [x] Open/close: the `` ` `` (backquote) key anywhere, unless a text field is focused, or long-press the `<mm/>` logo. `Esc` or `exit` closes it. — ✎ **Changed (decision):** all verified, including the long-press; the terminal also has a close button.
- [x] Bottom sheet: 45% of the viewport height on desktop, 90% on mobile, cyan top border
- [x] Initial line: `type help to list commands`
- [x] Prompt: `guest@portfolio:~$ `. Each command is echoed as `guest@portfolio:~$ {cmd}`.
- [x] Commands and output, verbatim:
  - [x] `help` → `help, whoami, ls, ls projects, cat <slug>, cd <section>, curl /<section>,` / `open github|linkedin|cv, history, clear, sudo hire <anything>, exit`
  - [x] `whoami` → the summary body (current locale)
  - [x] `ls` → `home  about  skills  projects  approach  experience  contact` — ✎ **Changed (decision):** `approach` is omitted while hidden.
  - [x] `ls projects` → one line per project: `{slug}  ({tags joined by ", "})`
  - [x] `cat <slug>` → `{title} — {summary}` then `repo: {githubUrl}`; unknown → `cat: {x}: no such project`
  - [x] `cd <section>` / `curl /<section>` → `→ routing to /{name}`, then after 300ms closes and scrolls; unknown → `{cd|curl}: {name}: no route to host`
  - [x] `open github|linkedin|cv` → `→ opening github` / `→ opening linkedin` / `→ opening cv`; unknown → `open: {x}: unknown target`. — ✔ **Resolved:** **bug fixed**: each one now actually opens in a new tab (verified).
  - [x] `history` → `{n}  {cmd}` per entry
  - [x] `clear` → empties the output
  - [x] `sudo hire …` → `[sudo] permission granted.`, `→ opening /contact`, then routes to contact; other `sudo x` → `sudo: {x}: command not found`
  - [x] `exit` → closes
  - [x] anything else → `command not found: {cmd}. try help`

### 6.7 Idle states. `lib/widgets/idle_watcher.dart`
- [x] After 15s with no activity (pointer, scroll, key), a heartbeat ping appears near the top-left (80,80) and repeats every 15s
- [x] At 45s: toast `408 Request Timeout`, Pak falls asleep (`z` `z`), and the page dims to 90% opacity (600ms) — ✎ **Changed (decision):** toast + 90% dim verified; Pak sleeping is deferred to the story.
- [x] First activity after the timeout: toast `Connection re-established`, Pak is startled — ✎ **Changed (decision):** toast verified; Pak startled is deferred to the story.
- [x] Timers pause while the tab is hidden — ✎ **Changed (decision):** implemented (`visibilitychange`); checked in code, not in an automated test.

### 6.8 Custom cursor (desktop mouse only). `lib/widgets/custom_cursor.dart`
- [x] The system cursor is hidden after the first mouse move and replaced by a cyan glowing 8px node with a fading 10-point trail — ✎ **Changed (decision):** canvas cursor; enable + hide-system-cursor verified (the trail is visual).
- [x] Over interactive elements a 28px ring appears, shrinking to 20px while pressed — ✎ **Changed (decision):** implemented; visual only (not asserted).
- [x] It is permanently disabled for the session on the first touch or pen event. It is off when reduced motion is on.

### 6.9 Background scene (being replaced by the new story). `lib/scene/*`
- [ ] Fixed backdrop: base colour, a radial glow tinted by the active "layer" colour at 8% (cross-fades in 450ms), and a 32px grid with 0.3× scroll parallax — ✗ **Not ported:** belongs to the scroll story (user decision #7). Documented for reuse in docs/STORY_DEV.md.
- [ ] Layer → accent colour: browser/network (Hero, About) = cyan `#22D3EE`; gateway/api/logic (Skills, Projects, Approach) = violet `#A78BFA`; database (Experience) = amber `#F59E0B`; response (Contact, Footer) = green `#4ADE80` — ✗ **Not ported:** belongs to the scroll story (user decision #7). Documented for reuse in docs/STORY_DEV.md.
- [ ] **Request path:** a dashed S-curve through one "station" per section in the left gutter (mirrored in RTL). The travelled part is solid, glowing and accent-coloured. Stations fill once reached. 3 packet dots loop along the travelled part (3s). — ✗ **Not ported:** belongs to the scroll story (user decision #7). Documented for reuse in docs/STORY_DEV.md.
- [ ] **Pak (mascot):** a small rounded "packet" character with eyes and a header cap that travels along the path with scroll (eased follow). Moods: idle, traveling, fast (squash and stretch on quick scroll), encrypted (dashed shell), carrying (backpack), lookingAt, throttled, dizzy (spiral eyes), sleeping (`z`s), startled, waving (arm), bowing (tilt), lost (`?`). Size 56px on desktop, 40px on mobile. — ✗ **Not ported:** belongs to the scroll story (user decision #7). Documented for reuse in docs/STORY_DEV.md.
- [x] **Port, replace, or retire?** The brief says the new scroll story plays behind the content. The path, Pak and layer tints are the old story. My plan: keep Pak reactions (look, dizzy, wave, sleep, bow) out of Phase 2, build only the story plumbing, and treat Pak and the request path as candidate characters for the new story. Their reactions in §6.4–6.7 would degrade to just badges and toasts until the story exists. Is that OK, or do you want Pak ported in Phase 2? — ✔ **Resolved:** left out of Phase 2 (user decision); the reactions show as badges and toasts.

---

## 7. Assets

All under `assets/images/` unless noted. Pixel sizes and byte sizes are measured.

### 7.1 Project images
- [x] `helpdesk-system/1.png` (1440×900, 242 KB) · [x] `2.png` (1440×900, 232 KB) · [x] `3.png` (1440×900, 225 KB) · [x] `4.png` (1440×900, 207 KB)
- [x] `portfoilo-website/image.png` (1919×906, 89 KB) · [x] `image copy.png` (1918×901, 1.25 MB) · [x] `image copy 2.png` (1908×904, 180 KB) — ✎ **Changed (decision):** replaced by screenshots of the new site, same names (§3.4 P2).
- [x] `outfitly-app/1.png` · [x] `2.png` · [x] `3.png` (each 258×558, ~90–103 KB)
- [x] `nutritrack-website/1.png` (957×483, 635 KB) · [x] `2.png` (1086×577, 527 KB) · [x] `3.png` (1137×481, 234 KB)
- [x] `clubconnect-website/1.png` (886×483, 343 KB) · [x] `2.png` (910×517, 410 KB) · [x] `3.png` (773×423, 138 KB)
- [x] `eary-woods-game/1.png` (1859×813, 2.0 MB) · [x] `2.png` (1833×805, 2.0 MB) · [x] `3.png` (1837×808, 2.2 MB)

### 7.2 Certificate images (not currently rendered, see §3.2)
- [x] `certificates/0_bachelors.jpg` (1400×984) · [x] `1_minor.jpg` (1400×987) · [x] `2_kanz_hackathon.jpg` (1400×989) · [x] `3_eartech_coding.jpg` (1400×1081) · [x] `4_minnalearn.jpg` (1400×1081) · [x] `5_codveda.jpg` (1400×1980) · [x] `6_ueskuedar_honor.jpg` (1400×991) · [x] `7_sce_registration.jpg` (1400×1978)

### 7.3 Documents and misc
- [x] **CV PDF:** `web/cv.pdf` (146 KB, 1 page). Served at `/cv.pdf`, downloads as `Mazen_Matran_CV.pdf`. *(It lived at `assets/files/Mazen_Matran_CV.pdf` before the redesign; `../My_portfolio/assets/files/` is now an empty, untracked folder.)* The original is kept as-is; it is not optimized. — ✎ **Changed (decision):** copied byte-for-byte to `public/cv.pdf` (verified with `cmp`).
- [x] `misc/cv_preview.jpg` (1200×1552, 277 KB). Not currently rendered (§5).

### 7.4 Icons
- [x] `web/favicon.png` (16×16) · [x] `web/icons/Icon-192.png` · [x] `Icon-512.png` · [x] `Icon-maskable-192.png` · [x] `Icon-maskable-512.png` — ✎ **Changed (decision):** same filenames, new `<mm/>` monogram (favicon.png is now 32×32, plus `favicon.svg`).
- [x] **All five are the stock Flutter logo** (I checked them visually). Porting them 1:1 would brand the React site with Flutter's logo. Should I generate a new `<mm/>` monogram icon set (SVG favicon + PNGs, same filenames) in the new palette? I recommend yes. — ✔ **Resolved:** a new `<mm/>` monogram set was generated (`scripts/assets.mjs`).
- [x] UI icons come from Material Icons (menu, close, dark_mode_outlined, light_mode_outlined, expand_more/less, send). They will be replaced by inline SVG equivalents, with no icon font. — ✎ **Changed (decision):** inline SVG icons (`src/components/ui/Icons.tsx`); theme icons dropped.

### 7.5 Not present
- [x] No font files, no Lottie, no Rive, no SVG, no video, no audio. (`docs/AUDIT.md` confirms Rive and Lottie were removed.)

---

## 8. Motion and reduced-motion contract (`lib/core/tokens.dart` `Motion`)
- [x] Durations: press 90ms · handshake 300 · ping 600 · badge float 800 · trace draw 400 · nav scroll 700–1100 · redirect 350 · reveal 500 · teardown step 380 · keep-alive 1000 · layer blend 450 — ✎ **Changed (decision):** ported as tokens (`src/lib/motion.ts`, `theme.css`); trace-draw/layer-blend are unused until the story exists.
- [x] Reduced motion: no section reveal (content shown immediately), nav is a 200ms scroll with no traceroute, ping shows its label only, badges fade in place, no handshake delay, no custom cursor, no grid parallax, Pak snaps instead of easing, teardown shows its final state instantly, and the boot loader has no animation — ✎ **Changed (decision):** verified: no reveal, instant nav, no handshake, no cursor, no boot loader, no Lenis. Traceroute/grid/Pak are story-owned.

---

## 9. Hosting and deploy

- [x] **Host: Netlify.** `netlify.toml`
  - [x] build command: clones Flutter `3.47.2` and runs `flutter build web --release` — ✎ **Changed (decision):** now `npm run build`.
  - [x] publish dir: `build/web` — ✎ **Changed (decision):** now `dist`.
  - [x] redirect: `/*` → `/index.html` with status `200` (SPA fallback) — ✎ **Changed (decision):** removed, so unknown paths return a real 404; 301s added for the legacy routes.
- [x] **No** `firebase.json`, GitHub Actions workflows, `CNAME`, `_redirects` or `_headers` files exist
- [x] **Custom domain or site URL: not found anywhere in the repo.** Netlify domains are configured in the dashboard, not in files. Please tell me the live URL (e.g. `xxx.netlify.app` or a custom domain). I need it for `sitemap.xml`, `robots.txt`, canonical and `og:url`. Also: should the new site deploy to the **same Netlify site** (by repointing it to this repo) or a new one? I won't touch Netlify settings myself either way. — ✔ **Resolved:** `https://mazenportfolio.netlify.app/`; the new site takes over the same Netlify site. Steps for you are in DEPLOY.md (no Netlify settings were changed).
- [x] New `netlify.toml` will use: `npm run build`, publish `dist`, Node version pinned, the 301s from §2.3, and a 404 page — ✎ **Changed (decision):** done: Node 24, 301s, no catch-all, immutable cache headers for `/assets/*`.

---

## 10. History notes (context only, not ported)
- Pre-redesign (≤ `b4073ef`): multi-page site (`/`, `/work`, `/work/:slug`, `/about`, `/contact`), a "cosmic" planet background, a floating left sidebar with name, nav, theme and language controls and a footer, a CV section with preview on every page, and snackbars on contact failures: `Email copied to clipboard: mmazen0132@gmail.com`, `Could not open WhatsApp`, `Could not open LinkedIn`, `Could not open GitHub`. All of its copy is still in the current strings files (§5), except those 4 snackbar messages.
- `lib/widgets/opening_splash.dart`: an unused "code swirl" intro typing `const you = build();`. It is dead code and will not be ported.

## 11. Inputs for the future story (not Phase 2 work)
- The current narrative is the "Life of an HTTP Request": each section is a network layer (browser → TLS → gateway → API → logic → database → response → FIN). It has the Pak mascot, the request path, layer colours and the protocol eyebrows. The eyebrows are ported as content; the rest is visual.
- WIP scenes in `../My_portfolio` (uncommitted): a lightbulb and desk with Pak's head in the hero, a server room, a dev desk.

---

## 12. Decisions applied (former `[?]` items)

| Item | Decision | Who decided |
|---|---|---|
| Flutter files in this repo | Moved to `./legacy` (gitignored) | You |
| Live URL / host | `https://mazenportfolio.netlify.app/`, same Netlify site (DEPLOY.md) | You |
| Approach section | Hidden until real principles exist | You |
| Hidden content (Languages, CV preview, certificate images, teaser) | Shown | You |
| Icons + manifest | New `<mm/>` monogram, navy manifest colours, real description | You |
| Light theme | Dropped (dark navy only) | You |
| Pak, request path | Left out of Phase 2 → story (STORY.md, docs/STORY_DEV.md) | You |
| Portfolio project + footer | Rewritten for React/TS/GSAP | You |
| Terminal `open …` | Fixed: actually opens | You |
| Page title | `Mazen Matran \| Portfolio` | You |
| OG image, canonical, og:url, Twitter card | Added | Me |
| Boot loader | Kept, 600ms, skipped on reduced motion | Me |
| Legacy routes | 301 → hash anchors | Me |
| Response-time formula | Ported as-is | Me |
| Contact form | `mailto:` only (1:1) | Me |
| AR contact tile labels | Translated | Me |
| Helpdesk GitHub URL | Profile URL kept | Me |
| C5/C6 shared image | Kept | Me |
| 404 | Real 404 status (static `404.html`) | Me |
| Gallery | Lightbox added | Me |
| Portfolio screenshots | Replaced with new-site shots, same filenames | Me |
| Background grid, layer tints, traceroute, Pak flyer | Not ported (story-owned) | Me |

## 13. Verification evidence (Phase 3)

- **Automated parity:** `node scripts/verify.mjs` → **596/596 passed** (`screenshots/verify.json`, `screenshots/verify.log`).
  It covers every verbatim string in EN and AR, all content links, every rendered image, the public files,
  head/SEO tags, manifest, sitemap/robots, and the interactions in §6 (terminal commands, rate limit, idle with a fake
  clock, CV download filename, lightbox, project accordion, teardown, Keep-Alive, EOF spring, hash deep link, mobile
  menu, skip link, reduced motion, debug overlay, StoryStage layering), plus no horizontal overflow at 375/768/1920.
- **Screenshots:** the new site per section at 375/768/1280/1920 in EN and AR (`screenshots/new/`), plus
  feature shots (`feature-*.png`). The legacy Flutter build (built from a scratch copy of `legacy/`) is captured
  one viewport at a time at 1280 and 375 (`screenshots/legacy/`). Side-by-side view: `screenshots/compare.html`.
- **Lighthouse** (production build, local): mobile — Performance 93, Accessibility 100, Best Practices 100,
  SEO 100. Desktop — 100 / 100 / 100 / 100.
- **Legacy observations made while comparing:** the Flutter build did not jump to `#hash` sections on load, and its
  "Skip to content" link is visible on load (known quirk in its AUDIT.md). Neither issue is present in the new site.
