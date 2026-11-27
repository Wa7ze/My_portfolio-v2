import Lenis from 'lenis';
import { gsap, ScrollTrigger } from './gsap';
import { easeInOutCubic, MOTION, prefersReducedMotion } from './motion';

let lenis: Lenis | null = null;

/**
 * Lenis smooth scrolling, synced with ScrollTrigger:
 *  - lenis.on('scroll', ScrollTrigger.update)
 *  - Lenis driven by gsap.ticker (one RAF loop for everything)
 *  - gsap.ticker.lagSmoothing(0)
 * Skipped entirely under prefers-reduced-motion (native scrolling, ScrollTrigger still works).
 */
export function initSmoothScroll(): Lenis | null {
  if (lenis || prefersReducedMotion()) return lenis;
  lenis = new Lenis({ autoRaf: false, anchors: false });
  lenis.on('scroll', ScrollTrigger.update);
  gsap.ticker.add((time) => lenis?.raf(time * 1000));
  gsap.ticker.lagSmoothing(0);
  return lenis;
}

export function getLenis(): Lenis | null {
  return lenis;
}

function maxScroll(): number {
  return Math.max(0, document.documentElement.scrollHeight - window.innerHeight);
}

/** Document Y of an element's top edge. */
export function offsetTop(el: Element): number {
  return el.getBoundingClientRect().top + window.scrollY;
}

/**
 * Scroll to a Y position. Duration scales with distance between the legacy 700–1100ms bounds
 * (ease in-out cubic) unless `fixedMs` is given; reduced motion jumps instantly.
 */
export function scrollToY(y: number, fixedMs?: number): void {
  const target = Math.min(Math.max(0, y), maxScroll());
  if (!lenis) {
    window.scrollTo({ top: target, behavior: 'instant' });
    return;
  }
  const max = maxScroll();
  const fraction = max > 0 ? Math.min(1, Math.abs(target - window.scrollY) / max) : 0;
  const ms = fixedMs ?? MOTION.navScrollMin + (MOTION.navScrollMax - MOTION.navScrollMin) * fraction;
  lenis.scrollTo(target, { duration: ms / 1000, easing: easeInOutCubic });
}

export function scrollToElement(el: Element, fixedMs?: number): void {
  scrollToY(offsetTop(el), fixedMs);
}

/** Instant jump, bypassing smoothing (initial hash, debug slider). */
export function jumpToY(y: number): void {
  if (lenis) lenis.scrollTo(y, { immediate: true, force: true });
  else window.scrollTo({ top: y, behavior: 'instant' });
}
