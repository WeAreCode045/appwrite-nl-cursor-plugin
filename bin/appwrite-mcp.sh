#!/usr/bin/env bash
# Appwrite MCP launcher (project API).
# Credentials from the open workspace .env.local / .env.
# Endpoint priority: env file → APPWRITE_DEFAULT_ENDPOINT → ~/.cursor/appwrite-nl/default-endpoint
#   (written by plugin Configure via appwrite-endpoint MCP) → error if still empty.
# Stdout is reserved for MCP — diagnostics go to stderr.
set -u
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

STATE_DIR="${HOME}/.cursor/appwrite-nl"
ACTIVE_WORKSPACE_FILE="${STATE_DIR}/active-workspace"
DEFAULT_ENDPOINT_FILE="${STATE_DIR}/default-endpoint"

start="${1:-}"
case "$start" in ""|*'${'*|\$*) start="";; esac
[ -z "$start" ] && start="${CURSOR_WORKSPACE_FOLDER:-${CURSOR_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-}}}"
if [ -z "$start" ] && [ -f "$ACTIVE_WORKSPACE_FILE" ]; then
  start=$(tr -d '\r\n' < "$ACTIVE_WORKSPACE_FILE" || true)
fi
[ -z "$start" ] && start="$PWD"
[ -d "$start" ] || start="$PWD"

read_var() { # $1=file $2=var name → value on stdout
  local line
  line=$(grep -E "^[[:space:]]*(export[[:space:]]+)?$2[[:space:]]*=" "$1" 2>/dev/null | tail -n1)
  [ -n "$line" ] || return 1
  line="${line#*=}"; line="${line%$'\r'}"
  line=$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  case "$line" in
    \"*) line=$(printf '%s' "$line" | sed -E 's/^"([^"]*)".*$/\1/');;
    \'*) line=$(printf '%s' "$line" | sed -E "s/^'([^']*)'.*\$/\\1/");;
    *)   line=$(printf '%s' "$line" | sed -E 's/[[:space:]]+#.*$//');;
  esac
  [ -n "$line" ] || return 1
  printf '%s' "$line"
}

resolve_fallback_endpoint() {
  local ep=""
  ep=$(printf '%s' "${APPWRITE_DEFAULT_ENDPOINT:-}" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  case "$ep" in ""|*'${'*) ep="";; esac
  if [ -n "$ep" ]; then
    printf '%s' "$ep"
    return 0
  fi
  if [ -f "$DEFAULT_ENDPOINT_FILE" ]; then
    ep=$(tr -d '\r\n' < "$DEFAULT_ENDPOINT_FILE" || true)
    ep=$(printf '%s' "$ep" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
    if [ -n "$ep" ]; then
      printf '%s' "$ep"
      return 0
    fi
  fi
  return 1
}

read_endpoint() {
  local f="$1" ep=""
  for v in APPWRITE_ENDPOINT VITE_APPWRITE_ENDPOINT; do
    ep=$(read_var "$f" "$v") && printf '%s' "$ep" && return 0
    ep=""
  done
  resolve_fallback_endpoint
}

read_project_id() {
  local f="$1" pid=""
  for v in APPWRITE_PROJECT_ID APPWRITE_PROJECT \
           VITE_APPWRITE_PROJECT_ID VITE_APPWRITE_PROJECT \
           NEXT_PUBLIC_APPWRITE_PROJECT_ID NEXT_PUBLIC_APPWRITE_PROJECT \
           EXPO_PUBLIC_APPWRITE_PROJECT_ID PUBLIC_APPWRITE_PROJECT_ID \
           NUXT_PUBLIC_APPWRITE_PROJECT_ID; do
    pid=$(read_var "$f" "$v") && printf '%s' "$pid" && return 0
    pid=""
  done
  return 1
}

try_env_file() {
  local f="$1"
  [ -f "$f" ] || return 1
  local key pid endpoint
  key=$(read_var "$f" APPWRITE_API_KEY) || return 1
  pid=$(read_project_id "$f") || {
    echo "appwrite-mcp: APPWRITE_API_KEY in $f but no project id (APPWRITE_PROJECT_ID or VITE_APPWRITE_PROJECT_ID)" >&2
    return 1
  }
  endpoint=$(read_endpoint "$f") || {
    echo "appwrite-mcp: no endpoint in $f and no default (set APPWRITE_ENDPOINT in .env, or Plugins → Configure → Default Appwrite endpoint)" >&2
    return 1
  }
  echo "appwrite-mcp: project '$pid' on $endpoint (from $f)" >&2
  export APPWRITE_ENDPOINT="$endpoint" APPWRITE_PROJECT_ID="$pid" APPWRITE_API_KEY="$key"
  return 0
}

collect_env_candidates() {
  local dir="$1"
  local -a out=()
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    for f in "$dir/.env.local" "$dir/.env"; do
      out+=("$f")
    done
    [ "$dir" = "$HOME" ] && break
    dir=$(dirname "$dir")
  done
  printf '%s\n' "${out[@]}"
}

env_geladen=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if try_env_file "$f"; then
    env_geladen=1
    break
  fi
done < <(collect_env_candidates "$start")

if [ "$env_geladen" = 1 ]; then
  # Exec once after candidate scanning — exec inside the loop left stdio in a state
  # where mcp-server-appwrite's transport closed ~150ms after "ready" (Cursor -32000).
  exec uvx mcp-server-appwrite
fi

echo "appwrite-mcp: no .env.local/.env with APPWRITE_API_KEY and a project id found from $start" >&2
echo "appwrite-mcp: add APPWRITE_API_KEY and APPWRITE_PROJECT_ID (or VITE_APPWRITE_PROJECT_ID) to workspace .env.local" >&2
exit 1
