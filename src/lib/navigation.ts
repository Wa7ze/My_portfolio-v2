import { sectionById, sectionForHash } from '../content/sections';
import type { SectionId } from '../content/types';
import { jumpToY, offsetTop, scrollToElement } from './smoothScroll';

/**
 * Section navigation + URL hash sync (legacy lib/navigation/{nav_controller,hash_sync}.dart).
 * The hash is always written with history.replaceState (never pushState), so in-page navigation
 * does not pollute browser history.
 */
export function replaceHash(hash: string): void {
  const url = `${window.location.pathname}${window.location.search}#${hash}`;
  if (window.location.hash !== `#${hash}`) window.history.replaceState(window.history.state, '', url);
}

export function goToSection(id: SectionId, fixedMs?: number): void {
  const el = document.getElementById(id);
  if (!el) return;
  scrollToElement(el, fixedMs);
  cancelPendingHash();
  replaceHash(sectionById(id).hash);
  // Move keyboard focus to the section so Tab continues from there.
  el.focus({ preventScroll: true });
}

let hashTimer = 0;
function cancelPendingHash() {
  window.clearTimeout(hashTimer);
}

/** Debounced (300ms) hash update as the active section changes while scrolling. */
export function onActiveSectionChanged(id: SectionId): void {
  cancelPendingHash();
  hashTimer = window.setTimeout(() => replaceHash(sectionById(id).hash), 300);
}

/** On load: jump straight to the section named in the URL hash, if any. */
export function jumpToInitialHash(): void {
  const target = sectionForHash(window.location.hash);
  if (!target || target.id === 'home') return;
  const el = document.getElementById(target.id);
  if (el) jumpToY(offsetTop(el));
}
