import { useId, useRef, useState } from 'react';
import { image } from '../../content/images';
import { projectJson, projects, responseTimeMs } from '../../content/projects';
import { wire } from '../../content/strings';
import type { Project } from '../../content/types';
import { scrollToElement } from '../../lib/smoothScroll';
import { useLocale } from '../../state/locale';
import { Section, SectionHeading } from '../layout/Section';
import { ChevronDownIcon, ExternalIcon } from '../ui/Icons';
import { useLightbox } from '../ui/Lightbox';
import { NetLink } from '../ui/NetLink';
import { Chip } from '../ui/Panel';

/**
 * Section 3 — projects (#projects). Legacy lib/sections/s3_api_projects.dart: cards as
 * `GET /projects/<slug>` endpoints; the header toggles an in-place case study. One open at a time.
 */
export function Projects() {
  const { t } = useLocale();
  const [expanded, setExpanded] = useState<string | null>(null);

  return (
    <Section id="projects" headingId="projects-title">
      <SectionHeading id="projects-title">{t.workPageTitle}</SectionHeading>
      <p className="mt-3 text-lead text-ink-2">{t.workPageSubtitle}</p>
      <ul className="mt-10 grid gap-6">
        {projects.map((p) => (
          <ProjectCard
            key={p.slug}
            project={p}
            expanded={expanded === p.slug}
            onToggle={() => setExpanded((cur) => (cur === p.slug ? null : p.slug))}
          />
        ))}
      </ul>
    </Section>
  );
}

function ProjectCard({
  project,
  expanded,
  onToggle,
}: {
  project: Project;
  expanded: boolean;
  onToggle: () => void;
}) {
  const { t } = useLocale();
  const openLightbox = useLightbox();
  const bodyId = useId();
  const cardRef = useRef<HTMLLIElement>(null);
  const cover = image(project.cover);
  const gallery = project.gallery.map((key, i) => ({
    src: image(key).full,
    thumb: image(key).thumb,
    alt: `${project.title} — ${i + 1}`,
  }));

  return (
    <li
      ref={cardRef}
      className={`overflow-hidden panel transition-[border-color] duration-300 ${expanded ? 'border-amber/50' : ''}`}
    >
      <div className="grid md:grid-cols-[minmax(0,1fr)_17rem] lg:grid-cols-[minmax(0,1fr)_22rem]">
        <div className="p-6 sm:p-8">
          <button
            type="button"
            dir="ltr"
            aria-expanded={expanded}
            aria-controls={bodyId}
            onClick={onToggle}
            className="flex w-full items-center gap-3 rounded-sm py-1 text-start font-mono text-mono hover:text-ink"
          >
            <span className="font-bold text-ok">{wire.projectMethod}</span>
            <span className="min-w-0 truncate text-ink-3">/projects/{project.slug}</span>
            <ChevronDownIcon
              className={`ms-auto shrink-0 text-lg text-ink-3 transition-transform duration-300 ${expanded ? 'rotate-180' : ''}`}
            />
          </button>
          <h3 className="mt-3 font-display text-h3 font-semibold text-ink">{project.title}</h3>
          <p className="mt-3 text-body text-ink-2">{project.summary}</p>
          <ul className="mt-5 flex flex-wrap gap-2">
            {project.tags.map((tag) => (
              <Chip key={tag} tone="amber">
                {tag}
              </Chip>
            ))}
          </ul>
        </div>
        <button
          type="button"
          onClick={() => openLightbox(gallery, Math.max(0, project.gallery.indexOf(project.cover)))}
          aria-label={wire.a11y.viewFullSize(project.title)}
          className="group relative hidden overflow-hidden border-s border-line bg-navy-950 md:block"
        >
          <img
            src={cover.thumb}
            alt=""
            loading="lazy"
            decoding="async"
            className="absolute inset-0 size-full object-cover object-top opacity-80 transition duration-500 group-hover:scale-105 group-hover:opacity-100"
          />
        </button>
      </div>

      <div
        id={bodyId}
        hidden={!expanded}
        className="border-t border-line bg-navy-950/40 px-6 pt-6 pb-2 sm:px-8"
      >
        <h4 className="label-mono text-amber">{t.projectOverview}</h4>
        <p className="mt-3 max-w-[72ch] text-body text-ink-2">{project.overview}</p>
        <pre
          dir="ltr"
          className="mt-6 overflow-x-auto rounded-md border border-line bg-navy-950/80 p-4 font-mono text-mono text-cyan-soft"
        >
          {projectJson(project)}
        </pre>
        <h4 className="mt-8 label-mono text-amber">{t.projectGallery}</h4>
        <ul className="mt-3 flex snap-x gap-3 overflow-x-auto pb-3">
          {gallery.map((img, i) => (
            <li key={img.src} className="shrink-0 snap-start">
              <button
                type="button"
                onClick={() => openLightbox(gallery, i)}
                aria-label={wire.a11y.viewFullSize(img.alt)}
                className="block overflow-hidden rounded-sm border border-line hover:border-cyan"
              >
                <img
                  src={img.thumb}
                  alt=""
                  loading="lazy"
                  decoding="async"
                  className="h-28 w-44 object-cover object-top sm:h-32 sm:w-52"
                />
              </button>
            </li>
          ))}
        </ul>
        <button
          type="button"
          onClick={() => {
            onToggle();
            if (cardRef.current) scrollToElement(cardRef.current);
          }}
          className="mt-4 mb-4 label-mono text-ink-2 hover:text-cyan"
        >
          <span aria-hidden="true" className="inline-block rtl:rotate-180">
            ←
          </span>{' '}
          {t.backToProjects}
        </button>
      </div>

      <div className="flex flex-wrap items-center gap-4 border-t border-line px-6 py-4 sm:px-8">
        <NetLink
          href={project.githubUrl}
          className="inline-flex items-center gap-1.5 label-mono text-cyan hover:text-cyan-soft"
        >
          {t.viewOnGithub}
          <ExternalIcon />
        </NetLink>
        <span dir="ltr" className="ms-auto label-mono text-ok">
          {wire.responseTime(responseTimeMs(project.slug))}
        </span>
      </div>
    </li>
  );
}
