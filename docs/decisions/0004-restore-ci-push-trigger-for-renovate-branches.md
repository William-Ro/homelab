# 0004 Restore the CI push trigger for Renovate branches

Date: 2026-11-10

## Status

Accepted. Supersedes [0002](0002-accept-renovate-automerge-without-ci-gate.md).

## Context

`ci-pr.yml` originally had a `push` trigger on `renovate/**` branches so
`yamllint`/`flux-local test` ran before Renovate's `automergeType: "branch"`
merged minor/patch/digest/pin updates into `main`. Commit `8560ded` ("ci: run
lint, validate and diff on pull requests only", 2026-11-08) removed that
trigger, leaving only `pull_request`. Decision 0002 accepted the resulting gap
— those updates reach `main` with no CI gate at all.

On 2026-11-10, the Dependency Dashboard (issue #17) showed 5 updates stuck
under "Pending Branch Automerge," each waiting on status checks that would
never arrive. Confirmed via the GitHub API: the stuck branches had zero check
runs and a `pending`/`total_count: 0` combined status. Root cause: the `main`
branch ruleset (added 2026-11-06, tightened in
[0003](0003-enforce-pr-required-workflow-for-owner.md)) requires the `Lint`
and `Validate` status checks to merge *anything* into `main`, including a
direct branch merge — but with no `push` trigger, those checks never run for
`renovate/**` branches, so Renovate waits forever for a status that will
never post.

## Decision

Restore a `push` trigger on `renovate/**` branches in `ci-pr.yml`, running the
same `lint`/`validate`/`diff` jobs as the `pull_request` trigger. Renovate's
branch automerges are now actually gated by `Lint`/`Validate`, closing the gap
decision 0002 accepted — not just unblocking the stuck queue, but giving these
updates the same CI coverage as everything else.

## Alternatives Considered

1. Remove `required_status_checks` from the ruleset for non-PR merges. Not
   possible with GitHub rulesets (no path/event-scoped required-check
   conditions) without a larger ruleset redesign.
2. Switch `automergeType` to `"pr"` so every update goes through the same
   `pull_request`-triggered path. Bigger behavior change than needed; not
   taken now.
3. Restore the `push` trigger (this decision's alternative 1 from 0002).
   Chosen — smallest change, reuses existing jobs, no new tooling.

## Consequences

Positive:

- Renovate's branch-automerge queue unblocks and stays unblocked.
- Minor/patch/digest/pin updates now get `yamllint`/`flux-local test` before
  reaching `main`, closing the CI gap decision 0002 had accepted.

Tradeoffs:

- Slightly more CI minutes (one more trigger path), negligible for a
  solo-maintained repo.

## Follow-Up

- None currently.
