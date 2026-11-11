# 0003 Enforce PR-required workflow for the repo owner

Date: 2026-11-10

## Status

Accepted.

## Context

On 2026-11-06 a branch ruleset ("Main branch") was added requiring a PR, 1
approval, and the `Lint`/`Validate` status checks before merging to `main`.
It also listed the repo owner (`William-Ro`) as a `bypass_actor` with
`bypass_mode: "always"` — added so a solo maintainer could still merge their
own PRs, since GitHub blocks self-approval and `required_approving_review_count`
was set to `1`. In practice this let the owner (and anyone pushing as them,
including an agent with their git credentials) push straight to `main` with
no PR, no review, and no CI gate at all — confirmed on 2026-11-10 when two
commits landed directly on `main` instead of going through a PR as intended.

## Decision

Drop `required_approving_review_count` to `0` and remove the owner from
`bypass_actors`. The ruleset still requires a PR and green `Lint`/`Validate`
checks to merge, but no second-reviewer approval is required, since there
isn't a second person. The repo owner can no longer bypass the ruleset;
direct pushes to `main` are rejected by GitHub for them. The existing
Integration bypass actor (Renovate) is unchanged — automerge still pushes
directly per [decision 0002](0002-accept-renovate-automerge-without-ci-gate.md).

## Alternatives Considered

1. Keep the owner bypass and treat "PR-first" as a workflow habit only, not
   something GitHub enforces. Rejected — this is exactly the gap that caused
   the accidental direct push this decision responds to.
2. Keep `required_approving_review_count: 1` and find some other reviewer
   mechanism (e.g. a bot approval). Not explored — adds complexity for a
   single-maintainer repo.

## Consequences

Positive:

- `main` can no longer be pushed to directly by anyone except the Renovate
  automerge path; every other change must go through a PR with `Lint` and
  `Validate` passing.

Tradeoffs:

- There is no second human reviewer, so `required_approving_review_count` stays
  at `0` rather than `1` — a PR only needs `Lint`/`Validate` green to merge,
  not a second opinion. This is a conscious trade for a solo-maintained repo,
  not an oversight.

## Follow-Up

- None currently.
