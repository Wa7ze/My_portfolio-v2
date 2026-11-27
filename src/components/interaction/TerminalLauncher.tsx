import { lazy, Suspense, useCallback, useEffect, useRef, useState } from 'react';
import { onToggleTerminal } from '../../lib/events';

const Terminal = lazy(() => import('./Terminal'));

/**
 * Opens/closes the hidden terminal: the backquote key anywhere (ignored while typing in a field),
 * or a long-press on the nav logo (via the event bus). The terminal chunk loads on first open.
 * Focus returns to where it was when the terminal closes.
 */
export function TerminalLauncher() {
  const [open, setOpen] = useState(false);
  const returnFocus = useRef<HTMLElement | null>(null);

  const toggle = useCallback(() => {
    setOpen((o) => {
      if (!o) returnFocus.current = document.activeElement as HTMLElement | null;
      return !o;
    });
  }, []);

  const close = useCallback(() => {
    setOpen(false);
    returnFocus.current?.focus?.();
  }, []);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key !== '`' || e.ctrlKey || e.metaKey || e.altKey) return;
      const el = e.target as HTMLElement | null;
      const typing = el?.closest('input, textarea, select, [contenteditable="true"]');
      if (typing) return;
      e.preventDefault();
      if (open) close();
      else toggle();
    };
    window.addEventListener('keydown', onKey);
    const off = onToggleTerminal(() => (open ? close() : toggle()));
    return () => {
      window.removeEventListener('keydown', onKey);
      off();
    };
  }, [open, toggle, close]);

  if (!open) return null;
  return (
    <Suspense fallback={null}>
      <Terminal onClose={close} />
    </Suspense>
  );
}
