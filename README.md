# Appwrite Cursor plugin

**Global Appwrite MCP for self-hosted Appwrite.** Install the plugin once — no MCP server config in each Cursor project. Open a repo with `.env.local` and the agent connects to that Appwrite instance automatically.

Built for teams on **self-hosted Appwrite** (and Cloud too): stop pasting MCP configs into every repo. Credentials stay in the project env; the plugin wires MCP for you.

**What you get**

- **One install, every project** — no per-repo MCP server setup
- **Env-based connection** — project ID and API key from the open workspace `.env` / `.env.local`
- **Self-hosted friendly** — set your host once globally, or override per project in `.env`
- **Docs in chat** — search current Appwrite docs without a second plugin
- **Ready-made skills** — CLI and TypeScript/SDK patterns when you need them
- **Extra always-on rules** (not in the official Appwrite Cursor plugin):
  - **`tablesdb`** — TablesDB-only terminology (`tables` / `rows` / `columns`); no legacy collections/documents; names from `appwrite.config.json` / shared types
  - **`config-cli`** — `appwrite.config.json` as source of truth; auto-update functions, tables, columns, buckets, permissions, etc. with the code so changes are ready to push; stack follows the project
  - **`secrets-deploy`** — credentials from workspace `.env`; no secrets in `VITE_*`
  - **No push without asking** — the agent must not run `appwrite push` / deploy or live Console/MCP mutations on its own, so nothing hits production or shared projects by surprise
  - **No CLI push when `providerRepositoryId` is set** — that resource is deployed via Git; a manual CLI push would fight the Git pipeline, erase the git connections and risk conflicting deployments
  - **No `--force` unless you explicitly allow it** — `--force` skips CLI warnings, including destructive table/schema prompts; without confirmation, an incomplete `appwrite.config.json` can drop columns or wipe data

## Install

1. In Cursor open **Settings → Plugins** and add this GitHub repo as a marketplace:
   `https://github.com/WeAreCode045/appwrite-nl-cursor-plugin`
2. Install **appwrite-nl-cursor-plugin**.
3. **Plugins → Configure** → set **Default Appwrite endpoint** once for all projects  
   (default: `https://cloud.appwrite.io/v1`). You only need `APPWRITE_ENDPOINT` in a project `.env` when that project uses a different host.
4. In **Customize → MCP**, sign in on **appwrite-docs** when prompted.
5. Reload the Cursor window.

## Per project

Only credentials — put in the project `.env.local` (do not commit secrets):

```env
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_API_KEY=your-api-key
# Optional — only if this project differs from the global Configure endpoint:
# APPWRITE_ENDPOINT=https://your-host/v1
```

## License

MIT — see `LICENSE`.
