import { useEffect } from 'react';
import { wire } from '../../content/strings';
import { useEffects } from '../../state/effects';
import { pickPingLabel } from './useClickRouter';

const HEARTBEAT_MS = 15_000;
const TIMEOUT_MS = 45_000;

/**
 * Idle states (legacy lib/widgets/idle_watcher.dart): after 15s without activity a heartbeat ping
 * appears near the top-start corner (repeating every 15s); at 45s a "408 Request Timeout" toast
 * shows and the page dims to 90%; the first activity afterwards shows "Connection re-established".
 * Timers pause while the tab is hidden.
 */
export function useIdleWatcher(): void {
  const { addPing, showToast } = useEffects();

  useEffect(() => {
    let heartbeat = 0;
    let timeout = 0;
    let timedOut = false;
    const root = document.getElementById('root');

    const setDim = (dim: boolean) => {
      if (!root) return;
      root.style.transition = 'opacity 600ms ease';
      root.style.opacity = dim ? '0.9' : '';
    };

    const arm = () => {
      window.clearInterval(heartbeat);
      window.clearTimeout(timeout);
      heartbeat = window.setInterval(() => {
        if (timedOut) return;
        const x = document.documentElement.dir === 'rtl' ? window.innerWidth - 80 : 80;
        addPing(x, 80, pickPingLabel());
      }, HEARTBEAT_MS);
      timeout = window.setTimeout(() => {
        timedOut = true;
        setDim(true);
        showToast(wire.toasts.timeout);
      }, TIMEOUT_MS);
    };

    const onActivity = () => {
      if (document.hidden) return;
      if (timedOut) {
        timedOut = false;
        setDim(false);
        showToast(wire.toasts.reconnected);
      }
      arm();
    };

    const onVisibility = () => {
      if (document.hidden) {
        window.clearInterval(heartbeat);
        window.clearTimeout(timeout);
      } else arm();
    };

    const events = ['pointermove', 'pointerdown', 'keydown', 'wheel', 'scroll', 'touchstart'] as const;
    events.forEach((ev) => window.addEventListener(ev, onActivity, { passive: true }));
    document.addEventListener('visibilitychange', onVisibility);
    arm();
    return () => {
      events.forEach((ev) => window.removeEventListener(ev, onActivity));
      document.removeEventListener('visibilitychange', onVisibility);
      window.clearInterval(heartbeat);
      window.clearTimeout(timeout);
    };
  }, [addPing, showToast]);
}
