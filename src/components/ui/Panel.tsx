import type { ElementType, ReactNode } from 'react';

/** Glass panel: readable surface over the animated story (token-driven `panel` utility). */
export function Panel({
  as: Tag = 'div',
  className = '',
  children,
}: {
  as?: ElementType;
  className?: string;
  children: ReactNode;
}) {
  return <Tag className={`panel ${className}`}>{children}</Tag>;
}

/** English-only protocol label above each section heading. Always LTR. */
export function Eyebrow({ children }: { children: ReactNode }) {
  return (
    <p dir="ltr" className="mb-5 inline-flex items-center gap-2 label-mono text-cyan">
      <span aria-hidden="true" className="size-1.5 rounded-pill bg-cyan shadow-glow-cyan" />
      {children}
    </p>
  );
}

export function Chip({ children, tone = 'default' }: { children: ReactNode; tone?: 'default' | 'amber' }) {
  const toneClass =
    tone === 'amber'
      ? 'border-amber/40 text-amber-soft bg-amber/5'
      : 'border-line-strong text-ink-2 bg-navy-900/40';
  return <li className={`rounded-pill border px-3 py-1 font-mono text-mono ${toneClass}`}>{children}</li>;
}
