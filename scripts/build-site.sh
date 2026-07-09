#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║  Building Jinbocho Site (Landing + Manuals EN + IT)   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Build English MkDocs documentation
echo "📚 Step 1: Building English documentation..."
mkdocs build
echo "✅ English docs built → site/manuals/"
echo ""

# Step 2: Build Italian MkDocs documentation
echo "📚 Step 2: Building Italian documentation..."
mkdocs build -f mkdocs.it.yml
echo "✅ Italian docs built → site/manuals/it/"
echo ""

# Step 3: Copy assets to both EN and IT docs
echo "🎨 Step 3: Syncing shared assets..."
mkdir -p site/manuals/assets site/manuals/it/assets
cp assets/custom.css        site/manuals/assets/custom.css        2>/dev/null || true
cp assets/custom.css        site/manuals/it/assets/custom.css     2>/dev/null || true
cp assets/jinbocho-logo.svg site/manuals/assets/jinbocho-logo.svg 2>/dev/null || true
cp assets/jinbocho-logo.svg site/manuals/it/assets/jinbocho-logo.svg 2>/dev/null || true
cp assets/jinbocho-logo.png site/manuals/assets/jinbocho-logo.png 2>/dev/null || true
cp assets/jinbocho-logo.png site/manuals/it/assets/jinbocho-logo.png 2>/dev/null || true
echo "✅ Assets synced to EN and IT manuals"
echo ""

# Step 4: Copy shared CSS/JS/screenshot assets used by the landing and pricing pages
echo "🎨 Step 4: Deploying site assets (css/js/screenshots)..."
mkdir -p site/assets
rm -rf site/assets/css site/assets/js site/assets/screenshots
cp -R assets/css         site/assets/css
cp -R assets/js          site/assets/js
cp -R assets/screenshots site/assets/screenshots
echo "✅ Assets deployed → site/assets/"
echo ""

# Step 5: Copy landing page to site root
echo "🎨 Step 5: Deploying landing page..."
cp index.html site/index.html
echo "✅ Landing page deployed"
echo ""

# Step 6: Copy pricing page
echo "💰 Step 6: Deploying pricing page..."
mkdir -p site/pricing
cp pricing/index.html site/pricing/index.html
echo "✅ Pricing page deployed → site/pricing/"
echo ""

# Step 7: Verify structure
echo "🔍 Step 7: Verifying site structure..."
ERRORS=0
for path in "site/index.html" "site/manuals/index.html" "site/manuals/it/index.html" "site/pricing/index.html" "site/assets/css/base.css" "site/assets/js/site.js" "site/assets/screenshots/hero-dashboard.webp"; do
  if [ -f "$path" ]; then
    echo "   ✅ $path"
  else
    echo "   ❌ MISSING: $path"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "❌ Error: Site structure incomplete ($ERRORS missing files)"
    exit 1
fi
echo ""

# Step 8: Display summary
echo "╔════════════════════════════════════════════════════════╗"
echo "║  ✅ Site Build Complete!                              ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📂 Output location: $(pwd)/site/"
echo ""
echo "🌐 Test locally:"
echo "   bash scripts/serve-local.sh"
echo "   Open: http://localhost:8080/"
echo ""
echo "📝 Live reload (single language):"
echo "   mkdocs serve                    →  EN manuals"
echo "   mkdocs serve -f mkdocs.it.yml   →  IT manuals"
echo ""
