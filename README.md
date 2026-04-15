<div align="center">

# homelab

Declarative Kubernetes platform configuration built with `Flux CD`, `Kustomize`, `HelmRelease`, and `Helmfile`.

This repository manages core services for a home cluster from a single Git source, with separate app folders for GitOps bootstrap, networking, DNS, storage, and security.

</div>

## Overview

The setup is split into two layers:

- `bootstrap/` for the initial cluster bootstrap using `Helmfile`, including `coredns`, the Flux controllers, and CRD pre-installation
- `apps/` for namespace-scoped services and supporting Kubernetes manifests reconciled by Flux

### Available systems

| System            | Namespace         | Components                                                 | Purpose                                                            |
| ----------------- | ----------------- | ---------------------------------------------------------- | ------------------------------------------------------------------ |
| `kube-system`     | `kube-system`     | `coredns`                                                  | Provides cluster-internal DNS and service discovery for workloads  |
| `flux-system`     | `flux-system`     | `flux-operator`, `flux-instance`                           | Installs and tunes the GitOps controllers that sync this repo      |
| `network-system`  | `network-system`  | `metallb`, `external-dns`, `envoy-gateway`, `cert-manager` | Exposes services on the LAN, manages DNS, TLS, and ingress routing |
| `dns`             | `dns`             | `pihole`                                                   | Provides local DNS resolution and a web UI                         |
| `storage-system`  | `storage-system`  | `longhorn`                                                 | Provides distributed persistent storage for cluster workloads      |
| `security-system` | `security-system` | `external-secrets-operator`, `bitwarden-sdk-server`        | Manages secrets from Bitwarden Secrets Manager via ESO             |

## Included setup

- CoreDNS managed declaratively in `kube-system` and exposed as `kube-dns` on `10.43.0.10`
- Flux configured to sync the `apps/` directory from Git every `5m`; Flux UI reachable at `https://flux.admin.reli.cc`
- MetalLB with an L2 address pool at `192.168.1.200-192.168.1.220`
- Envoy Gateway with two gateways — `envoy-internal` at `192.168.1.200` and `envoy-admin` at `192.168.1.201` — both with TLS termination and HTTP→HTTPS redirect
- cert-manager with a Let's Encrypt DNS01 `ClusterIssuer` via Cloudflare for `reli.cc`
- ExternalDNS publishing DNS records through Pi-hole, credentials sourced from Bitwarden
- Pi-hole reachable at `https://pihole.internal.reli.cc` via `envoy-internal`
- Longhorn using `/var/lib/longhorn-nvme` as the default data path on worker nodes
- External Secrets Operator backed by `bitwarden-sdk-server` (`ClusterSecretStore: bitwarden`) for cluster-wide secret management
- SOPS with age for encrypting secrets at rest in Git

> [!NOTE]
> This is a personal homelab setup. If you want to reuse it, review the values under `apps/kube-system/`, `apps/flux-system/`, `apps/network-system/`, `apps/dns/`, `apps/storage-system/`, and `apps/security-system/` first and adapt them to your cluster, LAN range, domain, and Bitwarden organization/project IDs.

## Repository layout

```text
.
├── bootstrap/          # Helmfile bootstrap and shared values template
│   └── crds/           # CRD pre-installation (Envoy Gateway)
├── apps/               # Flux-managed platform services by namespace
│   ├── kube-system/
│   ├── flux-system/
│   ├── network-system/
│   ├── dns/
│   ├── storage-system/
│   └── security-system/
└── README.md
```

## Getting started

### Prerequisites

- A working Kubernetes cluster and configured `kubectl` context
- [Nix](https://nixos.org/download/) or equivalent access to `helmfile`, `helm`, and `kubectl`
- A Bitwarden Secrets Manager account with an access token, organization ID, and project ID
- A Cloudflare API token scoped to DNS editing for your domain
- An age key for SOPS secret decryption, loaded into the cluster as a `Secret` in `flux-system`
- Network and DNS values updated to match your homelab

### Clone and inspect

```bash
nix shell nixpkgs#git --command git clone https://github.com/William-Ro/homelab.git
cd homelab
```

Before bootstrapping, inspect these files first:

- `apps/kube-system/coredns/app/helm-release.yaml`
- `apps/flux-system/flux-instance/app/helm-release.yaml`
- `apps/network-system/metallb/config/ip-pool.yaml`
- `apps/network-system/envoy-gateway/config/admin/gateway.yaml`
- `apps/network-system/envoy-gateway/config/internal/gateway.yaml`
- `apps/network-system/cert-manager/config/cluster-issuer.yaml`
- `apps/dns/pihole/app/helm-release.yaml`
- `apps/storage-system/longhorn/app/helm-release.yaml`
- `apps/security-system/bitwarden-sdk-server/config/clustersecretstore.yaml`

### Bootstrap CRDs

Before bootstrapping Flux, install the Envoy Gateway CRDs:

```bash
nix shell nixpkgs#helmfile nixpkgs#kubernetes-helm nixpkgs#kubectl --command \
  sh -c 'helmfile template -q -f bootstrap/crds/helmfile.yaml | \
  kubectl apply --server-side --force-conflicts -f -'
```

### Bootstrap Flux

```bash
nix shell nixpkgs#helmfile nixpkgs#kubernetes-helm --command \
  helmfile -f bootstrap/helmfile.yaml apply
```

This installs `coredns`, `flux-operator`, and `flux-instance`. `coredns` is bootstrapped first so the Flux controllers and workloads have cluster DNS available during reconciliation.

If you are using `k3s`, disable the bundled components you replace declaratively in `/etc/rancher/k3s/config.yaml` before bootstrapping:

```yaml
disable:
  - servicelb
  - coredns
  - local-storage
```

After that, Flux continuously reconciles the `apps/` directory from the tracked branch.

## Apply a configuration

Most day-to-day changes happen by editing manifests under `apps/` and pushing them to the Git branch watched by Flux.

```bash
nix shell nixpkgs#kubectl --command kubectl get kustomizations -A
nix shell nixpkgs#kubectl --command kubectl get helmreleases -A
nix shell nixpkgs#kubectl --command kubectl get pods -A
```

## Validation and maintenance

```bash
nix shell nixpkgs#kubectl --command kubectl get svc -A
nix shell nixpkgs#kubectl --command kubectl get httproutes -A
nix shell nixpkgs#kubectl --command kubectl get certificates -A
nix shell nixpkgs#kubectl --command kubectl get externalsecrets -A
nix shell nixpkgs#kubectl --command kubectl get all -n flux-system
```

Main user-facing endpoints:

| Endpoint                          | Gateway                            |
| --------------------------------- | ---------------------------------- |
| `https://pihole.internal.reli.cc` | `envoy-internal` (`192.168.1.200`) |
| `https://flux.admin.reli.cc`      | `envoy-admin` (`192.168.1.201`)    |
