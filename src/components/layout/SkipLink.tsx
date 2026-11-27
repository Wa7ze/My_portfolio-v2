import { wire } from '../../content/strings';

/** First focusable element; visible only on keyboard focus. Jumps past the nav to <main>. */
export function SkipLink() {
  return (
    <a
      href="#main"
      onClick={(e) => {
        e.preventDefault();
        document.getElementById('main')?.focus();
      }}
      className="fixed start-3 top-3 z-skip -translate-y-24 rounded-sm bg-cyan px-4 py-2 font-bold text-navy-950 transition-transform focus:translate-y-0"
    >
      {wire.skipToContent}
    </a>
  );
}
