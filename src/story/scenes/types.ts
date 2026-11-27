import type { FC } from 'react';

/** A normalized slice of total page scroll progress: [start, end] within 0..1. */
export type ProgressRange = readonly [start: number, end: number];

/**
 * One story scene. Each scene:
 *  - renders its own SVG content (a <g>-level fragment) inside the shared full-screen StoryStage
 *    <svg viewBox="0 0 1920 1080">; give elements ids/classes prefixed with the scene id;
 *  - adds its tweens to the master timeline at its progress range. The master timeline has a
 *    normalized duration of 1, so a timeline position IS a page-progress value
 *    (e.g. `tl.to(el, { x: 100, duration: end - start }, start)`).
 */
export interface StoryScene {
  id: string;
  range: ProgressRange;
  Svg: FC;
  build: (tl: gsap.core.Timeline, range: ProgressRange) => void;
}
