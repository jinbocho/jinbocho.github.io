#!/bin/bash
# Local server that mirrors the GitHub Pages structure for jinbocho.github.io (user/org page — served at root /).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SITE_DIR="$SCRIPT_DIR/site"

if [ ! -f "$SITE_DIR/index.html" ]; then
  echo "❌  site/ not found. Run 'bash scripts/build-site.sh' first."
  exit 1
fi

PORT="${1:-8080}"

echo ""
echo "🌐 Local server — jinbocho.github.io"
echo ""
echo "   Landing page:   http://localhost:$PORT/"
echo "   Manuals (EN):   http://localhost:$PORT/manuals/"
echo "   Manuals (IT):   http://localhost:$PORT/manuals/it/"
echo ""
echo "   Language switcher works correctly at this address."
echo "   Press Ctrl+C to stop."
echo ""

cd "$SITE_DIR" && python3 -m http.server "$PORT"
