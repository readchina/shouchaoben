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

### 3. Decode `%XX` directory names in a staging copy

Most fixups are now done **at generation** by the app (`modules/static-generator.xql`), driven by `context.json` → `static.base-path`:

- **Base-path rewrite** — pages are written with `/shouchaoben` instead of `/exist/apps/scb_sjnjc/output` (`sg:rebase`, folded into the HTML5 pass).
- **`index.jsonl` links** — witness links are stripped of the `TTJ/wit/<x>/xml/` source prefix and percent-decoded (`sg:fix-search-index`).
- **Explicit `</script>`** — the HTML5 serialization pass (`sg:htmlify`) already emits well-formed tags.

The only transform left is renaming the `%XX`-encoded collection directories to real Unicode (eXist stores collection names percent-encoded; GitHub Pages decodes URLs once). Do it in the *exported staging copy* — never against the repo root, so a stray `--delete` can't wipe `.git`, `.github`, `LICENSE`, `Readme.md`, etc.

```bash
export STAGING=/path/to/exported/output   # the exported output/ collection

python3 - <<'PY'
import os, re, urllib.parse
from pathlib import Path
root = Path(os.environ["STAGING"])
pct = re.compile(r'%[0-9A-Fa-f]{2}')
for dirpath, dirnames, filenames in os.walk(root, topdown=False):
    p = Path(dirpath)
    for name in dirnames + filenames:
        new = urllib.parse.unquote(name) if pct.search(name) else name
        if new != name:
            (p / name).rename(p / new)
PY
```

> If a stale export still contains `/exist/...` paths or self-closing `<script/>` tags, the
> app-side fixes were not deployed before generating — re-upload `context.json` and
> `modules/static-generator.xql`, clear the query cache, and regenerate rather than
> reintroducing the old client-side `sed`/`perl` passes.

### 4. Sync into the repo — non-destructively

Mirror the fixed-up staging copy into the repo with `rsync --delete`, but **exclude every
repo-only file** so Git metadata, CI, license, and this README are never deleted. `rsync`
excludes are protected from deletion as well as transfer:

```bash
SITE_ROOT=/path/to/shouchaoben
STAGING=/path/to/exported/output

# Dry-run first — review adds/updates/deletes before writing anything.
rsync -a --delete --omit-dir-times --no-perms -n --itemize-changes \
  --exclude='/.git/'  --exclude='/.github/' --exclude='/.gitignore' \
  --exclude='/.nojekyll' --exclude='/LICENSE' --exclude='/Readme.md' \
  --exclude='/.cursor/' --exclude='/.codacy/' --exclude='/.claude/' --exclude='/.moderne/' \
  --exclude='.DS_Store' \
  "$STAGING/" "$SITE_ROOT/"

# Re-run without -n to apply.
touch "$SITE_ROOT/.nojekyll"
```

`--omit-dir-times`/`--no-perms` avoid `utimensat`/permission errors on the destination root
under restricted filesystems. A second dry-run should report zero remaining transfers
(idempotent).

### 5. Commit and push

Review the diff, commit, and push to `main`. GitHub Pages will serve the updated files.

### App customizations

Templates, ODDs, CSS, and other files skipped by `jinks apply` must be kept in sync between [shouchaoben-app](https://github.com/readchina/shouchaoben-app) and the running server before regenerating. See that repo’s `config.json` `skip` list.
