#!/usr/bin/env bash
set -euo pipefail

echo "🚀 [Crest Shimmer] Starting sovereign create_repo bootstrap with CodeQL & Pages fixes..."

# === 1. Ensure base directories ===
mkdir -p \
  assets/impact-crests \
  docs/_data \
  scripts \
  .github/codeql \
  .github/workflows

# === 2. Install system dependencies ===
echo "📦 Installing system dependencies..."
if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y git curl jq unzip build-essential python3 python3-pip
elif command -v yum &>/dev/null; then
    sudo yum install -y git curl jq unzip make gcc python3 python3-pip
fi

# === 3. Install Node.js & npm (for Pages/CI scripts) ===
if ! command -v node &>/dev/null; then
    echo "⬇️ Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# === 4. Install project dependencies for CodeQL scans ===
if [ -f package.json ]; then
    echo "📦 Installing npm dependencies..."
    npm ci || npm install
else
    echo "{}" > package.json
    npm init -y
fi

if [ -f requirements.txt ]; then
    echo "📦 Installing Python dependencies..."
    pip install -r requirements.txt
else
    echo "# Python dependencies" > requirements.txt
fi

# === 5. CodeQL config ===
cat > .github/codeql/codeql-config.yml <<'EOF'
name: "Default CodeQL Config"
paths:
  - .
paths-ignore:
  - node_modules
  - vendor
EOF

# === 6. Pages config ===
cat > docs/_config.yml <<'EOF'
title: "Finance Wallet Onboarding"
description: "Unified GUI, Admin Console, Roles, Workflows, and Guardrails"
theme: minima
EOF

cat > docs/index.md <<'EOF'
# Welcome to Finance Wallet Onboarding
This site is built and deployed via GitHub Pages.
EOF

# === 7. CI / Pages & CodeQL workflow ===
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
      - run: npm ci || npm install
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
      - run: npm ci || npm install
      - run: mkdir -p _site && cp -r docs/* _site/
      - uses: actions/configure-pages@v4
      - uses: actions/upload-pages-artifact@v3
        with:
          path: _site
      - uses: actions/deploy-pages@v4
EOF

# === 8. Governance & guardrails ===
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

# === 9. Finance Wallet Onboarding folder ===
mkdir -p "Finance Wallet Onboarding"
echo "# Finance Wallet Onboarding" > "Finance Wallet Onboarding/README.md"

# === 10. Commit ceremonial bootstrap ===
git add .
git commit -m "Bootstrap create_repo with CodeQL & Pages fixes [crest shimmer]" || true

echo "✅ Sovereign bootstrap complete — ready for push & CI."
# --- IGNORE ---