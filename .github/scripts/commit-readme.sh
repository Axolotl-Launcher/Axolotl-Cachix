#!/usr/bin/env bash
#
# Commit README.md when report.sh changed it, and push. A run that leaves the
# README as it was commits nothing.
set -euo pipefail

git add README.md
if git diff --cached --quiet -- README.md; then
  echo "README.md is unchanged"
  exit 0
fi

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git commit -m "chore: update cached commit hashes"
git push
