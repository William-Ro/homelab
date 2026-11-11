# 0002 Accept Renovate automerge without a CI gate

Date: 2026-11-08

## Status

Superseded by [0004](0004-restore-ci-push-trigger-for-renovate-branches.md).

## Context

`.renovaterc.json` extends the shared `github>William-Ro/renovate-config//default.json5`,
which sets `automerge: true, automergeType: "branch"` for `minor`/`patch`/`pin`/`digest`/`pinDigest`
update types — only `major` updates open a PR. `.github/workflows/ci-pr.yml`
triggers only `on: pull_request`, so branch-automerged updates reach `main`
(and then the live cluster, via Flux) without `yamllint` or `flux-local test`
ever running.

A fix for the CI-gating gap (push trigger on `renovate/**` branches reusing
the existing jobs, plus a `manual-review` Renovate packageRule for
cluster-critical charts) was already built in PR #80, but it was bundled with
the tooling rejected in [decision 0001](0001-reject-policy-as-code-ci-tooling.md)
and closed along with it.

## Decision

Leave Renovate automerge behavior as-is for now: minor/patch/digest/pin
updates continue to bypass CI before reaching `main`/production. Per-package
Renovate constraints (`allowedVersions`/`enabled: false` in `.renovaterc.json`)
are the mechanism for protecting specific known-bad upgrades, not a blanket
CI-gating change.

## Alternatives Considered

1. Add a `push` trigger on `renovate/**` branches reusing only the existing
   `yamllint`/`flux-local` jobs (no new tools). Considered, not taken now.
2. Also add a `manual-review` Renovate packageRule disabling automerge for
   cluster-critical charts (operators, CSI, cert-manager, etc.). Considered,
   not taken now.
3. Switch `automergeType` to `"pr"` so every update goes through the same
   PR+CI path regardless of update type. Not explored in depth.
4. Leave as-is and rely on per-package Renovate constraints (see
   `.renovaterc.json`) plus `git revert` when something breaks. Chosen.

## Consequences

Positive:

- Fastest, lowest-friction update flow for routine bumps; no added CI/Renovate
  configuration complexity.

Tradeoffs:

- A bad minor/patch/digest update can reach the live cluster without
  `yamllint` or `flux-local test` ever running against it.
- Detection currently relies on someone noticing a `Stalled`/`Ready: False`
  Flux resource; there is no alerting wired up for this yet.
- Recovery is `git revert` + Flux reconcile; see
  [`runbooks/rollback.md`](../runbooks/rollback.md). Revert is not always safe
  for stateful resources (PVCs, CNPG databases) — read the runbook's caveats
  before reverting a storage-related change.

## Follow-Up

- Revisit if a Renovate-only update breaks the cluster. At minimum, consider
  the push-trigger fix from alternative 1 (narrow, no new tools) on its own
  merits, separately from the rejected tooling in decision 0001.
- Consider alerting on Flux `Stalled`/`Ready: False` conditions for faster
  detection.
