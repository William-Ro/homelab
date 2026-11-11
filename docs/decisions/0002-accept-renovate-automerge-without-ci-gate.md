# 0002 Gate Renovate branch automerge with CI

Date: 2026-11-08 (revised 2026-11-10)

## Status

Accepted. `flux-local`, the tool run by the `Lint`/`Validate` checks described
below, was later replaced by `flate` — see
[decision 0001](0001-reject-policy-as-code-ci-tooling.md). That swap doesn't
change the trigger/gating decision recorded here.

## Context

`.renovaterc.json` extends the shared `github>William-Ro/renovate-config//default.json5`,
which sets `automerge: true, automergeType: "branch"` for `minor`/`patch`/`pin`/`digest`/`pinDigest`
update types — only `major` updates open a PR. Renovate pushes these straight
to a `renovate/*` branch and merges it into `main` itself once that branch's
status checks pass; it never opens a PR for them.

`ci-pr.yml` originally had a `push` trigger on `renovate/**` branches so
`yamllint`/`flux-local test` ran before that merge. On 2026-11-08, `ci-pr.yml`
was trimmed to `pull_request`-only (commit `8560ded`), removing that trigger.
A fix restoring it (plus a `manual-review` Renovate packageRule for
cluster-critical charts) had already been built in PR #80, but it was bundled
with the tooling rejected in [decision 0001](0001-reject-policy-as-code-ci-tooling.md)
and closed along with it. At the time, leaving `ci-pr.yml` as `pull_request`-only
was accepted as a deliberate tradeoff: minor/patch/digest/pin updates would
reach `main` with no CI gate at all, relying instead on per-package Renovate
constraints (`allowedVersions`/`enabled: false` in `.renovaterc.json`) and
`git revert` + Flux reconcile (see [`runbooks/rollback.md`](../runbooks/rollback.md))
if one broke something.

That tradeoff broke in practice. On 2026-11-10, the `main` branch ruleset was
tightened to require the `Lint`/`Validate` status checks on _every_ update to
`main` — PR or direct merge — with no bypass for the repo owner (see
[0003](0003-enforce-pr-required-workflow-for-owner.md)). Renovate's own
automerge logic always waits for whatever checks the branch's protection
declares as required before attempting a merge, regardless of whether its
Integration bypass actor could skip them. With no `push` trigger, those checks
never ran on `renovate/**` branches, so 5 updates sat stuck under "Pending
Branch Automerge" in the Dependency Dashboard (issue #17), waiting on a status
that would never post. Confirmed via the GitHub API: the stuck branches had
zero check runs and a `pending`/`total_count: 0` combined status.

## Decision

Restore the `push` trigger on `renovate/**` branches in `ci-pr.yml`, running
the same `lint`/`validate`/`diff` jobs as the `pull_request` trigger.
Renovate's branch automerges are now gated by `Lint`/`Validate` like every
other update to `main` — there is no more CI-free path into `main` for
anyone, Renovate included.

## Alternatives Considered

1. Leave `ci-pr.yml` as `pull_request`-only and accept Renovate updates
   reaching `main` with no CI gate. This was the original decision, and it's
   what caused the stuck queue once `main` started requiring those checks
   unconditionally — rejected once that interaction was discovered.
2. Also add a `manual-review` Renovate packageRule disabling automerge for
   cluster-critical charts (operators, CSI, cert-manager, etc.). Still
   available as a future option; not needed to fix the stuck queue.
3. Remove `required_status_checks` from the ruleset for non-PR merges. Not
   possible with GitHub rulesets — no path/event-scoped required-check
   conditions exist.
4. Switch `automergeType` to `"pr"` so every update goes through the same
   `pull_request`-triggered path. Bigger behavior change than needed.
5. Restore the `push` trigger, reusing the existing jobs. Chosen — smallest
   change, no new tooling, and it closes the CI gap instead of reintroducing it.

## Consequences

Positive:

- Renovate's branch-automerge queue unblocks and stays unblocked.
- Minor/patch/digest/pin updates now get `yamllint`/`flux-local test` before
  reaching `main`, same as every PR.
- One CI trigger story for `main`, not "PRs are tested, Renovate isn't."

Tradeoffs:

- Slightly more CI minutes (one more trigger path), negligible for a
  solo-maintained repo.
- Per-package Renovate constraints and `git revert` (see
  [`runbooks/rollback.md`](../runbooks/rollback.md)) remain the mechanism for
  a bad update that still passes CI (e.g. a chart upgrade with a breaking
  runtime change `flux-local` can't catch) — CI is a lint/build check, not a
  live-cluster guarantee.

## Follow-Up

- Consider the `manual-review` packageRule for cluster-critical charts
  (alternative 2) if a Renovate update ever breaks something CI couldn't have
  caught.
- Consider alerting on Flux `Stalled`/`Ready: False` conditions for faster
  detection.
