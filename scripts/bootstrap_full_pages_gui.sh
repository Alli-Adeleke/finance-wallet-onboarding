#!/usr/bin/env bash
set -euo pipefail

DOCS_DIR="docs"
NAV_FILE="$DOCS_DIR/_data/navigation.yml"
INDEX_FILE="$DOCS_DIR/index.md"
ADMIN_FILE="$DOCS_DIR/admin/index.md"

echo "🚀 Bootstrapping full Pages GUI + Admin Console..."

# Ensure required directories
mkdir -p "$DOCS_DIR/_data" "$DOCS_DIR/admin" assets/impact-crests

# === 1️⃣ Generate navigation.yml with ceremonial grouping ===
echo "# Auto-generated navigation for Finance Wallet Onboarding™" > "$NAV_FILE"
echo "main:" >> "$NAV_FILE"

declare -A PHASES=(
  ["services"]="Services"
  ["apps"]="Applications"
  ["platform"]="Platform"
  ["docs"]="Documentation"
  ["scripts"]="Automation Scripts"
  ["assets"]="Assets & Crests"
  ["tools"]="Tools"
)

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

# Add Admin Console to nav
echo "  - title: \"Admin Console\"" >> "$NAV_FILE"
echo "    url: /admin/index.html" >> "$NAV_FILE"

# === 2️⃣ Create/refresh index.md (GUI landing) ===
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

# === 3️⃣ Create/refresh Admin Console ===
cat > "$ADMIN_FILE" <<EOF
---
layout: default
title: Admin Console — Finance Wallet Codex
---

# 🛡️ Admin Console — Finance Wallet Codex

Welcome, Sovereign Operator.  
This console provides direct access to operational controls, crest management, and lineage oversight.

## 📊 Repo Health & Lineage
- **Current branch:** \`main\`
- **Last commit:** $(git log -1 --format="%Y-%m-%d %H:%M:%S UTC" || echo "N/A")
- **Total commits:** $(git rev-list --count HEAD || echo "N/A")

## 🖼 Crest Management
- [View all crests](../assets/impact-crests/)
- *(Future enhancement: crest upload form)*

## 📜 Codex Index Controls
- [Regenerate Codex Index](../codex-index.md) *(auto-updates on push)*

## ⚙️ Workflow Console
- [View Actions](https://github.com/Alli-Adeleke/finance-wallet-onboarding/actions)
- [Trigger Pages Deploy](https://github.com/Alli-Adeleke/finance-wallet-onboarding/actions/workflows/pages.yml)

## 📄 Pages Deploy Log
- [Latest Deploy Logs](https://github.com/Alli-Adeleke/finance-wallet-onboarding/actions/workflows/pages.yml)
EOF

# === 4️⃣ Ensure _data is included in Jekyll config ===
if ! grep -q "include:" "$DOCS_DIR/_config.yml" 2>/dev/null; then
  echo "include:" >> "$DOCS_DIR/_config.yml"
  echo "  - _data" >> "$DOCS_DIR/_config.yml"
fi

echo "✅ Full Pages GUI + Admin Console bootstrap complete."
echo "📄 Navigation file: $NAV_FILE"
echo "📄 Index file: $INDEX_FILE"
echo "📄 Admin file: $ADMIN_FILE"   