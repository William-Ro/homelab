# 0001 Keep CI validation minimal: reject the policy-as-code bundle, adopt flate

Date: 2026-11-08 (revised 2026-11-11)

## Status

Accepted.

## Context

Explored adding a four-layer CI (`yamllint`, `conftest` with Rego policies for
naming/secrets conventions, `flate` to render the Flux tree, `kubeconform` to
schema-validate the rendered output) plus a `.renovate/manual-review.json5`
Renovate rule disabling automerge for cluster-critical charts. Prototyped in
homelab PR [#80](https://github.com/William-Ro/homelab/pull/80) ("Ci/tool
based validation") and a companion reusable-workflow draft in the
`github-workflows` repo. Rejected the whole bundle; both PRs were closed
without merging ("Not wanted; reverting."). CI stayed `yamllint --strict` +
`flux-local test`/`diff` only.

Separately, `flux-local` (`ghcr.io/allenporter/flux-local`), used in
`ci-pr.yml`'s `Validate` and `Diff` jobs since before this decision, was
deprecated upstream in favor of `flate` (and `konflate`), both maintained by
the `home-operations` org. Continuing to pin `flux-local:v8.4.0` meant staying
on a tool that no longer receives fixes.

Validated locally before changing `ci-pr.yml`:

- `ghcr.io/home-operations/flate:latest` resolves to a stale `v0.6.5` with an
  incompatible CLI (subcommand-only `test [all|hr|ks]`, no `-p`/`--path`,
  `--base`, or `--skip-kinds` flags). The CLI documented in flate's README
  only exists from the explicit `0.7.3` tag onward — **CI must pin `0.7.3`
  explicitly, never `:latest`.**
- `flate test --path .github/flux-local` against this repo's full tree passes
  (157 resources) with the same two warnings `flux-local` already tolerated:
  an `OmittedValues` warning for the `democratic-csi` HelmRelease's
  Secret-sourced values, and a `SOPSUnreadable` warning for the
  `bitwarden-access-token` Secret. Exit code `0` in both cases.
- `flate diff --base origin/main --path .github/flux-local --output github`
  renders a unified diff against a Git revision directly — no second
  `actions/checkout` of `main` is needed the way `flux-local diff` required.

## Decision

Two related but distinct calls, both reflected in today's CI:

1. **Reject the policy-as-code bundle.** No Rego policy engine, no
   `conftest`/`kubeconform`, no shell-script-driven validation layer on top of
   the existing tooling — disproportionate to a solo-maintained repo.
2. **Replace `flux-local` with `flate`**, pinned to
   `ghcr.io/home-operations/flate:0.7.3`, as a direct, like-for-like
   successor — not a new validation layer, just a swap of the one render/test
   tool `flux-local` used to be:
   - `Validate`: `flate test --path .github/flux-local`.
   - `Diff`: a single job running
     `flate diff --base origin/main --path .github/flux-local --output github`
     against one `fetch-depth: 0` checkout (replaces the old two-checkout
     `helmrelease`/`kustomization` matrix, since `flate diff` renders and
     diffs all Flux resource kinds together and resolves the baseline from
     Git history instead of a second checkout).

CI today is still exactly the two-tool shape this decision has always
defended: `yamllint` + one Flux render/validate tool (now `flate` instead of
`flux-local`), as documented in
[`.github/copilot-instructions.md`](../../.github/copilot-instructions.md).

## Alternatives Considered

1. Adopt conftest/kubeconform/flate as a policy-as-code bundle, as proposed.
   Rejected — adds new tool dependencies, a Rego policy layer to maintain,
   and shell-script-driven validation disproportionate to a solo-maintained
   repo.
2. Stay on `flux-local:v8.4.0` indefinitely. Rejected — deprecated upstream,
   no further fixes.
3. Use flate's official `home-operations/flate/action` composite action
   instead of a raw `docker run`. Not chosen for now — a plain `docker run`
   keeps the same "invoke the container directly" shape the repo already used
   for `flux-local` and avoids pinning a second GitHub Action; revisit if
   flate's action adds caching or other benefits worth the extra dependency.
4. Keep the two-checkout `helmrelease`/`kustomization` diff matrix. Rejected —
   `flate diff --base` makes it unnecessary; one job replaces two.

## Consequences

Positive:

- CI stays minimal, fast, and easy to reason about with two well-understood
  tools.
- Off a deprecated tool (`flux-local`) before it bit-rots further.
- Simpler `Diff` job: one checkout, one job, instead of two checkouts and a
  2-way matrix.

Tradeoffs:

- No automated enforcement of repo-specific conventions (hyphenated filenames,
  SOPS-only secrets, naming patterns) beyond manual review and agent
  instruction-following in `.github/copilot-instructions.md` /
  `.github/instructions/`.
- A new explicit version pin (`flate:0.7.3`) to track via Renovate, same as
  `flux-local:v8.4.0` was. `flate`'s `:latest` tag is unreliable (resolves to
  a stale, CLI-incompatible `v0.6.5`) — anyone touching this image reference
  must keep pinning an explicit version tag, not `:latest`.

## Follow-Up

- Don't re-propose conftest/kubeconform/Rego-style policy-as-code tooling
  without the user explicitly asking for it again.
