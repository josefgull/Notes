#!/usr/bin/env bash
set -euo pipefail

# Build every note in notes/<name>/<name>.tex into notes/<name>/index.html
# (lwarp) and notes/<name>/<name>.pdf, then regenerate the root index.html.
# Each note is built in an isolated temp dir so the note folders stay clean.
# Usage: ./build.sh [name ...]   (default: all notes)

ROOT=$(cd -- "$(dirname "$0")" && pwd)
NOTES_DIR="$ROOT/notes"
BUILD_ROOT="$ROOT/.lwarp_build"

# Verify tools
command -v lwarpmk >/dev/null 2>&1 || { echo "Error: lwarpmk not found (install TeX Live lwarp)." >&2; exit 1; }
command -v lualatex >/dev/null 2>&1 || { echo "Error: lualatex not found (install TeX Live)." >&2; exit 1; }
command -v rsync >/dev/null 2>&1 || { echo "Error: rsync not found (install rsync)." >&2; exit 1; }

if [[ $# -gt 0 ]]; then
  NAMES=("$@")
else
  NAMES=()
  for d in "$NOTES_DIR"/*/; do
    NAMES+=("$(basename "$d")")
  done
fi

build_note() {
  local name="$1"
  local src="$NOTES_DIR/$name"
  local build="$BUILD_ROOT/$name"

  [[ -f "$src/$name.tex" ]] || { echo "Error: $src/$name.tex not found." >&2; exit 1; }

  echo "[build] $name: preparing isolated build dir..."
  rm -rf "$build"
  mkdir -p "$build"
  rsync -a --exclude 'index.html' --exclude '*.pdf' --exclude '*.css' "$src/" "$build/"

  (
    cd "$build"

    # Bootstrap lwarpmk.conf
    lualatex --interaction=nonstopmode --shell-escape "$name.tex" >/dev/null

    echo "[build] $name: HTML..."
    lwarpmk html >/dev/null

    echo "[build] $name: PDF..."
    lwarpmk print >/dev/null
  )

  echo "[build] $name: collecting outputs..."
  # The page is published as index.html, so point in-page links at it
  sed "s|href=\"$name.html#|href=\"#|g" "$build/$name.html" > "$src/index.html"
  cp -f "$build/$name.pdf" "$src/$name.pdf"
  for css in "$build"/lwarp*.css; do
    [[ -f "$css" ]] && cp -f "$css" "$src/"
  done

  # Copy generated images, if any
  rsync -a \
    --include '*/' \
    --include '*.png' --include '*.jpg' --include '*.jpeg' --include '*.gif' --include '*.svg' --include '*.webp' \
    --exclude '*' \
    "$build/" "$src/" || true
}

# Root index: one entry per note, title taken from \title{...}
write_index() {
  local out="$ROOT/index.html"
  {
    cat <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Physics &amp; Mathematics Notes</title>
<meta name="description" content="Short notes on physics and mathematics, available as HTML and PDF." />
<link rel="stylesheet" href="style.css" />
</head>
<body>
<h1>Physics &amp; Mathematics Notes</h1>
<ul class="notes">
EOF
    for d in "$NOTES_DIR"/*/; do
      local name title
      name=$(basename "$d")
      [[ -f "$d/$name.tex" ]] || continue
      title=$(sed -n 's/^\\title{\(.*\)}.*/\1/p' "$d/$name.tex" | head -n1)
      title=${title:-$name}
      echo "  <li><a href=\"notes/$name/\">$title</a> <a class=\"pdf\" href=\"notes/$name/$name.pdf\">[PDF]</a></li>"
    done
    cat <<'EOF'
</ul>
</body>
</html>
EOF
  } > "$out"
}

for name in "${NAMES[@]}"; do
  build_note "$name"
done

echo "[build] Writing root index.html..."
write_index

rm -rf "$BUILD_ROOT"
echo "[build] Done. Serve with 'python3 -m http.server' and open http://localhost:8000/"
