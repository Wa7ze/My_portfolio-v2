import { useState, type MouseEvent } from 'react';
import { links } from '../../content/contact';
import { wire } from '../../content/strings';
import { DownloadIcon } from './Icons';

/**
 * CV download (legacy lib/interaction/cv_download_button.dart): a real
 * <a href="/cv.pdf" download="Mazen_Matran_CV.pdf">, so the file streams immediately, while the
 * button morphs into a 4-chunk progress bar (200ms per chunk), then `200 OK · cv.pdf` for 1.2s.
 */
export function CvDownloadButton({ label, className = '' }: { label: string; className?: string }) {
  const [phase, setPhase] = useState<'idle' | 'downloading' | 'done'>('idle');
  const [chunks, setChunks] = useState(0);

  async function onClick(e: MouseEvent<HTMLAnchorElement>) {
    if (phase !== 'idle') {
      e.preventDefault();
      return;
    }
    setPhase('downloading');
    setChunks(0);
    for (let i = 1; i <= 4; i++) {
      await new Promise((r) => setTimeout(r, 200));
      setChunks(i);
    }
    setPhase('done');
    await new Promise((r) => setTimeout(r, 1200));
    setPhase('idle');
  }

  return (
    <a
      href={links.cv}
      download={links.cvDownloadName}
      onClick={onClick}
      aria-live="polite"
      className={`inline-flex min-h-12 min-w-48 items-center justify-center gap-2.5 rounded-md border px-6 font-display text-body font-semibold transition-colors duration-300 ${
        phase === 'done'
          ? 'border-ok text-ok'
          : 'border-cyan/60 bg-navy-900/50 text-cyan hover:border-cyan hover:bg-cyan/10'
      } ${className}`}
    >
      {phase === 'idle' && (
        <>
          <DownloadIcon className="text-lg" />
          <span>{label}</span>
        </>
      )}
      {phase === 'downloading' && (
        <span
          className="flex w-28 gap-1"
          role="progressbar"
          aria-valuemin={0}
          aria-valuemax={4}
          aria-valuenow={chunks}
          aria-label={label}
        >
          {[0, 1, 2, 3].map((i) => (
            <span key={i} className={`h-1 flex-1 rounded-pill ${i < chunks ? 'bg-cyan' : 'bg-cyan/15'}`} />
          ))}
        </span>
      )}
      {phase === 'done' && (
        <span dir="ltr" className="label-mono normal-case">
          {wire.cvDone}
        </span>
      )}
    </a>
  );
}
