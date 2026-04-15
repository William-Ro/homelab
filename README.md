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

### Clone and inspect

Clone the repository and enter the directory:

```sh
git clone https://github.com/William-Ro/homelab.git
cd homelab
```

Before bootstrapping, review and adapt the following files for your environment:

- `apps/kube-system/coredns/app/helm-release.yaml`
- `apps/flux-system/flux-instance/app/helm-release.yaml`
- `apps/network-system/metallb/config/ip-pool.yaml`
- `apps/network-system/envoy-gateway/config/admin/gateway.yaml`
- `apps/network-system/envoy-gateway/config/internal/gateway.yaml`
- `apps/network-system/cert-manager/config/cluster-issuer.yaml`
- `apps/dns/pihole/app/helm-release.yaml`
- `apps/storage-system/longhorn/app/helm-release.yaml`
- `apps/security-system/bitwarden-sdk-server/config/clustersecretstore.yaml`

### Bootstrap steps

#### 1. (Optional) Taint master node

If you have multiple nodes and want to prevent workloads from scheduling on the master node:

```sh
kubectl taint nodes <master-node-name> node-role.kubernetes.io/master=:NoSchedule
```

#### 2. Disable bundled defaults (for k3s or similar distros)

If using k3s or any Kubernetes distribution with bundled defaults, disable the following in your cluster config (e.g., `/etc/rancher/k3s/config.yaml`):

```yaml
disable:
  - servicelb
  - coredns
  - local-storage
  - traefik
```

#### 3. Longhorn requirement

Longhorn requires `open-iscsi` to be installed on all nodes. Install it using your OS package manager, e.g.:

```sh
# Ubuntu/Debian
sudo apt-get install open-iscsi
# CentOS/RHEL
sudo yum install iscsi-initiator-utils
```

#### 4. Create SOPS secret for Flux

If you use SOPS for secret management, create the secret in the `flux-system` namespace:

```sh
kubectl -n flux-system create secret generic sops-age \
  --from-file=age.agekey=$HOME/.config/sops/age/keys.txt
```

#### 5. Install CRDs (Envoy Gateway, etc)

Before bootstrapping Flux, install the required CRDs:

```sh
helmfile -f bootstrap/crds/helmfile.yaml template -q | \
  yq ea 'select(.kind == "CustomResourceDefinition")' - | \
  kubectl apply --server-side --force-conflicts -f -
```

#### 6. Bootstrap Flux controllers and core apps

On the first install, use `helmfile sync` (not `apply`) to avoid dependency issues:

```sh
helmfile -f bootstrap/helmfile.yaml sync
```

After the initial install, you can use `helmfile apply` for subsequent updates:

```sh
helmfile -f bootstrap/helmfile.yaml apply
```

This installs `coredns`, `flux-operator`, and `flux-instance`. `coredns` is bootstrapped first so the Flux controllers and workloads have cluster DNS available during reconciliation.

Once bootstrapped, Flux will continuously reconcile the `apps/` directory from the tracked branch.

## Apply a configuration

Most day-to-day changes happen by editing manifests under `apps/` and pushing them to the Git branch watched by Flux.

```sh
kubectl get kustomizations -A
kubectl get helmreleases -A
kubectl get pods -A
```

## Validation and maintenance

```sh
kubectl get svc -A
kubectl get httproutes -A
kubectl get certificates -A
kubectl get externalsecrets -A
kubectl get all -n flux-system
```

Main user-facing endpoints:

| Endpoint                          | Gateway                            |
| --------------------------------- | ---------------------------------- |
| `https://pihole.internal.reli.cc` | `envoy-internal` (`192.168.1.200`) |
| `https://flux.admin.reli.cc`      | `envoy-admin` (`192.168.1.201`)    |
