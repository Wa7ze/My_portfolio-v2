import type { ApproachPrinciple } from './types';

/**
 * Approach section. HIDDEN (user decision): the legacy copy is placeholder text. It is kept here
 * verbatim so the section can be switched on by replacing these principles and setting
 * `visible: true` (nav, hash sync, terminal and page all read this flag via sections.ts).
 */
export const approach = {
  visible: false,
  principles: [
    {
      title: 'Principle 1',
      body: 'TODO(content): replace with a real principle on how you design software.',
    },
    {
      title: 'Principle 2',
      body: 'TODO(content): replace with a real principle on how you ship software.',
    },
    {
      title: 'Principle 3',
      body: 'TODO(content): replace with a real principle on how you approach engineering tradeoffs.',
    },
  ] satisfies ApproachPrinciple[],
};
