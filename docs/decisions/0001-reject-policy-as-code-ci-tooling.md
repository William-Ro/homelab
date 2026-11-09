# 0001 Reject policy-as-code CI tooling (conftest/kubeconform/flate)

Date: 2026-11-08

## Status

Accepted (the decision is to *not* adopt the proposal below; current CI stays
as-is).

## Context

Explored adding a four-layer CI (`yamllint`, `conftest` with Rego policies for
naming/secrets conventions, `flate` to render the Flux tree, `kubeconform` to
schema-validate the rendered output) plus a `.renovate/manual-review.json5`
Renovate rule disabling automerge for cluster-critical charts. Prototyped in
homelab PR [#80](https://github.com/William-Ro/homelab/pull/80) ("Ci/tool
based validation") and a companion reusable-workflow draft in the
`github-workflows` repo.

## Decision

Rejected the whole bundle. Both PRs were closed without merging ("Not wanted;
reverting."). CI stays `yamllint --strict` + `flux-local test`/`diff` only, as
documented in [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md).
No shell-script-based validation, no Rego policy engine, no new container
tools in CI.

## Alternatives Considered

1. Adopt conftest/kubeconform/flate as proposed. Rejected — adds new tool
   dependencies, a Rego policy layer to maintain, and shell-script-driven
   validation disproportionate to a solo-maintained repo.
2. Keep the existing two-tool CI (`yamllint` + `flux-local`). Chosen.

## Consequences

Positive:

- CI stays minimal, fast, and easy to reason about with two well-understood
  tools.

Tradeoffs:

- No automated enforcement of repo-specific conventions (hyphenated filenames,
  SOPS-only secrets, naming patterns) beyond manual review and agent
  instruction-following in `.github/copilot-instructions.md` /
  `.github/instructions/`.

## Follow-Up

- Don't re-propose conftest/kubeconform/flate or similar policy-as-code
  tooling without the user explicitly asking for it again.
