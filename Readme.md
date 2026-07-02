# shouchaoben

Static landing site and browse UI for the READCHINA *Shouchaoben — San Jin Nan Jing Cheng* edition.

Published at [https://readchina.github.io/shouchaoben/](https://readchina.github.io/shouchaoben/).

The TEI data live in [shouchaoben-data](https://github.com/readchina/shouchaoben-data); the TEI Publisher application that generates this site is [shouchaoben-app](https://github.com/readchina/shouchaoben-app).

## What is in this repo

Pre-rendered HTML, CSS, images, and supporting assets produced by the app’s static generator (`output/` collection). GitHub Pages serves the repository root as the site; `.nojekyll` disables Jekyll processing.

### eXist artifacts

`controller.xql` and `output-controller.xql` are **eXist routing controllers** — they only matter when `output/` is served inside eXist. GitHub Pages ignores them; they are listed in `.gitignore` so they are not committed after each export.

The `templates/` folder at the repo root is likewise unparsed Jinks source copied during export, not rendered HTML. It is gitignored for the same reason.

**Keep** `index.jsonl` — the static search UI fetches it client-side.

## Deployment

Pushing to `main` runs `.github/workflows/gh-pages.yml`, which **deploys** the committed files to GitHub Pages. It does **not** regenerate the site from TEI Publisher.

Repository settings must use **GitHub Actions** as the Pages source (not “Deploy from a branch”).

## Regenerating the static site

Regeneration is **manual** — only the deploy step is automated.

### 1. Generate on the server

With the app running (Docker or eXist), trigger static generation:

```bash
curl -u admin: \
  -X POST 'http://localhost:8080/exist/apps/scb_sjnjc/api/actions/static?root=/db/apps/scb_sjnjc'
```

The generated files appear under `/db/apps/scb_sjnjc/output` in eXist (or `output/` inside an app xar export).

### 2. Export `output/`

Either:

- download the `output` collection from eXist, or
- extract `output/` from a full app backup xar.

### 3. Rewrite paths for GitHub Pages

The generator writes paths for the live app (`/exist/apps/scb_sjnjc/output` or `http://localhost:8080/...`). Before copying into this repo, rewrite them to the Pages base path `/shouchaoben`:

```bash
SITE_ROOT=/path/to/shouchaoben
OUTPUT=/path/to/exported/output

rsync -a --delete "$OUTPUT/" "$SITE_ROOT/"

find "$SITE_ROOT" -type f \( -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.json' \) \
  -exec sed -i '' \
    -e 's|/exist/apps/scb_sjnjc/output|/shouchaoben|g' \
    -e 's|http://localhost:8080/exist/apps/scb_sjnjc/output|/shouchaoben|g' \
    {} +

touch "$SITE_ROOT/.nojekyll"

# HTML requires explicit </script> tags (self-closing <script/> breaks the DOM)
find "$SITE_ROOT" -name '*.html' -exec perl -pi -e 's/<script([^>]*)\/>/<script$1><\/script>/g' {} +
```

On Linux, use `sed -i` instead of `sed -i ''`.

### 4. Commit and push

Review the diff, commit, and push to `main`. GitHub Pages will serve the updated files.

### App customizations

Templates, ODDs, CSS, and other files skipped by `jinks apply` must be kept in sync between [shouchaoben-app](https://github.com/readchina/shouchaoben-app) and the running server before regenerating. See that repo’s `config.json` `skip` list.
