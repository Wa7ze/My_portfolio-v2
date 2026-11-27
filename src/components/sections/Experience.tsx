import { experience } from '../../content/profile';
import { wire } from '../../content/strings';
import { useLocale } from '../../state/locale';
import { Section, SectionHeading } from '../layout/Section';

/** Section 5 — experience (#experience). Legacy lib/sections/s5_database_experience.dart: result rows. */
export function Experience() {
  const { t, locale } = useLocale();

  return (
    <Section id="experience" headingId="experience-title">
      <SectionHeading id="experience-title">{t.experienceTitle}</SectionHeading>
      <ol className="mt-10 grid gap-6">
        {experience[locale].map((job, i) => (
          <li key={job.company} className="panel p-6 sm:p-8">
            <div className="flex flex-wrap items-center gap-3">
              <span dir="ltr" className="rounded-sm bg-amber/10 px-2 py-1 label-mono text-amber">
                {wire.experienceRowLabel(i + 1)}
              </span>
              <span className="ms-auto font-mono text-mono text-ink-3">{job.period}</span>
            </div>
            <h3 className="mt-4 font-display text-h3 font-semibold text-ink">{job.role}</h3>
            <p className="mt-1 font-mono text-mono text-ink-2">{job.company}</p>
            <ul className="mt-6 grid gap-3">
              {job.bullets.map((b) => (
                <li key={b} className="flex gap-3 text-body text-ink-2">
                  <span aria-hidden="true" dir="ltr" className="shrink-0 font-mono text-amber">
                    {wire.experienceBulletPrefix.trim()}
                  </span>
                  <span>{b}</span>
                </li>
              ))}
            </ul>
          </li>
        ))}
      </ol>
    </Section>
  );
}
