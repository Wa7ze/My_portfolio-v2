/**
 * Site-level metadata. The static copies live in index.html / 404.html (so crawlers see them
 * without JS); this module is the typed reference used by scripts and the app.
 */
export const site = {
  url: 'https://mazenportfolio.netlify.app/',
  /** Tab title (user decision: pipe separator, no em dash; not translated). */
  title: 'Mazen Matran | Portfolio',
  description: 'Mazen Matran | Software Engineer building with Flutter, Python, and AI.',
  ogTitle: 'Mazen Matran | Software Engineer',
  ogDescription: 'Building innovative solutions with Flutter, Python, and AI.',
  ogImage: 'https://mazenportfolio.netlify.app/og-image.png',
  themeColor: '#0B1426',
} as const;
