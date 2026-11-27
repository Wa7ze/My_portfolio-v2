// Renders public/og-image.png (1200×630) from an HTML card. Run: node scripts/og-image.mjs
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { chromium } from 'playwright-core';

const root = new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');
// Fonts are inlined as data URLs (setContent pages cannot read file:// URLs).
const font = async (p) =>
  `data:font/woff2;base64,${(await readFile(join(root, 'node_modules', p))).toString('base64')}`;
const sg = await font('@fontsource-variable/space-grotesk/files/space-grotesk-latin-wght-normal.woff2');
const jb = await font('@fontsource-variable/jetbrains-mono/files/jetbrains-mono-latin-wght-normal.woff2');
const icon = (await readFile(join(root, 'public/favicon.svg'), 'utf8')).replace(
  /<svg /,
  '<svg width="132" height="132" ',
);

const html = `<!doctype html><html><head><style>
@font-face { font-family: SG; src: url(${sg}); font-weight: 300 700; }
@font-face { font-family: JB; src: url(${jb}); font-weight: 100 800; }
* { margin: 0; box-sizing: border-box; }
body { width: 1200px; height: 630px; overflow: hidden; font-family: SG; color: #eaf0fa;
  background: radial-gradient(900px 520px at 88% 8%, rgb(61 224 255 / 0.18), transparent 60%),
              radial-gradient(700px 480px at 0% 100%, rgb(255 181 71 / 0.14), transparent 60%),
              linear-gradient(160deg, #0b1426, #16233f); }
.wrap { position: absolute; inset: 56px; border: 1px solid rgb(61 224 255 / 0.22); border-radius: 28px;
  background: rgb(15 26 49 / 0.55); padding: 64px 72px; display: flex; flex-direction: column; justify-content: center; }
.eyebrow { font-family: JB; font-weight: 700; letter-spacing: .08em; color: #3de0ff; font-size: 22px; }
h1 { font-size: 104px; line-height: 1; letter-spacing: -0.03em; margin-top: 26px; font-weight: 700; }
h2 { font-size: 46px; color: #3de0ff; font-weight: 600; margin-top: 14px; }
p { font-size: 26px; color: #b4c2dc; margin-top: 26px; }
.icon { position: absolute; top: 64px; right: 72px; }
.url { position: absolute; bottom: 52px; right: 72px; font-family: JB; color: #8f9fc0; font-size: 20px; }
</style></head><body><div class="wrap">
<div class="icon">${icon}</div>
<div class="eyebrow">● GET / HTTP/1.1</div>
<h1>Mazen Matran</h1><h2>Software Engineer</h2>
<p>Building innovative solutions with Flutter, Python, and AI.</p>
<div class="url">mazenportfolio.netlify.app</div>
</div></body></html>`;

const browser = await chromium.launch({
  executablePath: process.env.CHROME_PATH ?? 'C:/Program Files/Google/Chrome/Application/chrome.exe',
});
const page = await browser.newPage({ viewport: { width: 1200, height: 630 } });
await page.setContent(html, { waitUntil: 'load' });
await page.evaluate(() => document.fonts.ready);
await page.screenshot({ path: join(root, 'public/og-image.png') });
await browser.close();
console.log('public/og-image.png');
