import { approach } from '../../content/approach';
import { wire } from '../../content/strings';
import { Section, SectionHeading } from '../layout/Section';

/**
 * Section 4 — approach (#approach). Legacy lib/sections/s4_logic_approach.dart: a "call stack"
 * of principles. Not rendered while `approach.visible` is false (user decision).
 */
export function Approach() {
  if (!approach.visible) return null;
  return (
    <Section id="approach" headingId="approach-title">
      <SectionHeading id="approach-title">{wire.approachTitle}</SectionHeading>
      <ol className="mt-10 grid gap-4">
        {approach.principles.map((p, i) => (
          <li key={p.title} className="flex gap-4 panel p-6" style={{ marginInlineStart: `${i * 1.5}rem` }}>
            <span dir="ltr" className="font-mono text-mono font-bold text-amber">
              #{i + 1}
            </span>
            <div>
              <p className="font-semibold text-ink">{p.title}</p>
              <p className="mt-1 font-mono text-mono text-ink-3">{p.body}</p>
            </div>
          </li>
        ))}
      </ol>
    </Section>
  );
}
