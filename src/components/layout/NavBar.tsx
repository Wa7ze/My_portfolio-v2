import { useEffect, useRef, useState, type MouseEvent } from 'react';
import { navSections } from '../../content/sections';
import { wire } from '../../content/strings';
import { LOCALES, type SectionId } from '../../content/types';
import { toggleTerminal } from '../../lib/events';
import { goToSection } from '../../lib/navigation';
import { useLocale } from '../../state/locale';
import { useScrollState } from '../../state/scrollStore';
import { CloseIcon, MenuIcon } from '../ui/Icons';

const LONG_PRESS_MS = 500;

/**
 * Fixed top nav (legacy lib/navigation/nav_bar.dart): `<mm/>` logo (click → home, long-press →
 * hidden terminal), section links with an active underline bound to scroll position, and the
 * EN/AR switch. Under 768px it collapses into a hamburger + dropdown sheet.
 */
export function NavBar() {
  const { t, locale, setLocale } = useLocale();
  const active = useScrollState((s) => s.active);
  const [open, setOpen] = useState(false);
  const pressTimer = useRef(0);
  const longPressed = useRef(false);

  // Close the mobile sheet on Escape.
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && setOpen(false);
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open]);

  function navigate(e: MouseEvent, id: SectionId) {
    e.preventDefault();
    setOpen(false);
    goToSection(id);
  }

  const activeNav = active === 'footer' ? 'contact' : active;

  const localeSwitch = (
    <div role="group" aria-label={t.language} className="flex gap-1.5">
      {LOCALES.map((l) => (
        <button
          key={l}
          type="button"
          lang={l}
          aria-pressed={locale === l}
          onClick={() => setLocale(l)}
          className={`rounded-sm border px-2.5 py-1 label-mono transition-colors ${
            locale === l
              ? 'border-cyan bg-cyan text-navy-950'
              : 'border-line-strong text-ink-2 hover:border-cyan hover:text-cyan'
          }`}
        >
          {l.toUpperCase()}
        </button>
      ))}
    </div>
  );

  return (
    <header className="fixed inset-x-0 top-0 z-nav">
      <div className="border-b border-line bg-navy-950/70 px-5 backdrop-blur-[var(--blur-nav)] sm:px-8">
        <div className="mx-auto flex h-16 max-w-content items-center gap-6">
          <a
            href="#home"
            dir="ltr"
            aria-label={wire.a11y.homeLink}
            onClick={(e) => {
              if (longPressed.current) {
                e.preventDefault();
                longPressed.current = false;
                return;
              }
              navigate(e, 'home');
            }}
            onPointerDown={() => {
              longPressed.current = false;
              pressTimer.current = window.setTimeout(() => {
                longPressed.current = true;
                toggleTerminal();
              }, LONG_PRESS_MS);
            }}
            onPointerUp={() => window.clearTimeout(pressTimer.current)}
            onPointerLeave={() => window.clearTimeout(pressTimer.current)}
            onContextMenu={(e) => longPressed.current && e.preventDefault()}
            className="font-mono text-body font-bold text-ink select-none"
          >
            <span className="text-amber">&lt;</span>mm<span className="text-amber">/&gt;</span>
          </a>

          <nav aria-label={wire.a11y.primaryNav} className="ms-auto hidden md:block">
            <ul className="flex items-center gap-1 lg:gap-2">
              {navSections.map((s) => {
                const isActive = activeNav === s.id;
                return (
                  <li key={s.id}>
                    <a
                      href={`#${s.hash}`}
                      aria-current={isActive ? 'true' : undefined}
                      onClick={(e) => navigate(e, s.id)}
                      className={`group relative block px-2.5 py-2 text-[0.9rem] transition-colors lg:px-3 ${
                        isActive ? 'font-semibold text-cyan' : 'text-ink-2 hover:text-ink'
                      }`}
                    >
                      {s.navKey && t.nav[s.navKey]}
                      <span
                        aria-hidden="true"
                        className={`absolute inset-x-0 -bottom-0.5 mx-auto h-0.5 rounded-pill bg-cyan transition-[width] duration-150 ${
                          isActive ? 'w-4' : 'w-0'
                        }`}
                      />
                    </a>
                  </li>
                );
              })}
            </ul>
          </nav>
          <div className="hidden md:block">{localeSwitch}</div>

          <button
            type="button"
            aria-expanded={open}
            aria-controls="mobile-menu"
            aria-label={open ? t.closeMenu : t.openMenu}
            onClick={() => setOpen((o) => !o)}
            className="ms-auto grid size-11 place-items-center rounded-md text-2xl text-ink md:hidden"
          >
            {open ? <CloseIcon /> : <MenuIcon />}
          </button>
        </div>
      </div>

      {open && (
        <div id="mobile-menu" className="border-b border-line bg-navy-950/95 backdrop-blur-xl md:hidden">
          <nav aria-label={wire.a11y.primaryNav} className="px-5 py-3">
            <ul>
              {navSections.map((s) => {
                const isActive = activeNav === s.id;
                return (
                  <li key={s.id}>
                    <a
                      href={`#${s.hash}`}
                      aria-current={isActive ? 'true' : undefined}
                      onClick={(e) => navigate(e, s.id)}
                      className={`block rounded-sm px-3 py-3 text-lead ${
                        isActive ? 'font-semibold text-cyan' : 'text-ink'
                      }`}
                    >
                      {s.navKey && t.nav[s.navKey]}
                    </a>
                  </li>
                );
              })}
            </ul>
            <div className="mt-2 flex items-center justify-end border-t border-line pt-4 pb-2">
              {localeSwitch}
            </div>
          </nav>
        </div>
      )}
    </header>
  );
}
