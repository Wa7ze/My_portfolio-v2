import { useEffect, useRef, useState, type FormEvent } from 'react';
import { links } from '../../content/contact';
import { summary } from '../../content/profile';
import { projects } from '../../content/projects';
import { navSections } from '../../content/sections';
import { wire } from '../../content/strings';
import { terminalText as T } from '../../content/terminal';
import type { SectionId } from '../../content/types';
import { goToSection } from '../../lib/navigation';
import { getLenis } from '../../lib/smoothScroll';
import { useLocale } from '../../state/locale';
import { CloseIcon } from '../ui/Icons';

/** Section name → id, from the visible nav sections (a hidden Approach is not routable). */
const sectionsByName = new Map<string, SectionId>(navSections.map((s) => [s.hash, s.id]));

/**
 * Hidden terminal (legacy lib/widgets/terminal_overlay.dart), lazy-loaded on first open.
 * Every legacy command is supported verbatim. Fix vs legacy: `open github|linkedin|cv` now
 * actually opens the link (legacy only printed "→ opening …").
 */
export default function Terminal({ onClose }: { onClose: () => void }) {
  const { locale } = useLocale();
  const [output, setOutput] = useState<string[]>([T.welcome]);
  const [value, setValue] = useState('');
  const history = useRef<string[]>([]);
  const inputRef = useRef<HTMLInputElement>(null);
  const outputRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
    getLenis()?.stop();
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', onKey);
    return () => {
      window.removeEventListener('keydown', onKey);
      getLenis()?.start();
    };
  }, [onClose]);

  useEffect(() => {
    outputRef.current?.scrollTo({ top: outputRef.current.scrollHeight });
  }, [output]);

  const print = (...lines: string[]) => setOutput((o) => [...o, ...lines]);
  const routeTo = (id: SectionId) =>
    window.setTimeout(() => {
      onClose();
      goToSection(id);
    }, 300);
  const open = (url: string) => window.open(url, '_blank', 'noopener,noreferrer');

  function execute(cmd: string) {
    const parts = cmd.split(/\s+/);
    const head = (parts[0] ?? '').toLowerCase();
    const rest = parts.slice(1).join(' ');

    switch (head) {
      case 'help':
        print(...T.help);
        break;
      case 'whoami':
        print(summary[locale]);
        break;
      case 'ls':
        if (rest === 'projects') print(...projects.map((p) => `${p.slug}  (${p.tags.join(', ')})`));
        else print([...sectionsByName.keys()].join('  '));
        break;
      case 'cat': {
        const p = projects.find((x) => x.slug === rest);
        if (!p) print(T.noSuchProject(rest));
        else print(`${p.title} — ${p.summary}`, T.repo(p.githubUrl));
        break;
      }
      case 'cd':
      case 'curl': {
        const name = rest.replace('/', '');
        const target = sectionsByName.get(name);
        if (!target) print(T.noRoute(head, name));
        else {
          print(T.routing(name));
          routeTo(target);
        }
        break;
      }
      case 'open': {
        const urls: Record<string, string> = { github: links.github, linkedin: links.linkedin, cv: links.cv };
        const url = urls[rest];
        if (!url) print(T.unknownTarget(rest));
        else {
          print(T.opening(rest));
          open(url);
        }
        break;
      }
      case 'history':
        print(...history.current.map((h, i) => `${i + 1}  ${h}`));
        break;
      case 'clear':
        setOutput([]);
        break;
      case 'sudo':
        if (rest.startsWith('hire')) {
          print(T.sudoGranted, T.sudoOpeningContact);
          routeTo('contact');
        } else print(T.sudoNotFound(rest));
        break;
      case 'exit':
        onClose();
        break;
      default:
        print(T.notFound(cmd));
    }
  }

  function onSubmit(e: FormEvent) {
    e.preventDefault();
    const cmd = value.trim();
    setValue('');
    if (!cmd) return;
    history.current.push(cmd);
    print(`${T.prompt}${cmd}`);
    execute(cmd);
  }

  return (
    <div
      role="dialog"
      aria-label={wire.a11y.terminal}
      dir="ltr"
      data-lenis-prevent
      className="fixed inset-x-0 bottom-0 z-terminal flex h-[90dvh] flex-col border-t border-cyan bg-navy-950/95 p-4 font-mono text-mono text-ink shadow-panel backdrop-blur-xl md:h-[45dvh]"
    >
      <button
        type="button"
        onClick={onClose}
        aria-label={wire.a11y.close}
        className="absolute end-3 top-3 lb-btn"
      >
        <CloseIcon />
      </button>
      <div ref={outputRef} className="flex-1 overflow-y-auto pe-12 whitespace-pre-wrap" aria-live="polite">
        {output.map((line, i) => (
          <p key={i}>{line}</p>
        ))}
      </div>
      <form onSubmit={onSubmit} className="mt-2 flex items-center">
        <label htmlFor="terminal-input" className="shrink-0 whitespace-pre text-cyan">
          {T.prompt}
        </label>
        <input
          id="terminal-input"
          ref={inputRef}
          value={value}
          onChange={(e) => setValue(e.target.value)}
          aria-label={wire.a11y.terminalInput}
          autoComplete="off"
          autoCapitalize="off"
          spellCheck={false}
          className="min-w-0 flex-1 bg-transparent text-ink caret-cyan outline-none"
        />
      </form>
    </div>
  );
}
