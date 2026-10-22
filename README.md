# Physics & Mathematics Notes

A collection of notes I've written throughout my studies. They're my personal knowledge vault, a place to write things down properly once I've understood them. I also want them to be useful to others, so they're public.

**Read them online:** <https://josefgull.github.io/Notes/>

Every note is available as a web page and as a PDF.

## Notes

- [Dirac Notes for Integration over Energy Surfaces](https://josefgull.github.io/Notes/notes/dirac/)
- [Multipole Expansion: A Tutorial](https://josefgull.github.io/Notes/notes/multipole/) *(work in progress)*
- [Polarisierung und Magnetisierung](https://josefgull.github.io/Notes/notes/polarisierung-magnetisierung/) *(German)*
- [Boundary Value Problems](https://josefgull.github.io/Notes/notes/boundary-value/) *(work in progress)*

If you find a mistake or something is unclear, feel free to open an issue.

---

## How it works

The notes are written in LaTeX and converted to HTML with [lwarp](https://ctan.org/pkg/lwarp) (math rendered by MathJax). The site is hosted on GitHub Pages.

```text
index.html            generated list of all notes
notes/<name>/
  <name>.tex          source
  index.html          generated HTML page
  <name>.pdf          generated PDF
  lwarp*.css          generated styles
```

### Adding a note

1. Create `notes/<name>/<name>.tex`, using `notes/dirac/dirac.tex` as a template. Keep:
   - `\usepackage[mathjax]{lwarp}` right after `\documentclass`
   - `\title{...}` (page title and entry in the root index)
   - `\HTMLDescription{...}` (meta description)
   - the `warpHTML` block with the "Download PDF" link
2. Build and push:

```bash
./build.sh          # all notes
./build.sh dirac    # only one note
git add -A && git commit -m "Add note" && git push
```

Requires TeX Live (`lwarp`, `lualatex`) and `rsync`. Preview locally with `python3 -m http.server` and open <http://localhost:8000/>.
