// Screenshots of the legacy Flutter build, one per viewport while scrolling.
// Usage: node scripts/shoot-legacy.mjs [baseUrl=http://localhost:4174/] [outDir=screenshots/legacy]
import { mkdir } from 'node:fs/promises';
import { join } from 'node:path';
import { chromium } from 'playwright-core';

const [base = 'http://localhost:4174/', outDir = 'screenshots/legacy'] = process.argv.slice(2);
await mkdir(outDir, { recursive: true });
const browser = await chromium.launch({
  executablePath: process.env.CHROME_PATH ?? 'C:/Program Files/Google/Chrome/Application/chrome.exe',
});
// Flutter paints to a canvas and does not honour the URL hash on load, so scroll with real wheel
// input and capture one screenshot per viewport until the page stops moving.
for (const width of [1280, 375]) {
  const page = await browser.newPage({ viewport: { width, height: width < 700 ? 812 : 900 } });
  await page.goto(base, { waitUntil: 'networkidle' });
  await page.waitForTimeout(4500); // boot loader + CanvasKit first frame
  await page.mouse.move(width / 2, 450);
  let previous = null;
  for (let i = 0; i < 40; i++) {
    const png = await page.screenshot();
    if (previous && png.equals(previous)) break; // reached the bottom
    const file = join(outDir, `${width}-${String(i).padStart(2, '0')}.png`);
    await page.screenshot({ path: file });
    console.log(file);
    previous = png;
    await page.mouse.wheel(0, width < 700 ? 700 : 800);
    await page.waitForTimeout(1200);
  }
  await page.close();
}
await browser.close();
