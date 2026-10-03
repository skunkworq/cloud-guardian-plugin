# 🛡️☁️ Cloud Guardian plugin

Bring cloud cost reviews, provider onboarding, and project context into Codex.
This package contains the Cloud Guardian MCP connector, a `setup` skill, and a
`cloud-costs` skill. Install the local runtime and the package together.

```sh
curl -fsSL https://raw.githubusercontent.com/skunkworq/cloud-guardian-plugin/main/install.sh -o /tmp/install-cloud-guardian-mcp.sh
bash /tmp/install-cloud-guardian-mcp.sh
codex plugin marketplace add skunkworq/cloud-guardian-plugin --ref main
codex plugin add cloud-guardian@cloud-guardian
codex plugin list --marketplace cloud-guardian
```

The installer downloads a platform binary from the public
[Cloud Guardian binary releases](https://github.com/skunkworq/homebrew-tap/releases)
and verifies its SHA256 checksum before installing `~/.local/bin/cg-mcp`.
The plugin launcher checks `CLOUD_GUARDIAN_MCP_BINARY` (an optional absolute
executable path), `cg-mcp` on PATH, and the default install location. macOS and
Linux installations require Bash. No provider keys belong in the package.

Start a new chat after installing. Ask “Set up Cloud Guardian and open my cloud
cost overview.” Sign in through `cg_login`, verify with `cg_whoami`, and select
your organization. Invoke `$cloud-guardian:setup` for onboarding or
`$cloud-guardian:cloud-costs` to investigate spend. Provider onboarding begins
only when the user requests it; completing a guided authorization can also
start the first inventory scan.

Compatible Codex desktop hosts can open **Cloud cost overview** in the sidebar
or a chat tab and mention connected projects in the composer. Tools return
text for other MCP hosts. This stdio package runs locally; ChatGPT web needs a
hosted MCP connection. Use one Cloud Guardian connection per client.

To update, download and run `install.sh` again, then refresh the marketplace and
reinstall the current plugin package:

```sh
codex plugin marketplace upgrade cloud-guardian
codex plugin add cloud-guardian@cloud-guardian
```

Read the [marketplace page](https://cloudguard.dev/plugins/cloud-guardian),
[MCP onboarding](https://cloudguard.dev/docs/mcp/auth), and
[example workflows](https://cloudguard.dev/docs/mcp/workflows).
Source and issues are in the public
[Cloud Guardian plugin repository](https://github.com/skunkworq/cloud-guardian-plugin).

The root `plugin.json` and `mcp.json` use the portable Agent Plugins package
format. `.codex-plugin/plugin.json` and `.mcp.json` provide Codex compatibility;
keep identity, version, presentation, and server configuration synchronized.
The public GitHub marketplace is installed through Codex's supported CLI
commands and does not imply listing in OpenAI's public plugin directory.
