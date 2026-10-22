# Physics & Mathematics Notes

Short LaTeX notes, published on GitHub Pages as HTML (via lwarp + MathJax) and PDF.

## Layout

```text
index.html            generated list of all notes
notes/<name>/
  <name>.tex          source
  index.html          generated HTML page
  <name>.pdf          generated PDF
  lwarp*.css          generated styles
```

## Adding a note

1. Create `notes/<name>/<name>.tex`. Copy `notes/dirac/dirac.tex` as a template; the important parts are:
   - `\usepackage[mathjax]{lwarp}` right after `\documentclass`
   - `\title{...}` (used as page title and in the root index)
   - `\HTMLDescription{...}` (meta description for search engines)
   - the `warpHTML` block with the "Download PDF" link
2. Build and commit the outputs:

```bash
./build.sh          # all notes
./build.sh dirac    # only one note
git add -A && git commit -m "Add note" && git push
```

Requires TeX Live with `lwarp`, `lualatex` and `rsync`.

## Preview locally

```bash
python3 -m http.server
# open http://localhost:8000/
```

## Publishing

Settings → Pages → Deploy from branch → `main`, folder `/ (root)`.
