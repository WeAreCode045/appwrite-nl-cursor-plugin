#!/usr/bin/env bash
# Zorg dat origin naar GitHub wijst (Cursor marketplace-install via git-URL).
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
github_url="https://github.com/WeAreCode045/appwrite-nl-cursor-plugin.git"
if git -C "$repo_root" remote get-url origin >/dev/null 2>&1; then
  git -C "$repo_root" remote set-url origin "$github_url"
else
  git -C "$repo_root" remote add origin "$github_url"
fi
git -C "$repo_root" remote -v
git -C "$repo_root" ls-remote --symref origin HEAD