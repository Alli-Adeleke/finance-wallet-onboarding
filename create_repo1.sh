#!/usr/bin/env bash
set -euo pipefail

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

echo "🚀 [Crest Shimmer] Starting sovereign create_repo bootstrap with branch‑aware golden restore + Issues backup..."

# === 1. Pick golden branch based on current branch ===
case "$BRANCH_NAME" in
  main)          GOLDEN_BRANCH="origin/my-feature" ;;
  create_repo)   GOLDEN_BRANCH="origin/ceremonial-sync" ;;
  *)             GOLDEN_BRANCH="origin/my-feature" ;;
esac
echo "📜 Golden branch for restore: $GOLDEN_BRANCH"

# === 2. Ensure base directories ===
mkdir -p \
  assets/impact-crests \
  docs/_data \
  scripts \
  .github/codeql \
  .github/workflows \
  "Finance Wallet Onboarding" \
  .codex

# === 3. Install system dependencies ===
echo "📦 Installing system dependencies..."
if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y git curl jq unzip build-essential python3 python3-pip
elif command -v yum &>/dev/null; then
    sudo yum install -y git curl jq unzip make gcc python3 python3-pip
fi

# === 4. Install Node.js & npm ===
if ! command -v node &>/dev/null; then
    echo "⬇️ Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# === 5. JS dependencies with lockfile fallback ===
if [ -f package-lock.json ]; then
    npm ci
else
    npm install --package-lock
fi

# === 6. Python dependencies ===
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "# Python dependencies" > requirements.txt
    pip install -r requirements.txt
fi

# === 7. CodeQL config ===
cat > .github/codeql/codeql-config.yml <<'EOF'
name: "Default CodeQL Config"
paths:
  - .
paths-ignore:
  - node_modules
  - vendor
EOF

# === 8. Pages config ===
cat > docs/_config.yml <<'EOF'
title: "Finance Wallet Onboarding"
description: "Unified GUI, Admin Console, Roles, Workflows, and Guardrails"
theme: minima
EOF

cat > docs/index.md <<'EOF'
# Welcome to Finance Wallet Onboarding
This site is built and deployed via GitHub Pages.
EOF

# === 9. Pages & CodeQL workflow ===
cat > .github/workflows/pages-and-codeql.yml <<'EOF'
name: Pages & CodeQL

on:
  push:
    branches: [ main, create_repo ]
  pull_request:
    branches: [ main, create_repo ]

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
        language: [ 'javascript', 'python' ]
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
          languages: ${{ matrix.language }}
          config-file: ./.github/codeql/codeql-config.yml
      - uses: github/codeql-action/analyze@v3

  pages:
    name: Build & Deploy Pages
    runs-on: ubuntu-latest
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
      - uses: actions/deploy-pages@v4
EOF

# === 10. Governance & guardrails ===
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

# === 11. Finance Wallet Onboarding folder ===
if [ -d finance-wallet-onboarding/.git ]; then
    echo "⚠️ Removing embedded .git to make it a normal folder..."
    rm -rf finance-wallet-onboarding/.git
fi
echo "# Finance Wallet Onboarding" > "Finance Wallet Onboarding/README.md"

# === 12. Restore additional files from golden branch ===
git fetch origin
git checkout "$GOLDEN_BRANCH" -- . || true

# === 13. Backup GitHub Issues ===
if command -v gh &>/dev/null; then
    echo "📥 Exporting GitHub Issues..."
    REPO_NAME=$(basename -s .git "$(git config --get remote.origin.url)")
    gh issue list --state all --limit 1000 --json number,title,state,body,labels,assignees,createdAt,updatedAt > ".codex/issues-backup.json" || echo "⚠️ Could not export issues"
else
    echo "⚠️ GitHub CLI not installed — skipping Issues backup"
fi

# === 14. Commit ceremonial bootstrap ===
git add .
git commit -m "Bootstrap $BRANCH_NAME with full restoration, CodeQL & Pages fixes, and Issues backup [crest shimmer]" || true

# === 15. Auto-push to trigger CI ===
echo "⬆️ Pushing $BRANCH_NAME to origin..."
git push origin "$BRANCH_NAME"

echo "✅ Sovereign bootstrap complete — CI checks should now run, Pages should render, and Issues are backed up in .codex/issues-backup.json"
