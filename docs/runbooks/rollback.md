# Rollback

How to recover when a change merged to `main` turns out to be broken on the
live cluster. See [ARCHITECTURE.md](../../ARCHITECTURE.md) for the full
architecture; this is the short operational path.

## How Flux applies a change

- The root Kustomization (`cluster-apps`, created by FluxInstance) polls
  `main` on a 5-minute interval and applies `apps/` in `dependsOn` order.
- Every `app.ks.yaml`/`config.ks.yaml` Flux Kustomization in this repo runs
  with `prune: true` and `wait: true`: removing a manifest from Git **deletes**
  the corresponding live resource, and a Kustomization won't report healthy
  until its resources are actually Ready.
- Renovate's minor/patch/digest/pin automerges reach `main` via a direct
  branch merge, gated by the same `Lint`/`Validate` checks as a PR — see
  [decisions/0002](../decisions/0002-accept-renovate-automerge-without-ci-gate.md).
  A bad automerge that still passes CI (e.g. a chart upgrade with a breaking
  runtime change `flux-local` can't catch) is the most likely source of an
  unexpected breakage.

## Diagnose first

1. Check the Flux Kustomization/HelmRelease status for the affected app
   (`status.conditions`, looking for `Stalled` or `Ready: False`). The
   `mcp_flux-operator_get_kubernetes_resources` tool (or
   `flux get kustomizations -A` / `flux get helmreleases -A` with the Flux
   CLI) shows this directly.
2. Check events and logs for the affected workload
   (`mcp_flux-operator_get_kubernetes_events`, `mcp_flux-operator_get_kubernetes_logs`,
   or `kubectl describe` / `kubectl logs`).
3. Confirm which commit introduced the regression with `git log` /
   `git bisect` against the manifest path in question.

## Fast rollback

For a stateless config mistake (bad value, wrong image tag, broken Helm
values):

```sh
git revert <bad-commit>
git push
```

Then either wait for the next 5-minute poll, or force it immediately:

- Via the Flux Operator MCP tool: `mcp_flux-operator_reconcile_flux_resource`
  with `with_source: true` on the affected Kustomization (reconciles the
  GitRepository first, then the Kustomization).
- Via the Flux CLI: `flux reconcile kustomization <name> --with-source`.

## Before reverting anything that touches storage

**Do not blindly revert** a commit that added, resized, or removed a PVC, a
CloudNativePG `Cluster`/`Database`, or anything else with persistent state.
Because of `prune: true`, reverting a commit that _added_ a stateful resource
tells Flux to _delete_ it — which can mean real data loss, not just a config
rollback.

Before acting on anything stateful:

1. Pause reconciliation on the affected Kustomization first
   (`mcp_flux-operator_suspend_flux_reconciliation`, or
   `flux suspend kustomization <name>`) so Flux can't prune/apply while you
   investigate.
2. Confirm what the revert would actually delete (`flux-local diff` locally,
   or `mcp_flux-operator_diff_kubernetes_manifest` against the cluster) before
   pushing it.
3. Resume reconciliation (`mcp_flux-operator_resume_flux_reconciliation` /
   `flux resume kustomization <name>`) only once you're confident.

## Known gaps / Unknowns

- There is no backup/restore solution for PVC-backed data in this repo yet (no
  Velero/VolSync/Kopia). A stateful rollback that needs to recover prior data,
  not just prior config, currently has no tooling to do that — treat it as
  data loss until a backup solution exists.
- There is no alerting on Flux `Stalled`/`Ready: False` conditions. Nothing
  will proactively tell you a reconciliation is failing; you have to check.
