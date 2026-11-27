import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { ui, type UiStrings } from '../content/strings';
import type { Locale } from '../content/types';

interface LocaleContextValue {
  locale: Locale;
  dir: 'ltr' | 'rtl';
  t: UiStrings;
  setLocale: (locale: Locale) => void;
}

const LocaleContext = createContext<LocaleContextValue | null>(null);

/**
 * EN/AR switch. As on the legacy site, every load starts in English and the choice is not
 * persisted. Arabic flips the whole document to RTL via <html dir="rtl">.
 */
export function LocaleProvider({ children }: { children: ReactNode }) {
  const [locale, setLocaleState] = useState<Locale>('en');
  const dir = locale === 'ar' ? 'rtl' : 'ltr';

  useEffect(() => {
    document.documentElement.lang = locale;
    document.documentElement.dir = dir;
  }, [locale, dir]);

  const setLocale = useCallback((next: Locale) => setLocaleState(next), []);
  const value = useMemo(() => ({ locale, dir, t: ui[locale], setLocale }) as const, [locale, dir, setLocale]);

  return <LocaleContext.Provider value={value}>{children}</LocaleContext.Provider>;
}

export function useLocale(): LocaleContextValue {
  const ctx = useContext(LocaleContext);
  if (!ctx) throw new Error('useLocale must be used inside LocaleProvider');
  return ctx;
}
