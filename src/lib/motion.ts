/** Reduced-motion helpers. Read once at startup; the media query rarely changes mid-session. */
const query = typeof window !== 'undefined' ? window.matchMedia('(prefers-reduced-motion: reduce)') : null;

export function prefersReducedMotion(): boolean {
  return query?.matches ?? false;
}

/** Legacy Motion tokens (lib/core/tokens.dart), in ms. */
export const MOTION = {
  handshake: 300,
  ping: 600,
  badgeFloat: 800,
  navScrollMin: 700,
  navScrollMax: 1100,
  reveal: 500,
  teardownStep: 380,
  keepAlive: 1000,
  reducedNav: 200,
} as const;

export const easeInOutCubic = (t: number): number => (t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) ** 3 / 2);
