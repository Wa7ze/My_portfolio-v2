// Screenshot helper (dev only). Uses the installed Chrome via playwright-core.
// Usage: node scripts/shoot.mjs <url> <outDir> [widths=375,768,1280,1920] [locale=en] [mode=full|sections]
import { mkdir } from 'node:fs/promises';
import { join } from 'node:path';
import { chromium } from 'playwright-core';

const [
  url = 'http://localhost:4173/',
  outDir = 'screenshots/new',
  widthsArg = '375,768,1280,1920',
  locale = 'en',
  mode = 'full',
] = process.argv.slice(2);
const widths = widthsArg.split(',').map(Number);
const CHROME = process.env.CHROME_PATH ?? 'C:/Program Files/Google/Chrome/Application/chrome.exe';

await mkdir(outDir, { recursive: true });
const browser = await chromium.launch({ executablePath: CHROME });

for (const width of widths) {
  const page = await browser.newPage({
    viewport: { width, height: width < 700 ? 812 : 900 },
    deviceScaleFactor: 1,
  });
  await page.goto(url, { waitUntil: 'networkidle' });
  await page
    .waitForFunction(() => !document.getElementById('boot'), null, { timeout: 10_000 })
    .catch(() => {});
  if (locale === 'ar') {
    await page
      .getByRole('button', { name: 'AR', exact: true })
      .first()
      .click({ force: true })
      .catch(async () => {
        await page.getByRole('button', { name: /open menu/i }).click();
        await page.getByRole('button', { name: 'AR', exact: true }).click();
      });
    await page.keyboard.press('Escape');
  }
  // Scroll through once so every section's one-time reveal has fired.
  const height = await page.evaluate(() => document.documentElement.scrollHeight);
  for (let y = 0; y <= height; y += 500) {
    await page.evaluate((top) => window.scrollTo({ top, behavior: 'instant' }), y);
    await page.waitForTimeout(40);
  }
  await page.waitForTimeout(3000); // teardown sequence plays at the bottom
  await page.evaluate(() => window.scrollTo({ top: 0, behavior: 'instant' }));
  await page.waitForTimeout(800);

  if (mode === 'full') {
    const file = join(outDir, `${locale}-${width}.png`);
    await page.screenshot({ path: file, fullPage: true });
    console.log(file);
  } else {
    const ids = await page.evaluate(() =>
      [...document.querySelectorAll('main > section, footer#footer')].map((el) => el.id),
    );
    for (const id of ids) {
      await page.evaluate(
        (i) => document.getElementById(i)?.scrollIntoView({ block: 'start', behavior: 'instant' }),
        id,
      );
      await page.waitForTimeout(500);
      const file = join(outDir, `${locale}-${width}-${id}.png`);
      await page.screenshot({ path: file });
      console.log(file);
    }
  }
  await page.close();
}
await browser.close();
