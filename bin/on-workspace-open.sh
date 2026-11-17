#!/usr/bin/env bash
# workspaceOpen hook: remember the active Cursor workspace for appwrite-mcp.sh.
# Stdout must be JSON (hook output). Diagnostics → stderr.
set -euo pipefail

state_dir="${HOME}/.cursor/appwrite-nl"
state_file="$state_dir/active-workspace"
mkdir -p "$state_dir"

input=$(cat || true)
root=""

if [ -n "$input" ]; then
  root=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
roots = data.get("workspace_roots") or []
if roots:
    print(roots[0])
' 2>/dev/null || true)
fi

if [ -z "$root" ]; then
  root="${CURSOR_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-}}"
fi

if [ -n "$root" ] && [ -d "$root" ]; then
  printf '%s\n' "$root" > "$state_file"
  echo "appwrite-nl: active workspace -> $root" >&2
fi

printf '%s\n' '{}'
