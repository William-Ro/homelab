# 0005 Allow Flux MCP to reconcile, suspend and resume

Date: 2026-11-12

## Status

Accepted. Amends the read-only Flux stance in
[decision 0004](0004-aggregate-mcp-servers-behind-toolhive-gateway.md); the rest
of 0004 stands.

## Context

Decision 0004 made the Flux MCP backend read-only (`view` ClusterRole plus
`--read-only`) and left reconcile, suspend and resume out of the gateway
allowlist. There is now a need to trigger reconciliations and suspend or resume
Flux resources through MCP.

## Decision

Enable only those three actions, for Flux resources only:

- The `flux` backend no longer runs with `--read-only`.
- The gateway allowlist adds `reconcile_flux_resource`,
  `suspend_flux_reconciliation` and `resume_flux_reconciliation`. `apply`,
  `patch`, `delete`, `install_flux_instance` and `diff_kubernetes_manifest`
  stay hidden.
- The `flux-mcp` service account gets a ClusterRole that allows only `patch`
  on the Flux toolkit resources (sources, Kustomizations, HelmReleases, image
  automation, receivers, and the `fluxcd.controlplane.io` ResourceSets,
  ResourceSetInputProviders and FluxInstances). These tools only patch
  annotations or `spec.suspend`, so no `create`, `update` or `delete` is granted.

## Alternatives Considered

1. Also expose `apply`, `patch` and `delete` Kubernetes resources. Rejected:
   they are arbitrary cluster writes and would need broad RBAC.
2. Keep read-only and use `kubectl`/`flux` from a workstation. Rejected: the
   requirement is to do this through MCP.
3. Restrict writes to specific namespaces. Rejected for now: Flux resources
   live in many namespaces and the choice was all of them.

## Consequences

Positive:

- Reconcile, suspend and resume work through the gateway with the smallest
  RBAC that supports them.

Tradeoffs:

- Any holder of a gateway key can now suspend Flux resources, including
  FluxInstance, across all namespaces. A suspended Kustomization stops
  reconciling and pruning until it is resumed.
- Without `--read-only` the backend also registers its other write tools. They
  are blocked by the allowlist and by RBAC, but removing either would widen
  access: `patch` on Flux resources lets server-side apply change them.
- Keys are not scoped per client, so every key has the same write access.

## Follow-Up

- Revisit per-client scoping (ToolHive OIDC with Cedar policies) if write
  access should not be shared by every key.
