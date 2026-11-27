import { skillGroups, skillRoute } from '../../content/skills';
import { wire } from '../../content/strings';
import { useLocale } from '../../state/locale';
import { Section, SectionHeading } from '../layout/Section';
import { Chip } from '../ui/Panel';

/** Section 2 — skills (#skills). Legacy lib/sections/s2_gateway_skills.dart: groups as route-table entries. */
export function Skills() {
  const { t, locale } = useLocale();

  return (
    <Section id="skills" headingId="skills-title">
      <SectionHeading id="skills-title">{t.skillsTitle}</SectionHeading>
      <div className="mt-10 grid gap-5 md:grid-cols-2">
        {skillGroups.map((group) => {
          const name = group.name[locale];
          return (
            <article key={group.name.en} className="panel p-6 sm:p-7" aria-label={name}>
              <p className="flex flex-wrap items-baseline gap-2 font-mono text-mono">
                <span className="font-bold text-amber">{wire.skillRoutePrefix}</span>
                <span className="text-ink-3">{skillRoute(name)}</span>
              </p>
              <h3 className="mt-1.5 font-display text-h3 font-semibold text-ink">{name}</h3>
              <ul className="mt-4 flex flex-wrap gap-2">
                {group.skills[locale].map((skill) => (
                  <Chip key={skill}>{skill}</Chip>
                ))}
              </ul>
            </article>
          );
        })}
      </div>
    </Section>
  );
}
