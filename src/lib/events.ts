/** Tiny app-wide event bus for requests that cross component trees. */
const TERMINAL_TOGGLE = 'portfolio:terminal-toggle';

export function toggleTerminal(): void {
  window.dispatchEvent(new Event(TERMINAL_TOGGLE));
}

export function onToggleTerminal(handler: () => void): () => void {
  window.addEventListener(TERMINAL_TOGGLE, handler);
  return () => window.removeEventListener(TERMINAL_TOGGLE, handler);
}
