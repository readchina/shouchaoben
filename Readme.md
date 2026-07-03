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

### 3. Fix up the export in a staging directory

The generator writes paths for the live app (`/exist/apps/scb_sjnjc/output` or `http://localhost:8080/...`). Do **all** rewrites in the *exported staging copy* first, then sync into the repo (step 4). Never run these transforms against the repo root — a stray `--delete` there would wipe `.git`, `.github`, `LICENSE`, `Readme.md`, etc.

```bash
export STAGING=/path/to/exported/output   # the exported output/ collection

# Rewrite live-app paths to the Pages base path /shouchaoben, decode %XX
# collection names to Unicode, and fix index.jsonl links — all in one pass.
python3 - <<'PY'
import os, re, urllib.parse, json
from pathlib import Path
root = Path(os.environ["STAGING"])

# --- path rewrite (html/css/js/json/jsonl) ---
exts = {".html", ".css", ".js", ".json", ".jsonl"}
subs = [
    ("http://localhost:8080/exist/apps/scb_sjnjc/output", "/shouchaoben"),
    ("/exist/apps/scb_sjnjc/output", "/shouchaoben"),
]
for dp, _, fns in os.walk(root):
    for fn in fns:
        p = Path(dp) / fn
        if p.suffix.lower() not in exts:
            continue
        try:
            t = o = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for a, b in subs:
            t = t.replace(a, b)
        if t != o:
            p.write_text(t, encoding="utf-8")

# --- decode %XX dir/file names to real Unicode (GitHub Pages decodes URLs once) ---
pct = re.compile(r'%[0-9A-Fa-f]{2}')
for dirpath, dirnames, filenames in os.walk(root, topdown=False):
    p = Path(dirpath)
    for name in dirnames + filenames:
        new = urllib.parse.unquote(name) if pct.search(name) else name
        if new != name:
            (p / name).rename(p / new)

# --- index.jsonl link fixup (client-side search) ---
jsonl = root / "index.jsonl"
if jsonl.exists():
    out = []
    for line in jsonl.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        obj = json.loads(line)
        link = obj.get("link", "")
        if link.startswith("witnesses/TTJ/"):
            link = re.sub(r"^witnesses/TTJ/wit/[acf]/xml/", "witnesses/", link)
            obj["link"] = urllib.parse.unquote(link)
        out.append(json.dumps(obj, ensure_ascii=False))
    jsonl.write_text("\n".join(out) + "\n", encoding="utf-8")
PY

# Safety net for self-closing <script/> (now handled at generation via HTML5
# serialization, so this is normally a no-op — kept in case of stale exports).
export STAGING
python3 - <<'PY'
import os, re
from pathlib import Path
rx = re.compile(r"<script([^>]*)/>")
for dp, _, fns in os.walk(os.environ["STAGING"]):
    for fn in fns:
        if not fn.endswith(".html"):
            continue
        p = Path(dp) / fn
        t = p.read_text(encoding="utf-8")
        n = rx.sub(r"<script\1></script>", t)
        if n != t:
            p.write_text(n, encoding="utf-8")
PY
```

> Pure-Python transforms are used instead of `find … -exec sed/perl … {} +` because the
> `{} +` form probes `sysconf(_SC_ARG_MAX)`, which fails under some sandboxes; Python also
> avoids the macOS/Linux `sed -i ''` vs `sed -i` split.

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
