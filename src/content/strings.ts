import type { Localized } from './types';

/**
 * Translatable UI copy, verbatim from legacy lib/core/strings/{en,ar}_strings.dart.
 * (Theme-toggle strings were dropped together with the light theme.)
 */
export interface UiStrings {
  nav: {
    home: string;
    about: string;
    skills: string;
    work: string;
    approach: string;
    experience: string;
    contact: string;
  };
  language: string;
  openMenu: string;
  closeMenu: string;
  footerRights: string;
  footerBuiltWith: string;

  heroTitle: string;
  heroSubtitle: string;
  heroCtaWork: string;
  heroCtaContact: string;
  aboutTeaserTitle: string;
  aboutTeaserCta: string;

  aboutPageTitle: string;
  aboutPageSubtitle: string;
  summaryTitle: string;
  experienceTitle: string;
  educationTitle: string;
  skillsTitle: string;
  languagesTitle: string;
  certificatesTitle: string;
  certificatesSubtitle: string;
  otherCertificatesLabel: string;
  verificationLinkLabel: string;
  cvSectionTitle: string;
  cvSectionSubtitle: string;

  workPageTitle: string;
  workPageSubtitle: string;
  backToProjects: string;
  projectOverview: string;
  projectGallery: string;
  viewOnGithub: string;

  contactTitle: string;
  contactSubtitle: string;
  contactEmailLabel: string;
  contactPhoneLabel: string;
  contactLinkedinLabel: string;
  contactGithubLabel: string;
  downloadCvTitle: string;
  downloadCvButton: string;
}

export const ui: Localized<UiStrings> = {
  en: {
    nav: {
      home: 'Home',
      about: 'About',
      skills: 'Skills',
      work: 'My Work',
      approach: 'Approach',
      experience: 'Experience',
      contact: 'Get in touch',
    },
    language: 'Language',
    openMenu: 'Open menu',
    closeMenu: 'Close menu',
    footerRights: 'Mazen Matran. All rights reserved.',
    // Updated per user decision: the site is no longer built with Flutter.
    footerBuiltWith: 'Built with React, TypeScript & GSAP',

    heroTitle: 'Software Engineer',
    heroSubtitle: 'Building innovative solutions with Flutter, Python, and AI.',
    heroCtaWork: 'See My Work',
    heroCtaContact: 'Get in touch',
    aboutTeaserTitle: 'About Me',
    aboutTeaserCta: 'Read my full story',

    aboutPageTitle: 'About',
    aboutPageSubtitle: 'My background, experience, and skills.',
    summaryTitle: 'Professional Summary',
    experienceTitle: 'Work Experience',
    educationTitle: 'Education',
    skillsTitle: 'Technical Skills',
    languagesTitle: 'Languages',
    certificatesTitle: 'Certificates & Achievements',
    certificatesSubtitle: 'Courses, internships, and programs I have completed.',
    otherCertificatesLabel: 'Courses & Internships',
    verificationLinkLabel: 'Open Verification Link',
    cvSectionTitle: 'CV',
    cvSectionSubtitle: 'Tap the preview to view it full-size, or download the PDF.',

    workPageTitle: 'My Work',
    workPageSubtitle: 'Case studies & selected projects.',
    backToProjects: 'Back to Projects',
    projectOverview: 'Project Overview',
    projectGallery: 'Project Gallery',
    viewOnGithub: 'View on GitHub',

    contactTitle: 'Get In Touch',
    contactSubtitle:
      "I'm always open to discussing new opportunities, collaborations, or just having a chat about technology and coding.",
    contactEmailLabel: 'Email',
    contactPhoneLabel: 'Phone',
    contactLinkedinLabel: 'LinkedIn',
    contactGithubLabel: 'GitHub',
    downloadCvTitle: 'Download My CV',
    downloadCvButton: 'Download Full CV',
  },
  ar: {
    nav: {
      home: 'الرئيسية',
      about: 'نبذة عني',
      skills: 'المهارات',
      work: 'أعمالي',
      approach: 'النهج',
      experience: 'الخبرة',
      contact: 'تواصل معي',
    },
    language: 'اللغة',
    openMenu: 'فتح القائمة',
    closeMenu: 'إغلاق القائمة',
    footerRights: 'مازن مطران. جميع الحقوق محفوظة.',
    footerBuiltWith: 'صُنع باستخدام React وTypeScript وGSAP',

    heroTitle: 'مهندس برمجيات',
    heroSubtitle: 'أبني حلولاً مبتكرة باستخدام Flutter وPython والذكاء الاصطناعي.',
    heroCtaWork: 'شاهد أعمالي',
    heroCtaContact: 'تواصل معي',
    aboutTeaserTitle: 'نبذة عني',
    aboutTeaserCta: 'اقرأ قصتي كاملة',

    aboutPageTitle: 'نبذة عني',
    aboutPageSubtitle: 'خلفيتي المهنية وخبراتي ومهاراتي.',
    summaryTitle: 'الملخص المهني',
    experienceTitle: 'الخبرة العملية',
    educationTitle: 'التعليم',
    skillsTitle: 'المهارات التقنية',
    languagesTitle: 'اللغات',
    certificatesTitle: 'الشهادات والإنجازات',
    certificatesSubtitle: 'الدورات والتدريبات والبرامج التي أكملتها.',
    otherCertificatesLabel: 'الدورات والتدريبات',
    verificationLinkLabel: 'فتح رابط التحقق',
    cvSectionTitle: 'السيرة الذاتية',
    cvSectionSubtitle: 'اضغط على المعاينة لعرضها بالحجم الكامل، أو نزّل ملف PDF.',

    workPageTitle: 'أعمالي',
    workPageSubtitle: 'دراسات حالة ومشاريع مختارة.',
    backToProjects: 'العودة إلى المشاريع',
    projectOverview: 'نظرة عامة على المشروع',
    projectGallery: 'معرض الصور',
    viewOnGithub: 'عرض على GitHub',

    contactTitle: 'تواصل معي',
    contactSubtitle: 'أنا منفتح دائمًا لمناقشة الفرص الجديدة والتعاون، أو حتى لحديث عام حول التقنية والبرمجة.',
    contactEmailLabel: 'البريد الإلكتروني',
    contactPhoneLabel: 'الهاتف',
    contactLinkedinLabel: 'لينكدإن',
    contactGithubLabel: 'جيت هاب',
    downloadCvTitle: 'تحميل سيرتي الذاتية',
    downloadCvButton: 'تحميل السيرة الذاتية الكاملة',
  },
};

/**
 * English-only "wire" text, identical in both locales by design (legacy docs/AUDIT.md):
 * protocol labels, status badges, toasts, 404, teardown, terminal and misc chrome.
 */
export const wire = {
  name: 'Mazen Matran',
  logo: '<mm/>',
  skipToContent: 'Skip to content',

  /** Accessible names for icon-only controls added in the rebuild (no legacy equivalent). */
  a11y: {
    prevImage: 'Previous image',
    nextImage: 'Next image',
    close: 'Close',
    viewFullSize: (what: string) => `View full size: ${what}`,
    terminal: 'Terminal',
    terminalInput: 'Terminal command',
    homeLink: 'Mazen Matran — home',
    primaryNav: 'Primary',
  },

  /** Section eyebrows ("protocol" labels). */
  eyebrows: {
    home: 'GET / HTTP/1.1',
    about: 'TLS 1.3 handshake ok',
    skills: 'ROUTE /skills',
    projects: '200 OK /projects',
    approach: 'fn handle(req)',
    experience: 'SELECT * FROM experience',
    contact: 'POST /contact',
    footer: 'FIN',
  },

  approachTitle: 'Approach',
  skillRoutePrefix: 'ROUTE',
  projectMethod: 'GET',
  experienceRowLabel: (n: number) => `row ${n}`,
  experienceBulletPrefix: '> ',

  latency: (ms: number) => `${ms}ms`,
  roundTrip: (seconds: string) => `Round trip: ${seconds}s`,

  badges: {
    ok: 'OK',
    noMailClient: 'No mail client',
    error: 'Error',
    redirect: '301 Moved Permanently',
    smtp: 'SMTP 250 OK',
    tooMany: 'Too Many Requests',
  },
  cvDone: '200 OK · cv.pdf',
  responseTime: (ms: number) => `200 OK · ${ms}ms`,

  pingLabels: [
    { label: (ms: number) => `ping ${ms}ms`, weight: 0.5 },
    { label: () => 'ICMP echo reply', weight: 0.25 },
    { label: () => 'TTL=64', weight: 0.15 },
    { label: () => '404: nothing here', weight: 0.1 },
  ],

  toasts: {
    rateLimited: '429 Too Many Requests — slow down a little',
    timeout: '408 Request Timeout',
    reconnected: 'Connection re-established',
  },

  teardown: {
    client: 'client',
    server: 'server',
    rows: ['FIN →', '← ACK', '← FIN', 'ACK →'],
    closedTitle: 'Connection closed.',
    closedBody: 'Thanks for visiting.',
    keepAlive: 'Keep-Alive ↻',
    eof: 'EOF',
  },

  notFound: {
    code: '404',
    body: 'Packet lost in transit.',
    line: (path: string) => `GET ${path} → no route to host`,
    home: 'GET /',
  },
} as const;
