<div align="center">

# homelab

Declarative Kubernetes platform configuration built with `Flux CD`, `Kustomize`, `HelmRelease`, and `Helmfile`.

This repository manages core services for a home cluster from a single Git source, with separate app folders for GitOps bootstrap, networking, DNS, and storage.

</div>

## Overview

The setup is split into two layers:

- `bootstrap/` for the initial Flux installation using `Helmfile`
- `apps/` for namespace-scoped services and supporting Kubernetes manifests reconciled by Flux

### Available systems

| System           | Namespace        | Components                       | Purpose                                                       |
| ---------------- | ---------------- | -------------------------------- | ------------------------------------------------------------- |
| `flux-system`    | `flux-system`    | `flux-operator`, `flux-instance` | Installs and tunes the GitOps controllers that sync this repo |
| `network-system` | `network-system` | `metallb`, `external-dns`        | Exposes `LoadBalancer` IPs on the LAN and manages DNS records |
| `dns-system`     | `dns-system`     | `pihole`                         | Provides local DNS resolution and a web UI                    |
| `storage-system` | `storage-system` | `longhorn`                       | Provides distributed persistent storage for cluster workloads |

## Included setup

- Flux configured to sync the `apps/` directory from Git every `5m`
- MetalLB with an L2 address pool at `192.168.1.200-192.168.1.220`
- ExternalDNS configured to publish `.home` records through Pi-hole
- Pi-hole exposed on `192.168.1.220` and reachable at `http://pihole.home`
- Longhorn using `/var/lib/longhorn-nvme` as the default data path on worker nodes

> [!NOTE]
> This is a personal homelab setup. If you want to reuse it, review the values under `apps/flux-system/`, `apps/network-system/`, `apps/dns-system/`, and `apps/storage-system/` first and adapt them to your cluster, LAN range, secrets, and domain.

## Repository layout

```text
.
├── bootstrap/   # Helmfile bootstrap and shared values template
├── apps/        # Flux-managed platform services by namespace
│   ├── flux-system/
│   ├── network-system/
│   ├── dns-system/
│   └── storage-system/
└── README.md
```

## Getting started

### Prerequisites

- A working Kubernetes cluster and configured `kubectl` context
- [Nix](https://nixos.org/download/) or equivalent access to `helmfile`, `helm`, and `kubectl`
- Required secrets created for your environment, such as `pihole-password`
- Network and DNS values updated to match your homelab

### Clone and inspect

```bash
nix shell nixpkgs#git --command git clone https://github.com/William-Ro/homelab.git
cd homelab
```

Before bootstrapping, inspect these files first:

- `apps/flux-system/flux-instance/app/helm-release.yaml`
- `apps/network-system/metallb/config/ip-pool.yaml`
- `apps/dns-system/pihole/app/helm-release.yaml`
- `apps/storage-system/longhorn/app/helm-release.yaml`

### Bootstrap Flux

```bash
nix shell nixpkgs#helmfile nixpkgs#kubernetes-helm --command \
  helmfile -f bootstrap/helmfile.yaml apply
```

This installs `flux-operator` and `flux-instance`. After that, Flux continuously reconciles the `apps/` directory from the tracked branch.

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
nix shell nixpkgs#kubectl --command kubectl get ingress -A
nix shell nixpkgs#kubectl --command kubectl get all -n flux-system
```

With the current defaults, the main user-facing endpoint is `http://pihole.home`.
