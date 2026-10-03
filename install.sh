#!/usr/bin/env bash
# Install the standalone Cloud Guardian MCP server from public release assets.
set -euo pipefail

RELEASE_REPO="${CLOUD_GUARDIAN_MCP_RELEASE_REPO:-skunkworq/homebrew-tap}"
TAG_PREFIX=cg-mcp-v
VERSION="${VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
REGISTER_CODEX=false
DOWNLOAD_DIR=''
STAGED_BINARY=''

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
cleanup() {
  if [[ -n "$STAGED_BINARY" ]]; then rm -f -- "$STAGED_BINARY"; fi
  if [[ -n "$DOWNLOAD_DIR" ]]; then rm -rf -- "$DOWNLOAD_DIR"; fi
}
trap cleanup EXIT

usage() {
  # Shell variables and command examples are literal help text.
  # shellcheck disable=SC2016
  printf '%s\n' \
    'Cloud Guardian MCP installer ☁️🛡️' \
    '' \
    'Usage: install-mcp.sh [OPTIONS]' \
    '' \
    '  --version VERSION    Release version (default: latest; accepts 1.2.3 or v1.2.3)' \
    '  --install-dir DIR    Binary directory (default: $HOME/.local/bin)' \
    '  --repo OWNER/REPO    Public GitHub release repository' \
    '  --register-codex     Register the standalone server with `codex mcp add`' \
    '  --help              Show this help' \
    '' \
    'Environment: VERSION, INSTALL_DIR, CLOUD_GUARDIAN_MCP_RELEASE_REPO' \
    '' \
    'Install the Codex plugin separately to get its skills and marketplace entry.' \
    'Use --register-codex for standalone MCP only; the plugin registers its own MCP.'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version|--install-dir|--repo)
      [[ $# -ge 2 && -n "$2" ]] || fail "$1 needs a value"
      case "$1" in
        --version) VERSION="$2" ;;
        --install-dir) INSTALL_DIR="$2" ;;
        --repo) RELEASE_REPO="$2" ;;
      esac
      shift 2
      ;;
    --register-codex) REGISTER_CODEX=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
done

[[ "$RELEASE_REPO" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || fail 'Release repository must be OWNER/REPO'
if [[ "$REGISTER_CODEX" == true ]]; then
  command -v codex >/dev/null 2>&1 || fail 'Install Codex CLI before using --register-codex'
fi
command -v curl >/dev/null 2>&1 || fail 'curl is required'
if command -v sha256sum >/dev/null 2>&1; then
  HASH_COMMAND=sha256sum
elif command -v shasum >/dev/null 2>&1; then
  HASH_COMMAND=shasum
else
  fail 'sha256sum or shasum is required to verify the download'
fi

case "$(uname -s)" in
  Darwin) PLATFORM=darwin ;;
  Linux) PLATFORM=linux ;;
  *) fail 'This installer supports macOS and Linux; download the Windows .exe from the release page' ;;
esac
case "$(uname -m)" in
  arm64|aarch64) ARCH=arm64 ;;
  x86_64|amd64) ARCH=amd64 ;;
  armv7l) ARCH=arm ;;
  *) fail 'Unsupported architecture' ;;
esac
if [[ "$PLATFORM/$ARCH" == darwin/arm ]]; then fail 'Unsupported platform: darwin/arm'; fi

DOWNLOAD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/cloudguardian-mcp.XXXXXX")"
download() {
  curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error "$1" -o "$2"
}
if [[ "$VERSION" == latest ]]; then
  download "https://api.github.com/repos/$RELEASE_REPO/releases?per_page=100" "$DOWNLOAD_DIR/releases.json"
  if command -v jq >/dev/null 2>&1; then
    VERSION="$(jq -r --arg prefix "$TAG_PREFIX" \
      '[.[] | select(.draft == false and .prerelease == false) | .tag_name | select(startswith($prefix))] | first // empty' \
      "$DOWNLOAD_DIR/releases.json")"
  else
    # The tag must be a stable SemVer release. Public API responses exclude
    # unpublished drafts; the strict pattern also excludes prerelease tags.
    VERSION="$(sed -nE 's/.*"tag_name":[[:space:]]*"cg-mcp-v([0-9]+\.[0-9]+\.[0-9]+)".*/\1/p' "$DOWNLOAD_DIR/releases.json" | head -n 1)"
  fi
  [[ -n "$VERSION" ]] || fail "No published cg-mcp release found in $RELEASE_REPO; build services/cmd/mcp from the source checkout instead"
fi
VERSION="${VERSION#"$TAG_PREFIX"}"
VERSION="${VERSION#v}"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] || fail 'Version must be a SemVer such as 1.2.3'

RAW_ASSET="cg-mcp_${PLATFORM}_${ARCH}"
ASSET="$RAW_ASSET"
BASE_URL="https://github.com/$RELEASE_REPO/releases/download/${TAG_PREFIX}${VERSION}"
printf 'Downloading Cloud Guardian MCP %s for %s/%s\n' "$VERSION" "$PLATFORM" "$ARCH"
download "$BASE_URL/SHA256SUMS" "$DOWNLOAD_DIR/SHA256SUMS"
COMPRESSED_COUNT="$(awk -v name="$RAW_ASSET.gz" '$2 == name || $2 == "*" name { count++ } END { print count + 0 }' "$DOWNLOAD_DIR/SHA256SUMS")"
if [[ "$COMPRESSED_COUNT" -gt 1 ]]; then
  fail "SHA256SUMS must contain exactly one checksum for $RAW_ASSET.gz"
elif [[ "$COMPRESSED_COUNT" == 1 ]]; then
  if command -v gzip >/dev/null 2>&1; then
    ASSET="$RAW_ASSET.gz"
  elif ! awk -v name="$RAW_ASSET" '$2 == name || $2 == "*" name { found = 1 } END { exit !found }' "$DOWNLOAD_DIR/SHA256SUMS"; then
    fail 'gzip is required to install this compressed release'
  fi
fi
EXPECTED_HASH="$(awk -v name="$ASSET" '$2 == name || $2 == "*" name { print $1; count++ } END { if (count != 1) exit 1 }' "$DOWNLOAD_DIR/SHA256SUMS")" \
  || fail "SHA256SUMS must contain exactly one checksum for $ASSET"
[[ "$EXPECTED_HASH" =~ ^[0-9a-f]{64}$ ]] || fail 'Invalid SHA256 checksum in release'
download "$BASE_URL/$ASSET" "$DOWNLOAD_DIR/$ASSET"
if [[ "$HASH_COMMAND" == shasum ]]; then
  ACTUAL_HASH="$(shasum -a 256 "$DOWNLOAD_DIR/$ASSET" | awk '{print $1}')"
else
  ACTUAL_HASH="$(sha256sum "$DOWNLOAD_DIR/$ASSET" | awk '{print $1}')"
fi
[[ "$ACTUAL_HASH" == "$EXPECTED_HASH" ]] || fail 'SHA256 verification failed; existing installation was preserved'
if [[ "$ASSET" == "$RAW_ASSET.gz" ]]; then
  gzip -dc -- "$DOWNLOAD_DIR/$ASSET" > "$DOWNLOAD_DIR/$RAW_ASSET" \
    || fail 'gzip decompression failed; existing installation was preserved'
fi

mkdir -p -- "$INSTALL_DIR"
INSTALL_DIR="$(cd -- "$INSTALL_DIR" && pwd -P)"
DEST="$INSTALL_DIR/cg-mcp"
STAGED_BINARY="$INSTALL_DIR/.cg-mcp.$$.tmp"
install -m 0755 "$DOWNLOAD_DIR/$RAW_ASSET" "$STAGED_BINARY"
mv -f -- "$STAGED_BINARY" "$DEST"
STAGED_BINARY=''
printf 'Installed ☁️🛡️ Cloud Guardian MCP: %s\n' "$DEST"

if [[ "$REGISTER_CODEX" == true ]]; then
  codex mcp add cloud-guardian -- "$DEST"
  printf 'Registered standalone MCP. Restart Codex and ask Cloud Guardian to sign in.\n'
else
  printf 'Install the Codex plugin for skills, or register standalone MCP with:\n'
  printf '  codex mcp add cloud-guardian -- %q\n' "$DEST"
fi
