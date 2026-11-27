import { createContext, useContext, useMemo, useRef, useState, type ReactNode } from 'react';
import { MOTION } from '../lib/motion';

/**
 * Transient interaction effects (legacy lib/interaction/effects_controller.dart): pings,
 * status badges and redirect badges, positioned in viewport coordinates and auto-expiring.
 * Capped at 6 pings / 4 badges / 2 redirects (oldest evicted). Toasts live here too.
 */
export interface Ping {
  id: number;
  x: number;
  y: number;
  label: string;
}
export interface Badge {
  id: number;
  x: number;
  y: number;
  text: string;
  isError: boolean;
}
export interface Redirect {
  id: number;
  x: number;
  y: number;
  text: string;
}
export interface Toast {
  id: number;
  message: string;
  isError: boolean;
}

interface EffectsApi {
  addPing: (x: number, y: number, label: string) => void;
  addBadge: (x: number, y: number, text: string, isError: boolean) => void;
  addRedirect: (x: number, y: number, text: string) => void;
  showToast: (message: string, isError?: boolean) => void;
}

interface EffectsState {
  pings: Ping[];
  badges: Badge[];
  redirects: Redirect[];
  toast: Toast | null;
}

const ApiContext = createContext<EffectsApi | null>(null);
const StateContext = createContext<EffectsState | null>(null);

const EXTRA_LIFETIME = 200;
const REDIRECT_LIFETIME = 900;
const TOAST_DURATION = 2200;

export function EffectsProvider({ children }: { children: ReactNode }) {
  const [pings, setPings] = useState<Ping[]>([]);
  const [badges, setBadges] = useState<Badge[]>([]);
  const [redirects, setRedirects] = useState<Redirect[]>([]);
  const [toast, setToast] = useState<Toast | null>(null);
  const nextId = useRef(1);

  const api = useMemo<EffectsApi>(() => {
    function add<T extends { id: number }>(
      set: React.Dispatch<React.SetStateAction<T[]>>,
      item: T,
      cap: number,
      lifetime: number,
    ) {
      set((list) => [...list, item].slice(-cap));
      window.setTimeout(() => set((list) => list.filter((x) => x.id !== item.id)), lifetime);
    }
    return {
      addPing: (x, y, label) =>
        add(setPings, { id: nextId.current++, x, y, label }, 6, MOTION.ping + EXTRA_LIFETIME),
      addBadge: (x, y, text, isError) =>
        add(setBadges, { id: nextId.current++, x, y, text, isError }, 4, MOTION.badgeFloat + EXTRA_LIFETIME),
      addRedirect: (x, y, text) =>
        add(setRedirects, { id: nextId.current++, x, y, text }, 2, REDIRECT_LIFETIME + EXTRA_LIFETIME),
      showToast: (message, isError = false) => {
        const id = nextId.current++;
        setToast({ id, message, isError });
        window.setTimeout(() => setToast((t) => (t?.id === id ? null : t)), TOAST_DURATION);
      },
    };
  }, []);

  const state = useMemo(() => ({ pings, badges, redirects, toast }), [pings, badges, redirects, toast]);

  return (
    <ApiContext.Provider value={api}>
      <StateContext.Provider value={state}>{children}</StateContext.Provider>
    </ApiContext.Provider>
  );
}

export function useEffects(): EffectsApi {
  const ctx = useContext(ApiContext);
  if (!ctx) throw new Error('useEffects must be used inside EffectsProvider');
  return ctx;
}

export function useEffectsState(): EffectsState {
  const ctx = useContext(StateContext);
  if (!ctx) throw new Error('useEffectsState must be used inside EffectsProvider');
  return ctx;
}

/** Viewport-center of an element, used to anchor badges to the control that fired them. */
export function centerOf(el: Element): { x: number; y: number } {
  const r = el.getBoundingClientRect();
  return { x: r.left + r.width / 2, y: r.top + r.height / 2 };
}
