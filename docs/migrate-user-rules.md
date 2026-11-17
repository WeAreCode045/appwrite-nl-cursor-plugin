# Migrate Appwrite rules out of Cursor User Rules

Do this once in **Cursor Settings → Rules** (account user rules), so Appwrite guidance only loads when `appwrite-nl-cursor-plugin` is enabled.

## Remove or replace

| Was (user rule) | Now |
|---|---|
| **Universal Architecture & Multi-Agent** (TablesDB, `contract.json`, Agent 1–4, Tailwind, “no collections”) | Plugin rules `tablesdb`, `config-cli`, `secrets-deploy` |
| **No Push to appwrite if … providerRepositoryId** | Plugin rule `secrets-deploy` |

## Keep in user rules

- Opdracht afronden, git/PR-workflow, communicatiestijl, algemene frontend-designvoorkeuren (met uitzondering: volg altijd het project-designsystem).

## After plugin update

1. Pull/install plugin **1.1.0+** (of lokale marketplace herladen).
2. Restart Cursor / Reload Window.
3. In Customize → Rules: controleer dat de drie plugin-rules zichtbaar zijn onder de plugin.
4. Verwijder de oude Appwrite-user-rules hierboven.
