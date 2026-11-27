import type { ReactNode } from 'react';
import { sectionById } from '../../content/sections';
import type { SectionId } from '../../content/types';
import { useScrollState } from '../../state/scrollStore';
import { Eyebrow } from '../ui/Panel';

/**
 * Shared section layout (legacy lib/sections/section_scaffold.dart): anchor id, the English-only
 * protocol eyebrow, max content width, and a one-time fade/slide reveal the first time the section
 * is reached (skipped under reduced motion — see `.js-reveal` in global.css).
 */
export function Section({
  id,
  headingId,
  children,
  className = '',
  fullHeight = false,
}: {
  id: SectionId;
  headingId?: string;
  children: ReactNode;
  className?: string;
  fullHeight?: boolean;
}) {
  const def = sectionById(id);
  const revealed = useScrollState((s) => s.revealed.has(id));

  return (
    <section
      id={id}
      aria-labelledby={headingId}
      tabIndex={-1}
      className={`relative scroll-mt-16 px-5 py-20 outline-none sm:px-8 md:py-28 ${
        fullHeight ? 'flex min-h-dvh items-center pt-28' : ''
      } ${className}`}
    >
      <div data-reveal={revealed ? 'done' : ''} className="mx-auto w-full max-w-content">
        <Eyebrow>{def.eyebrow}</Eyebrow>
        {children}
      </div>
    </section>
  );
}

/** Section-level heading style. */
export function SectionHeading({ id, children }: { id: string; children: ReactNode }) {
  return (
    <h2 id={id} className="font-display text-h1 font-bold tracking-tight text-ink">
      {children}
    </h2>
  );
}
