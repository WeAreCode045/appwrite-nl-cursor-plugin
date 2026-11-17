---
name: appwrite-workspace-env
description: Resolve Appwrite endpoint, project ID, and API key from the Cursor workspace env files. Use before MCP calls, appwrite client in CI mode, or when the user asks which Appwrite project/credentials apply.
---

# Appwrite credentials from the workspace

## Rules

1. Read from the **open workspace** directory, not from global Cursor secrets alone.
2. Prefer **`.env.local`**, then **`.env`**, walking up from the workspace root toward `$HOME`.
3. **Never invent** a `APPWRITE_PROJECT_ID`. If missing, ask the user to add it.
4. **Never** put `APPWRITE_API_KEY` in `VITE_*` variables (bundle exposure). Frontend uses only `VITE_APPWRITE_ENDPOINT` and `VITE_APPWRITE_PROJECT_ID`.

## Variables

| Purpose | Names (first match wins) |
|---------|--------------------------|
| API endpoint | `APPWRITE_ENDPOINT`, `VITE_APPWRITE_ENDPOINT` in workspace env. If absent: plugin **Plugins → Configure → Default Appwrite endpoint** (synced to `~/.cursor/appwrite-nl/default-endpoint`). Never invent a host. |
| Project ID (MCP / CLI) | `APPWRITE_PROJECT_ID`, `APPWRITE_PROJECT`, `VITE_APPWRITE_PROJECT_ID`, … |
| Server API key (MCP, `appwrite client --key`) | `APPWRITE_API_KEY` only |

## Layout

- MCP / CLI / deploy: workspace **`.env.local`** with `APPWRITE_API_KEY`, `APPWRITE_PROJECT_ID`, and ideally `APPWRITE_ENDPOINT`.
- Frontend (Vite/etc.): public `VITE_APPWRITE_ENDPOINT` and `VITE_APPWRITE_PROJECT_ID` only — never the API key.
- Appwrite Functions at runtime use Appwrite-injected `APPWRITE_FUNCTION_*` — not the workspace `.env`.

## MCP

| Server | Where | Use for |
|--------|--------|---------|
| `appwrite-docs` | Plugin (`.mcp.json` → `https://mcp.appwrite.io/`) | Documentation search. OAuth once in Customize. |
| `appwrite-endpoint` | Plugin | Persists Configure default endpoint for the API launcher. |
| `appwrite-nl` | Project `.cursor/mcp.json` | API against the open workspace’s Appwrite project. |

**API MCP is project-scoped** (user-scope stdio MCP sticks credentials across windows):

1. Run command **`install-project-mcp`** (or copy `templates/project-mcp.json` → `.cursor/mcp.json`).
2. Ensure `~/.local/bin/appwrite-nl-mcp` exists (`bin/link-launcher.sh`).
3. Reload the window.

Endpoint resolution in the launcher: workspace env → Configure default → error if still missing.
