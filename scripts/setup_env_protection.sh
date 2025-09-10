#!/usr/bin/env bash
set -euo pipefail
: "${MY_PAT:?export MY_PAT=yourToken}"
: "${GH_OWNER:?export GH_OWNER=Alli-Adeleke}"
: "${REPO_NAME:?export REPO_NAME=finance-wallet-onboarding}"

# GitHub auto-creates environment 'github-pages' for Pages deployments
API="https://api.github.com/repos/$GH_OWNER/$REPO_NAME/environments/github-pages/protection_rules"

cat <<EOF | curl -sS -X PUT \
  -H "Authorization: token $MY_PAT" \
  -H "Accept: application/vnd.github+json" \
  "$API" \
  -d @- >/dev/null
{
  "required_approving_review_count": 1
}
EOF

echo "✅ Pages environment requires approval."
