/** Shared content types. All site copy lives in src/content/*.ts as typed data. */

export type Locale = 'en' | 'ar';
export const LOCALES: readonly Locale[] = ['en', 'ar'] as const;

/** A value that differs per locale. */
export type Localized<T> = Record<Locale, T>;

/** Key into the WebP image registry (src/content/images.ts), e.g. `helpdesk-system/1`. */
export type ImageKey = string;

export interface Project {
  slug: string;
  title: string;
  summary: string;
  tags: string[];
  githubUrl: string;
  /** Cover image (shown on the card). */
  cover: ImageKey;
  gallery: ImageKey[];
  overview: string;
}

export interface Certificate {
  title: string;
  issuer: string;
  date: string;
  image: ImageKey;
  url?: string;
}

export interface EducationEntry {
  degree: string;
  field: string;
  school: string;
  gpa: string;
  period: string;
}

export interface LanguageEntry {
  name: string;
  level: string;
}

export interface SkillGroup {
  /** Group name per locale; the ROUTE slug is derived from it, as in the legacy site. */
  name: Localized<string>;
  skills: Localized<string[]>;
}

export interface SocialLink {
  id: 'email' | 'phone' | 'linkedin' | 'github';
  value: string;
  url: string;
}

export interface ApproachPrinciple {
  title: string;
  body: string;
}

export type SectionId =
  'home' | 'about' | 'skills' | 'projects' | 'approach' | 'experience' | 'contact' | 'footer';
