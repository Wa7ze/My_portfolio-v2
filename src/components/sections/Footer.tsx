import { useEffect, useRef, useState } from 'react';
import { wire } from '../../content/strings';
import { MOTION, prefersReducedMotion } from '../../lib/motion';
import { goToSection } from '../../lib/navigation';
import { useLocale } from '../../state/locale';
import { useScrollState } from '../../state/scrollStore';
import { NetButton, ok } from '../ui/NetButton';
import { Eyebrow } from '../ui/Panel';

const ROW_START_MS = [500, 880, 1260, 1640];
const CARD_START_MS = 2100;

/**
 * Footer / TCP teardown (legacy lib/sections/s7_teardown_footer.dart). When the end of the page is
 * reached the FIN/ACK ladder draws row by row, then the "Connection closed." card fades in with the
 * Keep-Alive button (scrolls back to the top over 1000ms). Overscrolling past the bottom stretches
 * an EOF marker that springs back. Reduced motion shows the final state immediately.
 */
export function Footer() {
  const { t: strings } = useLocale();
  const ended = useScrollState((s) => s.ended);
  const [elapsed, setElapsed] = useState(-1);
  const pull = useEofPull();

  const reduced = prefersReducedMotion();

  useEffect(() => {
    if (!ended || reduced) return;
    const start = performance.now();
    let raf = 0;
    const tick = () => {
      const ms = performance.now() - start;
      setElapsed(ms);
      if (ms < CARD_START_MS + MOTION.reveal) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => {
      cancelAnimationFrame(raf);
      setElapsed(-1);
    };
  }, [ended, reduced]);

  // Reduced motion: final state immediately. Not ended: nothing drawn.
  const t = !ended ? -1 : reduced ? Infinity : elapsed;
  const rowT = (i: number) => clamp01((t - (ROW_START_MS[i] ?? 0)) / MOTION.teardownStep);
  const cardT = clamp01((t - CARD_START_MS) / MOTION.reveal);

  return (
    <footer id="footer" tabIndex={-1} className="relative px-5 pt-20 pb-16 outline-none sm:px-8 md:pt-28">
      <div className="mx-auto max-w-content">
        <Eyebrow>{wire.eyebrows.footer}</Eyebrow>
        <div className="max-w-xl panel p-6 sm:p-8" dir="ltr" aria-hidden="true">
          <div className="flex justify-between label-mono text-ink-3">
            <span>{wire.teardown.client}</span>
            <span>{wire.teardown.server}</span>
          </div>
          <div className="relative mt-3">
            <span className="absolute inset-y-0 start-0 w-px bg-line-strong" />
            <span className="absolute inset-y-0 end-0 w-px bg-line-strong" />
            {wire.teardown.rows.map((row, i) => {
              const toRight = row.endsWith('→');
              const v = rowT(i);
              return (
                <div
                  key={row}
                  className={`flex h-9 items-center ${toRight ? 'justify-start' : 'justify-end'}`}
                >
                  <div
                    className={`flex items-center gap-2 overflow-hidden ${toRight ? 'flex-row' : 'flex-row-reverse'}`}
                    style={{ width: `${easeOut(v) * 100}%`, opacity: v }}
                  >
                    <span className="h-px flex-1 bg-ok/60" />
                    <span className="shrink-0 px-1 font-mono text-mono text-ok">{row}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        <div
          className="mt-8"
          style={{
            opacity: cardT,
            transform: `translateY(${(1 - easeOut(cardT)) * 12}px)`,
            visibility: cardT > 0 ? 'visible' : 'hidden',
          }}
        >
          <p className="font-display text-h2 font-semibold text-ink">{wire.teardown.closedTitle}</p>
          <p className="mt-2 text-body text-ink-2">{wire.teardown.closedBody}</p>
          <NetButton
            className="mt-6"
            variant="ghost"
            label={wire.teardown.keepAlive}
            onRequest={() => {
              goToSection('home', MOTION.keepAlive);
              return ok();
            }}
          />
        </div>

        <p
          aria-hidden="true"
          dir="ltr"
          className="mt-8 h-6 origin-top font-mono text-mono text-ink-3"
          style={{ opacity: pull, transform: `translateY(${pull * 16}px) scaleY(${1 + pull * 0.6})` }}
        >
          {wire.teardown.eof}
        </p>

        <div className="mt-10 flex flex-col gap-1 border-t border-line pt-6 font-mono text-mono text-ink-3 sm:flex-row sm:justify-between">
          <p>
            © {new Date().getFullYear()} {strings.footerRights}
          </p>
          <p>{strings.footerBuiltWith}</p>
        </div>
      </div>
    </footer>
  );
}

const clamp01 = (v: number) => Math.min(1, Math.max(0, v));
const easeOut = (v: number) => 1 - (1 - v) ** 3;

/**
 * Overscroll-past-bottom "pull" (0..1): wheel/touch movement while already at the bottom adds pull;
 * 150ms after the last pull it springs back (stiffness 300, damping 20, as in the legacy store).
 */
function useEofPull(): number {
  const [pull, setPull] = useState(0);
  const state = useRef({ pull: 0, velocity: 0, timer: 0, raf: 0, touchY: 0 });

  useEffect(() => {
    const s = state.current;
    const atBottom = () => window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 1;

    const springBack = () => {
      cancelAnimationFrame(s.raf);
      const step = () => {
        const dt = 0.016;
        const force = -300 * s.pull - 20 * s.velocity;
        s.velocity += force * dt;
        s.pull = Math.max(0, s.pull + s.velocity * dt);
        if (s.pull < 0.001 && Math.abs(s.velocity) < 0.001) {
          s.pull = 0;
          s.velocity = 0;
          setPull(0);
          return;
        }
        setPull(s.pull);
        s.raf = requestAnimationFrame(step);
      };
      s.raf = requestAnimationFrame(step);
    };

    const add = (delta: number) => {
      cancelAnimationFrame(s.raf);
      s.velocity = 0;
      s.pull = clamp01(s.pull + delta);
      setPull(s.pull);
      window.clearTimeout(s.timer);
      s.timer = window.setTimeout(springBack, 150);
    };

    const onWheel = (e: WheelEvent) => {
      if (e.deltaY > 0 && atBottom()) add(e.deltaY / 600);
    };
    const onTouchStart = (e: TouchEvent) => {
      s.touchY = e.touches[0]?.clientY ?? 0;
    };
    const onTouchMove = (e: TouchEvent) => {
      const y = e.touches[0]?.clientY ?? 0;
      const delta = s.touchY - y;
      s.touchY = y;
      if (delta > 0 && atBottom()) add(delta / 120);
    };

    window.addEventListener('wheel', onWheel, { passive: true });
    window.addEventListener('touchstart', onTouchStart, { passive: true });
    window.addEventListener('touchmove', onTouchMove, { passive: true });
    return () => {
      window.removeEventListener('wheel', onWheel);
      window.removeEventListener('touchstart', onTouchStart);
      window.removeEventListener('touchmove', onTouchMove);
      window.clearTimeout(s.timer);
      cancelAnimationFrame(s.raf);
    };
  }, []);

  return pull;
}
