#!/usr/bin/env bash
set -euo pipefail

DOCS_DIR="docs"
NAV_FILE="$DOCS_DIR/_data/navigation.yml"
INDEX_FILE="$DOCS_DIR/index.md"

echo "🚀 Bootstrapping enhanced Pages GUI with ceremonial grouping and timestamps..."

mkdir -p "$DOCS_DIR/_data"

# 1️⃣ Start navigation.yml
echo "# Auto-generated navigation for Finance Wallet Onboarding™" > "$NAV_FILE"
echo "main:" >> "$NAV_FILE"

# 2️⃣ Define ceremonial phases
declare -A PHASES=(
  ["services"]="Services"
  ["apps"]="Applications"
  ["platform"]="Platform"
  ["docs"]="Documentation"
  ["scripts"]="Automation Scripts"
  ["assets"]="Assets & Crests"
  ["tools"]="Tools"
)

# 3️⃣ Loop through phases
for dir in "${!PHASES[@]}"; do
  if [ -d "$dir" ]; then
    echo "  - title: \"${PHASES[$dir]}\"" >> "$NAV_FILE"
    echo "    children:" >> "$NAV_FILE"

    find "$dir" -type f | sort | while read -r file; do
      rel_path="${file#./}"
      title=$(basename "$file")
      last_updated=$(git log -1 --format="%Y-%m-%d" -- "$file" 2>/dev/null || echo "N/A")
      echo "      - title: \"$title (updated $last_updated)\"" >> "$NAV_FILE"
      echo "        url: /$rel_path" >> "$NAV_FILE"
    done
  fi
done

# 4️⃣ Create index.md
cat > "$INDEX_FILE" <<EOF
---
layout: default
title: Finance Wallet Codex GUI
---

# 🛡️ Finance Wallet Codex — Operational Dashboard

Welcome to the sovereign GUI for the entire codebase.  
Select a crest or module to explore its lineage.

![First Crest](../assets/impact-crests/first-crest.svg)

## 📂 Navigation by Ceremonial Phase
{% for section in site.data.navigation.main %}
### {{ section.title }}
{% if section.children %}
{% for item in section.children %}
- [{{ item.title }}]({{ item.url }})
{% endfor %}
{% endif %}
{% endfor %}
EOF

# 5️⃣ Ensure _data is included in Jekyll config
if ! grep -q "include:" "$DOCS_DIR/_config.yml"; then
  echo "include:" >> "$DOCS_DIR/_config.yml"
  echo "  - _data" >> "$DOCS_DIR/_config.yml"
fi

echo "✅ Enhanced Pages GUI bootstrap complete."
