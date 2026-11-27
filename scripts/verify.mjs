// Phase 3 parity verifier (dev only). Loads the real content modules through Vite SSR and checks the
// running site (default http://localhost:4173/) with Playwright + installed Chrome:
//   1. every verbatim string, per locale, is present in the rendered DOM
//   2. every content link exists as an <a href>
//   3. every image/asset request succeeds
//   4. interactions behave as in the legacy site
// Usage: node scripts/verify.mjs [baseUrl]   → prints a report, writes screenshots/verify.json
import { mkdir, writeFile } from 'node:fs/promises';
import { chromium } from 'playwright-core';
import { createServer } from 'vite';

const BASE = process.argv[2] ?? 'http://localhost:4173/';
const CHROME = process.env.CHROME_PATH ?? 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const results = [];
const check = (group, name, ok, detail = '') => {
  results.push({ group, name, ok: !!ok, detail });
  console.log(`${ok ? 'PASS' : 'FAIL'}  [${group}] ${name}${detail && !ok ? ` — ${detail}` : ''}`);
};

// ---------- Load content via Vite SSR ----------
const vite = await createServer({ server: { middlewareMode: true }, appType: 'custom', logLevel: 'error' });
const load = (p) => vite.ssrLoadModule(p);
const { ui, wire } = await load('/src/content/strings.ts');
const profile = await load('/src/content/profile.ts');
const { skillGroups, skillRoute } = await load('/src/content/skills.ts');
const { projects, responseTimeMs, projectJson } = await load('/src/content/projects.ts');
const { featuredCertificates, otherCertificates } = await load('/src/content/certificates.ts');
const { socialLinks, links } = await load('/src/content/contact.ts');
const { visibleSections, navSections } = await load('/src/content/sections.ts');
await vite.close();

const norm = (s) => s.replace(/\s+/g, ' ').trim();

function expectedStrings(locale) {
  const t = ui[locale];
  const out = [];
  const push = (label, value) => out.push([label, value]);
  for (const s of navSections) push(`nav.${s.navKey}`, t.nav[s.navKey]);
  for (const key of Object.keys(t)) {
    if (['nav', 'openMenu', 'closeMenu', 'language'].includes(key)) continue; // aria-only, checked separately
    push(`ui.${key}`, t[key]);
  }
  push('summary', profile.summary[locale]);
  push('aboutTeaser', profile.aboutTeaser[locale]);
  for (const job of profile.experience[locale]) {
    push('exp.role', job.role);
    push('exp.company', job.company);
    push('exp.period', job.period);
    push('exp.roleLine', `${job.role} — ${job.company} (${job.period})`);
    job.bullets.forEach((b, i) => push(`exp.bullet${i + 1}`, b));
  }
  for (const e of profile.education[locale]) {
    push('edu.title', `${e.degree} — ${e.field}`);
    push('edu.school', e.school);
    push('edu.gpaPeriod', `${e.gpa} · ${e.period}`);
  }
  for (const l of profile.languages[locale]) push(`lang.${l.name}`, `${l.name}${l.level}`);
  for (const g of skillGroups) {
    push(`skills.group`, g.name[locale]);
    push(`skills.route`, `ROUTE${skillRoute(g.name[locale])}`);
    for (const s of g.skills[locale]) push(`skill`, s);
  }
  for (const p of projects) {
    push(`project.${p.slug}.endpoint`, `GET/projects/${p.slug}`);
    push(`project.${p.slug}.title`, p.title);
    push(`project.${p.slug}.summary`, p.summary);
    push(`project.${p.slug}.overview`, p.overview);
    push(`project.${p.slug}.json`, projectJson(p));
    push(`project.${p.slug}.time`, wire.responseTime(responseTimeMs(p.slug)));
    for (const tag of p.tags) push(`project.${p.slug}.tag`, tag);
  }
  for (const c of [...featuredCertificates, ...otherCertificates]) {
    push('cert.title', c.title);
    push('cert.issuer', c.issuer);
    push('cert.date', c.date);
  }
  for (const s of socialLinks) push(`social.${s.id}`, s.value);
  for (const s of visibleSections) push(`eyebrow.${s.id}`, s.eyebrow);
  push('name', wire.name);
  push('teardown.client', wire.teardown.client);
  push('teardown.server', wire.teardown.server);
  wire.teardown.rows.forEach((r) => push('teardown.row', r));
  push('teardown.closed', wire.teardown.closedTitle);
  push('teardown.body', wire.teardown.closedBody);
  push('teardown.keepAlive', wire.teardown.keepAlive);
  push('footer.copyright', `© ${new Date().getFullYear()} ${t.footerRights}`);
  push('skip', wire.skipToContent);
  return out;
}

// ---------- Browser ----------
await mkdir('screenshots', { recursive: true });
const browser = await chromium.launch({ executablePath: CHROME });
const ctx = await browser.newContext({ viewport: { width: 1280, height: 900 }, acceptDownloads: true });
const failedRequests = [];
ctx.on('response', (r) => r.status() >= 400 && failedRequests.push(`${r.status()} ${r.url()}`));

async function freshPage(url = BASE, opts = {}) {
  const page = await ctx.newPage();
  if (opts.clock) await page.clock.install();
  await page.goto(url, { waitUntil: 'networkidle' });
  if (!opts.clock)
    await page.waitForFunction(() => !document.getElementById('boot'), null, { timeout: 8000 });
  return page;
}
const scrollBottom = (page) =>
  page.evaluate(() => window.scrollTo({ top: document.documentElement.scrollHeight, behavior: 'instant' }));
const scrollThrough = async (page) => {
  const h = await page.evaluate(() => document.documentElement.scrollHeight);
  for (let y = 0; y <= h; y += 600) {
    await page.evaluate((top) => window.scrollTo({ top, behavior: 'instant' }), y);
    await page.waitForTimeout(30);
  }
};

// 1 + 2: text and links, per locale
for (const locale of ['en', 'ar']) {
  const page = await freshPage();
  if (locale === 'ar') await page.getByRole('button', { name: 'AR', exact: true }).first().click();
  await check(
    `text-${locale}`,
    'html lang/dir',
    await page.evaluate(
      (l) =>
        document.documentElement.lang === l && document.documentElement.dir === (l === 'ar' ? 'rtl' : 'ltr'),
      locale,
    ),
  );
  await scrollThrough(page);
  await page.waitForTimeout(3200); // teardown sequence at the bottom
  // textContent includes the collapsed project bodies (rendered with the `hidden` attribute).
  const dom = norm(await page.evaluate(() => document.body.textContent ?? ''));
  const domNoSpace = dom.replace(/\s/g, '');
  for (const [label, value] of expectedStrings(locale)) {
    const v = norm(value);
    check(
      `text-${locale}`,
      `${label}: ${v.slice(0, 60)}`,
      dom.includes(v) || domNoSpace.includes(v.replace(/\s/g, '')),
    );
  }
  // aria-only strings
  const t = ui[locale];
  check(
    `text-${locale}`,
    'aria: language group',
    (await page.getByRole('group', { name: t.language }).count()) > 0,
  );
  if (locale === 'en') {
    // Hidden Approach must not render anywhere.
    check(
      'text-en',
      'Approach hidden (no #approach, no nav item)',
      !(await page.$('#approach')) && !dom.includes('fn handle(req)'),
    );
    const hrefs = await page.$$eval('a[href]', (as) => as.map((a) => a.getAttribute('href')));
    const want = [
      ...socialLinks.map((s) => s.url),
      ...projects.map((p) => p.githubUrl),
      ...[...featuredCertificates, ...otherCertificates].filter((c) => c.url).map((c) => c.url),
      links.cv,
      ...navSections.map((s) => `#${s.hash}`),
    ];
    for (const h of new Set(want)) check('links', h.slice(0, 90), hrefs.includes(h));
    const cvAnchors = await page.$$eval(`a[href="${links.cv}"]`, (as) =>
      as.map((a) => a.getAttribute('download')),
    );
    check(
      'links',
      'CV anchors download as Mazen_Matran_CV.pdf',
      cvAnchors.length >= 2 && cvAnchors.every((d) => d === links.cvDownloadName),
    );
    const extTargets = await page.$$eval('a[href^="http"]', (as) =>
      as.every((a) => a.target === '_blank' && a.rel.includes('noopener')),
    );
    check('links', 'external links open in new tab with noopener', extTargets);
  }
  await page.close();
}

// 3: assets — every image in the registry and every public file
{
  const page = await freshPage();
  await scrollThrough(page);
  const imgs = await page.$$eval('img', (els) => els.map((e) => e.currentSrc || e.src));
  for (const src of imgs) {
    if (src.startsWith('data:')) {
      check('assets', 'img (inlined data: URL)', true);
      continue;
    }
    const r = await page.request.get(src);
    check('assets', `img ${decodeURIComponent(src.replace(BASE, '/'))}`, r.ok());
  }
  for (const f of [
    'cv.pdf',
    'favicon.png',
    'favicon.svg',
    'manifest.json',
    'robots.txt',
    'sitemap.xml',
    'og-image.png',
    'icons/Icon-192.png',
    'icons/Icon-512.png',
    'icons/Icon-maskable-192.png',
    'icons/Icon-maskable-512.png',
  ]) {
    const r = await page.request.get(BASE + f);
    check('assets', `/${f}`, r.ok());
  }
  const allBroken = await page.$$eval(
    'img',
    (els) => els.filter((e) => e.complete && e.naturalWidth === 0).length,
  );
  check('assets', 'no broken <img> after scroll-through', allBroken === 0, `${allBroken} broken`);
  await page.close();
}

// 4: interactions
{
  const page = await freshPage();
  // Hero CTA → projects, NetButton badge
  await page.getByRole('button', { name: ui.en.heroCtaWork }).click();
  await page.waitForTimeout(250);
  check(
    'interaction',
    'NetButton handshake (busy state)',
    (await page.getByRole('button', { name: ui.en.heroCtaWork }).getAttribute('aria-busy')) === 'true',
  );
  await page.waitForTimeout(1600);
  const top = await page.evaluate(() => document.getElementById('projects').getBoundingClientRect().top);
  check('interaction', '"See My Work" scrolls to #projects', Math.abs(top) < 40, `top=${top}`);
  check('interaction', 'hash becomes #projects', (await page.evaluate(() => location.hash)) === '#projects');

  // Nav click + active state
  await page
    .getByRole('navigation', { name: 'Primary' })
    .getByRole('link', { name: ui.en.nav.about })
    .click();
  await page.waitForTimeout(1500);
  check(
    'interaction',
    'nav About → #about with aria-current',
    (await page.evaluate(() => location.hash)) === '#about' &&
      (await page
        .getByRole('navigation', { name: 'Primary' })
        .getByRole('link', { name: ui.en.nav.about })
        .getAttribute('aria-current')) === 'true',
  );

  // Lightbox on a certificate
  await page.getByRole('button', { name: /View full size: Bachelor/ }).click();
  await page.waitForTimeout(300);
  check('interaction', 'certificate lightbox opens', await page.locator('dialog[open] img').isVisible());
  const first = await page.locator('dialog[open] img').getAttribute('alt');
  await page.keyboard.press('ArrowRight');
  const second = await page.locator('dialog[open] img').getAttribute('alt');
  check('interaction', 'lightbox ArrowRight steps', first !== second, `${first} → ${second}`);
  await page.screenshot({ path: 'screenshots/new/feature-lightbox.png' });
  await page.keyboard.press('Escape');
  check('interaction', 'lightbox Esc closes', (await page.locator('dialog[open]').count()) === 0);

  // Project expand / collapse
  const toggle = page.getByRole('button', { name: /GET \/projects\/helpdesk-system/ });
  await toggle.click();
  check(
    'interaction',
    'project expands (aria-expanded)',
    (await toggle.getAttribute('aria-expanded')) === 'true',
  );
  check(
    'interaction',
    'overview visible when expanded',
    await page.getByText(projects[0].overview.slice(0, 40)).isVisible(),
  );
  await page.getByRole('button', { name: /GET \/projects\/outfitly-app/ }).click();
  check(
    'interaction',
    'only one project open at a time',
    (await toggle.getAttribute('aria-expanded')) === 'false',
  );
  await page.locator('h4:visible', { hasText: ui.en.projectGallery }).scrollIntoViewIfNeeded();
  await page.screenshot({ path: 'screenshots/new/feature-project-expanded.png' });
  await page.getByRole('button', { name: new RegExp(ui.en.backToProjects) }).click();
  check(
    'interaction',
    '"Back to Projects" collapses',
    (await page
      .getByRole('button', { name: /GET \/projects\/outfitly-app/ })
      .getAttribute('aria-expanded')) === 'false',
  );

  // CV download
  const dlPromise = page.waitForEvent('download');
  await page.evaluate(() => window.scrollTo({ top: 0, behavior: 'instant' }));
  await page.getByRole('link', { name: ui.en.downloadCvButton }).click();
  const dl = await dlPromise;
  check(
    'interaction',
    'hero CV downloads as Mazen_Matran_CV.pdf',
    dl.suggestedFilename() === 'Mazen_Matran_CV.pdf',
  );
  await page.waitForTimeout(1000);
  check('interaction', 'CV button shows "200 OK · cv.pdf"', await page.getByText(wire.cvDone).isVisible());

  // Empty click ping + 429 rate limit
  await page.waitForTimeout(1500);
  await page.mouse.click(1240, 450);
  await page.waitForTimeout(120);
  const pingTxt = await page.locator('.z-effects').first().textContent();
  check(
    'interaction',
    'empty click spawns a ping label',
    /ping \d+ms|ICMP echo reply|TTL=64|404: nothing here/.test(pingTxt ?? ''),
    pingTxt,
  );
  for (let i = 0; i < 9; i++) await page.mouse.click(1240, 450 + i);
  await page.waitForTimeout(100);
  check(
    'interaction',
    '>8 clicks in 2.5s → 429 toast',
    await page.getByText(wire.toasts.rateLimited).first().isVisible(),
  );

  // Redirect badge on an external link (popup opens)
  const popup = ctx.waitForEvent('page');
  await page.getByRole('link', { name: /Wa7ze/ }).first().click();
  const pop = await popup;
  check('interaction', 'GitHub tile opens new tab', pop.url().includes('github.com/Wa7ze'));
  await pop.close();
  check(
    'interaction',
    'redirect badge "301 Moved Permanently"',
    await page.getByText(wire.badges.redirect).first().isVisible(),
  );

  // Teardown at the end of the page
  await scrollBottom(page);
  await page.waitForTimeout(3200);
  check(
    'interaction',
    'teardown card visible at page end',
    await page.getByText(wire.teardown.closedTitle).isVisible(),
  );
  check(
    'interaction',
    'latency freezes to "Round trip"',
    await page.getByText(/Round trip: \d\.\d\ds/).isVisible(),
  );
  await page.screenshot({ path: 'screenshots/new/feature-teardown.png' });
  await page.getByRole('button', { name: wire.teardown.keepAlive }).click();
  await page.waitForTimeout(1800);
  check('interaction', 'Keep-Alive scrolls to top', (await page.evaluate(() => window.scrollY)) < 5);
  await page.close();
}

// Terminal
{
  const page = await freshPage();
  await page.keyboard.press('Backquote');
  const term = page.getByRole('dialog', { name: 'Terminal' });
  await term.waitFor();
  check('terminal', 'backquote opens terminal', await term.isVisible());
  check('terminal', 'welcome line', await term.getByText('type help to list commands').isVisible());
  const run = async (cmd) => {
    await page.locator('#terminal-input').fill(cmd);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(60);
    return norm((await term.textContent()) ?? '');
  };
  let out = await run('help');
  check(
    'terminal',
    'help',
    out.includes('open github|linkedin|cv, history, clear, sudo hire <anything>, exit'),
  );
  out = await run('ls');
  check(
    'terminal',
    'ls (approach hidden)',
    out.includes('home about skills projects experience contact'.replace(/ /g, '  ').replace(/\s+/g, ' ')) &&
      !out.includes('approach'),
  );
  out = await run('ls projects');
  check(
    'terminal',
    'ls projects',
    out.includes('helpdesk-system (Python, FastAPI, PostgreSQL, React, TypeScript)'),
  );
  out = await run('cat outfitly-app');
  check('terminal', 'cat <slug>', out.includes('repo: https://github.com/Wa7ze/outfitly-3'));
  out = await run('cat nope');
  check('terminal', 'cat unknown', out.includes('cat: nope: no such project'));
  out = await run('cd nowhere');
  check('terminal', 'cd unknown', out.includes('cd: nowhere: no route to host'));
  out = await run('whoami');
  check('terminal', 'whoami', out.includes(profile.summary.en.slice(0, 50)));
  for (const [target, url] of [
    ['github', 'github.com/Wa7ze'],
    ['linkedin', 'linkedin.com/in/mazen-matran'],
    ['cv', '/cv.pdf'],
  ]) {
    const p = ctx.waitForEvent('page', { timeout: 5000 }).catch(() => null);
    out = await run(`open ${target}`);
    const opened = await p;
    check(
      'terminal',
      `open ${target} actually opens (legacy bug fixed)`,
      out.includes(`→ opening ${target}`) && !!opened && opened.url().includes(url),
      opened?.url(),
    );
    await opened?.close();
  }
  out = await run('open foo');
  check('terminal', 'open unknown', out.includes('open: foo: unknown target'));
  out = await run('history');
  check('terminal', 'history', out.includes('1 help'));
  out = await run('sudo rm');
  check('terminal', 'sudo other', out.includes('sudo: rm: command not found'));
  out = await run('xyz');
  check('terminal', 'unknown command', out.includes('command not found: xyz. try help'));
  await page.screenshot({ path: 'screenshots/new/feature-terminal.png' });
  out = await run('clear');
  check('terminal', 'clear', !out.includes('xyz'));
  await run('sudo hire me');
  await page.waitForTimeout(1800);
  check(
    'terminal',
    'sudo hire → closes and routes to #contact',
    (await term.count()) === 0 && (await page.evaluate(() => location.hash)) === '#contact',
  );
  await page.keyboard.press('Backquote');
  await term.waitFor();
  await page.keyboard.press('Escape');
  check('terminal', 'Esc closes', (await term.count()) === 0);
  await page.close();
}

// Hash deep link, 404, debug overlay, story stage
{
  const page = await freshPage(`${BASE}#experience`);
  await page.waitForTimeout(400);
  const top = await page.evaluate(() => document.getElementById('experience').getBoundingClientRect().top);
  check('routing', 'load with #experience jumps there', Math.abs(top) < 40, `top=${top}`);

  const stage = await page.evaluate(() => {
    const el = document.getElementById('story-stage')?.parentElement;
    if (!el) return null;
    const cs = getComputedStyle(el);
    const content = getComputedStyle(document.querySelector('.z-content'));
    return {
      position: cs.position,
      pe: cs.pointerEvents,
      z: Number(cs.zIndex),
      contentZ: Number(content.zIndex),
      hidden: el.getAttribute('aria-hidden'),
    };
  });
  check(
    'story',
    'StoryStage fixed, behind content, pointer-events none, aria-hidden',
    stage &&
      stage.position === 'fixed' &&
      stage.pe === 'none' &&
      stage.z < stage.contentZ &&
      stage.hidden === 'true',
    JSON.stringify(stage),
  );
  check(
    'story',
    'StoryStage contains one full-screen <svg>',
    (await page.$$eval('#story-stage', (s) => s.length)) === 1,
  );
  check('story', 'no debug overlay without ?debug', (await page.getByText('story debug').count()) === 0);
  await page.close();

  const dbg = await freshPage(`${BASE}?debug`);
  await dbg.waitForTimeout(500);
  check('story', '?debug shows overlay', await dbg.getByText('story debug').isVisible());
  check(
    'story',
    '?debug shows ScrollTrigger markers',
    (await dbg.locator('.gsap-marker-start, .gsap-marker-scroller-start').count()) > 0,
  );
  await dbg.evaluate(() =>
    window.scrollTo({ top: (document.documentElement.scrollHeight - innerHeight) / 2, behavior: 'instant' }),
  );
  await dbg.waitForTimeout(600);
  const midY = await dbg.evaluate(() => scrollY);
  const prog = Number((await dbg.locator('text=progress').locator('span').textContent()) ?? 0);
  check(
    'story',
    'master timeline follows scroll (≈0.5 at mid-page)',
    Math.abs(prog - 0.5) < 0.05,
    `progress=${prog}`,
  );
  await dbg.getByRole('checkbox', { name: 'detach from scroll' }).check();
  const box = await dbg.getByRole('slider', { name: 'Scrub master timeline' }).boundingBox();
  await dbg.mouse.click(box.x + box.width * 0.8, box.y + box.height / 2); // real input, like a user drag
  await dbg.waitForTimeout(200);
  const prog2 = Number((await dbg.locator('text=progress').locator('span').textContent()) ?? 0);
  check(
    'story',
    'detached slider scrubs timeline directly',
    Math.abs(prog2 - 0.8) < 0.05 && Math.abs((await dbg.evaluate(() => scrollY)) - midY) < 2,
    `progress=${prog2}`,
  );
  await dbg.screenshot({ path: 'screenshots/new/feature-debug.png' });
  await dbg.close();

  // Unknown paths get a real 404 status (Netlify then serves dist/404.html as the body; vite preview
  // returns an empty body), so the page content is checked at /404.html directly.
  const nf = await ctx.newPage();
  const resp = await nf.request.get(`${BASE}some/missing/page`);
  check('routing', 'unknown path → HTTP 404', resp.status() === 404, `status=${resp.status()}`);
  await nf.goto(`${BASE}404.html`, { waitUntil: 'networkidle' });
  const nfText = norm((await nf.textContent('body')) ?? '');
  check(
    'routing',
    '404 page content (code, body, real path line, GET / button)',
    nfText.includes('404') &&
      nfText.includes(wire.notFound.body) &&
      nfText.includes('GET /404.html → no route to host') &&
      (await nf.getByRole('button', { name: wire.notFound.home }).count()) === 1,
    nfText.slice(0, 160),
  );
  await nf.getByRole('button', { name: wire.notFound.home }).click();
  await nf.waitForURL(BASE, { timeout: 4000 }).catch(() => {});
  check('routing', '404 "GET /" button returns home', nf.url() === BASE, nf.url());
  await nf.goto(`${BASE}404.html`, { waitUntil: 'networkidle' });
  await nf.screenshot({ path: 'screenshots/new/feature-404.png' });
  await nf.close();
}

// Idle states with a fake clock
{
  const page = await freshPage(BASE, { clock: true });
  await page.clock.runFor(15_100); // ping appears at 15s and lives 800ms
  check(
    'idle',
    '15s heartbeat ping',
    /ping \d+ms|ICMP echo reply|TTL=64|404: nothing here/.test(
      (await page.locator('.z-effects').first().textContent()) ?? '',
    ),
  );
  await page.clock.runFor(30_000); // → 45.1s
  check(
    'idle',
    '45s → "408 Request Timeout" toast',
    await page.getByText(wire.toasts.timeout).first().isVisible(),
  );
  check(
    'idle',
    '45s → page dims to 90%',
    (await page.evaluate(() => document.getElementById('root').style.opacity)) === '0.9',
  );
  await page.mouse.move(400, 400);
  await page.mouse.move(420, 420);
  check(
    'idle',
    'activity → "Connection re-established"',
    await page.getByText(wire.toasts.reconnected).first().isVisible(),
  );
  await page.close();
}

// Keyboard + mobile menu + reduced motion
{
  const page = await freshPage();
  await page.keyboard.press('Tab');
  check(
    'a11y',
    'first Tab focuses visible "Skip to content"',
    (await page.evaluate(() => document.activeElement?.textContent)) === wire.skipToContent,
  );
  await page.keyboard.press('Enter');
  check(
    'a11y',
    'skip link moves focus to <main>',
    (await page.evaluate(() => document.activeElement?.id)) === 'main',
  );
  await page.close();

  const mctx = await browser.newContext({ viewport: { width: 375, height: 812 }, hasTouch: true });
  const m = await mctx.newPage();
  await m.goto(BASE, { waitUntil: 'networkidle' });
  await m.waitForFunction(() => !document.getElementById('boot'));
  const burger = m.getByRole('button', { name: ui.en.openMenu });
  await burger.click();
  check(
    'mobile',
    'hamburger opens menu (aria-expanded)',
    (await m.getByRole('button', { name: ui.en.closeMenu }).getAttribute('aria-expanded')) === 'true',
  );
  await m.screenshot({ path: 'screenshots/new/feature-mobile-menu.png' });
  await m.locator('#mobile-menu').getByRole('link', { name: ui.en.nav.skills }).click();
  await m.waitForTimeout(1500);
  check(
    'mobile',
    'menu item navigates and closes menu',
    (await m.locator('#mobile-menu').count()) === 0 && (await m.evaluate(() => location.hash)) === '#skills',
  );
  const overflow = await m.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  check('mobile', 'no horizontal overflow at 375px', !overflow);
  await mctx.close();

  const rctx = await browser.newContext({ viewport: { width: 1280, height: 900 }, reducedMotion: 'reduce' });
  const r = await rctx.newPage();
  await r.goto(BASE, { waitUntil: 'networkidle' });
  check('motion', 'reduced motion: no boot loader', (await r.$('#boot')) === null);
  check(
    'motion',
    'reduced motion: sections visible without reveal',
    await r.evaluate(() =>
      [...document.querySelectorAll('[data-reveal]')].every((e) => getComputedStyle(e).opacity === '1'),
    ),
  );
  check(
    'motion',
    'reduced motion: Lenis not active',
    !(await r.evaluate(() => document.documentElement.classList.contains('lenis'))),
  );
  await rctx.close();
}

// Extras: logo long-press, EOF marker, custom cursor, reduced-motion NetButton, head meta, boot text
{
  const page = await freshPage();
  const logo = page.getByRole('link', { name: wire.a11y.homeLink });
  const lb = await logo.boundingBox();
  await page.mouse.move(lb.x + lb.width / 2, lb.y + lb.height / 2);
  await page.mouse.down();
  await page.waitForTimeout(650);
  await page.mouse.up();
  const longPressOpened = await page
    .getByRole('dialog', { name: 'Terminal' })
    .waitFor({ timeout: 3000 }) // the terminal chunk is lazy-loaded on first open
    .then(() => true)
    .catch(() => false);
  check('terminal', 'long-press on <mm/> logo opens terminal', longPressOpened);
  await page.keyboard.press('Escape');

  check(
    'cursor',
    'mouse use enables custom cursor (system cursor hidden)',
    await page.evaluate(() => document.documentElement.classList.contains('custom-cursor')),
  );
  check(
    'cursor',
    'cursor canvas is decorative and non-interactive',
    await page.evaluate(() => {
      const c = document.querySelector('canvas.z-cursor');
      return !!c && c.getAttribute('aria-hidden') === 'true' && getComputedStyle(c).pointerEvents === 'none';
    }),
  );

  await scrollBottom(page);
  await page.waitForTimeout(800);
  await page.mouse.move(640, 400);
  for (let i = 0; i < 4; i++) await page.mouse.wheel(0, 120);
  await page.waitForTimeout(60);
  const eof = await page.evaluate(() => {
    const el = [...document.querySelectorAll('footer p')].find((p) => p.textContent === 'EOF');
    return el ? Number(getComputedStyle(el).opacity) : -1;
  });
  check('interaction', 'overscroll at bottom reveals the EOF marker', eof > 0.2, `opacity=${eof}`);
  await page.waitForTimeout(1200);
  const eofAfter = await page.evaluate(() =>
    Number(
      getComputedStyle([...document.querySelectorAll('footer p')].find((p) => p.textContent === 'EOF'))
        .opacity,
    ),
  );
  check('interaction', 'EOF marker springs back', eofAfter < 0.05, `opacity=${eofAfter}`);
  await page.close();

  const tctx = await browser.newContext({ viewport: { width: 1280, height: 900 }, hasTouch: true });
  const tp = await tctx.newPage();
  await tp.goto(BASE, { waitUntil: 'networkidle' });
  await tp.waitForFunction(() => !document.getElementById('boot'));
  await tp.touchscreen.tap(1200, 600);
  check(
    'cursor',
    'touch input leaves the system cursor alone',
    !(await tp.evaluate(() => document.documentElement.classList.contains('custom-cursor'))),
  );
  await tctx.close();

  const rctx = await browser.newContext({ viewport: { width: 1280, height: 900 }, reducedMotion: 'reduce' });
  const r = await rctx.newPage();
  await r.goto(BASE, { waitUntil: 'networkidle' });
  const btn = r.getByRole('button', { name: ui.en.heroCtaContact });
  await btn.click();
  check(
    'motion',
    'reduced motion: NetButton skips the handshake',
    (await btn.getAttribute('aria-busy')) !== 'true',
  );
  await r.waitForTimeout(150);
  const contactTop = await r.evaluate(() => document.getElementById('contact').getBoundingClientRect().top);
  check('motion', 'reduced motion: nav jumps instantly', Math.abs(contactTop) < 40, `top=${contactTop}`);
  check(
    'motion',
    'reduced motion: no custom cursor',
    !(await r.evaluate(() => document.documentElement.classList.contains('custom-cursor'))),
  );
  await rctx.close();

  const html = await (await ctx.request.get(BASE)).text();
  const meta = [
    ['<title>', '<title>Mazen Matran | Portfolio</title>'],
    ['description', 'content="Mazen Matran | Software Engineer building with Flutter, Python, and AI."'],
    ['og:title', 'property="og:title" content="Mazen Matran | Software Engineer"'],
    [
      'og:description',
      'property="og:description" content="Building innovative solutions with Flutter, Python, and AI."',
    ],
    ['og:type', 'property="og:type" content="website"'],
    ['og:url', 'property="og:url" content="https://mazenportfolio.netlify.app/"'],
    ['og:image', 'property="og:image" content="https://mazenportfolio.netlify.app/og-image.png"'],
    ['twitter:card', 'name="twitter:card" content="summary_large_image"'],
    ['canonical', 'rel="canonical" href="https://mazenportfolio.netlify.app/"'],
    ['theme-color', 'name="theme-color" content="#0B1426"'],
    ['viewport', 'content="width=device-width, initial-scale=1"'],
    ['mobile-web-app-capable', 'name="mobile-web-app-capable" content="yes"'],
    ['apple status bar', 'name="apple-mobile-web-app-status-bar-style" content="black"'],
    ['apple-touch-icon', 'rel="apple-touch-icon" href="/icons/Icon-192.png"'],
    ['favicon', 'rel="icon" type="image/png" href="/favicon.png"'],
    ['manifest link', 'rel="manifest" href="/manifest.json"'],
    ['noscript text', 'Mazen Matran | Software Engineer. This site requires JavaScript to run.'],
    ['crawler summary', '<h1>Mazen Matran</h1>'],
    ['boot: resolving DNS', 'resolving DNS'],
    ['boot: TLS handshake', "'TLS handshake…'"],
    ['boot: connecting', "'connecting'"],
    ['no analytics', null],
  ];
  for (const [name, needle] of meta) {
    if (needle === null) check('seo', name, !/gtag|googletagmanager|analytics|plausible|umami/i.test(html));
    else check('seo', name, html.includes(needle));
  }
  const manifest = await (await ctx.request.get(BASE + 'manifest.json')).json();
  check(
    'seo',
    'manifest: navy colours + real description + 4 icons',
    manifest.background_color === '#0B1426' &&
      manifest.theme_color === '#0B1426' &&
      !manifest.description.includes('Flutter project') &&
      manifest.icons.length === 4,
  );
  const sitemap = await (await ctx.request.get(BASE + 'sitemap.xml')).text();
  const robots = await (await ctx.request.get(BASE + 'robots.txt')).text();
  check(
    'seo',
    'sitemap lists the live URL',
    sitemap.includes('<loc>https://mazenportfolio.netlify.app/</loc>'),
  );
  check(
    'seo',
    'robots.txt allows all + points to sitemap',
    robots.includes('Allow: /') && robots.includes('Sitemap: https://mazenportfolio.netlify.app/sitemap.xml'),
  );
}

for (const w of [768, 1920]) {
  const p = await ctx.newPage();
  await p.setViewportSize({ width: w, height: 900 });
  await p.goto(BASE, { waitUntil: 'networkidle' });
  check(
    'responsive',
    `no horizontal overflow at ${w}px`,
    !(await p.evaluate(() => document.documentElement.scrollWidth > window.innerWidth)),
  );
  await p.close();
}

const ownFailures = failedRequests.filter(
  (u) => u.includes(new URL(BASE).host) && !u.includes('some/missing/page'),
);
check(
  'assets',
  'no failed (>=400) same-origin requests (except the intentional 404 probe)',
  ownFailures.length === 0,
  ownFailures.join(', '),
);
console.log(
  'external non-2xx (informational):',
  failedRequests.filter((u) => !u.includes(new URL(BASE).host)).join(', ') || 'none',
);

await browser.close();
const failed = results.filter((r) => !r.ok);
await writeFile('screenshots/verify.json', JSON.stringify(results, null, 2));
console.log(`\n${results.length - failed.length}/${results.length} checks passed`);
if (failed.length) {
  console.log('FAILED:');
  for (const f of failed) console.log(`  [${f.group}] ${f.name} ${f.detail}`);
}
