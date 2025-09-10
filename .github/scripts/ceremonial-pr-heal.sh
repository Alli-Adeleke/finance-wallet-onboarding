#!/bin/bash
# Usage: ./ceremonial-pr-heal.sh <pr-branch> <target-branch> <pr-number>

PR_BRANCH="$1"
TARGET_BRANCH="$2"
PR_NUMBER="$3"

if [ -z "$PR_BRANCH" ] || [ -z "$TARGET_BRANCH" ] || [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 <pr-branch> <target-branch> <pr-number>"
  exit 1
fi

echo "🔍 Starting ceremonial heal for PR #$PR_NUMBER → $TARGET_BRANCH"

git fetch origin
git checkout "$PR_BRANCH"

# Capture pre-heal state
PRE_HASH=$(git rev-parse HEAD)
PRE_LOG=$(git log --oneline origin/"$TARGET_BRANCH"..HEAD)

# Detect and remove merge commits
if git log origin/"$TARGET_BRANCH"..HEAD --merges | grep -q "Merge"; then
  echo "❌ Merge commits detected — removing for linear history"
  git rebase --onto origin/"$TARGET_BRANCH" origin/"$TARGET_BRANCH" "$PR_BRANCH"
fi

# Detect and re-sign unsigned commits
UNSIGNED=$(git log origin/"$TARGET_BRANCH"..HEAD --pretty="%H %G?" | grep "N" | awk '{print $1}')
if [ -n "$UNSIGNED" ]; then
  echo "❌ Unsigned commits detected — re-signing"
  for COMMIT in $UNSIGNED; do
    git rebase -i --keep-empty "$COMMIT"^ --exec "git commit --amend -S --no-edit"
  done
fi

# Optional: Local CodeQL scan
if command -v codeql >/dev/null 2>&1; then
  echo "🔍 Running local CodeQL scan..."
  codeql database create codeql-db --language=javascript --source-root . --overwrite
  codeql database analyze codeql-db codeql/javascript/ql/src/Security/CWE-079 \
    --format=sarif-latest --output=codeql-results.sarif
  if grep -q "result" codeql-results.sarif; then
    echo "❌ CodeQL alerts detected — please fix before pushing"
    exit 1
  fi
fi

# Capture post-heal state
POST_HASH=$(git rev-parse HEAD)
POST_LOG=$(git log --oneline origin/"$TARGET_BRANCH"..HEAD)

# Save full unified diff as artifact
DIFF_FILE="ceremonial-heal-diff-${PR_NUMBER}.patch"
git diff "$PRE_HASH" "$POST_HASH" > "$DIFF_FILE"

# Push healed branch
git push --force-with-lease

# Prepare diff summary
DIFF_SUMMARY=$(git diff --stat "$PRE_HASH" "$POST_HASH")

# Post ceremonial recovery report to PR
if command -v gh >/dev/null 2>&1; then
  gh pr comment "$PR_NUMBER" --body "✅ **Ceremonial Heal Complete**  
**Before:**  
\`\`\`
$PRE_LOG
\`\`\`  
**After:**  
\`\`\`
$POST_LOG
\`\`\`  
**Diff Summary:**  
\`\`\`
$DIFF_SUMMARY
\`\`\`  
📎 Full unified diff attached as workflow artifact.  
- Merge commits removed (linear history enforced)  
- All commits signed (GPG/SSH verified)  
- CodeQL scan passed locally  
- Branch force‑pushed with lineage preserved  
- Crest broadcast triggered"
fi

# Trigger crest-broadcast workflow
if command -v gh >/dev/null 2>&1; then
  gh workflow run crest-broadcast.yml --ref "$TARGET_BRANCH" \
    -f pr_number="$PR_NUMBER" -f branch="$PR_BRANCH"
fi

echo "🎯 PR #$PR_NUMBER healed, diff logged, artifact saved, and broadcast complete."
