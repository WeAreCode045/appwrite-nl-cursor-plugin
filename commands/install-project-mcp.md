---
name: install-project-mcp
description: Wire Appwrite NL MCP into the current project via .cursor/mcp.json (per-workspace credentials)
---

# Install project-scoped Appwrite NL MCP

Cursor user-scope plugin MCP is a **single shared process** across windows. Credentials from workspace `.env` stick until the plugin is toggled. Skills/commands stay in the user plugin; **MCP must be project-scoped**.

## Do this in the open workspace

1. Ensure the stable launcher exists:

```sh
PLUGIN_BIN=$(ls -1d "$HOME/.cursor/plugins/cache/wearecode045-appwrite-nl-cursor-plugin/appwrite-nl-cursor-plugin"/*/bin 2>/dev/null | head -1)
if [ -z "$PLUGIN_BIN" ] && [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
  PLUGIN_BIN="${CURSOR_PLUGIN_ROOT}/bin"
fi
if [ -n "$PLUGIN_BIN" ] && [ -x "$PLUGIN_BIN/link-launcher.sh" ]; then
  bash "$PLUGIN_BIN/link-launcher.sh"
elif [ -x "$HOME/Code045/appwrite-nl-cursor-plugin/bin/link-launcher.sh" ]; then
  bash "$HOME/Code045/appwrite-nl-cursor-plugin/bin/link-launcher.sh"
else
  echo "link-launcher.sh not found; install/update the appwrite-nl-cursor-plugin first" >&2
  exit 1
fi
test -x "$HOME/.local/bin/appwrite-nl-mcp"
```

2. Create or merge `.cursor/mcp.json` in the **workspace root** so it contains:

```json
{
  "mcpServers": {
    "appwrite-nl": {
      "command": "bash",
      "args": [
        "${userHome}/.local/bin/appwrite-nl-mcp",
        "${workspaceFolder}"
      ]
    }
  }
}
```

Preserve any other existing `mcpServers` entries. Do not nest this under the plugin; it must live in the project.

3. Confirm workspace `.env.local` (preferred) or `.env` has `APPWRITE_API_KEY` and `APPWRITE_PROJECT_ID` (or `VITE_APPWRITE_PROJECT_ID`).

4. If Customize still shows a **plugin** MCP named like `appwrite-nl` / `plugin-…-appwrite-nl`, disable that duplicate. Only the project `.cursor/mcp.json` server should run.

5. Ask the user to run **Developer: Reload Window**, then verify MCP `appwrite-nl` connects in Customize / Tools & MCP.

## Why

`${workspaceFolder}` in project `.cursor/mcp.json` resolves to this project. Each project gets its own MCP config string and credentials. User-scope plugin MCP cannot do that.
