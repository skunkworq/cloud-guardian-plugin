# Installation and connection

The package bundles skills and a stdio MCP definition. Its launcher discovers
`cg-mcp` on `PATH` or at `~/.local/bin/cg-mcp`; it connects to
`https://api.cloudguard.dev` and uses `https://cloudguard.dev` for browser sign-in
unless `CLOUD_GUARDIAN_API_URL` and `CLOUD_GUARDIAN_WEB_URL` are set.

Use the repository's [installation guide](https://github.com/skunkworq/cloud-guardian-plugin#readme) and
the commands supported by the installed Codex version. The marketplace is
`cloud-guardian`; the plugin selector is `cloud-guardian@cloud-guardian`.

Install the SHA256-verified runtime from the public binary releases and register
the public plugin marketplace. macOS and Linux assets are compressed; the
installer verifies their checksum before extraction and replaces the binary
only after validation succeeds:

```sh
curl -fsSL https://raw.githubusercontent.com/skunkworq/cloud-guardian-plugin/main/install.sh -o /tmp/install-cloud-guardian-mcp.sh
bash /tmp/install-cloud-guardian-mcp.sh --version v0.1.2
codex plugin marketplace add skunkworq/cloud-guardian-plugin --ref main
codex plugin add cloud-guardian@cloud-guardian
codex plugin list --marketplace cloud-guardian
```

For an existing local marketplace checkout:

```sh
codex plugin marketplace add .
codex plugin add cloud-guardian@cloud-guardian
```

Restart the MCP connection and begin a new chat after installation. In the
Codex desktop app, find **🛡️☁️ Cloud Guardian** in Plugins. Sign in by asking
Codex to call `cg_login`, then verify with `cg_whoami`.

To update the marketplace skills and configuration:

```sh
codex plugin marketplace upgrade cloud-guardian
codex plugin add cloud-guardian@cloud-guardian
```

Update `cg-mcp` separately using the repository's `install.sh --version v0.1.2`; marketplace refresh
does not replace a previously installed executable. If an older Codex CLI has
no `plugin` subcommand, use a supported Codex release or register the executable
as a bare MCP server with the installer's `--register-codex` option. That fallback
provides tools; install the skills separately if the workflow requires them.

If tools appear twice, inspect the installed plugin and bare MCP connections
and remove only the redundant connection after confirming which one is in use.
If `cg-mcp` cannot be found, rerun the installer. For a custom install location,
set `CLOUD_GUARDIAN_MCP_BINARY` to an absolute executable path in the host's
environment. The launcher falls back to `~/.local/bin` when a desktop app's
`PATH` omits it. If no native view appears, confirm the
host supports MCP Apps and the OpenAI MCP extensions. Successful tools/list
does not imply support for every native host surface.

Version 0.1.2 adds immediate native opens, session snapshot updates, and paginated project search. Vercel CLI billing exploration remains available.
Restart the MCP connection after replacing the binary so an old process or
embedded view is not still in use. A current local Vercel CLI and `vercel login`
are required for `cg_explore_vercel_costs`; Cloud Guardian login is not required
for that tool. An optional `VERCEL_CLI_BINARY` must be an absolute executable
path. Read [Vercel setup](vercel.md) for CLI checks and the separate upcoming
persistent connector path.
