import { wire } from '../../content/strings';
import { latencyMs, useScrollState } from '../../state/scrollStore';

/**
 * Fixed latency readout (legacy lib/widgets/latency_counter.dart): 12ms at the top of the page,
 * 1380ms at the bottom; freezes to a green "Round trip: x.xxs" once the end of the page is reached.
 * Pinned to the inline-end side, so it mirrors in RTL. Decorative for assistive tech.
 */
export function LatencyCounter() {
  const progress = useScrollState((s) => s.progress);
  const ended = useScrollState((s) => s.ended);
  const roundTrip = useScrollState((s) => s.roundTripMs);

  const label = ended
    ? wire.roundTrip(((roundTrip ?? latencyMs(progress)) / 1000).toFixed(2))
    : wire.latency(latencyMs(progress));

  return (
    <div
      aria-hidden="true"
      dir="ltr"
      className={`pointer-events-none fixed end-4 bottom-4 z-nav rounded-pill border px-3 py-1 font-mono text-mono tabular-nums backdrop-blur-md transition-colors md:top-20 md:bottom-auto ${
        ended ? 'border-ok/60 bg-navy-950/80 text-ok' : 'border-line bg-navy-950/70 text-ink-3'
      }`}
    >
      {label}
    </div>
  );
}
