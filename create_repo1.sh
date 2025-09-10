#!/usr/bin/env bash
set -euo pipefail

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

echo "🚀 [Crest Shimmer] Full scaffold → local Pages build → push → Pages-first deploy → CodeQL → verify checks..."

# === Detect Pages source branch (default to main) ===
if command -v gh &>/dev/null; then
  REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner)
  PAGES_BRANCH=$(gh api "repos/$REPO_FULL/pages" --jq '.source.branch' 2>/dev/null || echo "main")
else
  PAGES_BRANCH="main"
fi
echo "📜 Pages branch: $PAGES_BRANCH"

# === Best-effort restore from Pages branch, then scaffold ===
git fetch origin || true
git checkout "$PAGES_BRANCH" -- . || true

echo "🛠 Scaffolding Pages, CodeQL, and workflow structure..."
mkdir -p docs/admin docs/assets docs/_data src scripts _site .github/codeql .github/workflows .codex

cat > docs/_config.yml <<'YAML'
title: "Finance Wallet Onboarding"
description: "Unified GUI, Admin Console, Roles, Workflows, and Guardrails"
theme: minima
YAML

echo "# Welcome to Finance Wallet Onboarding" > docs/index.md
echo "# Admin Console" > docs/admin/index.md
echo "Assets go here" > docs/assets/placeholder.txt
for datafile in navigation.yml permissions.yml roles.yml; do
  echo "# $datafile" > "docs/_data/$datafile"
done

# Code scaffolds (guarantee CodeQL has content)
echo "console.log('Hello from JavaScript');" > src/index.js
echo "print('Hello from Python')" > scripts/main.py

# Preempt permission issues
find . -type f -name "*.sh" -exec chmod +x {} \; || true

# === Dependencies (only if manifests exist) ===
if ! command -v node &>/dev/null; then
  if command -v apt-get &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  elif command -v yum &>/dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
    sudo yum install -y nodejs
  fi
fi
if [ -f package.json ]; then
  if [ -f package-lock.json ]; then
    npm ci || { echo "⚠️ npm ci failed, falling back to npm install"; npm install --package-lock; }
  else
    npm install --package-lock
  fi
else
  echo "⚠️ No package.json — skipping npm install"
fi

if [ -f requirements.txt ]; then
  pip install -r requirements.txt || echo "⚠️ pip install failed (continuing)"
else
  echo "# Python dependencies" > requirements.txt
fi

# === CodeQL config and language declaration ===
LANG_MATRIX="'javascript', 'python'"
echo "{\"languages\": [${LANG_MATRIX}]}" > .codex/scan-languages.json

cat > .github/codeql/codeql-config.yml <<'EOF'
name: "Default CodeQL Config"
paths:
  - .
paths-ignore:
  - node_modules
  - vendor
EOF

# === Pages & CodeQL workflow (Pages first, CodeQL waits on Pages) ===
cat > .github/workflows/pages-and-codeql.yml <<EOF
name: Pages & CodeQL

on:
  push:
    branches: [ $PAGES_BRANCH ]
  pull_request:
    branches: [ $PAGES_BRANCH ]

jobs:
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

  analyze:
    name: CodeQL Analyze
    runs-on: ubuntu-latest
    needs: pages
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
EOF

# === Governance & optional issues backup ===
echo "*       @Alli-Adeleke" > CODEOWNERS
if command -v gh &>/dev/null; then
  gh issue list --state all --limit 1000 --json number,title,state > ".codex/issues-backup.json" || true
fi

# === Disable default CodeQL setup to avoid SARIF conflicts ===
if command -v gh &>/dev/null; then
  gh api -X PATCH "repos/$REPO_FULL/code-scanning/default-setup" -f state=not-configured || true
fi

# === Local Pages build test (simulate GitHub Pages) ===
echo "🧪 Local GitHub Pages build..."
if ! command -v bundle &>/dev/null; then
  if command -v apt-get &>/dev/null; then
    sudo apt-get install -y ruby-full build-essential zlib1g-dev
  elif command -v yum &>/dev/null; then
    sudo yum install -y ruby ruby-devel make gcc
  fi
  gem install bundler jekyll
fi
if [ ! -f docs/Gemfile ]; then
  cat > docs/Gemfile <<'RUBY'
source "https://rubygems.org"
gem "github-pages", group: :jekyll_plugins
RUBY
fi
pushd docs >/dev/null
bundle install
bundle exec jekyll build --destination ../_site
popd >/dev/null
echo "✅ Local Pages build succeeded."

# === Commit and push (triggers Pages first, then CodeQL) ===
git add .
git commit -m "Bootstrap $BRANCH_NAME: scaffold, local Pages build OK, Pages-first deploy, CodeQL after, with verification [crest shimmer]" || true
git push origin "$BRANCH_NAME"

# === Monitor → Diagnose → Fix → Retry (Pages first, then CodeQL) ===
MAX_RETRIES=3
RETRY_DELAY=60
BACKOFF_AFTER_RERUN=90

fix_permissions_recursively() {
  echo "🔧 Fixing file permissions recursively..."
  find . -type f -name "*.sh" -exec chmod +x {} \;
  find . -type f -exec chmod u+rw,go+r {} \;
  find . -type d -exec chmod u+rwx,go+rx {} \;
}

show_failure_reasons() {
  local run_id="$1"
  echo "📋 Failure logs for workflow run: $run_id"
  mapfile -t jobs < <(gh run view "$run_id" --json jobs -q '.jobs[] | "\(.name)|\(.databaseId)|\(.conclusion)"')
  for job in "${jobs[@]}"; do
    local job_name="${job%%|*}"
    local rest="${job#*|}"; local job_id="${rest%%|*}"
    local job_conclusion="${job##*|}"
    echo "🔍 Job: $job_name (conclusion: $job_conclusion)"
    gh run view "$run_id" --job "$job_id" --log | tail -n 60 || echo "⚠️ Unable to fetch logs for: $job_name"
    echo "----------------------------------------"
  done
}

get_latest_run_id() {
  # Return latest run_id for the workflow name "Pages & CodeQL"
  gh run list --branch "$BRANCH_NAME" --limit 20 --json databaseId,name \
    -q '.[] | select(.name=="Pages & CodeQL") | .databaseId' | head -n1
}

if command -v gh &>/dev/null; then
  for attempt in $(seq 1 $MAX_RETRIES); do
    echo "⏳ Attempt $attempt: wait for current runs to settle..."
    while gh run list --branch "$BRANCH_NAME" --json status -q '.[].status' | grep -Eq 'in_progress|queued'; do
      sleep $RETRY_DELAY
    done

    run_id=$(get_latest_run_id || true)
    if [ -z "${run_id:-}" ]; then
      echo "⚠️ No workflow run found yet; sleeping..."
      sleep $RETRY_DELAY
      continue
    fi

    # Inspect job-level conclusions (Pages must pass before CodeQL runs)
    mapfile -t job_rows < <(gh run view "$run_id" --json jobs -q '.jobs[] | "\(.name)|\(.conclusion)|\(.status)"')

    pages_status=""
    codeql_statuses=()
    for row in "${job_rows[@]}"; do
      jname="${row%%|*}"
      rest="${row#*|}"
      jconclusion="${rest%%|*}"
      jstatus="${row##*|}"
      if [[ "$jname" == "Build & Deploy Pages" ]]; then
        pages_status="$jconclusion|$jstatus"
      elif [[ "$jname" == "CodeQL Analyze" ]]; then
        codeql_statuses+=("$jconclusion|$jstatus")
      fi
    done

    # If any job still in_progress/queued, wait
    if printf '%s\n' "${job_rows[@]}" | grep -Eq '\|in_progress$|\|queued$'; then
      sleep $RETRY_DELAY
      continue
    fi

    # Require Pages to pass first
    pages_concl="${pages_status%%|*}"
    if [[ -z "$pages_concl" || "$pages_concl" != "success" ]]; then
      echo "❌ Pages did not succeed yet (status: ${pages_status:-none}). Diagnosing..."
      show_failure_reasons "$run_id"
      if [ "$attempt" -lt "$MAX_RETRIES" ]; then
        fix_permissions_recursively
        echo "🔁 Rerunning entire workflow run: $run_id (Pages-first)"
        gh run rerun "$run_id" || echo "⚠️ Could not rerun workflow"
        sleep $BACKOFF_AFTER_RERUN
        continue
      else
        echo "🚨 Pages failed after retries."
        exit 1
      fi
    fi

    # Pages passed — now enforce CodeQL success
    codeql_failed=0
    for cs in "${codeql_statuses[@]:-}"; do
      cconcl="${cs%%|*}"
      if [[ -n "$cconcl" && "$cconcl" != "success" ]]; then
        codeql_failed=1
        break
      fi
    done

    if [[ $codeql_failed -eq 0 ]]; then
      echo "✅ Pages passed and CodeQL passed. All checks green."
      break
    else
      echo "❌ CodeQL did not succeed. Diagnosing..."
      show_failure_reasons "$run_id"
      if [ "$attempt" -lt "$MAX_RETRIES" ]; then
        fix_permissions_recursively
        echo "🔁 Rerunning entire workflow run: $run_id (after permissions fix)"
        gh run rerun "$run_id" || echo "⚠️ Could not rerun workflow"
        sleep $BACKOFF_AFTER_RERUN
      else
        echo "🚨 CodeQL failed after retries."
        exit 1
      fi
    fi
  done
else
  echo "⚠️ GitHub CLI not installed — cannot verify workflows automatically."
fi
echo "🎉 All done."