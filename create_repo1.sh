#!/usr/bin/env bash
set -euo pipefail

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

echo "🚀 [Crest Shimmer] Starting sovereign create_repo bootstrap — golden restore, Issues backup, Pages fix, dynamic CodeQL, and workflow rerun..."

# === 1. Detect Pages source branch ===
if command -v gh &>/dev/null; then
    echo "🔍 Detecting GitHub Pages source branch..."
    REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner)
    PAGES_BRANCH=$(gh api repos/$REPO_FULL/pages --jq '.source.branch' 2>/dev/null || echo "main")
else
    echo "⚠️ GitHub CLI not installed — defaulting Pages branch to 'main'"
    PAGES_BRANCH="main"
fi
echo "📜 Pages will deploy from branch: $PAGES_BRANCH"

# === 2. Pick golden branch for restore ===
case "$BRANCH_NAME" in
  main)          GOLDEN_BRANCH="origin/my-feature" ;;
  create_repo)   GOLDEN_BRANCH="origin/ceremonial-sync" ;;
  *)             GOLDEN_BRANCH="$PAGES_BRANCH" ;;
esac
echo "📜 Golden branch for restore: $GOLDEN_BRANCH"

# === 3. Ensure base directories ===
mkdir -p \
  assets/impact-crests \
  docs/_data \
  scripts \
  .github/codeql \
  .github/workflows \
  "Finance Wallet Onboarding" \
  .codex

# === 4. Install system dependencies ===
echo "📦 Installing system dependencies..."
if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y git curl jq unzip build-essential python3 python3-pip
elif command -v yum &>/dev/null; then
    sudo yum install -y git curl jq unzip make gcc python3 python3-pip
fi

# === 5. Restore additional files from golden branch ===
git fetch origin
git checkout "$GOLDEN_BRANCH" -- . || true

# === 6. JS dependencies with lockfile fallback ===
if [ -f package.json ]; then
    if [ -f package-lock.json ]; then
        npm ci
    else
        npm install --package-lock
    fi
else
    echo "⚠️ No package.json found — skipping npm install"
fi

# === 7. Python dependencies ===
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "# Python dependencies" > requirements.txt
    pip install -r requirements.txt
fi

# === 8. Detect present languages for CodeQL ===
LANGS=()
if find . -type f \( -name "*.js" -o -name "*.ts" \) | grep -q .; then
    LANGS+=("javascript")
fi
if find . -type f -name "*.py" | grep -q .; then
    LANGS+=("python")
fi
if [ ${#LANGS[@]} -eq 0 ]; then
    echo "⚠️ No JavaScript or Python files found — defaulting to JavaScript for workflow scaffold"
    LANGS=("javascript")
fi
LANG_MATRIX=$(printf "'%s', " "${LANGS[@]}" | sed 's/, $//')
echo "📜 CodeQL will scan languages: ${LANGS[*]}"
echo "{\"languages\": [${LANG_MATRIX}]}" > .codex/scan-languages.json

# === 9. CodeQL config ===
cat > .github/codeql/codeql-config.yml <<'EOF'
name: "Default CodeQL Config"
paths:
  - .
paths-ignore:
  - node_modules
  - vendor
EOF

# === 10. Pages config ===
cat > docs/_config.yml <<'EOF'
title: "Finance Wallet Onboarding"
description: "Unified GUI, Admin Console, Roles, Workflows, and Guardrails"
theme: minima
EOF

cat > docs/index.md <<'EOF'
# Welcome to Finance Wallet Onboarding
This site is built and deployed via GitHub Pages.
EOF

# === 11. Pages & CodeQL workflow ===
cat > .github/workflows/pages-and-codeql.yml <<EOF
name: Pages & CodeQL

on:
  push:
    branches: [ $PAGES_BRANCH ]
  pull_request:
    branches: [ $PAGES_BRANCH ]

jobs:
  analyze:
    name: CodeQL Analyze
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      actions: read
      contents: read
    strategy:
      fail-fast: false
      matrix:
        language: [ $LANG_MATRIX ]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci || npm install --package-lock
      - uses: actions/setup-python@v5
        with:
          python-version: '3.x'
      - run: pip install -r requirements.txt
      - uses: github/codeql-action/init@v3
        with:
          languages: \${{ matrix.language }}
          config-file: ./.github/codeql/codeql-config.yml
      - uses: github/codeql-action/analyze@v3

  pages:
    name: Build & Deploy Pages
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: \${{ steps.deployment.outputs.page_url }}
    permissions:
      contents: read
      pages: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci || npm install --package-lock
      - run: mkdir -p _site && cp -r docs/* _site/
      - uses: actions/configure-pages@v4
      - uses: actions/upload-pages-artifact@v3
        with:
          path: _site
      - id: deployment
        uses: actions/deploy-pages@v4
EOF

# === 12. Governance & guardrails ===
cat > CODEOWNERS <<'EOF'
*       @Alli-Adeleke
EOF
cat > scripts/setup_env_protection.sh <<'EOF'
#!/usr/bin/env bash
echo "🔒 Setting up environment protection..."
EOF
chmod +x scripts/setup_env_protection.sh
cat > scripts/setup_guardrails.sh <<'EOF'
#!/usr/bin/env bash
echo "🛡 Applying repo guardrails..."
EOF
chmod +x scripts/setup_guardrails.sh

# === 13. Finance Wallet Onboarding folder ===
if [ -d finance-wallet-onboarding/.git ]; then
    echo "⚠️ Removing embedded .git to make it a normal folder..."
    rm -rf finance-wallet-onboarding/.git
fi
echo "# Finance Wallet Onboarding" > "Finance Wallet Onboarding/README.md"

# === 14. Backup GitHub Issues ===
if command -v gh &>/dev/null; then
    echo "📥 Exporting GitHub Issues..."
    gh issue list --state all --limit 1000 --json number,title,state,body,labels,assignees,createdAt,updatedAt > ".codex/issues-backup.json" || echo "⚠️ Could not export issues"
else
    echo "⚠️ GitHub CLI not installed — skipping Issues backup"
fi

# === 15. Disable default CodeQL setup ===
if command -v gh &>/dev/null; then
    echo "🛡 Disabling default CodeQL setup..."
    gh api -X PATCH "repos/$REPO_FULL/code-scanning/default-setup" -f state=not-configured || echo "⚠️ Could not disable default CodeQL setup"
else
    echo "⚠️ GitHub CLI not installed — skipping default CodeQL disable"
fi

# === 16. Commit ceremonial bootstrap ===
git add .
git commit -m "Bootstrap $BRANCH_NAME with full restoration, dynamic CodeQL, Pages fix, Issues backup, and workflow rerun [crest shimmer]" || true

# === 17. Auto-push to trigger CI ===
echo "⬆️ Pushing $BRANCH_NAME to origin..."
git push origin "$BRANCH_NAME"

# === 18. Auto-rerun all workflows (safe for spaces) ===
if command -v gh &>/dev/null; then
    echo "🔄 Rerunning latest run for all workflows..."
    gh workflow list --json name -q '.[].name' | while IFS= read -r wf; do
        echo "🔄 Rerunning: $wf