---
applyTo: "apps/**/*.yaml,bootstrap/**/*.yaml,components/**/*.yaml,.github/flux-local/**/*.yaml"
description: "Repository-specific conventions for Flux and Kubernetes manifests"
---

# Flux and Kubernetes manifests

- Preserve the repository's application split: chart resources and values belong under `<app>/app/`; supporting resources belong under `<app>/config/`.
- Keep each Kustomize base's `kustomization.yaml` explicit about its resources, patches, and components.
- Configure ordering, namespace targeting, and substitutions on Flux Kustomizations (`app.ks.yaml` / `config.ks.yaml`), not on the plain Kustomize base. Add `dependsOn` for required in-cluster services, including cross-namespace dependencies.
- Put shared resources in `components/` when multiple apps can use them; add the component to the consuming Flux Kustomization.
- Keep bootstrap chart configuration in the app's `HelmRelease`; `bootstrap/templates/values.yaml.gotmpl` reads it to avoid a second copy of values.
- Use the existing SOPS filename and encryption rules in `.sops.yaml` for encrypted Secrets. Do not introduce plaintext secret values.
- Add new resources to the appropriate Kustomize base and area-level Kustomization so Flux and CI can discover them.
- Validate YAML with `nix shell nixpkgs#yamllint --command yamllint --strict -c .yamllint.yaml <file>` and validate the assembled Flux tree with the `flux-local test` command documented in `.github/copilot-instructions.md`.
