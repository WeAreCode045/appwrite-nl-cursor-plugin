# appwrite-nl-cursor-plugin

Lokale, ingekorte Cursor-plugin gebaseerd op de Appwrite marketplace-plugin, gericht op **appwrite.nl** en de Code045 / Research Navigator-stack (CLI + TypeScript/Web/Node).

## Wat zit erin

| Onderdeel | Beschrijving |
|-----------|--------------|
| **MCP** | `appwrite-nl` — start `mcp-server-appwrite` met credentials uit de workspace |
| **Skills** | `appwrite-cli`, `appwrite-typescript`, `appwrite-workspace-env` |
| **Commands** | `deploy-function`, `deploy-site` |

Geen Dart, Go, Kotlin, PHP, Python, Ruby, Swift skills (minder tokens).

## Credentials

De MCP-launcher (`bin/appwrite-mcp.sh`) leest **alleen** uit env-bestanden van het project dat in Cursor open staat:

1. Vanaf `${workspaceFolder}` omhoog: `.env.local`, dan `.env`
2. Fallback: `sites/navigator-web/.env.local` / `.env` (monorepo)

| Variabele | Gebruik |
|-----------|---------|
| `APPWRITE_API_KEY` | Server/MCP (verplicht voor MCP) |
| `APPWRITE_PROJECT_ID` (of `VITE_APPWRITE_PROJECT_ID`, …) | Project |
| `APPWRITE_ENDPOINT` (of `VITE_APPWRITE_ENDPOINT`) | Default `https://appwrite.nl/v1` |

**Research Navigator:** zet MCP-credentials in **repo-root** `.env.local` (gitignored). Frontend: `sites/navigator-web/.env` met alleen `VITE_APPWRITE_*` (zie RN `.env.example`).

Kopieer `.env.example` uit deze plugin als sjabloon — commit geen echte keys.

## Installatie in Cursor

Dit is een **lokale marketplace**: één map bevat zowel `marketplace.json` als de plugin (`source: "./"`). Je selecteert die map als marketplace-root — geen aparte submap.

### Verplichte bestanden (marketplace-root)

```
/Users/maurice/Code045/appwrite-nl-cursor-plugin/
├── .cursor-plugin/
│   ├── marketplace.json    ← Cursor zoekt dit bij “Add local plugin”
│   └── plugin.json
├── .claude-plugin/
│   └── marketplace.json    ← zelfde inhoud (fallback voor Cursor)
├── skills/
├── commands/
├── bin/appwrite-mcp.sh
└── .mcp.json
```

### Stappen

1. **Cursor Settings → Plugins** (eventueel **Features → Plugins** of **Beta → Plugins**, afhankelijk van je build).
2. Kies **Add local plugin** / **Install from folder**.
3. Selecteer exact: **`/Users/maurice/Code045/appwrite-nl-cursor-plugin`** (de repo-root, niet `skills/` of `.cursor-plugin/`).
4. Na installatie: enable plugin **appwrite-nl-cursor-plugin** in de pluginlijst.
5. Open je project-workspace (bijv. Research Navigator). Refresh MCP indien nodig; server **`appwrite-nl`** komt uit plugin-`.mcp.json`.
6. Workspace **`.mcp.json`** / **`.cursor/mcp.json`** blijft voor andere servers (bijv. Deepgram).

**Fout “Failed to install” / “Failed to resolve git ref HEAD” (Cursor 3.30.x):** de Agent-host zet `file:///Users/maurice/...` soms om naar een ongeldige SSH-URL `git@:Users/maurice.git` bij `git ls-remote … HEAD`. De manifests wijzen met `repository: file:///Users/maurice/Code045/appwrite-nl-cursor-plugin`; zet lokaal ook een `origin`-remote:

```sh
git -C /Users/maurice/Code045/appwrite-nl-cursor-plugin remote add origin \
  file:///Users/maurice/Code045/appwrite-nl-cursor-plugin 2>/dev/null || \
git -C /Users/maurice/Code045/appwrite-nl-cursor-plugin remote set-url origin \
  file:///Users/maurice/Code045/appwrite-nl-cursor-plugin
```

Daarna: marketplace **Uninstall** → opnieuw **Add local plugin** → plugin inschakelen → **Developer: Reload Window**. Als de toast nog faalt maar de marketplace wel verschijnt, na reload opnieuw inschakelen (backend cacheert dan op commit-hash, niet op `HEAD`).

**Schone herinstallatie (optioneel):**

```sh
rm -rf ~/.cursor/plugins/cache/code045-appwrite-nl
rm -rf ~/.cursor/plugins/marketplaces/_/users/maurice/46889aa*
```

### Vereisten

- `uv` / `uvx` voor `mcp-server-appwrite`
- `APPWRITE_API_KEY` + project-id in workspace `.env.local`
- **Git:** minstens **één commit** op `main` in deze plugin-repo. Cursor resolveert lokale plugins via `git ls-remote … HEAD`; bij `git init` zonder commit faalt dat (foutmeldingen als `git@:Users/maurice.git` of “unresolvable commit for HEAD”). Geen remote nodig.

## appwrite.io vs appwrite.nl

- **Cloud/API default:** `https://appwrite.nl/v1`
- **CLI install & docs links** kunnen nog `appwrite.io` gebruiken (upstream tooling/docs); geen product-endpoint-wijziging.

## Skills (overzicht)

- **appwrite-cli** — CLI, deploy, TablesDB, `appwrite.config.json`
- **appwrite-typescript** — `appwrite`, `node-appwrite`, TablesDB, functions
- **appwrite-workspace-env** — waar credentials vandaan komen

## Licentie

MIT — zie `LICENSE` (Appwrite upstream).