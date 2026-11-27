import { prefersReducedMotion } from '../../lib/motion';
import { useEffectsState } from '../../state/effects';

/**
 * Single fixed overlay for every transient effect (legacy lib/interaction/effects_layer.dart):
 * pings, status badges, redirect badges and the toast. Decorative visuals are aria-hidden;
 * meaningful messages (toasts, error badges) are mirrored into polite/assertive live regions.
 */
export function EffectsLayer() {
  const { pings, badges, redirects, toast } = useEffectsState();
  const reduced = prefersReducedMotion();
  // Error badges carry meaning a sighted user gets from colour; announce the latest one.
  const lastError = badges.filter((b) => b.isError).at(-1);

  return (
    <>
      <div aria-hidden="true" className="pointer-events-none fixed inset-0 z-effects overflow-hidden">
        {pings.map((p) => (
          <div key={p.id} className="absolute" style={{ left: p.x, top: p.y }}>
            {!reduced && (
              <>
                <span
                  className="absolute size-[68px] rounded-pill border-2 border-cyan"
                  style={{ animation: 'ping-ring 600ms var(--ease-out-cubic) forwards' }}
                />
                <span
                  className="absolute size-9 rounded-pill border-2 border-cyan/60"
                  style={{ animation: 'ping-ring 600ms var(--ease-out-cubic) forwards' }}
                />
                <span className="absolute size-1.5 -translate-1/2 rounded-pill bg-cyan" />
              </>
            )}
            <span
              className="absolute label-mono whitespace-nowrap text-cyan"
              style={{
                animation: `${reduced ? 'fade-hold' : 'float-up'} 600ms var(--ease-out-cubic) forwards`,
              }}
            >
              {p.label}
            </span>
          </div>
        ))}

        {badges.map((b) => (
          <span
            key={b.id}
            dir="ltr"
            className={`absolute rounded-pill border px-3 py-1 label-mono whitespace-nowrap normal-case ${
              b.isError ? 'border-err bg-err/15 text-err' : 'border-ok bg-ok/15 text-ok'
            }`}
            style={{
              left: b.x,
              top: b.y,
              animation: `${reduced ? 'fade-hold' : 'float-up'} 800ms var(--ease-out-cubic) forwards`,
            }}
          >
            {b.text}
          </span>
        ))}

        {redirects.map((r) => (
          <span
            key={r.id}
            dir="ltr"
            className="absolute rounded-pill border border-cyan bg-cyan/15 px-3 py-1 label-mono whitespace-nowrap text-cyan normal-case"
            style={{ left: r.x, top: r.y - 28, animation: 'pop-in 800ms var(--ease-back) forwards' }}
          >
            {r.text}
          </span>
        ))}
      </div>

      <div className="pointer-events-none fixed inset-x-0 bottom-8 z-effects flex justify-center px-4">
        {toast && (
          <p
            key={toast.id}
            className={`rounded-pill border bg-navy-900/95 px-5 py-3 font-mono text-mono text-ink shadow-panel backdrop-blur-md ${
              toast.isError ? 'border-err' : 'border-ok'
            }`}
            style={{ animation: 'fade-hold 2200ms linear forwards' }}
          >
            {toast.message}
          </p>
        )}
      </div>

      <div className="sr-only" role="status" aria-live="polite">
        {toast?.message}
      </div>
      <div className="sr-only" role="alert">
        {lastError?.text}
      </div>
    </>
  );
}
