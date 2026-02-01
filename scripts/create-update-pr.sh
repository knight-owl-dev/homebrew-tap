#!/usr/bin/env bash
set -euo pipefail

# Create a PR with staged Manifest changes
#
# Usage:
#   GH_TOKEN=<token> GITHUB_RUN_ID=<id> GITHUB_REPOSITORY=<owner/repo> ./scripts/create-update-pr.sh
#
# Environment variables:
#   GH_TOKEN          - GitHub token with repo scope for creating PRs
#   GITHUB_RUN_ID     - Unique run ID for branch naming
#   GITHUB_REPOSITORY - Repository in owner/repo format
#
# Prerequisites:
#   - Changes must already be staged (git add)
#   - gh CLI must be installed

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GITHUB_RUN_ID:?GITHUB_RUN_ID is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

if git diff --staged --quiet
then
  echo "No changes to commit"
  exit 0
fi

# Collect updated formulas and versions for commit message
UPDATES=""
for file in $(git diff --staged --name-only)
do
  formula=$(basename "${file}" .rb)
  version=$(grep -E '^\s*VERSION\s*=' "${file}" | sed 's/.*"\(.*\)".*/\1/')
  if [[ -n "${UPDATES}" ]]
  then
    UPDATES="${UPDATES}, "
  fi
  UPDATES="${UPDATES}${formula} to ${version}"
done

# Create branch with run ID (globally unique)
BRANCH="auto-update-formula/${GITHUB_RUN_ID}"
git checkout -b "${BRANCH}"

# Commit changes
if [[ -n "${UPDATES}" ]]
then
  TITLE="Update ${UPDATES}"
else
  TITLE="Update formulas"
fi
git commit -m "${TITLE}"

# Push and create PR
git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git push -u origin "${BRANCH}"

PR_URL=$(gh pr create --title "${TITLE}" --body "Automated formula update. \`brew test-bot --only-tap-syntax\` passed.")

echo "Created PR: ${PR_URL}"

# Enable auto-merge (squash)
if ! gh pr merge --auto --squash "${PR_URL}"
then
  echo "Failed to enable auto-merge for PR: ${PR_URL}"
  echo "Ensure auto-merge is enabled in repository settings and branch protection allows it."
  exit 1
fi
