import type { ReactNode } from 'react';
import { contactMailto, links, socialLinks } from '../../content/contact';
import { image } from '../../content/images';
import type { UiStrings } from '../../content/strings';
import type { SocialLink } from '../../content/types';
import { useLocale } from '../../state/locale';
import { Section, SectionHeading } from '../layout/Section';
import { ExpandIcon, GithubIcon, LinkedinIcon, MailIcon, PhoneIcon, SendIcon } from '../ui/Icons';
import { useLightbox } from '../ui/Lightbox';
import { NetButton, ok } from '../ui/NetButton';
import { NetLink } from '../ui/NetLink';

const tileLabel: Record<SocialLink['id'], keyof UiStrings> = {
  email: 'contactEmailLabel',
  phone: 'contactPhoneLabel',
  linkedin: 'contactLinkedinLabel',
  github: 'contactGithubLabel',
};
const tileIcon: Record<SocialLink['id'], ReactNode> = {
  email: <MailIcon />,
  phone: <PhoneIcon />,
  linkedin: <LinkedinIcon />,
  github: <GithubIcon />,
};

/**
 * Section 6 — contact (#contact). Legacy lib/sections/s6_response_contact.dart: mailto button
 * (no form — nothing is posted anywhere) + social tiles, plus the CV block from the
 * pre-redesign site (preview → full size, PDF download).
 */
export function Contact() {
  const { t } = useLocale();
  const openLightbox = useLightbox();
  const cv = image('misc/cv_preview');

  return (
    <Section id="contact" headingId="contact-title">
      <div className="grid gap-6 lg:grid-cols-[minmax(0,1.4fr)_minmax(0,1fr)]">
        <div className="panel p-7 sm:p-10">
          <SectionHeading id="contact-title">{t.contactTitle}</SectionHeading>
          <p className="mt-4 max-w-prose text-lead text-ink-2">{t.contactSubtitle}</p>
          <NetButton
            className="mt-8"
            label={t.contactEmailLabel}
            icon={<SendIcon />}
            onRequest={() => {
              window.location.href = contactMailto;
              return ok();
            }}
          />
          <ul className="mt-10 grid gap-3 sm:grid-cols-2">
            {socialLinks.map((link) => (
              <li key={link.id}>
                <NetLink
                  href={link.url}
                  className="group flex items-center gap-4 rounded-md border border-line bg-navy-950/40 p-4 transition-colors hover:border-cyan"
                >
                  <span className="grid size-10 shrink-0 place-items-center rounded-pill bg-cyan/10 text-xl text-cyan">
                    {tileIcon[link.id]}
                  </span>
                  <span className="min-w-0">
                    <span className="block label-mono text-ink-3">{t[tileLabel[link.id]] as string}</span>
                    <span
                      dir="ltr"
                      className="block truncate font-mono text-mono text-cyan group-hover:text-cyan-soft"
                    >
                      {link.value}
                    </span>
                  </span>
                </NetLink>
              </li>
            ))}
          </ul>
        </div>

        <aside className="flex flex-col panel p-7 sm:p-8" aria-labelledby="cv-title">
          <h3 id="cv-title" className="font-display text-h2 font-semibold text-ink">
            {t.cvSectionTitle}
          </h3>
          <p className="mt-2 text-body text-ink-2">{t.cvSectionSubtitle}</p>
          <button
            type="button"
            onClick={() => openLightbox([{ src: cv.full, alt: t.cvSectionTitle }])}
            aria-label={`${t.cvSectionTitle} — ${t.cvSectionSubtitle}`}
            className="group relative mt-6 block overflow-hidden rounded-md border border-line bg-navy-950 hover:border-cyan"
          >
            <img
              src={cv.thumb}
              alt=""
              loading="lazy"
              decoding="async"
              width={480}
              height={621}
              className="aspect-[1200/1552] w-full object-cover object-top opacity-90 transition group-hover:opacity-100"
            />
            <span className="absolute end-3 top-3 grid size-9 place-items-center rounded-pill bg-navy-950/85 text-cyan">
              <ExpandIcon />
            </span>
          </button>
          <a
            href={links.cv}
            download={links.cvDownloadName}
            className="mt-6 inline-flex min-h-12 items-center justify-center rounded-md bg-amber px-6 font-semibold text-navy-950 shadow-glow-amber transition-colors hover:bg-amber-soft"
          >
            {t.downloadCvTitle}
          </a>
        </aside>
      </div>
    </Section>
  );
}
