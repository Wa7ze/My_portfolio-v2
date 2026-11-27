import type { StoryScene } from './types';

/**
 * Scene registry. Scenes are built onto the master timeline in this order. Empty until the story
 * is written (spec: STORY.md; how-to: docs/STORY_DEV.md); copy `_template.tsx` to start a new scene and add it here.
 */
export const scenes: StoryScene[] = [];

export type { ProgressRange, StoryScene } from './types';
