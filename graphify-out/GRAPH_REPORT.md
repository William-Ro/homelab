# Graph Report - /home/deishuu/homelab  (2026-07-08)

## Corpus Check
- Corpus is ~14,418 words - fits in a single context window. You may not need a graph.

## Summary
- 374 nodes · 300 edges · 104 communities (31 shown, 73 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Flux GitOps & Media Sync
- App Config Overlays
- Media Stack Apps
- Flux Operator & Envoy Gateway
- Ingress Routes & Admin Endpoints
- Data & Observability Config
- Media & Storage Config
- OCI Helm Repositories
- Metrics Collection
- Security & Storage Backends
- DNS & Network System
- Intel GPU Plugins
- Kube System Tools
- Autobrr Download Automation
- Bazarr Subtitle Manager
- Immich Photo Library
- Jellyfin Media Server
- MetalLB Load Balancer Config
- Alertmanager
- Mimir Metrics Store
- Cluster Root Kustomization
- CloudNative-PG Database
- CoreDNS
- FlareSolverr Proxy
- Cert Manager TLS
- External DNS
- MetalLB App
- Alloy Collector App
- Blackbox Exporter
- Grafana Dashboard
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 66
- Community 67
- Community 68
- Community 69
- Community 70
- Community 71
- Community 72
- Community 73
- Community 74
- Community 75
- Community 76
- Community 77
- Community 78
- Community 79
- Community 80
- Community 81
- Community 82
- Community 83
- Community 84
- Community 85
- Community 86
- Community 87
- Community 88
- Community 89
- Community 90
- Community 91
- Community 92
- Community 93
- Community 94
- Community 95
- Community 96
- Community 97
- Community 98
- Community 99
- Community 100
- Community 101
- Community 102
- Community 103

## God Nodes (most connected - your core abstractions)
1. `bitwarden-sdk-server-config` - 17 edges
2. `envoy-internal` - 13 edges
3. `media` - 12 edges
4. `oci://ghcr.io/bjw-s-labs/helm/app-template` - 11 edges
5. `envoy-admin` - 7 edges
6. `democratic-csi` - 7 edges
7. `flux-operator` - 6 edges
8. `alertmanager` - 6 edges
9. `alloy-config` - 6 edges
10. `grafana` - 5 edges

## Surprising Connections (you probably didn't know these)
- `https-redirect` --references--> `envoy-internal`  [EXTRACTED]
  apps/network-system/envoy-gateway/config/https-redirect.http-route.yaml → apps/flux-system/flux-mcp/config/http-route.yaml
- `kube-state-metrics-config` --references--> `grafana`  [EXTRACTED]
  apps/observability-system/kube-state-metrics/config.ks.yaml → apps/database-system/cloudnative-pg/config.ks.yaml
- `envoy-gateway-config` --references--> `envoy-gateway`  [EXTRACTED]
  apps/network-system/envoy-gateway/config.ks.yaml → apps/flux-system/flux-operator/config.ks.yaml
- `https-redirect` --references--> `envoy-admin`  [EXTRACTED]
  apps/network-system/envoy-gateway/config/https-redirect.http-route.yaml → apps/flux-system/flux-operator/config/http-route.yaml
- `bazarr (OCI)` --references--> `oci://ghcr.io/bjw-s-labs/helm/app-template`  [EXTRACTED]
  apps/media/bazarr/app/oci-repository.yaml → apps/media/autobrr/app/oci-repository.yaml

## Import Cycles
- None detected.

## Communities (104 total, 73 thin omitted)

### Community 0 - "Flux GitOps & Media Sync"
Cohesion: 0.08
Nodes (31): ./apps/flux-system/flux-mcp/config, flux-mcp, flux-mcp-config, flux-system, autobrr, bazarr, immich, jellyfin (+23 more)

### Community 1 - "App Config Overlays"
Cohesion: 0.07
Nodes (30): ./apps/media/bazarr/config, ./apps/media/radarr/config, ./apps/media/recyclarr/config, ./apps/network-system/cert-manager/config, ./apps/network-system/external-dns/config, ./apps/observability-system/alertmanager/config, ./apps/observability-system/grafana-mcp/config, ./apps/observability-system/mimir/config (+22 more)

### Community 2 - "Media Stack Apps"
Cohesion: 0.07
Nodes (30): ./apps/media/prowlarr/app, ./apps/media/prowlarr/config, ./apps/media/qbittorrent/app, ./apps/media/radarr/app, ./apps/media/recyclarr/app, ./apps/media/seerr/app, ./apps/media/sonarr/app, ./apps/media/sonarr/config (+22 more)

### Community 3 - "Flux Operator & Envoy Gateway"
Cohesion: 0.09
Nodes (22): ./apps/flux-system/flux-instance/app, ./apps/flux-system/flux-mcp/app, ./apps/flux-system/flux-operator/app, ./apps/flux-system/flux-operator/config, ./apps/network-system/envoy-gateway/app, ./apps/network-system/envoy-gateway/config, flux-instance, flux-system (+14 more)

### Community 4 - "Ingress Routes & Admin Endpoints"
Cohesion: 0.12
Nodes (19): ./apps/observability-system/blackbox-exporter/config, alertmanager.admin.reli.cc, alloy.admin.reli.cc, alloy-metrics, https-redirect, pihole, alertmanager, alloy (+11 more)

### Community 5 - "Data & Observability Config"
Cohesion: 0.11
Nodes (18): ./apps/database-system/cloudnative-pg/config, ./apps/flux-system/flux-instance/config, ./apps/media/immich/config, ./apps/observability-system/grafana/config, ./apps/observability-system/grafana-mcp/app, cloudnative-pg-config, flux-system, flux-instance-config (+10 more)

### Community 6 - "Media & Storage Config"
Cohesion: 0.12
Nodes (17): ./apps/media/autobrr/config, ./apps/media/jellyfin/config, ./apps/media/qbittorrent/config, ./apps/media/seerr/config, ./apps/storage-system/democratic-csi/config, autobrr-config, flux-system, flux-system (+9 more)

### Community 7 - "OCI Helm Repositories"
Cohesion: 0.17
Nodes (12): autobrr (OCI), bazarr (OCI), flaresolverr (OCI), jellyfin (OCI), prowlarr (OCI), qbittorrent (OCI), radarr (OCI), recyclarr (OCI) (+4 more)

### Community 8 - "Metrics Collection"
Cohesion: 0.22
Nodes (9): ./apps/observability-system/alloy/config, ./apps/observability-system/kube-state-metrics/config, alloy, alloy-config, flux-system, flux-system, kube-state-metrics-config, kube-state-metrics (+1 more)

### Community 9 - "Security & Storage Backends"
Cohesion: 0.22
Nodes (9): ./apps/security-system/bitwarden-sdk-server/app, ./apps/security-system/external-secrets-operator/app, ./apps/storage-system/democratic-csi/app, bitwarden-sdk-server, flux-system, external-secrets-operator, flux-system, democratic-csi (+1 more)

### Community 10 - "DNS & Network System"
Cohesion: 0.25
Nodes (8): ./apps/network-system/pihole/app, ./apps/network-system/pihole/config, network-system, flux-system, pihole, flux-system, pihole-config, pihole-config

### Community 11 - "Intel GPU Plugins"
Cohesion: 0.33
Nodes (7): ./apps/kube-system/intel-device-plugins-operator/app, ./apps/kube-system/intel-gpu-device-plugin/app, flux-system, flux-system, intel-device-plugins-operator, flux-system, intel-gpu-device-plugin

### Community 12 - "Kube System Tools"
Cohesion: 0.50
Nodes (4): ./apps/kube-system/reloader/app, kube-system, flux-system, reloader

### Community 13 - "Autobrr Download Automation"
Cohesion: 0.50
Nodes (4): ./apps/media/autobrr/app, autobrr, flux-system, autobrr-config

### Community 14 - "Bazarr Subtitle Manager"
Cohesion: 0.50
Nodes (4): ./apps/media/bazarr/app, bazarr, flux-system, bazarr-config

### Community 15 - "Immich Photo Library"
Cohesion: 0.50
Nodes (4): ./apps/media/immich/app, flux-system, immich, immich-config

### Community 16 - "Jellyfin Media Server"
Cohesion: 0.50
Nodes (4): ./apps/media/jellyfin/app, flux-system, jellyfin, jellyfin-config

### Community 17 - "MetalLB Load Balancer Config"
Cohesion: 0.50
Nodes (4): ./apps/network-system/metallb/config, flux-system, metallb-config, metallb

### Community 18 - "Alertmanager"
Cohesion: 0.50
Nodes (4): ./apps/observability-system/alertmanager/app, alertmanager-config, alertmanager, flux-system

### Community 19 - "Mimir Metrics Store"
Cohesion: 0.50
Nodes (4): ./apps/observability-system/mimir/app, flux-system, mimir, mimir-config

### Community 20 - "Cluster Root Kustomization"
Cohesion: 0.67
Nodes (3): ./apps, cluster-apps, flux-system

### Community 21 - "CloudNative-PG Database"
Cohesion: 0.67
Nodes (3): ./apps/database-system/cloudnative-pg/app, cloudnative-pg, flux-system

### Community 22 - "CoreDNS"
Cohesion: 0.67
Nodes (3): ./apps/kube-system/coredns/app, coredns, flux-system

### Community 23 - "FlareSolverr Proxy"
Cohesion: 0.67
Nodes (3): ./apps/media/flaresolverr/app, flaresolverr, flux-system

### Community 24 - "Cert Manager TLS"
Cohesion: 0.67
Nodes (3): ./apps/network-system/cert-manager/app, cert-manager, flux-system

### Community 25 - "External DNS"
Cohesion: 0.67
Nodes (3): ./apps/network-system/external-dns/app, external-dns, flux-system

### Community 26 - "MetalLB App"
Cohesion: 0.67
Nodes (3): ./apps/network-system/metallb/app, flux-system, metallb

### Community 27 - "Alloy Collector App"
Cohesion: 0.67
Nodes (3): ./apps/observability-system/alloy/app, alloy, flux-system

### Community 28 - "Blackbox Exporter"
Cohesion: 0.67
Nodes (3): ./apps/observability-system/blackbox-exporter/app, blackbox-exporter, flux-system

### Community 29 - "Grafana Dashboard"
Cohesion: 0.67
Nodes (3): ./apps/observability-system/grafana/app, flux-system, grafana

### Community 30 - "Community 30"
Cohesion: 0.67
Nodes (3): ./apps/observability-system/kube-state-metrics/app, flux-system, kube-state-metrics

## Knowledge Gaps
- **275 isolated node(s):** `$schema`, `extends`, `flux-system`, `./apps`, `homelab` (+270 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **73 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `bitwarden-sdk-server-config` connect `App Config Overlays` to `Media Stack Apps`, `Data & Observability Config`, `Media & Storage Config`, `Security & Storage Backends`, `DNS & Network System`?**
  _High betweenness centrality (0.169) - this node is a cross-community bridge._
- **Why does `envoy-admin` connect `Ingress Routes & Admin Endpoints` to `Flux Operator & Envoy Gateway`?**
  _High betweenness centrality (0.103) - this node is a cross-community bridge._
- **Why does `grafana` connect `Data & Observability Config` to `Metrics Collection`?**
  _High betweenness centrality (0.083) - this node is a cross-community bridge._
- **What connects `$schema`, `extends`, `flux-system` to the rest of the system?**
  _275 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Flux GitOps & Media Sync` be split into smaller, more focused modules?**
  _Cohesion score 0.08387096774193549 - nodes in this community are weakly interconnected._
- **Should `App Config Overlays` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._
- **Should `Media Stack Apps` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._