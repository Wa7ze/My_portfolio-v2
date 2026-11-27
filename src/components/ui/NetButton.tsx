import { useRef, useState, type ReactNode } from 'react';
import { wire } from '../../content/strings';
import { MOTION, prefersReducedMotion } from '../../lib/motion';
import { centerOf, useEffects } from '../../state/effects';

export interface NetResult {
  ok: boolean;
  status: number;
  label: string;
}
export const ok = (status = 200, label: string = wire.badges.ok): NetResult => ({ ok: true, status, label });

type Variant = 'primary' | 'ghost';

const base =
  'relative inline-flex min-h-12 items-center justify-center gap-2.5 rounded-md px-6 font-display text-body font-semibold transition-[background-color,border-color,box-shadow,transform] duration-200 ease-out-cubic active:scale-[0.98] disabled:cursor-progress';
const variants: Record<Variant, string> = {
  primary: 'bg-amber text-navy-950 shadow-glow-amber hover:bg-amber-soft',
  ghost: 'border border-line-strong bg-navy-900/50 text-ink hover:border-cyan hover:text-cyan',
};

/**
 * Every action modeled as a fake network request (legacy lib/interaction/net_button.dart):
 * press → 300ms "handshake" (spinner, disabled) → action → floating status badge
 * (`200 OK` green / error red, announced to screen readers). Reduced motion skips the handshake.
 */
export function NetButton({
  label,
  icon,
  onRequest,
  variant = 'primary',
  className = '',
}: {
  label: string;
  icon?: ReactNode;
  onRequest: () => NetResult | Promise<NetResult>;
  variant?: Variant;
  className?: string;
}) {
  const [phase, setPhase] = useState<'idle' | 'handshaking' | 'ok' | 'error'>('idle');
  const ref = useRef<HTMLButtonElement>(null);
  const { addBadge } = useEffects();

  async function activate() {
    if (phase !== 'idle') return;
    const reduced = prefersReducedMotion();
    if (!reduced) {
      setPhase('handshaking');
      await new Promise((r) => setTimeout(r, MOTION.handshake));
    }
    let result: NetResult;
    try {
      result = await onRequest();
    } catch {
      result = { ok: false, status: 500, label: wire.badges.error };
    }
    setPhase(result.ok ? 'ok' : 'error');
    if (ref.current) {
      const { x, y } = centerOf(ref.current);
      addBadge(x, y, `${result.status} ${result.label}`, !result.ok);
    }
    setTimeout(() => setPhase('idle'), reduced ? 0 : MOTION.badgeFloat);
  }

  const ring = phase === 'ok' ? 'ring-2 ring-ok' : phase === 'error' ? 'ring-2 ring-err' : '';

  return (
    <button
      ref={ref}
      type="button"
      onClick={activate}
      disabled={phase === 'handshaking'}
      aria-busy={phase === 'handshaking'}
      className={`${base} ${variants[variant]} ${ring} ${className}`}
    >
      {phase === 'handshaking' ? (
        <span
          aria-hidden="true"
          className="size-4 animate-[spin_0.8s_linear_infinite] rounded-pill border-2 border-current border-t-transparent"
        />
      ) : (
        icon
      )}
      <span>{label}</span>
    </button>
  );
}
