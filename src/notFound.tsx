import '@fontsource-variable/space-grotesk';
import '@fontsource-variable/jetbrains-mono';
import './styles/global.css';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { EffectsLayer } from './components/interaction/EffectsLayer';
import { NetButton, ok } from './components/ui/NetButton';
import { wire } from './content/strings';
import { EffectsProvider } from './state/effects';

/**
 * 404 page (legacy lib/pages/not_found_page.dart), served by Netlify as dist/404.html with a real
 * 404 status. Shows the actual requested path. The legacy "lost Pak" drawing is deferred to the
 * story (spec: STORY.md; notes: docs/STORY_DEV.md).
 */
function NotFound() {
  const path = window.location.pathname + window.location.search;
  return (
    <main className="grid min-h-dvh place-items-center px-5">
      <div className="w-full max-w-xl panel p-10 text-center">
        <p aria-hidden="true" className="font-mono text-h1 text-err">
          ?
        </p>
        <h1 className="mt-2 font-display text-display font-bold text-ink">{wire.notFound.code}</h1>
        <p className="mt-4 text-lead text-ink-2">{wire.notFound.body}</p>
        <p dir="ltr" className="mt-3 font-mono text-mono break-all text-ink-3">
          {wire.notFound.line(path)}
        </p>
        <NetButton
          className="mt-8"
          label={wire.notFound.home}
          onRequest={async () => {
            await new Promise((r) => setTimeout(r, 400));
            window.location.assign('/');
            return ok();
          }}
        />
      </div>
      <div className="grain" aria-hidden="true" />
    </main>
  );
}

const root = document.getElementById('root');
if (!root) throw new Error('#root missing');
createRoot(root).render(
  <StrictMode>
    <EffectsProvider>
      <NotFound />
      <EffectsLayer />
    </EffectsProvider>
  </StrictMode>,
);
