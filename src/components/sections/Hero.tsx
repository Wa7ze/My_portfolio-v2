import { aboutTeaser } from '../../content/profile';
import { wire } from '../../content/strings';
import { goToSection } from '../../lib/navigation';
import { useLocale } from '../../state/locale';
import { Section } from '../layout/Section';
import { CvDownloadButton } from '../ui/CvDownloadButton';
import { ChevronDownIcon } from '../ui/Icons';
import { NetButton, ok } from '../ui/NetButton';

/** Section 0 — hero (#home). Legacy lib/sections/s0_browser_hero.dart + the "About Me" teaser. */
export function Hero() {
  const { t, locale } = useLocale();

  return (
    <Section id="home" headingId="hero-name" fullHeight>
      <div className="grid gap-8 lg:grid-cols-[minmax(0,1.35fr)_minmax(0,1fr)] lg:items-end lg:gap-10">
        <div className="panel p-7 sm:p-10 lg:p-12">
          <h1 id="hero-name" className="font-display text-display font-bold text-ink">
            {wire.name}
          </h1>
          <p className="mt-3 font-display text-h1 font-semibold text-cyan">{t.heroTitle}</p>
          <p className="mt-6 max-w-prose text-lead text-ink-2">{t.heroSubtitle}</p>
          <div className="mt-10 flex flex-wrap gap-3 sm:gap-4">
            <NetButton
              label={t.heroCtaWork}
              onRequest={() => {
                goToSection('projects');
                return ok();
              }}
            />
            <NetButton
              variant="ghost"
              label={t.heroCtaContact}
              onRequest={() => {
                goToSection('contact');
                return ok();
              }}
            />
            <CvDownloadButton label={t.downloadCvButton} />
          </div>
        </div>

        <aside aria-labelledby="about-teaser-title" className="panel p-7 sm:p-8">
          <h2 id="about-teaser-title" className="label-mono text-amber">
            {t.aboutTeaserTitle}
          </h2>
          <p className="mt-4 text-body text-ink-2">{aboutTeaser[locale]}</p>
          <a
            href="#about"
            onClick={(e) => {
              e.preventDefault();
              goToSection('about');
            }}
            className="group mt-6 inline-flex items-center gap-2 font-semibold text-cyan hover:text-cyan-soft"
          >
            {t.aboutTeaserCta}
            <ChevronDownIcon className="transition-transform group-hover:translate-y-0.5" />
          </a>
        </aside>
      </div>
    </Section>
  );
}
