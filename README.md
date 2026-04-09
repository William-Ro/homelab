# homelab

Declarative Kubernetes configuration for a small homelab cluster, bootstrapped with `Helmfile` and continuously reconciled with `Flux CD`.

[Overview](#overview) • [Repository layout](#repository-layout) • [Bootstrap](#bootstrap) • [Operations](#operations)

## Overview

This repository is the source of truth for a set of cluster-level services running on a home network. It uses:

- `Helmfile` for the initial Flux bootstrap
- `Flux CD` for GitOps reconciliation
- `Kustomize` for composing namespaces and app layers
- `HelmRelease` and `OCIRepository` manifests for Helm-based deployments

The current stack includes:

| Area | Components | Purpose |
| --- | --- | --- |
| GitOps | `flux-operator`, `flux-instance` | Installs and tunes the Flux controllers that sync this repo |
| Networking | `metallb`, `external-dns` | Provides LAN `LoadBalancer` IPs and publishes DNS records through Pi-hole |
| DNS | `pihole` | Local DNS resolver and web UI exposed on the home network |
| Storage | `longhorn` | Distributed persistent storage for workloads |

> [!IMPORTANT]
> This repo contains environment-specific values such as local IP ranges, DNS names, storage paths, and placeholder credentials. Review them before applying the manifests to another cluster.

## Repository layout

```text
bootstrap/
  helmfile.yaml                 # installs Flux operator and Flux instance
  templates/values.yaml.gotmpl  # reuses values from app HelmRelease manifests

apps/
  flux-system/                  # Flux bootstrap and controller tuning
  network-system/               # MetalLB and ExternalDNS
  dns-system/                   # Pi-hole and ingress configuration
  storage-system/               # Longhorn
```

Within each app directory:

- `app.ks.yaml` defines the Flux `Kustomization` for the application layer
- `config.ks.yaml` defines the Flux `Kustomization` for supporting manifests
- `app/` contains `HelmRelease`, `OCIRepository`, and local `kustomization.yaml`
- `config/` contains plain Kubernetes manifests such as ingress rules or MetalLB pools

## Environment-specific defaults

These values should usually be adjusted first:

| Setting | Current value | File |
| --- | --- | --- |
| Flux Git source | `https://github.com/William-Ro/homelab.git` | `apps/flux-system/flux-instance/app/helm-release.yaml` |
| MetalLB pool | `192.168.1.200-192.168.1.220` | `apps/network-system/metallb/config/ip-pool.yaml` |
| Pi-hole service IP | `192.168.1.220` | `apps/dns-system/pihole/app/helm-release.yaml` |
| Pi-hole ingress host | `pihole.home` | `apps/dns-system/pihole/config/ingress.yaml` |
| ExternalDNS domain filter | `home` | `apps/network-system/external-dns/app/helm-release.yaml` |
| Longhorn data path | `/var/lib/longhorn-nvme` | `apps/storage-system/longhorn/app/helm-release.yaml` |

> [!NOTE]
> `external-dns` expects a `pihole-password` secret in `network-system`. Flux is also configured for controller-level SOPS decryption through an `sops-age` secret when encrypted manifests are used.

## Bootstrap

The examples below use `nix shell` so no cluster tooling has to be installed globally.

### Prerequisites

- A working Kubernetes cluster and a configured `kubectl` context
- An ingress controller if the Pi-hole ingress should be reachable by hostname
- Network settings that match, or are updated from, the defaults in this repo
- Required secrets created out-of-band for your environment

### 1. Clone the repository

```bash
nix shell nixpkgs#git --command git clone https://github.com/William-Ro/homelab.git
cd homelab
```

### 2. Review the environment-specific values

Before the first apply, update the files listed in [Environment-specific defaults](#environment-specific-defaults) to match your network, domain, and storage layout.

### 3. Bootstrap Flux

```bash
nix shell nixpkgs#helmfile nixpkgs#kubernetes-helm --command \
  helmfile -f bootstrap/helmfile.yaml apply
```

This installs `flux-operator` and `flux-instance`. The Flux instance is configured to watch the `apps/` directory in this repository every `5m`.

### 4. Verify reconciliation

```bash
nix shell nixpkgs#kubectl --command kubectl get pods -A
nix shell nixpkgs#kubectl --command kubectl get kustomizations -A
nix shell nixpkgs#kubectl --command kubectl get helmreleases -A
```

## Operations

### GitOps flow

1. `bootstrap/helmfile.yaml` installs the Flux control plane.
2. `flux-instance` syncs the `apps/` directory from Git.
3. System kustomizations create namespaces and deploy each platform component.
4. Changes are applied automatically after a push, or on the next reconciliation interval.

### Making changes

1. Edit manifests under `apps/`
2. Push the change to the tracked branch
3. Check reconciliation status with `kubectl get kustomizations -A`

### Useful checks

```bash
nix shell nixpkgs#kubectl --command kubectl get all -n flux-system
nix shell nixpkgs#kubectl --command kubectl get svc -A
nix shell nixpkgs#kubectl --command kubectl get ingress -A
```

## Access points

With the current defaults:

- Pi-hole web UI is exposed at `http://pihole.home`
- Pi-hole DNS and web services share `192.168.1.220`
- MetalLB advertises addresses from `192.168.1.200-192.168.1.220`

This repository intentionally stays focused on the platform layer, keeping cluster add-ons declarative and easy to audit.
