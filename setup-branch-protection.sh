#!/bin/bash
# ================================================================
# BluWav CRM — Branch Protection Setup Script
# Run once to apply protection rules via GitHub API
# Usage: GITHUB_TOKEN=ghp_xxx bash setup-branch-protection.sh
# ================================================================

REPO="AMTCrushingit/bluwav-crm"
TOKEN="${GITHUB_TOKEN}"
BRANCH="main"

if [ -z "$TOKEN" ]; then
  echo "❌ Error: Set GITHUB_TOKEN environment variable first"
  echo "   export GITHUB_TOKEN=ghp_your_token_here"
  exit 1
fi

echo "Applying branch protection to $REPO/$BRANCH..."

curl -s -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/branches/$BRANCH/protection" \
  -d '{
    "required_status_checks": {
      "strict": true,
      "contexts": [
        "check / 2. Auth Flow & Regression Tests"
      ]
    },
    "enforce_admins": false,
    "required_pull_request_reviews": null,
    "restrictions": null,
    "allow_force_pushes": false,
    "allow_deletions": false,
    "block_creations": false,
    "required_conversation_resolution": false
  }' | python3 -c "
import sys, json
r = json.load(sys.stdin)
if 'url' in r:
    print('✅ Branch protection applied successfully')
    print('   Force pushes: BLOCKED')
    print('   Required checks: Auth Flow & Regression Tests must pass')
    print('   Branch deletions: BLOCKED')
else:
    print('❌ Error:', r.get('message', r))
"

echo ""
echo "Done. To verify: https://github.com/$REPO/settings/branches"
