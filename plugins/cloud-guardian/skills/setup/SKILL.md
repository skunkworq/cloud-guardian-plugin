---
name: setup
description: Set up the Cloud Guardian Codex plugin, sign in, select an organization, connect cloud accounts, verify connector health, and open the native cost overview. Use when the user asks to install, onboard, reconnect, or troubleshoot Cloud Guardian.
---

# Set up Cloud Guardian

Connect the account the user requested and verify its real connector and project
state. Use existing authorization and account preferences. Ask for missing scope
only when multiple accounts or organizations are plausible.

## Install and discover

If the plugin's tools are unavailable, read [installation](references/install.md)
and inspect the current client's supported commands. The plugin runs the local
`cg-mcp` executable. Install the executable before enabling the plugin and start
a new chat after installation. Keep one Cloud Guardian MCP connection active in
each client so tools and native entrypoints are not duplicated.

## Sign in and choose the organization

1. Call `cg_whoami`. If it reports that authentication is required, call
   `cg_login`; let the user complete Google Sign-In in their browser, then verify
   with `cg_whoami` again. A successful browser opening alone is not a sign-in.
2. List organizations with `cg_list_organizations`. Reuse the requested
   organization; select the sole organization when unambiguous. When there are
   several and none was specified, resolve the choice before creating connectors.
3. Inspect `cg_list_connectors` and `cg_list_org_projects` using the selected
   `org_id`. Reuse matching healthy connectors instead of creating duplicates.

Authentication uses the executable's loopback browser callback and stores its
session at `~/.config/cloud-guardian/auth.json`. Never print, upload, or commit
this file or provider secrets. For this stdio connection, use `cg_login` rather
than the host's HTTP MCP OAuth login command.

## Connect the requested cloud

Prefer the provider's guided account authorization or Cloud Guardian's
[guided setup](https://cloudguard.dev/admin/connectors) when it avoids copying
credentials into chat.

| Provider | Preferred path |
| --- | --- |
| AWS | `cg_onboarding_start` with `provider="aws"`; provide the returned CloudFormation quick-create link and poll `cg_onboarding_status` with its token. For a requested CLI setup, inspect `cg_onboard_aws` and prefer its least-privilege provisioning flow over admin keys. |
| GCP | `cg_onboarding_start` with `provider="gcp"` and the requested `project_id`; provide the returned OAuth link and poll `cg_onboarding_status`. `cg_onboard_gcp_project` is the alternative when local `gcloud` provisioning was requested. |
| DigitalOcean | `cg_onboarding_start` with `provider="digitalocean"`; provide its OAuth link and poll `cg_onboarding_status`. |
| Neon | `cg_onboard_neon` with `org_id`, omitting `api_key` for the supported browser OAuth flow. |
| Azure, Supabase, Hetzner, Vultr | Use guided setup and the current provider onboarding documentation. Existing provider tools are `cg_onboard_azure`, `cg_onboard_supabase`, `cg_onboard_hetzner`, and `cg_onboard_vultr`; inspect their schemas before supplying credentials. |

`cg_onboarding_start` uses the backend's default organization: it has no
`org_id` parameter. The web guided onboarding also omits an explicit
organization. Selecting an organization in the web UI or an earlier read call
does not establish the guided session's destination. Confirm that the default
is the requested organization before using either guided path. For another
organization, use a provider-specific MCP onboarding tool with an explicit
`org_id`. Do not assume a manual web connector flow provides organization
scope without verifying its requests and project-linking behavior.

Provider-side setup can create service accounts, IAM roles, keys, connectors,
or linked projects. Perform it within the account and scope the user requested.
Keep optional remediation and automatic remediation scopes empty unless those
capabilities were explicitly requested. Do not treat connector onboarding as
authorization to change workloads. Completing a guided provider authorization
also starts the connector's first inventory scan. If the user requested only
plugin installation or sign-in, finish after identity and overview checks;
connect a provider only when that account onboarding was requested. Vultr
connectors provide account inventory
and cost evidence and do not support workload remediation.

Poll an active onboarding session at bounded intervals until it completes,
fails, or expires. If the user must complete a browser step, return its exact
link and describe that step. Report the server's failure detail and resume with
the existing session or connector when possible.

## Verify and hand over

After onboarding, use `cg_test_connector`, then confirm the linked projects with
`cg_list_org_projects`. Read the latest state with `cg_get_project_status` and
`cg_open_overview` for the selected `org_id`. A connector can be healthy before
its first cost observations arrive; identify that state rather than reporting
zero spend.

In a compatible Codex desktop host, the user can open **Cloud cost overview**
from the sidebar or a chat tab and mention a connected project with `@`.
Other MCP clients can call the same tools and receive text output. Finish with
the verified account, organization, connector health, and any remaining user
step.
