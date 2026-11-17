---
name: install-project-mcp
description: Confirm Appwrite API MCP from the plugin (no per-project mcp.json needed)
---

# Appwrite API MCP

This plugin already registers **`appwrite-api`** in its own `.mcp.json`. Do **not** add a duplicate Appwrite MCP entry to the project `.cursor/mcp.json`.

## Checklist for the open workspace

1. Plugin **appwrite-nl-cursor-plugin** is installed and enabled.
2. **Plugins → Configure → Default Appwrite endpoint** is set (unless every project sets `APPWRITE_ENDPOINT` in `.env`).
3. Workspace `.env.local` (or `.env`) has at least:

```env
APPWRITE_PROJECT_ID=...
APPWRITE_API_KEY=...
```

4. Customize → MCP: **`appwrite-api`** is on. If it failed earlier, toggle it or **Developer: Reload Window**.
5. Do not keep an old project-level `appwrite-nl` server next to the plugin server (disable/remove the duplicate).

Credentials always come from the open workspace env; the global Configure value is only the endpoint fallback.
