# DEPLOY.md: switching mazenportfolio.netlify.app to the new site

The Netlify site **mazenportfolio.netlify.app** currently builds the Flutter app from the GitHub repo
`Wa7ze/My_portfolio`. These steps point the same site at this repo (`Wa7ze/My_portfolio-v2`), so the
URL, any custom domain and the HTTPS certificate all stay the same. Claude does not change Netlify
settings; these steps are for you to run.

Everything the build needs is in `netlify.toml` (build command, publish directory, Node version,
legacy redirects, cache headers), so the dashboard only needs the repo link changed.

## Before you start

1. Commit and push this repo to `main` on GitHub (`Wa7ze/My_portfolio-v2`).
   `legacy/` is gitignored and will not be pushed.
2. Locally: `npm ci && npm run build`. The build should finish with no errors.

## Option A: relink the existing site (recommended)

1. Netlify dashboard → **Sites → mazenportfolio** → **Site configuration → Build & deploy →
   Continuous deployment → Repository** → **Manage repository → Link to a different repository**.
2. Choose GitHub → `Wa7ze/My_portfolio-v2`, branch `main`.
3. Under **Build settings**, clear any dashboard overrides so `netlify.toml` wins:
   - Build command: _(empty)_, or `npm run build`
   - Publish directory: _(empty)_, or `dist`
   - Base directory: _(empty)_
4. Under **Environment variables**, remove any Flutter-specific variables if you added any. The Node
   version comes from `netlify.toml` (`NODE_VERSION = "24"`).
5. **Deploys → Trigger deploy → Clear cache and deploy site.** Clearing the cache matters, because
   the old cache contains the Flutter SDK.
6. Check the deploy log. It should show `npm run build` and publish `dist`.

## Option B: deploy preview first (safer)

1. Create a **new** Netlify site from `Wa7ze/My_portfolio-v2` (it gets a random `*.netlify.app` URL).
2. Check it using the list below.
3. Then do Option A on the real site and delete the temporary one.

## After the deploy, check

- `https://mazenportfolio.netlify.app/` loads the new site, and `/#projects` jumps to projects.
- `/cv.pdf` downloads (and the hero button saves it as `Mazen_Matran_CV.pdf`).
- `/work/helpdesk-system` returns a **301** to `/#projects`. `/about` → `/#about`, `/contact` → `/#contact`.
- `/anything-else` shows the 404 page **with HTTP status 404**
  (`curl -I https://mazenportfolio.netlify.app/nope`).
- `/robots.txt`, `/sitemap.xml`, `/manifest.json` and `/og-image.png` load.
- Share preview: paste the URL into https://www.opengraph.xyz/ (or LinkedIn's Post Inspector) to
  refresh cached previews of the old site.
- Optional: in Google Search Console, submit `https://mazenportfolio.netlify.app/sitemap.xml`.

## Rollback

Netlify → **Deploys** → choose the last Flutter deploy → **Publish deploy**. That restores the old
site instantly. Then relink the old repo if you want builds to come from it again.
