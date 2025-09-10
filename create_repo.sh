#!/usr/bin/env bash
set -euo pipefail

# ================================
# Ceremonial Repo Bootstrap Script
# ================================
# Purpose:
#   - Create or reset a GitHub repo with sovereign guardrails
#   - Auto-detect token source (local, Codespaces, Actions)
#   - Avoid submodule traps by stripping nested .git folders
#   - Push clean-slate lineage to main
#
# Ibukun Alli-Adeleke — Finance Wallet Onboarding™
# ================================

# --- Token Resolution ---
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    if [[ -n "${MY_PAT:-}" ]]; then
        echo "[token-bridge] Using MY_PAT as GITHUB_TOKEN"
        export GITHUB_TOKEN="$MY_PAT"
    elif [[ -f "$HOME/.github_token" ]]; then
        echo "[token-bridge] Using token from ~/.github_token"
        export GITHUB_TOKEN="$(< "$HOME/.github_token")"
    else
        echo "❌ ERROR: No GITHUB_TOKEN or MY_PAT found."
        echo "Set one of these before running:"
        echo "  export GITHUB_TOKEN=ghp_yourTokenHere"
        echo "  export MY_PAT=ghp_yourTokenHere"
        exit 1
    fi
fi

# --- Config ---
REPO_NAME="finance-wallet-onboarding"
REPO_OWNER="Alli-Adeleke"   # Change if needed
DEFAULT_BRANCH="main"

# --- Remove nested .git folders ---
echo "[cleanup] Removing nested .git folders..."
find . -type d -name ".git" -not -path "./.git" -exec rm -rf {} +

# --- Create orphan branch ---
echo "[branch] Creating orphan branch..."
git checkout --orphan temp-"$DEFAULT_BRANCH"

# --- Stage and commit ---
echo "[commit] Staging files..."
git add .
git commit -m "Initial commit: clean slate for admin integration"

# --- Rename branch ---
echo "[branch] Renaming to $DEFAULT_BRANCH..."
git branch -M "$DEFAULT_BRANCH"

# --- Create repo via API (if it doesn't exist) ---
echo "[github] Ensuring remote repo exists..."
API_URL="https://api.github.com/user/repos"
REPO_CHECK=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME" | jq -r .message)

if [[ "$REPO_CHECK" == "Not Found" ]]; then
    echo "[github] Creating new repo $REPO_OWNER/$REPO_NAME..."
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
         -d "{\"name\":\"$REPO_NAME\",\"private\":false}" \
         "$API_URL" > /dev/null
else
    echo "[github] Repo already exists — will push to it."
fi

# --- Set remote and push ---
echo "[push] Setting remote and pushing..."
git remote remove origin 2>/dev/null || true
git remote add origin "git@github.com:$REPO_OWNER/$REPO_NAME.git"
git push -u origin "$DEFAULT_BRANCH" --force

echo "✅ Ceremonial bootstrap complete."
echo "🌟 Repo: https://github.com/$REPO_OWNER/$REPO_NAME"
