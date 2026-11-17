# appwrite-nl-cursor-plugin

Cursor-plugin voor **appwrite.nl**: always-on platformregels, CLI- en TypeScript-skills, hosted docs-MCP, plus project-scoped API-MCP met credentials uit de open workspace.

## Wat zit erin

| Onderdeel | Beschrijving |
|-----------|--------------|
| **Rules** | `tablesdb`, `secrets-deploy`, `config-cli` (`alwaysApply`) — alleen actief waar deze plugin aan staat |
| **Skills** | `appwrite-cli`, `appwrite-typescript`, `appwrite-workspace-env` |
| **Commands** | `deploy-function`, `deploy-site`, `install-project-mcp` |
| **Hooks** | `workspaceOpen` — schrijft actieve workspace naar `~/.cursor/appwrite-nl/active-workspace` |
| **MCP (docs)** | Plugin-server `appwrite-docs` → `https://mcp.appwrite.io/` (documentatie + OAuth; geen aparte appwrite.io-plugin nodig) |
| **MCP (API)** | Project `.cursor/mcp.json` + `~/.local/bin/appwrite-nl-mcp` — per workspace `.env` |

Zet Appwrite-platformregels **hier**, niet in globale Cursor user rules. Product-/domeinregels blijven in het project (`AGENTS.md` / `Docs/agents/`). Migratie vanuit oude user rules: [`docs/migrate-user-rules.md`](docs/migrate-user-rules.md).

Geen Dart, Go, Kotlin, PHP, Python, Ruby, Swift skills (minder tokens).

## Credentials

De MCP-launcher (`bin/appwrite-mcp.sh`) leest **alleen** uit env-bestanden van het project dat in Cursor open staat:

1. Vanaf workspace-root omhoog: `.env.local`, dan `.env`
2. Optioneel: pad in `~/.cursor/appwrite-nl/active-workspace` (workspaceOpen-hook)

| Variabele | Gebruik |
|-----------|---------|
| `APPWRITE_API_KEY` | Server/MCP (verplicht voor MCP) |
| `APPWRITE_PROJECT_ID` (of `VITE_APPWRITE_PROJECT_ID`, …) | Project |
| `APPWRITE_ENDPOINT` (of `VITE_APPWRITE_ENDPOINT`) | Default `https://appwrite.nl/v1` |

Zet MCP-credentials in workspace **`.env.local`** (gitignored). Frontend: alleen `VITE_APPWRITE_*` (geen API key). Kopieer `.env.example` als sjabloon — commit geen echte keys.

## Installatie in Cursor

**Aanbevolen (GitHub):** voorkomt de `file://`-bug in Cursor 3.30.x.

1. **Cursor Settings → Plugins → Add marketplace** (of vergelijkbaar).
2. URL: `https://github.com/WeAreCode045/appwrite-nl-cursor-plugin`
3. Installeer plugin **appwrite-nl-cursor-plugin** (user-scope is OK voor skills/commands/docs-MCP).
4. Bij eerste connect: in Customize / MCP bij **`appwrite-docs`** op **Needs login** / sign-in klikken (OAuth naar Appwrite). Daarna is docs-search beschikbaar zonder de officiële appwrite.io-plugin.
5. **Per Appwrite-project** API-MCP koppelen (eenmalig per repo):

```sh
# stabiele launcher
bash /pad/naar/plugin/bin/link-launcher.sh
# of na marketplace-install:
bash "$(ls -1d "$HOME/.cursor/plugins/cache/wearecode045-appwrite-nl-cursor-plugin/appwrite-nl-cursor-plugin"/*/bin/link-launcher.sh | head -1)"
```

Zet in de **project-root** `.cursor/mcp.json` (zie `templates/project-mcp.json`):

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

Of in chat: command **`install-project-mcp`**. Daarna **Developer: Reload Window**.

### Docs vs API MCP

| Server | Scope | Doel |
|--------|--------|------|
| `appwrite-docs` (plugin) | User / globaal | Officiële Appwrite-documentatie (`appwrite_search_docs`). Hosted HTTP + OAuth. (Server heeft ook Cloud-API-tools via appwrite.io-login; voor **appwrite.nl**-projecten gebruik je `appwrite-nl`.) |
| `appwrite-nl` (project) | Per repo `.cursor/mcp.json` | Jouw **appwrite.nl**-project via API key uit `.env.local`. |

De oude standalone docs-MCP (`mcp-for-docs.appwrite.io`) is deprecated; `mcp.appwrite.io` is de vervanger (zelfde stack als de officiële Cursor-plugin, zonder die plugin te installeren).

**API-MCP** blijft project-scoped: Cursor deelt user-scope stdio-MCP over windows, waardoor workspace-credentials anders blijven hangen. Zie [forum](https://forum.cursor.com/t/how-do-we-configure-workspace-specific-plugin-mcp-servers/161660).

### Project-scope plugin (optioneel)

UI **Add to Project** faalt vaak met `Workspace collection is not available` (Cursor-bug). Handmatig in het doelproject `.cursor/settings.json` (zie `templates/project-cursor-settings.json`):

```json
{
  "plugins": {
    "appwrite-nl-cursor-plugin": {
      "enabled": true
    }
  }
}
```

### Lokale marketplace (optioneel)

Één map bevat zowel `marketplace.json` als de plugin (`source: "./"`). Je selecteert die map als marketplace-root — geen aparte submap.

### Verplichte bestanden (marketplace-root)

```
appwrite-nl-cursor-plugin/
├── .cursor-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── .claude-plugin/
│   └── marketplace.json
├── rules/                    ← always-on Appwrite platform rules
├── skills/
├── commands/
├── hooks/
├── templates/
│   ├── project-mcp.json
│   └── project-cursor-settings.json
├── .mcp.json                 ← appwrite-docs (hosted)
└── bin/
    ├── appwrite-mcp.sh
    ├── link-launcher.sh
    └── on-workspace-open.sh
```

### Vereisten

- `uv` / `uvx` voor `mcp-server-appwrite`
- `APPWRITE_API_KEY` + project-id in workspace `.env.local`
- `~/.local/bin/appwrite-nl-mcp` via `bin/link-launcher.sh`
- **Git:** minstens **één commit** op `main` in deze plugin-repo bij lokale marketplace-install

## appwrite.io vs appwrite.nl

- **Cloud/API default:** `https://appwrite.nl/v1`
- **CLI install & docs links** kunnen nog `appwrite.io` gebruiken (upstream tooling/docs); geen product-endpoint-wijziging.

## Rules (overzicht)

- **tablesdb** — TablesDB-terminologie; types via config/`specs/types.ts`; projectregels winnen
- **secrets-deploy** — workspace `.env`, geen `VITE_`-geheimen; geen push bij `providerRepositoryId`
- **config-cli** — `appwrite.config.json` SSOT; stack volgt het project

## Skills (overzicht)

- **appwrite-cli** — CLI, deploy, TablesDB, `appwrite.config.json`
- **appwrite-typescript** — `appwrite`, `node-appwrite`, TablesDB, functions
- **appwrite-workspace-env** — waar credentials vandaan komen

## Licentie

MIT — zie `LICENSE` (Appwrite upstream).
