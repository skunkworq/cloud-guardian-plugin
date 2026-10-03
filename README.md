# 🛡️☁️ Cloud Guardian for Codex

Cloud Guardian brings your connected cloud inventory, cost explanations, and
project context into Codex. The plugin bundles the local `cg-mcp` server with two
skills: `setup` for sign-in and onboarding, and `cloud-costs` for investigating
spend with the right organization and project scope.

## Install

Requires Codex with the `plugin` CLI commands and a macOS or Linux computer.
The installer downloads a platform binary from the public
[Cloud Guardian binary releases](https://github.com/skunkworq/homebrew-tap/releases),
checks its SHA-256 checksum, and installs it in `~/.local/bin/cg-mcp`.

```sh
curl -fsSL https://raw.githubusercontent.com/skunkworq/cloud-guardian-plugin/main/install.sh -o /tmp/install-cloud-guardian-mcp.sh
bash /tmp/install-cloud-guardian-mcp.sh
codex plugin marketplace add skunkworq/cloud-guardian-plugin --ref main
codex plugin add cloud-guardian@cloud-guardian
codex plugin list --marketplace cloud-guardian
```

Restart Codex or open a new chat so the installed skills and tools load. Ask:

> Set up Cloud Guardian and show my cloud cost overview.

You can explicitly invoke `$cloud-guardian:setup` or
`$cloud-guardian:cloud-costs` in a chat. Open the plugin browser with `/plugins`
in Codex CLI to find **🛡️☁️ Cloud Guardian** under the **Cloud Guardian** marketplace.
This is a GitHub repository marketplace; it is separate from OpenAI's public
plugin directory review process.

## First run

1. Ask Codex to call `cg_login`. It opens your browser and waits while you sign
   in; the tool returns your email after authentication completes.
2. Confirm your identity with `cg_whoami`, list your organizations with
   `cg_list_organizations`, and choose the organization to use.
3. Ask to open the cloud cost overview. Codex calls `cg_open_overview` with your
   `org_id`. Select a project or mention it in the composer when supported.
4. If no providers are connected, ask for provider setup. Cloud Guardian will
   guide you through the provider's browser consent or credential setup.
   Connecting a provider can create a connector and trigger an initial scan;
   authorize that step when you want it to happen.

Read [MCP onboarding](https://cloudguard.dev/docs/mcp/auth) and
[example workflows](https://cloudguard.dev/docs/mcp/workflows). Provider credentials
belong in the provider setup flow, rather than the plugin's configuration.

The native overview requires an MCP Apps host that supports the relevant
[OpenAI MCP extensions](https://github.com/openai/mcp-extensions). Tools also
return text for other hosts. This package uses a local stdio process in Codex
desktop/CLI; a ChatGPT web installation needs a hosted MCP service.

## Update or remove

```sh
# Update the binary, refresh the marketplace, and install the current package.
bash /tmp/install-cloud-guardian-mcp.sh
codex plugin marketplace upgrade cloud-guardian
codex plugin add cloud-guardian@cloud-guardian

# Remove the plugin and its marketplace registration.
codex plugin remove cloud-guardian@cloud-guardian
codex plugin marketplace remove cloud-guardian
```

Download the installer again before updating if you no longer have the file.
Removing the plugin does not delete your Cloud Guardian account, provider
connections, or the local sign-in file at `~/.config/cloud-guardian/auth.json`. Remove
that file separately if you want to clear the saved sign-in on this computer.

## MCP only

For a host that does not support plugins, use the same binary directly:

```sh
bash /tmp/install-cloud-guardian-mcp.sh --register-codex
codex mcp get cloud-guardian
```

Choose either this registration or the plugin, so the server loads once.
The installer also supports `--version v0.1.0` and `--install-dir /absolute/path`;
run it with `--help` for the complete options. Windows binaries are available in
the release assets for manual stdio configuration; the plugin launcher and
installer currently require Bash on macOS/Linux.

## Troubleshooting

- **Plugin commands are unavailable:** update your Codex CLI and check
  `codex plugin --help`.
- **Binary is missing:** rerun the installer. The launcher checks PATH and
  `~/.local/bin/cg-mcp`. Set `CLOUD_GUARDIAN_MCP_BINARY` to an absolute binary path
  for a custom location.
- **Signed out:** call `cg_login` and complete the browser flow.
- **Wrong organization:** choose an organization and pass its `org_id` to scoped
  tools. Both `cg_onboarding_start` and the web guided wizard use the default
  organization. For another organization, use a provider onboarding tool that
  accepts an explicit `org_id`.
- **No overview UI:** ask Codex for a text cost breakdown. UI support depends
  on your host's MCP Apps capabilities.
- **Costs are incomplete:** billing and scanner estimates are shown separately;
  partial, stale, or unavailable results are not evidence of zero spend.

Questions and issues: [GitHub issues](https://github.com/skunkworq/cloud-guardian-plugin/issues).
Service [privacy policy](https://cloudguard.dev/privacy) and
[terms](https://cloudguard.dev/terms) apply to the connected Cloud Guardian service.

## Package and releases

The public repo contains only `.agents/plugins/marketplace.json`,
`plugins/cloud-guardian/`, `install.sh`, and this README. Backend source,
credentials, private configuration, and compiled binaries are not part of the
plugin repository. The MCP binary is distributed separately through the public
Homebrew tap releases with tags `cg-mcp-v<version>`.

Maintainers work in the private Cloud Guardian source repo. To prepare updates:

```sh
# In the private source checkout:
scripts/build-mcp-release.sh /tmp/cloud-guardian-mcp-release
scripts/export-codex-plugin.sh /tmp/cloud-guardian-plugin-export
```

Review the export inventory, commit the exported files to the public plugin repo,
and publish the MCP assets with `SHA256SUMS` under the matching release tag. Bump
both plugin manifests together when package contents change. The dispatch-only
MCP release workflow always produces build artifacts; optional cross-repository
publication needs an `MCP_RELEASE_TOKEN` with contents-write access to the binary
distribution repo. Do not add tokens to the plugin package.

The plugin package uses the portable Agent Plugins manifest and a matching
Codex compatibility manifest. Refer to the
[OpenAI packaging documentation](https://developers.openai.com/plugins/build/plugins)
for the marketplace format and supported installation commands.
