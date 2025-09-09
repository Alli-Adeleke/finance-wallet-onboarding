#!/usr/bin/env bash
set -euo pipefail

# === CONFIGURATION ===
DOCS_DIR="docs"
NAV_FILE="$DOCS_DIR/_data/navigation.yml"
INDEX_FILE="$DOCS_DIR/index.md"

echo "🚀 Bootstrapping Pages GUI for full codebase..."

# Ensure docs/_data exists for Jekyll navigation
mkdir -p "$DOCS_DIR/_data"

# 1️⃣ Generate navigation.yml
echo "# Auto-generated navigation for Finance Wallet Onboarding™" > "$NAV_FILE"
echo "main:" >> "$NAV_FILE"

find . -type d \( -path './.git' -o -path './node_modules' -o -path "./$DOCS_DIR/_site" \) -prune -o -type f -print \
  | grep -vE '(\.git/|node_modules/|_site/)' \
  | sort \
  | while read -r file; do
    rel_path="${file#./}"
    title=$(basename "$file")
    echo "  - title: \"$title\"" >> "$NAV_FILE"
    echo "    url: /$rel_path" >> "$NAV_FILE"
done

# 2️⃣ Create/overwrite index.md with GUI entry
cat > "$INDEX_FILE" <<EOF
---
layout: default
title: Finance Wallet Codex GUI
---

# 🛡️ Finance Wallet Codex — GUI Navigation

Welcome to the sovereign GUI for the entire codebase.  
Select a crest or module to explore its lineage.

![First Crest](../assets/impact-crests/first-crest.svg)

## 📂 Navigation
{% for item in site.data.navigation.main %}
- [{{ item.title }}]({{ item.url }})
{% endfor %}
EOF

# 3️⃣ Ensure Jekyll config supports data files
if ! grep -q "include:" "$DOCS_DIR/_config.yml"; then
  echo "include:" >> "$DOCS_DIR/_config.yml"
  echo "  - _data" >> "$DOCS_DIR/_config.yml"
fi

echo "✅ Pages GUI bootstrap complete."
echo "📄 Navigation file: $NAV_FILE"
echo "📄 Index file: $INDEX_FILE"
