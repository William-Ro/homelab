# 0004 Aggregate MCP servers behind a ToolHive gateway

Date: 2026-11-12

## Status

Accepted.

## Context

`grafana-mcp` and `flux-mcp` were each deployed as their own app-template or
chart HelmRelease with their own HTTPRoute, hostname and credential. That did
not scale and had real gaps:

- `flux-mcp` ran with `readonly: false` and no authentication, so anyone on the
  LAN could reconcile, suspend or delete Flux resources.
- `grafana-mcp` used an env var (`GRAFANA_AUTH`) that mcp-grafana never reads,
  so it silently ran as Grafana's anonymous Viewer, and it served over SSE
  while clients expected streamable-http on `/mcp`.
- Every new server meant a new route, secret and client config entry, with its
  own authentication story.

## Decision

Deploy the ToolHive operator in a new `ai-system` area and expose every MCP
server through one `VirtualMCPServer` (`mcp-gateway`) at
`mcp.internal.reli.cc`.

- Backends are `MCPServer` resources in the `mcp-tools` `MCPGroup` (`grafana`,
  `flux`). Both are read-only: the Grafana service account is Viewer, and Flux
  uses the built-in `view` ClusterRole plus `--read-only`.
- Tool exposure is deny-by-default. A tool, or a new backend, is invisible to
  clients until it is added to the allowlist in `virtual-mcp-server.yaml`.
  `grafana_api_request` and all write tools are intentionally left out.
- Clients authenticate at the Envoy route with an `x-api-key` header, enforced
  by a `SecurityPolicy` (`apiKeyAuth`). There is one key per client
  (`laptop`, `desktop`), stored as Bitwarden items and synced by External
  Secrets. Revoking a client means removing its entry. The VirtualMCPServer
  itself uses anonymous incoming auth because Envoy has already authenticated
  the request.
- Backend credentials (the Grafana service-account token) stay in the cluster
  and never reach clients.
- The old `grafana-mcp` and `flux-mcp` apps, their routes and the per-server
  server token were removed in the same change.

## Alternatives Considered

1. Keep one app per MCP server with a per-server bearer token. Rejected: it
   repeats the route/secret/client setup for every server and does not give
   per-client revocation.
2. Envoy `SecurityPolicy` on each existing route, without ToolHive. Viable and
   smaller, but still one endpoint per server and no central tool allowlist.
3. ToolHive with OIDC and Cedar policies for per-user, expiring tokens. Better
   for many users or agents, but needs an identity provider. Revisit if the
   number of clients or servers grows.

## Consequences

Positive:

- One URL and one client key per device; adding a server is one `MCPServer`
  plus allowlist entries.
- Read-only by default, with an explicit allowlist and per-client revocation.

Tradeoffs:

- One more operator (ToolHive) to run and keep updated. Its CRDs follow the
  repo's convention: the `toolhive-operator-crds` chart is listed in
  `bootstrap/crds/helmfile.yaml` and applied manually with
  `kubectl apply --server-side`, so they must be applied (and re-applied on
  version bumps) before the `toolhive` and `toolhive-config` Kustomizations can
  reconcile. `toolhive-config` depends on the operator app, the reverse of the
  usual `app` -> `config` order, because its resources are ToolHive CRs.
- Keys do not expire and every key sees the same tool set. A leaked key is only
  contained by rotating it.
- Clients no longer reach `grafana-mcp.internal.reli.cc` or
  `flux-mcp.internal.reli.cc`; they must use the gateway.
- Flux write tools (reconcile, suspend, resume, apply) are unavailable through
  MCP until a write role is added deliberately.

## Follow-Up

- Add a NetworkPolicy so only the gateway can reach the backend pods.
- Delete the unused `Grafana MCP Server Token` Bitwarden item.
- Consider Grafana Viewer-token expiry and rotation.
