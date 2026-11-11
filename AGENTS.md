# Agent Instructions

This is a **Flux CD GitOps repository** for a single Kubernetes cluster — there
is no application code or build step. Everything under `apps/` is a
declarative manifest tree that Flux continuously reconciles onto the live
cluster. Merging to `main` is a production change, not just a code change.

This file is a short router. It applies to any coding agent (Copilot, Claude
Code, Codex, Cursor, etc.), not just one tool.

## Start here

- [ARCHITECTURE.md](ARCHITECTURE.md) — full technical deep-dive: tech stack,
  directory layout, deployment surface, known gotchas.
- [.github/copilot-instructions.md](.github/copilot-instructions.md) — repo
  conventions and validation commands. Read before editing anything under
  `apps/`, `bootstrap/`, or `components/`.
- [.github/instructions/kubernetes-manifests.instructions.md](.github/instructions/kubernetes-manifests.instructions.md) —
  scoped conventions for manifest files specifically.
- [.github/instructions/pr-workflow.instructions.md](.github/instructions/pr-workflow.instructions.md) —
  branching model (GitHub Flow) and how to carry a change through to an open PR.
- [decisions/](docs/decisions/README.md) — lasting decisions and their rationale.
  Check here before "fixing" something that looks wrong; it may be
  intentional (e.g. a version pin).
- [runbooks/](docs/runbooks/) — operational recovery procedures.
- [playbooks/](docs/playbooks/README.md) — step-by-step guides for recurring
  build-time tasks (e.g. deploying a new app). Read the relevant playbook
  before starting that kind of task.

## Verification

```sh
nix shell nixpkgs#yamllint --command yamllint --strict -c .yamllint.yaml apps/ bootstrap/

nix shell nixpkgs#docker --command docker run --rm \
  -v "$PWD:/github/workspace" -w /github/workspace \
  ghcr.io/home-operations/flate:0.7.3 test --path .github/flux-local
```

Both run in CI on pull requests targeting `main`, and also on push to
Renovate's `renovate/**` automerge branches (see
[decisions/0002](docs/decisions/0002-accept-renovate-automerge-without-ci-gate.md)).
A plain `kustomize build <base>` is not full validation — it skips Flux
`dependsOn` ordering and `postBuild.substitute`.

## Authority gate

Before changing anything externally observable in production — ingress
hosts/ports, storage classes, PVC sizing, security contexts, replica counts,
resource limits, secret handling, namespace layout, chart version pins — confirm
the choice is already settled by an existing convention, an instructions file,
or a record in `docs/decisions/`. A configurable default, or "it happened to be set
this way," is **not** authority. If no settled answer exists, stop and ask
instead of inventing one.

## Stop and ask before

- Deleting or resizing a PVC/PV, or any change that could cause data loss.
  Flux Kustomizations here run with `prune: true` — deleting a manifest from
  Git deletes the live resource.
- Changing Secret/SOPS handling or `.sops.yaml` rules.
- Deleting a namespace or a CloudNativePG `Cluster`/`Database`.
- Changing CI or Renovate automerge behavior — this was a deliberate,
  recently-revisited choice (`docs/decisions/0001`, `docs/decisions/0002`). Propose a
  new decision record instead of silently editing it.
- Any change where this repo doesn't already state which option is correct.

## Definition of done

A change is done when `flate test` and `yamllint --strict` both pass
locally — not when the YAML looks right. If the change is risky per the rules
above, state what evidence (e.g. `flux reconcile` output, HelmRelease/
Kustomization `status.conditions`, pod status) would confirm it actually
reconciled cleanly on the live cluster, since CI only proves the manifest
renders — it doesn't prove the cluster is healthy afterward.
