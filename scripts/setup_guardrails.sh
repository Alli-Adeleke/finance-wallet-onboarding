#!/usr/bin/env bash
set -euo pipefail
: "${MY_PAT:?export MY_PAT=yourToken}"
: "${GH_OWNER:?export GH_OWNER=Alli-Adeleke}"
: "${REPO_NAME:?export REPO_NAME=finance-wallet-onboarding}"

API="https://api.github.com/repos/$GH_OWNER/$REPO_NAME/branches/main/protection"

cat <<EOF | curl -sS -X PUT \
  -H "Authorization: token $MY_PAT" \
  -H "Accept: application/vnd.github.v3+json" \
  "$API" \
  -d @- >/dev/null
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "require_code_owner_reviews": true,
    "dismiss_stale_reviews": true
  },
  "restrictions": {
    "users": ["$GH_OWNER"],
    "teams": []
  }
}
EOF

echo "✅ Branch protection on main enabled."
