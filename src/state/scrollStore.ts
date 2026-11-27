import { useSyncExternalStore } from 'react';
import { visibleSections } from '../content/sections';
import type { SectionId } from '../content/types';

/**
 * Single shared scroll state (legacy lib/scroll/scroll_progress.dart): page progress, active
 * section, which sections have been revealed, and the end-of-page "teardown" flag.
 * An external store so only subscribers re-render on scroll, not the whole app.
 */
export interface ScrollState {
  progress: number;
  active: SectionId;
  revealed: ReadonlySet<SectionId>;
  ended: boolean;
  roundTripMs: number | null;
}

const LOOKAHEAD = 0.4; // fraction of viewport height (legacy _activeLayerLookahead)
const END_TRIGGER_PX = 40;
const END_REARM_PX = 400;

let state: ScrollState = {
  progress: 0,
  active: 'home',
  revealed: new Set<SectionId>(['home']),
  ended: false,
  roundTripMs: null,
};
const listeners = new Set<() => void>();

function emit(next: ScrollState) {
  state = next;
  listeners.forEach((l) => l());
}

export const latencyMs = (progress: number) => Math.round(12 + progress * 1368);

function measure() {
  const scrollY = window.scrollY;
  const max = Math.max(0, document.documentElement.scrollHeight - window.innerHeight);
  const progress = max > 0 ? Math.min(1, Math.max(0, scrollY / max)) : 0;

  const threshold = scrollY + window.innerHeight * LOOKAHEAD;
  let active: SectionId = 'home';
  let revealed = state.revealed;
  for (const s of visibleSections) {
    const el = document.getElementById(s.id);
    if (!el) continue;
    if (el.getBoundingClientRect().top + scrollY <= threshold) {
      active = s.id;
      if (!revealed.has(s.id)) revealed = new Set([...revealed, s.id]);
    } else break;
  }

  let { ended, roundTripMs } = state;
  const fromEnd = max - scrollY;
  if (!ended && max > 0 && fromEnd <= END_TRIGGER_PX) {
    ended = true;
    roundTripMs = 12 + progress * 1368;
  } else if (ended && fromEnd >= END_REARM_PX) {
    ended = false;
  }

  if (
    progress !== state.progress ||
    active !== state.active ||
    revealed !== state.revealed ||
    ended !== state.ended
  ) {
    emit({ progress, active, revealed, ended, roundTripMs });
  }
}

let started = false;
let frame = 0;
function schedule() {
  if (frame) return;
  frame = requestAnimationFrame(() => {
    frame = 0;
    measure();
  });
}

/** Start listening (idempotent). Called once from App. */
export function startScrollStore(): void {
  if (started) return;
  started = true;
  window.addEventListener('scroll', schedule, { passive: true });
  window.addEventListener('resize', schedule);
  new ResizeObserver(schedule).observe(document.body);
  schedule();
}

/** Force a section into the revealed set (used when jumping straight to a hash). */
export function refreshScrollStore(): void {
  measure();
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function useScrollState<T>(select: (s: ScrollState) => T): T {
  return useSyncExternalStore(subscribe, () => select(state));
}

export function getScrollState(): ScrollState {
  return state;
}

export function subscribeScroll(listener: () => void): () => void {
  return subscribe(listener);
}
