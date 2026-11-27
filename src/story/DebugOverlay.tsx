import { useEffect, useState } from 'react';
import { gsap } from '../lib/gsap';
import { jumpToY } from '../lib/smoothScroll';
import { scenes } from './scenes';
import { useStoryProgress } from './useStoryProgress';

/**
 * Story debug overlay (only with `?debug` in the URL; lazy-loaded). Shows live progress, the
 * registered scenes and their ranges, and a slider:
 *  - default: the slider drives page scroll, which scrubs the master timeline through ScrollTrigger;
 *  - "detach": ScrollTrigger is disabled and the slider scrubs `timeline.progress()` directly.
 * ScrollTrigger markers are enabled on the master trigger when debug is on.
 */
export default function DebugOverlay() {
  const story = useStoryProgress();
  const [progress, setProgress] = useState(0);
  const [detached, setDetached] = useState(false);

  useEffect(() => {
    if (!story) return;
    // Debug-only handle for poking at the timeline from the console.
    (window as unknown as { __story?: typeof story }).__story = story;
    const update = () => setProgress(story.timeline.progress());
    gsap.ticker.add(update);
    return () => gsap.ticker.remove(update);
  }, [story]);

  useEffect(() => {
    if (!story) return;
    if (detached) story.trigger.disable(false);
    else story.trigger.enable();
  }, [detached, story]);

  if (!story) return null;

  function onSlide(value: number) {
    if (!story) return;
    if (detached) story.timeline.progress(value);
    else {
      const max = document.documentElement.scrollHeight - window.innerHeight;
      jumpToY(value * max);
    }
  }

  return (
    <div
      dir="ltr"
      data-interactive
      data-lenis-prevent
      className="fixed start-3 bottom-3 z-terminal w-72 rounded-md border border-amber/60 bg-navy-950/95 p-4 font-mono text-mono text-ink shadow-panel"
    >
      <p className="label-mono text-amber">story debug</p>
      <p className="mt-2 tabular-nums">
        progress <span className="text-cyan">{progress.toFixed(4)}</span>
      </p>
      <label className="mt-3 block">
        <span className="sr-only">Scrub master timeline</span>
        <input
          type="range"
          min={0}
          max={1}
          step={0.001}
          value={progress}
          onChange={(e) => onSlide(Number(e.target.value))}
          className="w-full accent-amber"
        />
      </label>
      <label className="mt-2 flex items-center gap-2">
        <input type="checkbox" checked={detached} onChange={(e) => setDetached(e.target.checked)} />
        detach from scroll
      </label>
      <p className="mt-3 text-ink-3">scenes: {scenes.length === 0 ? 'none registered' : ''}</p>
      <ul className="text-ink-2">
        {scenes.map((s) => (
          <li key={s.id}>
            {s.id} [{s.range[0]}, {s.range[1]}]
          </li>
        ))}
      </ul>
    </div>
  );
}
