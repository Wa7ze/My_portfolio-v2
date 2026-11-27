import { scenes } from './scenes';

/**
 * Fixed full-viewport layer BEHIND all content (z-story, pointer-events none, hidden from
 * assistive tech) holding one full-screen SVG. Each registered scene renders its SVG here.
 */
export function StoryStage() {
  return (
    <div aria-hidden="true" className="pointer-events-none fixed inset-0 z-story overflow-hidden">
      <svg
        id="story-stage"
        className="size-full"
        viewBox="0 0 1920 1080"
        preserveAspectRatio="xMidYMid slice"
        xmlns="http://www.w3.org/2000/svg"
      >
        {scenes.map(({ id, Svg }) => (
          <g key={id} data-scene={id}>
            <Svg />
          </g>
        ))}
      </svg>
    </div>
  );
}
