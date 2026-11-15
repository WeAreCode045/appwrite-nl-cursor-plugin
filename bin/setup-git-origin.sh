#!/usr/bin/env bash
# Zorg dat git ls-remote origin HEAD werkt voor Cursor plugin-install (file://, geen push).
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
file_url="file://${repo_root}"
if git -C "$repo_root" remote get-url origin >/dev/null 2>&1; then
  git -C "$repo_root" remote set-url origin "$file_url"
else
  git -C "$repo_root" remote add origin "$file_url"
fi
git -C "$repo_root" remote -v
git -C "$repo_root" ls-remote --symref origin HEAD