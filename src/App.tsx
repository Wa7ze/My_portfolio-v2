import { lazy, Suspense, useEffect } from 'react';
import { CustomCursor } from './components/interaction/CustomCursor';
import { EffectsLayer } from './components/interaction/EffectsLayer';
import { TerminalLauncher } from './components/interaction/TerminalLauncher';
import { useClickRouter } from './components/interaction/useClickRouter';
import { useIdleWatcher } from './components/interaction/useIdleWatcher';
import { LatencyCounter } from './components/layout/LatencyCounter';
import { NavBar } from './components/layout/NavBar';
import { SkipLink } from './components/layout/SkipLink';
import { About } from './components/sections/About';
import { Approach } from './components/sections/Approach';
import { Contact } from './components/sections/Contact';
import { Experience } from './components/sections/Experience';
import { Footer } from './components/sections/Footer';
import { Hero } from './components/sections/Hero';
import { Projects } from './components/sections/Projects';
import { Skills } from './components/sections/Skills';
import { LightboxProvider } from './components/ui/Lightbox';
import { ScrollTrigger } from './lib/gsap';
import { jumpToInitialHash, onActiveSectionChanged } from './lib/navigation';
import { initSmoothScroll } from './lib/smoothScroll';
import { EffectsProvider } from './state/effects';
import { LocaleProvider } from './state/locale';
import { getScrollState, refreshScrollStore, startScrollStore, subscribeScroll } from './state/scrollStore';
import { StoryStage } from './story/StoryStage';
import { isDebug, StoryProvider } from './story/useStoryProgress';

const DebugOverlay = lazy(() => import('./story/DebugOverlay'));

declare global {
  interface Window {
    bootDone?: () => void;
  }
}

export function App() {
  return (
    <LocaleProvider>
      <EffectsProvider>
        <LightboxProvider>
          <StoryProvider>
            <Site />
          </StoryProvider>
        </LightboxProvider>
      </EffectsProvider>
    </LocaleProvider>
  );
}

function Site() {
  useStartup();
  useClickRouter();
  useIdleWatcher();

  return (
    <>
      <StoryStage />
      <SkipLink />
      <NavBar />
      <div className="relative z-content">
        <main id="main" tabIndex={-1} className="outline-none">
          <Hero />
          <About />
          <Skills />
          <Projects />
          <Approach />
          <Experience />
          <Contact />
        </main>
        <Footer />
      </div>
      <LatencyCounter />
      <EffectsLayer />
      <TerminalLauncher />
      <CustomCursor />
      {isDebug() && (
        <Suspense fallback={null}>
          <DebugOverlay />
        </Suspense>
      )}
      <div className="grain" aria-hidden="true" />
    </>
  );
}

/** Smooth scroll, scroll store, initial hash jump, hash sync, and boot-loader hand-off. */
function useStartup() {
  useEffect(() => {
    initSmoothScroll();
    startScrollStore();

    let last = getScrollState().active;
    const unsubscribe = subscribeScroll(() => {
      const { active } = getScrollState();
      if (active !== last) {
        last = active;
        onActiveSectionChanged(active);
      }
    });

    const raf = requestAnimationFrame(() => {
      jumpToInitialHash();
      ScrollTrigger.refresh();
      refreshScrollStore();
      window.bootDone?.();
    });
    // Web fonts change layout height: once they are in, re-measure and, unless the visitor has
    // already scrolled, re-apply the initial #hash jump (the target may have moved).
    let userScrolled = false;
    const markScrolled = () => (userScrolled = true);
    const inputs = ['wheel', 'touchmove', 'keydown', 'pointerdown'] as const;
    inputs.forEach((ev) => window.addEventListener(ev, markScrolled, { once: true, passive: true }));
    void document.fonts?.ready.then(() => {
      if (!userScrolled) jumpToInitialHash();
      ScrollTrigger.refresh();
      refreshScrollStore();
    });

    return () => {
      cancelAnimationFrame(raf);
      unsubscribe();
      inputs.forEach((ev) => window.removeEventListener(ev, markScrolled));
    };
  }, []);
}
