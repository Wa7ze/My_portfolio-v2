import 'models.dart';

/// All structurally-new PRD content (Sections 3/4/6, and the certificates
/// folded into Section 1). Ported verbatim from the pre-overhaul
/// lib/features/work/work_data.dart and lib/features/about/certificate_data.dart,
/// plus the social links previously hardcoded in
/// lib/features/contact/contact_page.dart. See docs/AUDIT.md for why this
/// is a single locale-independent object rather than an EN/AR pair.
abstract final class PortfolioContent {
  // --- Section 3 (API/projects) --- ported verbatim from work_data.dart.
  static List<String> _images(String slug) {
    if (slug == 'portfoilo-website') {
      return const [
        'assets/images/portfoilo-website/image.png',
        'assets/images/portfoilo-website/image copy.png',
        'assets/images/portfoilo-website/image copy 2.png',
      ];
    }
    if (slug == 'helpdesk-system') {
      return const [
        'assets/images/helpdesk-system/1.png',
        'assets/images/helpdesk-system/2.png',
        'assets/images/helpdesk-system/3.png',
        'assets/images/helpdesk-system/4.png',
      ];
    }
    return [
      'assets/images/$slug/1.png',
      'assets/images/$slug/2.png',
      'assets/images/$slug/3.png',
    ];
  }

  static final List<Project> projects = [
    Project(
      slug: 'helpdesk-system',
      title: 'Helpdesk & Inventory Management System',
      imageUrl: 'assets/images/helpdesk-system/2.png',
      summary: 'Production FastAPI + React helpdesk and inventory platform serving ~300 daily users, with ticket '
          'approval workflows, device inventory, and activity tracking, built and shipped solo end-to-end.',
      tags: const ['Python', 'FastAPI', 'PostgreSQL', 'React', 'TypeScript'],
      githubUrl: 'https://github.com/Wa7ze',
      galleryImages: _images('helpdesk-system'),
      overview: 'An independent, full-stack helpdesk and inventory system used daily by roughly 300 employees at a real '
          'company. The backend is built with Python and FastAPI on PostgreSQL, exposing a REST API for ticketing, '
          'device/inventory records, and role-based access control, deployed on Render; the frontend is a React + '
          'TypeScript SPA deployed on Netlify. The ticketing module supports full approval workflows (create, edit, '
          'close, and approve requests), the inventory module tracks devices with bulk Excel import, and an activity '
          'log records changes across the system for auditability. This project demonstrates end-to-end ownership of a '
          'production system: API design, relational data modeling, authentication, deployment, and a responsive UI — '
          'all shipped and actively used, not just a demo.',
    ),
    Project(
      slug: 'portfolio-website',
      title: 'Portfolio Website',
      imageUrl: 'assets/images/portfoilo-website/image copy 2.png',
      summary: 'This site: a responsive Flutter web app with a theme system (dark/light), full Arabic/English i18n '
          'with RTL support, and choreographed motion built on Flutter\'s animation and custom-painting APIs.',
      tags: const ['Flutter', 'Dart', 'i18n / RTL', 'Custom Animation', 'Responsive Design'],
      githubUrl: 'https://github.com/Wa7ze/My_portfolio',
      galleryImages: _images('portfoilo-website'),
      // TODO(content): this overview describes the pre-overhaul architecture
      // (cosmic background, floating sidebar) — ask the user for an updated
      // description once the "life of an HTTP request" redesign ships.
      overview: 'My portfolio, built entirely in Flutter for web rather than a templated site builder. It implements a '
          'shared light/dark ThemeData pair with a custom ThemeExtension for palette tokens, a hand-rolled Arabic/'
          'English localization layer that drives Flutter\'s Directionality so the entire layout mirrors correctly in '
          'RTL, a Provider-based state layer for theme/locale/navigation state, and a CustomPainter-driven opening '
          'animation. The floating, hamburger-triggered sidebar, staggered scroll-reveal animations, and responsive '
          'grid layouts across every page are all hand-built. The project is a practical showcase of Flutter web '
          'architecture: state management, custom painting, internationalization, and motion design working together.',
    ),
    Project(
      slug: 'outfitly-app',
      title: 'Outfitly App',
      imageUrl: 'assets/images/outfitly-app/1.png',
      summary: 'Cross-platform Flutter wardrobe app with a Django + TensorFlow recommendation backend — my graduation '
          'project, covering mobile UI, API integration, and applied ML end-to-end.',
      tags: const ['Flutter', 'Django', 'TensorFlow', 'REST API', 'Mobile App'],
      githubUrl: 'https://github.com/Wa7ze/outfitly-3',
      galleryImages: _images('outfitly-app'),
      overview: 'Outfitly is my graduation project: an AI-powered wardrobe companion split cleanly between a Flutter '
          'cross-platform client and a Django + TensorFlow backend. The Flutter app handles the digital wardrobe, '
          'outfit planner, and social feed, communicating with the backend over a REST API; the backend uses '
          'TensorFlow models to analyze clothing items and generate personalized outfit recommendations. Building it '
          'meant working across the whole stack — mobile UI/UX in Flutter, API contract design, and integrating a '
          'trained ML model into a real product — which is what made it the strongest demonstration of my range as an '
          'engineer during my degree.',
    ),
    Project(
      slug: 'nutritrack-website',
      title: 'Nutritrack Website',
      imageUrl: 'assets/images/nutritrack-website/1.png',
      summary: 'Django-based social nutrition tracker (~65% individual contribution) — built the authentication system '
          'and validated it with Selenium functional tests and JMeter load tests.',
      tags: const ['Python', 'Django', 'SQLite', 'Selenium', 'JMeter'],
      githubUrl: 'https://github.com/Wa7ze/nutritrack',
      galleryImages: _images('nutritrack-website'),
      overview: 'NutriTrack is a social nutrition-tracking platform built with Django, HTML, and SQLite, where I owned '
          'roughly 65% of the project. My core contribution was the authentication and account system — signup, login, '
          'profile management, and follow/unfollow logic — plus the meal-posting and search features that sit on top '
          'of it. I also designed and ran the test suite: functional test cases in Selenium to verify user flows end '
          'to end, and load/performance testing with Apache JMeter to check the app under concurrent traffic. This '
          'project reflects both backend ownership and a QA mindset — building the feature and proving it works under '
          'load, not just that it compiles.',
    ),
    Project(
      slug: 'clubconnect-website',
      title: 'ClubConnect Website',
      imageUrl: 'assets/images/clubconnect-website/1.png',
      summary: 'Full-stack member benefits platform — account management, benefit redemption, and an admin-facing '
          'backend for a member offers program (ticketing, fuel discounts, parking).',
      tags: const ['Full-Stack Web', 'Database Design', 'Member Management'],
      githubUrl: 'https://github.com/Wa7ze/clubconnect',
      galleryImages: _images('clubconnect-website'),
      overview: 'ClubConnect is a member-benefits platform that centralizes access to movie ticketing, fuel discounts, '
          'parking, and other exclusive offers behind a single member account system. I designed the data model for '
          'members and benefit entitlements, built the backend logic for account management and benefit redemption, '
          "and implemented the front-end views members use to browse and claim offers. The project's focus was on "
          'clean relational data design and a straightforward, reliable user flow — the parts of full-stack '
          'development that matter most for a real membership product, rather than a purely visual exercise.',
    ),
    Project(
      slug: 'eary-woods-game',
      title: 'Eary Woods Game',
      imageUrl: 'assets/images/eary-woods-game/1.png',
      summary: 'Unity horror roll-a-ball game — wrote the C# gameplay systems: player movement/physics, enemy AI '
          'behavior, and level scripting.',
      tags: const ['Unity', 'C#', 'Game AI', 'Physics'],
      githubUrl: 'https://github.com/Wa7ze/eary-woods',
      galleryImages: _images('eary-woods-game'),
      overview: 'Eary Woods is a horror-themed roll-a-ball game built in Unity, where I was responsible for coding '
          'most of the core gameplay in C#: physics-driven player movement and input handling, an enemy AI state '
          'system that drives chase/patrol behavior to create tension, and scripted level logic and triggers. Beyond '
          'gameplay code, I worked on level design adjustments to pace the horror atmosphere correctly. The project is '
          'a concrete demonstration of applied game-engine programming — physics, AI state machines, and player-facing '
          'game feel — rather than just using pre-built Unity assets.',
    ),
  ];

  // --- Folded into Section 1 (Network/about) --- ported verbatim from
  // certificate_data.dart. Featured (degrees/registration) shown first,
  // then courses/internships, matching the original grouping.
  static const List<CertificateEntry> featuredCertificates = [
    CertificateEntry(
      title: "Bachelor's Degree — Software Engineering",
      issuer: 'Üsküdar University — Faculty of Engineering and Natural Sciences',
      date: 'Graduated October 24, 2025 · Diploma No. 02-03548',
      imageAsset: 'assets/images/certificates/0_bachelors.jpg',
    ),
    CertificateEntry(
      title: 'Minor Degree — Computer Engineering',
      issuer: 'Üsküdar University — Faculty of Engineering and Natural Sciences',
      date: 'October 31, 2025 · Certificate No. 3603',
      imageAsset: 'assets/images/certificates/1_minor.jpg',
    ),
    CertificateEntry(
      title: 'Registered Software Engineer',
      issuer: 'Saudi Council of Engineers (SCE) — Membership ID 1245821',
      date: 'Valid May 2026 – May 2027',
      imageAsset: 'assets/images/certificates/7_sce_registration.jpg',
    ),
  ];

  static const List<CertificateEntry> otherCertificates = [
    CertificateEntry(
      title: 'AI Training Hackathon',
      issuer: 'Kanz (HumanityAI)',
      date: 'July 15, 2026',
      imageAsset: 'assets/images/certificates/2_kanz_hackathon.jpg',
      url: 'https://try.ka.nz/certificate/KANZ-ATT-442AA89710?certificate_type=participation&recipient_name=Mazen+Matran&issue_date=July+15%2C+2026&certificate_id=KANZ-ATT-442AA89710',
    ),
    CertificateEntry(
      title: '"Artificial Intelligence with Cloud & Cybersecurity" Internship Program',
      issuer: 'EARTech Information Technology',
      date: 'October 8, 2025',
      imageAsset: 'assets/images/certificates/3_eartech_coding.jpg',
      url: 'https://credsverse.com/credentials/5f6cbab5-3e19-40a4-b003-caf0e029dc17?preview=1',
    ),
    CertificateEntry(
      title: '"Artificial Intelligence with Coding & Cybersecurity" Internship Program',
      issuer: 'EARTech Information Technology',
      date: 'September 17, 2025',
      imageAsset: 'assets/images/certificates/3_eartech_coding.jpg',
      url: 'https://credsverse.com/credentials/21dd3325-670f-4f22-8995-f58b38670e5d?preview=1',
    ),
    CertificateEntry(
      title: 'Elements of AI',
      issuer: 'MinnaLearn — Tech Pathways MENA Program (Village Capital × MinnaLearn / University of Helsinki, supported by Google.org)',
      date: 'January 2026',
      imageAsset: 'assets/images/certificates/4_minnalearn.jpg',
    ),
    CertificateEntry(
      title: 'Full Stack Development Internship',
      issuer: 'Codveda Technologies',
      date: 'November – December 2025',
      imageAsset: 'assets/images/certificates/5_codveda.jpg',
    ),
    CertificateEntry(
      title: 'High Honor Certificate (Yüksek Onur Belgesi)',
      issuer: 'Üsküdar University — awarded for graduating academic distinction',
      date: '2024–2025 Academic Year',
      imageAsset: 'assets/images/certificates/6_ueskuedar_honor.jpg',
    ),
  ];

  // --- Section 6 (Response/contact) --- ported verbatim from the hardcoded
  // values in the pre-overhaul contact_page.dart.
  static const List<SocialLink> socialLinks = [
    SocialLink(label: 'Email', value: 'mmazen0132@gmail.com', url: 'mailto:mmazen0132@gmail.com'),
    SocialLink(label: 'Phone', value: '+966 54 674 8006', url: 'https://wa.me/966546748006'),
    SocialLink(label: 'LinkedIn', value: 'Mazen Matran', url: 'https://linkedin.com/in/mazen-matran'),
    SocialLink(label: 'GitHub', value: 'Wa7ze', url: 'https://github.com/Wa7ze'),
  ];

  // --- Section 4 (Logic/approach) --- TODO(content): no source content
  // exists for this section. Placeholder principles only — see
  // docs/AUDIT.md. Replace once the user supplies real copy.
  static const List<ApproachPrinciple> approachPrinciples = [
    ApproachPrinciple(
      title: 'Principle 1',
      body: 'TODO(content): replace with a real principle on how you design software.',
    ),
    ApproachPrinciple(
      title: 'Principle 2',
      body: 'TODO(content): replace with a real principle on how you ship software.',
    ),
    ApproachPrinciple(
      title: 'Principle 3',
      body: 'TODO(content): replace with a real principle on how you approach engineering tradeoffs.',
    ),
  ];
}
