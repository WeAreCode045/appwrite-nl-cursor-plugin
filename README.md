# appwrite-nl-cursor-plugin

Cursor-plugin voor Appwrite: always-on platformregels, CLI- en TypeScript-skills, hosted docs-MCP, plus project-scoped API-MCP met credentials uit de open workspace.

## Wat zit erin

| Onderdeel | Beschrijving |
|-----------|--------------|
| **Rules** | `tablesdb`, `secrets-deploy`, `config-cli` (`alwaysApply`) — alleen actief waar deze plugin aan staat |
| **Skills** | `appwrite-cli`, `appwrite-typescript`, `appwrite-workspace-env` |
| **Commands** | `deploy-function`, `deploy-site`, `install-project-mcp` |
| **Hooks** | `workspaceOpen` — schrijft actieve workspace naar `~/.cursor/appwrite-nl/active-workspace` |
| **Variables** | `APPWRITE_ENDPOINT` — globaal default-endpoint (Plugins → Configure bij install/later) |
| **MCP (docs)** | Plugin-server `appwrite-docs` → `https://mcp.appwrite.io/` (documentatie + OAuth) |
| **MCP (endpoint)** | Plugin-server `appwrite-endpoint` — schrijft Configure-waarde naar `~/.cursor/appwrite-nl/default-endpoint` |
| **MCP (API)** | Project `.cursor/mcp.json` + `~/.local/bin/appwrite-nl-mcp` — per workspace `.env` |

Zet Appwrite-platformregels **hier**, niet in globale Cursor user rules. Product-/domeinregels blijven in het project (`AGENTS.md` / `Docs/agents/`). Migratie vanuit oude user rules: [`docs/migrate-user-rules.md`](docs/migrate-user-rules.md).

Geen Dart, Go, Kotlin, PHP, Python, Ruby, Swift skills (minder tokens).

## Endpoint-prioriteit

1. **Workspace `.env.local` / `.env`**: `APPWRITE_ENDPOINT` of `VITE_APPWRITE_ENDPOINT` (wint altijd).
2. Anders: **Plugins → Configure → Default Appwrite endpoint** (plugin-variabele; default in schema is `https://appwrite.nl/v1` voor Code045; anderen zetten bv. `https://cloud.appwrite.io/v1`).
3. Die Configure-waarde wordt door MCP `appwrite-endpoint` gesynchroniseerd naar `~/.cursor/appwrite-nl/default-endpoint`.
4. Ontbreekt alles: launcher/agent vraagt om een endpoint — geen stille aanname van een host in skills/commands.

## Credentials

De MCP-launcher (`bin/appwrite-mcp.sh`) leest project-id en API-key uit env-bestanden van het open project:

1. Vanaf workspace-root omhoog: `.env.local`, dan `.env`
2. Optioneel: pad in `~/.cursor/appwrite-nl/active-workspace` (workspaceOpen-hook)

| Variabele | Gebruik |
|-----------|---------|
| `APPWRITE_API_KEY` | Server/MCP (verplicht voor API-MCP) |
| `APPWRITE_PROJECT_ID` (of `VITE_APPWRITE_PROJECT_ID`, …) | Project |
| `APPWRITE_ENDPOINT` (of `VITE_APPWRITE_ENDPOINT`) | Host; anders Configure-default |

Zet MCP-credentials in workspace **`.env.local`** (gitignored). Frontend: alleen `VITE_APPWRITE_*` (geen API key). Kopieer `.env.example` als sjabloon — commit geen echte keys.

## Installatie in Cursor

**Aanbevolen (GitHub):** voorkomt de `file://`-bug in Cursor 3.30.x. De marketplace-repo moet **publiek** zijn (of elke gebruiker moet toegang hebben); een private repo werkt niet voor willekeurige ontvangers van de link.

1. **Cursor Settings → Plugins → Add marketplace**.
2. URL: `https://github.com/WeAreCode045/appwrite-nl-cursor-plugin`
3. Installeer plugin **appwrite-nl-cursor-plugin**.
4. **Plugins → Configure** (of install-prompt): vul **Default Appwrite endpoint** in als je workspace-`.env` die regel niet altijd heeft. Code045 mag de schema-default laten staan; anderen bv. `https://cloud.appwrite.io/v1`.
5. Customize / MCP: **`appwrite-docs`** → Needs login (OAuth). **`appwrite-endpoint`** moet starten (schrijft de default weg).
6. **Per Appwrite-project** API-MCP koppelen (eenmalig per repo):

```sh
bash "$(ls -1d "$HOME/.cursor/plugins/cache/wearecode045-appwrite-nl-cursor-plugin/appwrite-nl-cursor-plugin"/*/bin/link-launcher.sh | head -1)"
```

Zet in de **project-root** `.cursor/mcp.json` (zie `templates/project-mcp.json`), of command **`install-project-mcp`**. Daarna **Developer: Reload Window**.

### Custom input bij installatie (onderzoek)

**Ja — via plugin `variables` in `.cursor-plugin/plugin.json`.** Cursor toont die velden onder **Plugins → Configure** (bij installatie en later). Waarden worden gesubstitueerd in `${VAR}`-placeholders in plugin-`mcp.json`. Ze belanden **niet** automatisch in project-`.cursor/mcp.json` of hooks.

Deze plugin gebruikt dat voor `APPWRITE_ENDPOINT`: Configure → MCP `appwrite-endpoint` → bestand → API-launcher. Workspace-`.env` blijft leidend per project.

### Docs vs API MCP

| Server | Scope | Doel |
|--------|--------|------|
| `appwrite-docs` | Plugin | Documentatie (`appwrite_search_docs`). OAuth. |
| `appwrite-endpoint` | Plugin | Sync van Configure-default-endpoint. |
| `appwrite-nl` | Project `.cursor/mcp.json` | API van hét open project via `.env` + key. |

**API-MCP** blijft project-scoped: user-scope stdio-MCP deelt één proces over windows. Zie [forum](https://forum.cursor.com/t/how-do-we-configure-workspace-specific-plugin-mcp-servers/161660).

### Project-scope plugin (optioneel)

UI **Add to Project** faalt vaak met `Workspace collection is not available` (Cursor-bug). Handmatig `.cursor/settings.json` (zie `templates/project-cursor-settings.json`).

### Vereisten

- `uv` / `uvx` voor `mcp-server-appwrite`
- `node` voor `bin/sync-endpoint-mcp.mjs`
- `APPWRITE_API_KEY` + project-id in workspace `.env.local`
- Endpoint in `.env` of via Plugins → Configure
- `~/.local/bin/appwrite-nl-mcp` via `bin/link-launcher.sh`

## Licentie

MIT — zie `LICENSE` (Appwrite upstream).
