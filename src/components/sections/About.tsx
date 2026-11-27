import { featuredCertificates, otherCertificates } from '../../content/certificates';
import { image } from '../../content/images';
import { education, experience, languages, summary } from '../../content/profile';
import { wire } from '../../content/strings';
import type { Certificate } from '../../content/types';
import { useLocale } from '../../state/locale';
import { Section, SectionHeading } from '../layout/Section';
import { ExpandIcon, ExternalIcon } from '../ui/Icons';
import { useLightbox } from '../ui/Lightbox';
import { NetLink } from '../ui/NetLink';

/**
 * Section 1 — about (#about). Legacy lib/sections/s1_network_about.dart: summary, current role,
 * education and certificates, plus the Languages block and certificate images that the legacy
 * site defined but no longer rendered (user decision: show all hidden content).
 */
export function About() {
  const { t, locale } = useLocale();
  const job = experience[locale][0];

  return (
    <Section id="about" headingId="about-title">
      <SectionHeading id="about-title">{t.aboutPageTitle}</SectionHeading>
      <p className="mt-3 text-lead text-ink-2">{t.aboutPageSubtitle}</p>

      <div className="mt-10 grid gap-6 lg:grid-cols-3">
        <article className="panel p-7 sm:p-8 lg:col-span-2" aria-labelledby="summary-title">
          <h3 id="summary-title" className="font-display text-h3 font-semibold text-ink">
            {t.summaryTitle}
          </h3>
          <p className="mt-4 text-body text-ink-2">{summary[locale]}</p>
          {job && (
            <p className="mt-5 border-s-2 border-cyan ps-4 font-mono text-mono text-cyan">
              {job.role} — {job.company} ({job.period})
            </p>
          )}
        </article>

        <article className="panel p-7 sm:p-8" aria-labelledby="languages-title">
          <h3 id="languages-title" className="font-display text-h3 font-semibold text-ink">
            {t.languagesTitle}
          </h3>
          <dl className="mt-5 space-y-3">
            {languages[locale].map((l) => (
              <div
                key={l.name}
                className="flex items-baseline justify-between gap-4 border-b border-line pb-3"
              >
                <dt className="text-ink">{l.name}</dt>
                <dd className="font-mono text-mono text-amber">{l.level}</dd>
              </div>
            ))}
          </dl>
        </article>
      </div>

      <h3 className="mt-16 font-display text-h2 font-semibold text-ink">{t.educationTitle}</h3>
      <ul className="mt-6 grid gap-4 md:grid-cols-2">
        {education[locale].map((edu) => (
          <li key={edu.degree} className="panel p-6">
            <p className="font-semibold text-ink">
              {edu.degree} — {edu.field}
            </p>
            <p className="mt-1 font-mono text-mono text-ink-2">{edu.school}</p>
            <p className="mt-1 font-mono text-mono text-ink-3">
              {edu.gpa} · {edu.period}
            </p>
          </li>
        ))}
      </ul>

      <h3 id="certificates-title" className="mt-16 font-display text-h2 font-semibold text-ink">
        {t.certificatesTitle}
      </h3>
      <p className="mt-2 text-body text-ink-2">{t.certificatesSubtitle}</p>
      <CertificateGrid entries={featuredCertificates} featured />
      <h4 className="mt-10 label-mono text-ink-3">{t.otherCertificatesLabel}</h4>
      <CertificateGrid entries={otherCertificates} />
    </Section>
  );
}

function CertificateGrid({ entries, featured = false }: { entries: Certificate[]; featured?: boolean }) {
  const { t } = useLocale();
  const openLightbox = useLightbox();
  const all = [...featuredCertificates, ...otherCertificates];

  return (
    <ul className={`mt-5 grid gap-4 sm:grid-cols-2 ${featured ? 'lg:grid-cols-3' : 'lg:grid-cols-3'}`}>
      {entries.map((cert) => {
        const img = image(cert.image);
        return (
          <li key={cert.title} className="flex flex-col overflow-hidden panel">
            <button
              type="button"
              onClick={() =>
                openLightbox(
                  all.map((c) => ({ src: image(c.image).full, alt: c.title })),
                  all.indexOf(cert),
                )
              }
              aria-label={wire.a11y.viewFullSize(cert.title)}
              className="group relative block aspect-[16/10] overflow-hidden border-b border-line bg-navy-950"
            >
              <img
                src={img.thumb}
                alt=""
                loading="lazy"
                decoding="async"
                width={480}
                height={300}
                className="size-full object-cover object-top opacity-85 transition duration-300 group-hover:scale-[1.03] group-hover:opacity-100"
              />
              <span className="absolute end-3 bottom-3 grid size-9 place-items-center rounded-pill bg-navy-950/80 text-cyan opacity-0 transition-opacity group-hover:opacity-100 group-focus-visible:opacity-100">
                <ExpandIcon />
              </span>
            </button>
            <div className="flex flex-1 flex-col p-5">
              <p className={`font-semibold text-ink ${featured ? 'text-lead' : ''}`}>{cert.title}</p>
              <p className="mt-2 font-mono text-mono text-ink-2">{cert.issuer}</p>
              <p className="mt-1 font-mono text-mono text-ink-3">{cert.date}</p>
              {cert.url && (
                <NetLink
                  href={cert.url}
                  className="mt-auto inline-flex items-center gap-1.5 self-start pt-4 label-mono text-cyan hover:text-cyan-soft"
                >
                  {t.verificationLinkLabel}
                  <ExternalIcon />
                </NetLink>
              )}
            </div>
          </li>
        );
      })}
    </ul>
  );
}
