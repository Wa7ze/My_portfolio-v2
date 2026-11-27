import { approach } from './approach';
import { wire, type UiStrings } from './strings';
import type { SectionId } from './types';

export interface SectionDef {
  id: SectionId;
  /** URL hash (without #). The footer shares #contact, as on the legacy site. */
  hash: string;
  eyebrow: string;
  /** Nav label key; null = not a nav target. */
  navKey: keyof UiStrings['nav'] | null;
  visible: boolean;
}

/** Ordered page sections. Nav, hash sync, terminal and story all read from this list. */
export const sections: SectionDef[] = [
  { id: 'home', hash: 'home', eyebrow: wire.eyebrows.home, navKey: 'home', visible: true },
  { id: 'about', hash: 'about', eyebrow: wire.eyebrows.about, navKey: 'about', visible: true },
  { id: 'skills', hash: 'skills', eyebrow: wire.eyebrows.skills, navKey: 'skills', visible: true },
  { id: 'projects', hash: 'projects', eyebrow: wire.eyebrows.projects, navKey: 'work', visible: true },
  {
    id: 'approach',
    hash: 'approach',
    eyebrow: wire.eyebrows.approach,
    navKey: 'approach',
    visible: approach.visible,
  },
  {
    id: 'experience',
    hash: 'experience',
    eyebrow: wire.eyebrows.experience,
    navKey: 'experience',
    visible: true,
  },
  { id: 'contact', hash: 'contact', eyebrow: wire.eyebrows.contact, navKey: 'contact', visible: true },
  { id: 'footer', hash: 'contact', eyebrow: wire.eyebrows.footer, navKey: null, visible: true },
];

export const visibleSections = sections.filter((s) => s.visible);
export const navSections = visibleSections.filter((s) => s.navKey !== null);

export function sectionById(id: SectionId): SectionDef {
  const s = sections.find((x) => x.id === id);
  if (!s) throw new Error(`Unknown section ${id}`);
  return s;
}

/** Hash → first visible section using that hash. */
export function sectionForHash(hash: string): SectionDef | undefined {
  const name = hash.replace(/^#/, '');
  return visibleSections.find((s) => s.hash === name);
}
