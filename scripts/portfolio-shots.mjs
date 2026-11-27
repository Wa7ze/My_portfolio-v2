// Screenshots of THIS site for the "Portfolio Website" project gallery (same filenames as the legacy
// gallery: image, image copy, image copy 2). Run against a running preview:
//   node scripts/portfolio-shots.mjs [baseUrl]
import { mkdir } from 'node:fs/promises';
import { join } from 'node:path';
import { chromium } from 'playwright-core';
import sharp from 'sharp';

const BASE = process.argv[2] ?? 'http://localhost:4173/';
const root = new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');
const out = join(root, 'src/assets/images/portfoilo-website');
await mkdir(out, { recursive: true });

const browser = await chromium.launch({
  executablePath: process.env.CHROME_PATH ?? 'C:/Program Files/Google/Chrome/Application/chrome.exe',
});
const page = await browser.newPage({ viewport: { width: 1920, height: 905 }, reducedMotion: 'reduce' });

async function shot(name, setup) {
  await page.goto(BASE, { waitUntil: 'networkidle' });
  await page.evaluate(() => document.fonts.ready);
  await setup();
  await page.waitForTimeout(500);
  const png = await page.screenshot();
  await sharp(png)
    .resize({ width: 1600 })
    .webp({ quality: 80 })
    .toFile(join(out, `${name}.webp`));
  await sharp(png)
    .resize({ width: 480 })
    .webp({ quality: 72 })
    .toFile(join(out, `${name}-480.webp`));
  console.log(name);
}

await shot('image', async () => {}); // hero
await shot('image copy', async () => {
  await page.getByRole('button', { name: 'AR', exact: true }).first().click(); // Arabic / RTL
  await page.evaluate(() => document.getElementById('skills')?.scrollIntoView({ behavior: 'instant' }));
});
await shot('image copy 2', async () => {
  await page.getByRole('button', { name: /GET \/projects\/helpdesk-system/ }).click(); // expanded case study
  await page.evaluate(() => {
    const el = document.getElementById('projects');
    window.scrollTo({ top: (el?.getBoundingClientRect().top ?? 0) + scrollY + 120, behavior: 'instant' });
  });
});
await browser.close();
