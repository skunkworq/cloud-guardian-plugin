#!/usr/bin/env bash
set -euo pipefail

# Add local CLI/Node directories only after choosing the MCP runtime, so a
# desktop client's small PATH can run Vercel without changing cg-mcp priority.
cloud_guardian_add_cli_path() {
  local cloud_guardian_cli_dir
  for cloud_guardian_cli_dir in \
    "${HOME}/Library/pnpm/bin" \
    "${HOME}/.local/bin" \
    /opt/homebrew/bin \
    /usr/local/bin; do
    if [[ -d "$cloud_guardian_cli_dir" ]]; then
      case ":${PATH:-}:" in
        *":${cloud_guardian_cli_dir}:"*) ;;
        *) PATH="${PATH:+${PATH}:}${cloud_guardian_cli_dir}" ;;
      esac
    fi
  done
  export PATH
}

if [[ -n "${CLOUD_GUARDIAN_MCP_BINARY:-}" ]]; then
  if [[ "$CLOUD_GUARDIAN_MCP_BINARY" != /* || ! -x "$CLOUD_GUARDIAN_MCP_BINARY" ]]; then
    printf '%s\n' 'CLOUD_GUARDIAN_MCP_BINARY must point to an absolute executable path.' >&2
    exit 126
  fi
  cloud_guardian_add_cli_path
  exec "$CLOUD_GUARDIAN_MCP_BINARY"
fi

# Desktop clients may not inherit the shell's ~/.local/bin PATH entry.
if command -v cg-mcp >/dev/null 2>&1; then
  cloud_guardian_mcp_binary="$(command -v cg-mcp)"
  cloud_guardian_add_cli_path
  exec "$cloud_guardian_mcp_binary"
fi

if [[ -x "${HOME}/.local/bin/cg-mcp" ]]; then
  cloud_guardian_add_cli_path
  exec "${HOME}/.local/bin/cg-mcp"
fi

printf '%s\n' \
  'Cloud Guardian could not find cg-mcp.' \
  'Install the MCP runtime by running bash install.sh in a checkout of' \
  'https://github.com/skunkworq/cloud-guardian-plugin.' \
  'Then restart the Cloud Guardian MCP connection.' >&2
exit 127
