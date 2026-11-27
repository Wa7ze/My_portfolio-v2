import type { SocialLink } from './types';

/** Verbatim from legacy lib/data/portfolio_content.dart `socialLinks`. Labels come from ui strings. */
export const socialLinks: SocialLink[] = [
  { id: 'email', value: 'mmazen0132@gmail.com', url: 'mailto:mmazen0132@gmail.com' },
  { id: 'phone', value: '+966 54 674 8006', url: 'https://wa.me/966546748006' },
  { id: 'linkedin', value: 'Mazen Matran', url: 'https://linkedin.com/in/mazen-matran' },
  { id: 'github', value: 'Wa7ze', url: 'https://github.com/Wa7ze' },
];

/** Contact button target (legacy s6_response_contact.dart `_sendEmail`). */
export const contactMailto = 'mailto:mmazen0132@gmail.com?subject=Hello from Portfolio&body=Hi Mazen,';

export const links = {
  github: 'https://github.com/Wa7ze',
  linkedin: 'https://linkedin.com/in/mazen-matran',
  cv: '/cv.pdf',
  cvDownloadName: 'Mazen_Matran_CV.pdf',
} as const;
