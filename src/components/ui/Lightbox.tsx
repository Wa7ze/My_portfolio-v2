import { createContext, useCallback, useContext, useEffect, useRef, useState, type ReactNode } from 'react';
import { wire } from '../../content/strings';
import { useLocale } from '../../state/locale';
import { getLenis } from '../../lib/smoothScroll';
import { ChevronLeftIcon, ChevronRightIcon, CloseIcon } from './Icons';

export interface LightboxImage {
  src: string;
  alt: string;
}

type Open = (images: LightboxImage[], index?: number) => void;
const LightboxContext = createContext<Open | null>(null);

/**
 * Full-size image viewer (certificates, CV preview, project galleries) on a native <dialog>:
 * Esc closes, ←/→ step, focus returns to the opener, background scroll is paused.
 */
export function LightboxProvider({ children }: { children: ReactNode }) {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [images, setImages] = useState<LightboxImage[]>([]);
  const [index, setIndex] = useState(0);
  const { dir } = useLocale();

  const open = useCallback<Open>((imgs, i = 0) => {
    setImages(imgs);
    setIndex(i);
    getLenis()?.stop();
    dialogRef.current?.showModal();
  }, []);

  const close = () => dialogRef.current?.close();
  const step = useCallback(
    (delta: number) => setIndex((i) => (images.length ? (i + delta + images.length) % images.length : 0)),
    [images.length],
  );

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    const onClose = () => getLenis()?.start();
    // Click on the backdrop (the dialog element itself, outside the figure) closes.
    const onClick = (e: MouseEvent) => e.target === dialog && dialog.close();
    dialog.addEventListener('close', onClose);
    dialog.addEventListener('click', onClick);
    return () => {
      dialog.removeEventListener('close', onClose);
      dialog.removeEventListener('click', onClick);
    };
  }, []);

  // ←/→ step through images while open (mirrored in RTL).
  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog || images.length < 2) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight') step(dir === 'rtl' ? -1 : 1);
      if (e.key === 'ArrowLeft') step(dir === 'rtl' ? 1 : -1);
    };
    dialog.addEventListener('keydown', onKey);
    return () => dialog.removeEventListener('keydown', onKey);
  }, [images.length, dir, step]);

  const current = images[index];
  const many = images.length > 1;
  // In RTL the visual "next" arrow points left.
  const prevIcon = dir === 'rtl' ? <ChevronRightIcon /> : <ChevronLeftIcon />;
  const nextIcon = dir === 'rtl' ? <ChevronLeftIcon /> : <ChevronRightIcon />;

  return (
    <LightboxContext.Provider value={open}>
      {children}
      <dialog
        ref={dialogRef}
        aria-label={current?.alt}
        className="m-auto max-h-[92dvh] max-w-[94vw] overflow-visible bg-transparent p-0 text-ink"
      >
        {current && (
          <figure className="relative flex flex-col items-center gap-3">
            <img
              src={current.src}
              alt={current.alt}
              className="max-h-[82dvh] max-w-[94vw] rounded-md border border-line-strong object-contain shadow-panel"
            />
            <figcaption className="max-w-prose text-center text-mono text-ink-2">
              {current.alt}
              {many && (
                <span dir="ltr" className="ms-2 font-mono text-ink-3">
                  {index + 1}/{images.length}
                </span>
              )}
            </figcaption>
          </figure>
        )}
        <div className="fixed end-4 top-4 flex gap-2">
          {many && (
            <>
              <button
                type="button"
                aria-label={wire.a11y.prevImage}
                onClick={() => step(-1)}
                className="lb-btn"
              >
                {prevIcon}
              </button>
              <button
                type="button"
                aria-label={wire.a11y.nextImage}
                onClick={() => step(1)}
                className="lb-btn"
              >
                {nextIcon}
              </button>
            </>
          )}
          {/* eslint-disable-next-line jsx-a11y/no-autofocus -- moving focus into the modal is expected */}
          <button type="button" aria-label={wire.a11y.close} onClick={close} className="lb-btn" autoFocus>
            <CloseIcon />
          </button>
        </div>
      </dialog>
    </LightboxContext.Provider>
  );
}

export function useLightbox(): Open {
  const ctx = useContext(LightboxContext);
  if (!ctx) throw new Error('useLightbox must be used inside LightboxProvider');
  return ctx;
}
