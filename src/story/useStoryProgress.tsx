import { createContext, useContext, useLayoutEffect, useState, type ReactNode } from 'react';
import { gsap, ScrollTrigger } from '../lib/gsap';
import { scenes } from './scenes';

export interface StoryContextValue {
  /** Master timeline, normalized to duration 1 (timeline position === page progress). */
  timeline: gsap.core.Timeline;
  /** The ScrollTrigger binding the timeline to page scroll. */
  trigger: ScrollTrigger;
}

const StoryContext = createContext<StoryContextValue | null>(null);

export const isDebug = () => new URLSearchParams(window.location.search).has('debug');

/**
 * Builds the ONE master GSAP timeline and binds it to page scroll:
 *   ScrollTrigger { trigger: document.body, start: 'top top', end: 'bottom bottom', scrub: true }
 * Every registered scene adds its tweens at its progress range. Must be rendered around
 * <StoryStage> so the scene SVGs exist before scenes build (child layout effects run first).
 */
export function StoryProvider({ children }: { children: ReactNode }) {
  const [value, setValue] = useState<StoryContextValue | null>(null);

  useLayoutEffect(() => {
    const ctx = gsap.context(() => {
      const timeline = gsap.timeline({ paused: true, defaults: { ease: 'none' } });
      for (const scene of scenes) scene.build(timeline, scene.range);
      // Pad to exactly 1 so positions map 1:1 to page progress, even with no scenes.
      timeline.set({}, {}, 1);

      const trigger = ScrollTrigger.create({
        trigger: document.body,
        start: 'top top',
        end: 'bottom bottom',
        scrub: true,
        animation: timeline,
        markers: isDebug(),
        invalidateOnRefresh: true,
      });
      setValue({ timeline, trigger });
    });
    return () => {
      ctx.revert();
      setValue(null);
    };
  }, []);

  return <StoryContext.Provider value={value}>{children}</StoryContext.Provider>;
}

/** The master timeline + trigger (null until mounted). */
export function useStoryProgress(): StoryContextValue | null {
  return useContext(StoryContext);
}
