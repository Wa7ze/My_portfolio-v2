import type { Project } from './types';

/**
 * Projects in display order. Verbatim from legacy lib/data/portfolio_content.dart, except
 * `portfolio-website`, which was rewritten (user decision) to describe the new React stack.
 * Project content is English in both locales, as on the legacy site.
 */
export const projects: Project[] = [
  {
    slug: 'helpdesk-system',
    title: 'Helpdesk & Inventory Management System',
    summary:
      'Production FastAPI + React helpdesk and inventory platform serving ~300 daily users, with ticket approval workflows, device inventory, and activity tracking, built and shipped solo end-to-end.',
    tags: ['Python', 'FastAPI', 'PostgreSQL', 'React', 'TypeScript'],
    githubUrl: 'https://github.com/Wa7ze',
    cover: 'helpdesk-system/2',
    gallery: ['helpdesk-system/1', 'helpdesk-system/2', 'helpdesk-system/3', 'helpdesk-system/4'],
    overview:
      'An independent, full-stack helpdesk and inventory system used daily by roughly 300 employees at a real company. The backend is built with Python and FastAPI on PostgreSQL, exposing a REST API for ticketing, device/inventory records, and role-based access control, deployed on Render; the frontend is a React + TypeScript SPA deployed on Netlify. The ticketing module supports full approval workflows (create, edit, close, and approve requests), the inventory module tracks devices with bulk Excel import, and an activity log records changes across the system for auditability. This project demonstrates end-to-end ownership of a production system: API design, relational data modeling, authentication, deployment, and a responsive UI — all shipped and actively used, not just a demo.',
  },
  {
    slug: 'portfolio-website',
    title: 'Portfolio Website',
    summary:
      'This site: a responsive React + TypeScript web app with full Arabic/English i18n and RTL support, smooth scrolling, and a scroll-driven animated story choreographed with GSAP.',
    tags: ['React', 'TypeScript', 'GSAP', 'Tailwind CSS', 'i18n / RTL'],
    githubUrl: 'https://github.com/Wa7ze/My_portfolio-v2',
    cover: 'portfoilo-website/image copy 2',
    gallery: ['portfoilo-website/image', 'portfoilo-website/image copy', 'portfoilo-website/image copy 2'],
    overview:
      'My portfolio, rebuilt from a Flutter web app into a web-native React + TypeScript site bundled with Vite. All copy lives in typed data files, so projects and text are edited without touching components, and a hand-rolled Arabic/English localization layer switches the document language and direction so the entire layout mirrors correctly in RTL. Styling is Tailwind CSS driven by a single design-token file, with glass panels that keep text readable over an animated background. Motion is built on GSAP: one master timeline bound to page scroll through ScrollTrigger and synced with Lenis smooth scrolling drives a layered SVG story behind the content, while the interaction layer — status-code badges, a hidden terminal, idle states — is hand-built and keyboard-accessible. The project is a practical showcase of modern front-end architecture: type-safe content, internationalization, accessibility, and performance-minded motion design working together.',
  },
  {
    slug: 'outfitly-app',
    title: 'Outfitly App',
    summary:
      'Cross-platform Flutter wardrobe app with a Django + TensorFlow recommendation backend — my graduation project, covering mobile UI, API integration, and applied ML end-to-end.',
    tags: ['Flutter', 'Django', 'TensorFlow', 'REST API', 'Mobile App'],
    githubUrl: 'https://github.com/Wa7ze/outfitly-3',
    cover: 'outfitly-app/1',
    gallery: ['outfitly-app/1', 'outfitly-app/2', 'outfitly-app/3'],
    overview:
      'Outfitly is my graduation project: an AI-powered wardrobe companion split cleanly between a Flutter cross-platform client and a Django + TensorFlow backend. The Flutter app handles the digital wardrobe, outfit planner, and social feed, communicating with the backend over a REST API; the backend uses TensorFlow models to analyze clothing items and generate personalized outfit recommendations. Building it meant working across the whole stack — mobile UI/UX in Flutter, API contract design, and integrating a trained ML model into a real product — which is what made it the strongest demonstration of my range as an engineer during my degree.',
  },
  {
    slug: 'nutritrack-website',
    title: 'Nutritrack Website',
    summary:
      'Django-based social nutrition tracker (~65% individual contribution) — built the authentication system and validated it with Selenium functional tests and JMeter load tests.',
    tags: ['Python', 'Django', 'SQLite', 'Selenium', 'JMeter'],
    githubUrl: 'https://github.com/Wa7ze/nutritrack',
    cover: 'nutritrack-website/1',
    gallery: ['nutritrack-website/1', 'nutritrack-website/2', 'nutritrack-website/3'],
    overview:
      'NutriTrack is a social nutrition-tracking platform built with Django, HTML, and SQLite, where I owned roughly 65% of the project. My core contribution was the authentication and account system — signup, login, profile management, and follow/unfollow logic — plus the meal-posting and search features that sit on top of it. I also designed and ran the test suite: functional test cases in Selenium to verify user flows end to end, and load/performance testing with Apache JMeter to check the app under concurrent traffic. This project reflects both backend ownership and a QA mindset — building the feature and proving it works under load, not just that it compiles.',
  },
  {
    slug: 'clubconnect-website',
    title: 'ClubConnect Website',
    summary:
      'Full-stack member benefits platform — account management, benefit redemption, and an admin-facing backend for a member offers program (ticketing, fuel discounts, parking).',
    tags: ['Full-Stack Web', 'Database Design', 'Member Management'],
    githubUrl: 'https://github.com/Wa7ze/clubconnect',
    cover: 'clubconnect-website/1',
    gallery: ['clubconnect-website/1', 'clubconnect-website/2', 'clubconnect-website/3'],
    overview:
      "ClubConnect is a member-benefits platform that centralizes access to movie ticketing, fuel discounts, parking, and other exclusive offers behind a single member account system. I designed the data model for members and benefit entitlements, built the backend logic for account management and benefit redemption, and implemented the front-end views members use to browse and claim offers. The project's focus was on clean relational data design and a straightforward, reliable user flow — the parts of full-stack development that matter most for a real membership product, rather than a purely visual exercise.",
  },
  {
    slug: 'eary-woods-game',
    title: 'Eary Woods Game',
    summary:
      'Unity horror roll-a-ball game — wrote the C# gameplay systems: player movement/physics, enemy AI behavior, and level scripting.',
    tags: ['Unity', 'C#', 'Game AI', 'Physics'],
    githubUrl: 'https://github.com/Wa7ze/eary-woods',
    cover: 'eary-woods-game/1',
    gallery: ['eary-woods-game/1', 'eary-woods-game/2', 'eary-woods-game/3'],
    overview:
      'Eary Woods is a horror-themed roll-a-ball game built in Unity, where I was responsible for coding most of the core gameplay in C#: physics-driven player movement and input handling, an enemy AI state system that drives chase/patrol behavior to create tension, and scripted level logic and triggers. Beyond gameplay code, I worked on level design adjustments to pace the horror atmosphere correctly. The project is a concrete demonstration of applied game-engine programming — physics, AI state machines, and player-facing game feel — rather than just using pre-built Unity assets.',
  },
];

/** Legacy fake-but-stable "response time": 40 + (sum of slug char codes % 141). Ported as-is. */
export function responseTimeMs(slug: string): number {
  let sum = 0;
  for (const ch of slug) sum += ch.charCodeAt(0);
  return 40 + (sum % 141);
}

/** The JSON "response body" shown in an expanded card, in the legacy format. */
export function projectJson(p: Project): string {
  const stack = p.tags.map((t) => `"${t}"`).join(', ');
  return `{\n  "slug": "${p.slug}",\n  "stack": [${stack}],\n  "repo": "${p.githubUrl}"\n}`;
}
