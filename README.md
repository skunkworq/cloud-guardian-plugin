# 🛡️☁️ Cloud Guardian for Codex

Cloud Guardian brings connected cloud inventory, cost explanations, Vercel
billing, and project context into Codex. The plugin bundles the local `cg-mcp`
server with two skills: `setup` for sign-in and onboarding, and `cloud-costs`
for investigating spend with the right account, period, and project scope.

Plugin package **0.1.4** uses MCP runtime **0.1.5**. Package documentation and
skills can update independently of the binary; the commands below pin the
runtime explicitly.

## Install

Requires Codex with the `plugin` CLI commands and a macOS or Linux computer.
The installer downloads a platform binary from the public
[Cloud Guardian binary releases](https://github.com/skunkworq/homebrew-tap/releases),
checks its SHA-256 checksum, and installs it in `~/.local/bin/cg-mcp`.
macOS and Linux downloads are compressed to reduce transfer time; the installer
verifies the archive before extracting it and replacing an existing binary.

```sh
curl -fsSL https://raw.githubusercontent.com/skunkworq/cloud-guardian-plugin/main/install.sh -o /tmp/install-cloud-guardian-mcp.sh
bash /tmp/install-cloud-guardian-mcp.sh --version v0.1.5
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

## First run: explore Vercel billing

For immediate Vercel costs, install or update the
[Vercel CLI](https://vercel.com/docs/cli), run
[`vercel login`](https://vercel.com/docs/cli/login), and check `vercel whoami`.
This path uses your existing local Vercel login and requires no Cloud Guardian
sign-in, organization, persistent connector, or scan.

```text
$cloud-guardian:cloud-costs
Explore Vercel costs for team YOUR_TEAM_SLUG_OR_ID.
Show billed and effective costs with the billing period and project/service details.
```

The `cg_explore_vercel_costs` tool takes a required `team` slug or ID. It uses
the current billing period by default; optional paired `from_date` and `to_date`
accept `YYYY-MM-DD` dates in America/Los_Angeles. Use the returned period and
observation time as evidence, and keep provisional current-period charges
separate from resource monthly run-rate. See the
[CLI usage reference](https://vercel.com/docs/cli/usage).

The native overview offers an explicit **Explore Vercel costs** button after
you enter a team. It never requests Vercel costs automatically on opening.
If the desktop host cannot find the CLI, set `VERCEL_CLI_BINARY` to its absolute
executable path in the MCP host's environment and restart the connection.

For a requested persistent Vercel connection, sign in to Cloud Guardian and
call `cg_onboard_vercel` with an explicit `org_id` and a `team_...` team ID.
For a new connector, supply a dedicated API token through
`CLOUD_GUARDIAN_VERCEL_TOKEN` or the optional `api_token` parameter. Matching
team connectors are reused without requiring a new token. Onboarding tests
access; scheduled collection supplies saved billing and linked projects. Request
a fresh team-only scan separately when needed. Keep the CLI's OAuth credentials
under the CLI's control; do not copy them into a saved connector. See the packaged
[Vercel setup guide](plugins/cloud-guardian/skills/setup/references/vercel.md)
and the [billing API reference](https://vercel.com/docs/rest-api/billing/list-focus-billing-charges).

## First run: saved Cloud Guardian costs

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

MCP runtime 0.1.5 opens the native app immediately through `cg_overview_app` and
loads complete saved costs in the background. A recent session snapshot stays
visible while updating, with its load time shown. Complete results are fresh
for 30 seconds; the app can reuse a snapshot up to five minutes old while it
requests fresh data. Snapshots are held only in the running MCP process and
are isolated by sign-in session and organization. Normal token renewal keeps
the cache; a new sign-in invalidates it.

Runtime 0.1.5 adds organization selection to the overview and keeps saved cost
reads scoped to the selected organization. Regional resources keep distinct
identities, and cost details identify allocated billing, partial pricing, and
unavailable estimates. Billing totals are net of provider credits; estimated
credits apply only to the scanner estimate portion and are not subtracted from
the displayed combined total.

Project search and pagination keep large inventories responsive. **Refresh**
waits for a new saved-data read and does not start a provider scan. The full
`cg_open_overview` tool still returns a complete text summary for other clients.
Initial cost-read time depends on the API; opening the native app no longer
waits for that read to finish.

## Update or remove

```sh
# Update the binary, refresh the marketplace, and install the current package.
bash /tmp/install-cloud-guardian-mcp.sh --version v0.1.5
codex plugin marketplace upgrade cloud-guardian
codex plugin add cloud-guardian@cloud-guardian

# Remove the plugin and its marketplace registration.
codex plugin remove cloud-guardian@cloud-guardian
codex plugin marketplace remove cloud-guardian
```

Download the installer again before updating. Restart the MCP connection and
start a new chat afterward; updating the marketplace alone does not replace a
previously installed executable or running process.
Removing the plugin does not delete your Cloud Guardian account, provider
connections, or the local sign-in file at `~/.config/cloud-guardian/auth.json`. Remove
that file separately if you want to clear the saved sign-in on this computer.

## MCP only

For a host that does not support plugins, use the same binary directly:

```sh
bash /tmp/install-cloud-guardian-mcp.sh --version v0.1.5 --register-codex
codex mcp get cloud-guardian
```

Choose either this registration or the plugin, so the server loads once.
The installer also supports `--version v0.1.5` and `--install-dir /absolute/path`;
run it with `--help` for the complete options. Windows cross-builds are available
in the release assets for development. Browser sign-in currently works on
macOS/Linux, which are also required by the plugin launcher and installer.

## Troubleshooting

- **Plugin commands are unavailable:** update your Codex CLI and check
  `codex plugin --help`.
- **Binary is missing:** rerun the installer. The launcher checks PATH and
  `~/.local/bin/cg-mcp`. Set `CLOUD_GUARDIAN_MCP_BINARY` to an absolute binary path
  for a custom location.
- **Signed out:** call `cg_login` and complete the browser flow.
- **Vercel billing login or CLI is unavailable:** update the Vercel CLI, run
  `vercel login` / `vercel whoami`, and verify access to the requested team's
  billing. Cloud Guardian login does not sign you in to Vercel.
- **Wrong organization:** choose an organization and pass its `org_id` to scoped
  tools. Both `cg_onboarding_start` and the web guided wizard use the default
  organization. For another organization, use a provider onboarding tool that
  accepts an explicit `org_id`.
- **No overview UI:** ask Codex for a text cost breakdown. UI support depends
  on your host's MCP Apps capabilities.
- **Still waiting on an old overview:** install runtime 0.1.5, restart the MCP
  connection, and open a new view. The new view automatically requests saved
  data when the host omits its opening result; a provider scan is not required.
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

Maintainers work in the private Cloud Guardian source repo. Plugin package and
MCP runtime versions advance independently. Package 0.1.4 uses runtime 0.1.5;
keep installation examples pinned to `--version v0.1.5` until a new runtime is
released and verified. Documentation or skill changes can bump the package
without rebuilding or republishing the binary.

To prepare a package export and, when runtime code changes, binary assets:

```sh
# In the private source checkout; only build for a runtime release:
scripts/build-mcp-release.sh /tmp/cloud-guardian-mcp-release
scripts/export-codex-plugin.sh /tmp/cloud-guardian-plugin-export
```

Review the export inventory and commit the exported files to the public plugin
repo. For a runtime release, publish its MCP assets with `SHA256SUMS` under the
tag matching the runtime version, such as `cg-mcp-v0.1.5`. Bump both plugin
manifests together when package contents change and record the runtime pin in
the installation guides. The dispatch-only
MCP release workflow always produces build artifacts; optional cross-repository
publication needs an `MCP_RELEASE_TOKEN` with contents-write access to the binary
distribution repo. Do not add tokens to the plugin package.

The plugin package uses the portable Agent Plugins manifest and a matching
Codex compatibility manifest. Refer to the
[OpenAI packaging documentation](https://developers.openai.com/plugins/build/plugins)
for the marketplace format and supported installation commands.
