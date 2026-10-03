#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CLOUD_GUARDIAN_MCP_BINARY:-}" ]]; then
  if [[ "$CLOUD_GUARDIAN_MCP_BINARY" != /* || ! -x "$CLOUD_GUARDIAN_MCP_BINARY" ]]; then
    printf '%s\n' 'CLOUD_GUARDIAN_MCP_BINARY must point to an absolute executable path.' >&2
    exit 126
  fi
  exec "$CLOUD_GUARDIAN_MCP_BINARY"
fi

# Desktop clients may not inherit the shell's ~/.local/bin PATH entry.
if command -v cg-mcp >/dev/null 2>&1; then
  exec cg-mcp
fi

if [[ -x "${HOME}/.local/bin/cg-mcp" ]]; then
  exec "${HOME}/.local/bin/cg-mcp"
fi

printf '%s\n' \
  'Cloud Guardian could not find cg-mcp.' \
  'Install the MCP runtime by running bash install.sh in a checkout of' \
  'https://github.com/skunkworq/cloud-guardian-plugin.' \
  'Then restart the Cloud Guardian MCP connection.' >&2
exit 127
