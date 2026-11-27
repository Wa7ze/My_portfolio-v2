import type { StoryScene } from './types';

/**
 * TEMPLATE — not registered. Copy to `<name>.tsx`, rename the id, and add it to `scenes` in
 * index.ts. Coordinates are in the stage's 1920×1080 viewBox (scaled with `xMidYMid slice`).
 */
function TemplateSvg() {
  return (
    <g id="template">
      <circle id="template-dot" cx="160" cy="540" r="18" className="fill-cyan" />
    </g>
  );
}

export const templateScene: StoryScene = {
  id: 'template',
  range: [0, 0.2],
  Svg: TemplateSvg,
  build: (tl, [start, end]) => {
    const duration = end - start;
    tl.fromTo('#template-dot', { x: 0, opacity: 0 }, { x: 1600, opacity: 1, duration, ease: 'none' }, start);
  },
};
