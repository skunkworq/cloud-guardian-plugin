# Vercel cost exploration and persistent onboarding

## Immediate billing through the local CLI

The 0.1.1 MCP runtime provides `cg_explore_vercel_costs`. It invokes the user's
local Vercel CLI and does not require Cloud Guardian authentication, an
organization, a connector, or a scan. Use this path for an immediate cost review.

Check the installed CLI with `vercel --version` and `vercel usage --help`. If it
is missing or lacks `usage`, direct the user to the current
[Vercel CLI installation guide](https://vercel.com/docs/cli). Authenticate with
[`vercel login`](https://vercel.com/docs/cli/login) and check `vercel whoami`.
Reuse an existing valid login. Billing access depends on the user's team role.
No project linking or deployment is needed for billing exploration.

Call the tool with the requested team slug or ID:

```json
{ "team": "YOUR_TEAM_SLUG_OR_ID" }
```

The default is the current billing period. A custom interval requires both
`from_date` and `to_date`, for example:

```json
{
  "team": "YOUR_TEAM_SLUG_OR_ID",
  "from_date": "2026-09-01",
  "to_date": "2026-09-30"
}
```

Dates use `YYYY-MM-DD`, must be ordered, and span at most 365 days. CLI date
filters use America/Los_Angeles and include both calendar dates; use the returned
period timestamps as the actual evidence window. The result contains billed
and effective cost cents in USD, project/service breakdowns, observation time,
and warnings. Current-period charges are provisional. Keep these charges
separate from Cloud Guardian's resource monthly run-rate and saved scan data.
See [Vercel usage](https://vercel.com/docs/cli/usage) and the
[FOCUS billing API](https://vercel.com/docs/rest-api/billing/list-focus-billing-charges).

If the MCP host cannot find the CLI, set `VERCEL_CLI_BINARY` to the absolute
executable path in its environment and restart the connection. Never read,
print, copy, or persist the CLI's OAuth credentials. The CLI owns that login.
Report missing CLI, expired login, or team access errors with their next step.

## Persistent connector: next backend deployment

The persistent Vercel backend implementation is not deployed to production yet.
Do not offer this as a working production path until backend availability is
confirmed. Immediate CLI exploration above works independently of it.

Once deployed, and only when persistent onboarding is requested:

1. Verify Cloud Guardian identity and choose an explicit `org_id`.
2. Obtain the Vercel team ID beginning `team_`; a slug is not sufficient for
   `cg_onboard_vercel`. Inspect matching connectors and reuse them.
3. Use a dedicated [Vercel API token](https://vercel.com/kb/guide/how-do-i-use-a-vercel-api-access-token)
   with access to the team. Prefer `CLOUD_GUARDIAN_VERCEL_TOKEN` in the MCP host's
   environment; the optional `api_token` argument is available when necessary.
   Do not ask the user to paste secrets into chat or copy the CLI OAuth session.
4. Call `cg_onboard_vercel` with `org_id`, `team_id`, and optional `name`.
   It reuses a matching team connector. A new connector preflights access,
   stores the dedicated token encrypted, links the team account, and tests it.
5. Report the actual connector ID, reuse status, and test result. A successful
   test is not proof that saved billing observations have arrived.
6. The scheduled first scan records actual billing charges and links Vercel
   projects. Query `cg_query_provider_billing` with the explicit `org_id`,
   `provider: "vercel"`, and returned `connector_id` after observations arrive.

If the user requests a fresh scan, scope `cg_trigger_scan` to the team account
using its legacy provider filter:

```json
{
  "org_id": "YOUR_ORG_ID",
  "gcp_project_id": "vercel:team_YOUR_TEAM_ID"
}
```

Do not omit this filter and accidentally scan every provider in the organization.
Vercel onboarding and cost review do not enable workload remediation.
