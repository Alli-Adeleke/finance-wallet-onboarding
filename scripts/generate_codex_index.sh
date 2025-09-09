#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="docs/codex-index.md"

echo "# 📜 Finance Wallet Codex Index" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "_Auto-generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")_" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Crest badge
if [[ -f "assets/impact-crests/first-crest.svg" ]]; then
  echo "![First Crest](../assets/impact-crests/first-crest.svg)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# List docs
echo "## 📂 Repository Structure" >> "$OUTPUT_FILE"
find . -type d \( -path './.git' -o -path './node_modules' \) -prune -o -type f -print \
  | grep -vE '(\.git/|node_modules/|codex-index\.md$)' \
  | sed 's|^\./||' \
  | sort \
  | while read -r file; do
      echo "- \`$file\`" >> "$OUTPUT_FILE"
    done

echo "✅ Codex Index generated at $OUTPUT_FILE"
