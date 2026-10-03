# 🛡️☁️ Cloud Guardian plugin

Bring cloud cost reviews, Vercel billing, provider onboarding, and project context into Codex.
This package contains the Cloud Guardian MCP connector, a `setup` skill, and a
`cloud-costs` skill. Install the local runtime and the package together.

Plugin package **0.1.3** uses MCP runtime **0.1.2**. Documentation and skills can
update independently; the runtime install below remains pinned to `v0.1.2`.

```sh
curl -fsSL https://raw.githubusercontent.com/skunkworq/cloud-guardian-plugin/main/install.sh -o /tmp/install-cloud-guardian-mcp.sh
bash /tmp/install-cloud-guardian-mcp.sh --version v0.1.2
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

The `cg_overview_app` sidebar/chat entrypoint opens immediately and loads complete
saved data in the background. It reuses a recent session snapshot while updating
and shows when that snapshot was loaded. Full reads are cached for 30 seconds;
the app can retain a snapshot up to five minutes old during a background update.
A new sign-in invalidates the cache; normal token renewal preserves it. Project
search and pagination keep large inventories responsive. **Refresh** waits for a
new saved-data read. Opening or refreshing does not start a provider scan.

## Explore Vercel costs with your existing login

MCP runtime 0.1.2 can read Vercel billing through a current local Vercel CLI. Install
or update the [Vercel CLI](https://vercel.com/docs/cli), then run
[`vercel login`](https://vercel.com/docs/cli/login) and `vercel whoami`.
Cloud Guardian sign-in and a persistent connector are not required for this path.

```text
$cloud-guardian:cloud-costs
Explore Vercel costs for team YOUR_TEAM_SLUG_OR_ID.
Show billed and effective costs, the billing period, and project/service details.
```

The tool is `cg_explore_vercel_costs` with required `team` and optional paired
`from_date` / `to_date` in `YYYY-MM-DD` format. Without dates it uses the current
billing period. Date filters use America/Los_Angeles; report the returned period
and keep provisional charges separate from resource monthly run-rate.
See the [Vercel usage reference](https://vercel.com/docs/cli/usage).
For a custom CLI location, set `VERCEL_CLI_BINARY` to its absolute executable
path in the MCP host's environment. The native overview also offers an explicit
**Explore Vercel costs** button; it never queries Vercel automatically on opening.

For a requested persistent connection, use `cg_onboard_vercel` after Cloud
Guardian sign-in with an explicit `org_id` and a `team_...` ID. A new connector
requires a dedicated API token; prefer `CLOUD_GUARDIAN_VERCEL_TOKEN` in the MCP
host's environment. Matching connectors are reused without a new token;
onboarding tests access and scheduled collection supplies saved billing and
linked projects. Request a fresh
team-only scan separately when needed. Do not copy the CLI's OAuth credentials
into a backend connector. See [Vercel setup](skills/setup/references/vercel.md) for that separate
workflow and the [billing API](https://vercel.com/docs/rest-api/billing/list-focus-billing-charges).

To update, download and run `install.sh --version v0.1.2` again, then refresh the marketplace and
reinstall the current plugin package:

```sh
codex plugin marketplace upgrade cloud-guardian
codex plugin add cloud-guardian@cloud-guardian
```

Restart the MCP connection and start a new chat after updating. Updating the
marketplace alone does not replace the locally installed `cg-mcp` executable.

Read the [marketplace page](https://github.com/skunkworq/cloud-guardian-plugin#readme),
[MCP onboarding](https://cloudguard.dev/docs/mcp/auth), and
[example workflows](https://cloudguard.dev/docs/mcp/workflows).
Source and issues are in the public
[Cloud Guardian plugin repository](https://github.com/skunkworq/cloud-guardian-plugin).

The root `plugin.json` and `mcp.json` use the portable Agent Plugins package
format. `.codex-plugin/plugin.json` and `.mcp.json` provide Codex compatibility;
keep identity, version, presentation, and server configuration synchronized.
The public GitHub marketplace is installed through Codex's supported CLI
commands and does not imply listing in OpenAI's public plugin directory.
