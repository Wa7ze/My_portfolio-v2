import { useEffect } from 'react';
import { wire } from '../../content/strings';
import { useEffects } from '../../state/effects';

const MOVE_THRESHOLD = 8;
const HOLD_THRESHOLD_MS = 300;
const RATE_MAX = 8;
const RATE_WINDOW_MS = 2500;
const INTERACTIVE =
  'a, button, input, textarea, select, label, summary, dialog, [role="button"], [data-interactive]';

export function pickPingLabel(): string {
  const r = Math.random();
  let acc = 0;
  for (const entry of wire.pingLabels) {
    acc += entry.weight;
    if (r <= acc) return entry.label(20 + Math.floor(Math.random() * 60));
  }
  return wire.pingLabels[0].label(42);
}

/**
 * Empty-click detector (legacy lib/interaction/click_router.dart + rate_limiter.dart): a primary
 * click/tap on blank page area (moved < 8px, held < 300ms, not on a control or selecting text)
 * spawns a ping. More than 8 within 2.5s trips a mock 429 badge + toast.
 */
export function useClickRouter(): void {
  const { addPing, addBadge, showToast } = useEffects();

  useEffect(() => {
    const downs = new Map<number, { x: number; y: number; t: number }>();
    const stamps: number[] = [];

    const onDown = (e: PointerEvent) => {
      if (!e.isPrimary || e.button !== 0) return;
      if ((e.target as Element | null)?.closest(INTERACTIVE)) return;
      downs.set(e.pointerId, { x: e.clientX, y: e.clientY, t: performance.now() });
    };
    const onUp = (e: PointerEvent) => {
      const down = downs.get(e.pointerId);
      downs.delete(e.pointerId);
      if (!down) return;
      const moved = Math.hypot(e.clientX - down.x, e.clientY - down.y);
      if (moved >= MOVE_THRESHOLD || performance.now() - down.t >= HOLD_THRESHOLD_MS) return;
      if (window.getSelection()?.toString()) return;

      const now = performance.now();
      while (stamps.length && now - (stamps[0] ?? now) > RATE_WINDOW_MS) stamps.shift();
      stamps.push(now);
      if (stamps.length > RATE_MAX) {
        addBadge(e.clientX, e.clientY, `429 ${wire.badges.tooMany}`, true);
        showToast(wire.toasts.rateLimited, true);
        return;
      }
      addPing(e.clientX, e.clientY, pickPingLabel());
    };
    const onCancel = (e: PointerEvent) => downs.delete(e.pointerId);

    document.addEventListener('pointerdown', onDown);
    document.addEventListener('pointerup', onUp);
    document.addEventListener('pointercancel', onCancel);
    return () => {
      document.removeEventListener('pointerdown', onDown);
      document.removeEventListener('pointerup', onUp);
      document.removeEventListener('pointercancel', onCancel);
    };
  }, [addPing, addBadge, showToast]);
}
