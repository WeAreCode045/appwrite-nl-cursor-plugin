---
name: appwrite-workspace-env
description: Resolve Appwrite endpoint, project ID, and API key from the Cursor workspace env files. Use before MCP calls, appwrite client in CI mode, or when the user asks which Appwrite project/credentials apply.
---

# Appwrite credentials from the workspace

## Rules

1. Read from the **open workspace** directory, not from global Cursor secrets alone.
2. Prefer **`.env.local`**, then **`.env`**, walking up from the workspace root toward `$HOME`.
3. For monorepos (e.g. Research Navigator), also check `sites/navigator-web/.env.local` and `.env` if nothing was found walking up.
4. **Never invent** a `APPWRITE_PROJECT_ID`. If missing, ask the user to add it.
5. **Never** put `APPWRITE_API_KEY` in `VITE_*` variables (bundle exposure). Frontend uses only `VITE_APPWRITE_ENDPOINT` and `VITE_APPWRITE_PROJECT_ID`.

## Variables

| Purpose | Names (first match wins) |
|---------|--------------------------|
| API endpoint | `APPWRITE_ENDPOINT`, `VITE_APPWRITE_ENDPOINT` — default `https://appwrite.nl/v1` |
| Project ID (MCP / CLI) | `APPWRITE_PROJECT_ID`, `APPWRITE_PROJECT`, `VITE_APPWRITE_PROJECT_ID`, … |
| Server API key (MCP, `appwrite client --key`) | `APPWRITE_API_KEY` only |

## Research Navigator

- Public frontend: `sites/navigator-web/.env` — `VITE_APPWRITE_ENDPOINT`, `VITE_APPWRITE_PROJECT_ID` (see `.env.example`).
- MCP and deploy automation: repo-root **`.env.local`** with `APPWRITE_API_KEY`, `APPWRITE_PROJECT_ID`, optional `APPWRITE_ENDPOINT=https://appwrite.nl/v1`.
- Functions at runtime use Appwrite-injected `APPWRITE_FUNCTION_*` — not the workspace `.env`.

## MCP in this plugin

The `appwrite-nl` MCP server runs `bin/appwrite-mcp.sh` with `${workspaceFolder}`. It exports `APPWRITE_ENDPOINT`, `APPWRITE_PROJECT_ID`, and `APPWRITE_API_KEY` to `uvx mcp-server-appwrite`.