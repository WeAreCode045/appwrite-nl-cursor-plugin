#!/usr/bin/env bash
# Install a stable ~/.local/bin/appwrite-nl-mcp → this plugin's appwrite-mcp.sh
# so project .cursor/mcp.json can call the launcher without CURSOR_PLUGIN_ROOT.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
source_launcher="$script_dir/appwrite-mcp.sh"
target_dir="${HOME}/.local/bin"
target_launcher="$target_dir/appwrite-nl-mcp"

if [ ! -f "$source_launcher" ]; then
  echo "link-launcher: missing $source_launcher" >&2
  exit 1
fi
if [ ! -x "$source_launcher" ]; then
  chmod +x "$source_launcher"
fi

mkdir -p "$target_dir"
ln -sfn "$source_launcher" "$target_launcher"
echo "link-launcher: $target_launcher -> $source_launcher" >&2
