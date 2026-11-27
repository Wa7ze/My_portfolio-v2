import { useEffect, useRef } from 'react';
import { prefersReducedMotion } from '../../lib/motion';

const INTERACTIVE = 'a, button, [role="button"], summary, label, [data-interactive]';
const CYAN = '61 224 255'; // --color-cyan as RGB channels for canvas strokes

/**
 * Desktop-mouse-only cursor (legacy lib/widgets/custom_cursor.dart): a glowing cyan node that
 * follows the pointer, a fading trail of its last 10 positions, and a ring over interactive
 * elements (shrinks while pressed). Enabled after the first mouse move; disabled for the rest of
 * the session on the first touch/pen event; never enabled under reduced motion.
 */
export function CustomCursor() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas || prefersReducedMotion() || !window.matchMedia('(pointer: fine)').matches) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const html = document.documentElement;
    const trail: { x: number; y: number }[] = [];
    let pos: { x: number; y: number } | null = null;
    let hovering = false;
    let pressed = false;
    let enabled = false;
    let disabled = false;
    let raf = 0;

    const resize = () => {
      const dpr = window.devicePixelRatio || 1;
      canvas.width = window.innerWidth * dpr;
      canvas.height = window.innerHeight * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };

    const draw = () => {
      raf = 0;
      ctx.clearRect(0, 0, window.innerWidth, window.innerHeight);
      if (!pos || disabled) return;
      ctx.lineCap = 'round';
      for (let i = 0; i < trail.length - 1; i++) {
        const a = trail[i];
        const b = trail[i + 1];
        if (!a || !b) continue;
        const f = i / trail.length;
        ctx.strokeStyle = `rgb(${CYAN} / ${0.4 * f})`;
        ctx.lineWidth = 0.5 + 1.5 * f;
        ctx.beginPath();
        ctx.moveTo(a.x, a.y);
        ctx.lineTo(b.x, b.y);
        ctx.stroke();
      }
      if (hovering) {
        ctx.strokeStyle = `rgb(${CYAN})`;
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.arc(pos.x, pos.y, pressed ? 20 : 28, 0, Math.PI * 2);
        ctx.stroke();
      }
      const glow = ctx.createRadialGradient(pos.x, pos.y, 0, pos.x, pos.y, 12);
      glow.addColorStop(0, `rgb(${CYAN} / 0.45)`);
      glow.addColorStop(1, `rgb(${CYAN} / 0)`);
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(pos.x, pos.y, 12, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = `rgb(${CYAN})`;
      ctx.beginPath();
      ctx.arc(pos.x, pos.y, 4, 0, Math.PI * 2);
      ctx.fill();
    };
    const schedule = () => {
      if (!raf) raf = requestAnimationFrame(draw);
    };

    const onMove = (e: PointerEvent) => {
      if (e.pointerType !== 'mouse') {
        disabled = true;
        html.classList.remove('custom-cursor');
        schedule();
        return;
      }
      if (disabled) return;
      if (!enabled) {
        enabled = true;
        html.classList.add('custom-cursor');
      }
      pos = { x: e.clientX, y: e.clientY };
      trail.push(pos);
      if (trail.length > 10) trail.shift();
      hovering = !!(e.target as Element | null)?.closest(INTERACTIVE);
      schedule();
    };
    const onDown = (e: PointerEvent) => {
      onMove(e);
      pressed = true;
      schedule();
    };
    const onUp = () => {
      pressed = false;
      schedule();
    };
    const onLeave = () => {
      pos = null;
      trail.length = 0;
      schedule();
    };

    resize();
    window.addEventListener('resize', resize);
    window.addEventListener('pointermove', onMove, { passive: true });
    window.addEventListener('pointerdown', onDown, { passive: true });
    window.addEventListener('pointerup', onUp, { passive: true });
    document.documentElement.addEventListener('pointerleave', onLeave);
    return () => {
      cancelAnimationFrame(raf);
      html.classList.remove('custom-cursor');
      window.removeEventListener('resize', resize);
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerdown', onDown);
      window.removeEventListener('pointerup', onUp);
      document.documentElement.removeEventListener('pointerleave', onLeave);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      className="pointer-events-none fixed inset-0 z-cursor size-full"
    />
  );
}
