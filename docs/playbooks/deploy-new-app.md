# Deploy a new app

How to add a new containerized app to the cluster — e.g. something found on
GitHub, a self-hosted project, or anything else that ships (or can be built
into) a container image. See [ARCHITECTURE.md](../../ARCHITECTURE.md) for the
full picture; this is the concrete step-by-step path.

The cluster runs containers, not arbitrary packages. If the app you want to
test only ships a `.deb` or similar, you need to wrap it in a container image
first (a small `Dockerfile` that installs it on a base image, pushed to a
registry like `ghcr.io`) before anything below applies.

## Step 0: Does this even need Flux?

For a quick "does this work at all" test that you don't intend to keep, skip
everything below: `kubectl create deployment test-app --image=<image> --port=<port>`
and `kubectl port-forward` to poke at it. Flux never touches resources it
doesn't manage, so this is safe to throw away. Use the rest of this playbook
once you've decided the app is worth keeping and committing to Git.

## Step 1: Gather requirements first

**Do not create any files until these are answered.** Per the
[AGENTS.md authority gate](../../AGENTS.md#authority-gate), things like
hostnames, resource limits, and security context are production-observable —
don't guess them.

| Question           | Notes                                                                                                                                                                                                                                                                                                                                                         |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Container image    | Full reference, e.g. `ghcr.io/foo/bar:1.2.3`. Check the upstream repo's `Dockerfile`/`ghcr.io` packages page if unclear.                                                                                                                                                                                                                                      |
| Area / namespace   | One of the existing `apps/<area>/` directories. A new area is a bigger decision — ask before creating one.                                                                                                                                                                                                                                                    |
| App name           | Kebab-case, used as the directory and resource name.                                                                                                                                                                                                                                                                                                          |
| Exposed port       | The port the container listens on.                                                                                                                                                                                                                                                                                                                            |
| HTTP route needed? | Only `envoy-internal` (network-system, LAN-only) exists in this cluster right now — there is no public/external gateway. Confirm before assuming one is wanted.                                                                                                                                                                                               |
| Persistent data?   | If yes: ad-hoc scratch data → `emptyDir`; app config/state → `persistentVolumeClaim` (defaults to the `truenas-iscsi` StorageClass); large shared media libraries → `nfs` type pointed at `truenas.reli.cc` (see existing media apps). There is **no backup solution** (no Velero/VolSync/Kopia) for any of this yet — say so if the user asks about backups. |
| Secrets needed?    | If yes, ask which Bitwarden item/field to pull from (`ClusterSecretStore: bitwarden`).                                                                                                                                                                                                                                                                        |

### Optional: check for prior art

Search `site:github.com home-ops <app-name> helm-release.yaml` or similar for
how other home-ops repos deploy the same app. Adapt findings to the patterns
below — don't copy another repo's conventions verbatim (different secret
store names, gateway names, schema URLs, etc.).

## Step 2: File layout

```text
apps/<area>/<app-name>/
├── kustomization.yaml      # includes app.ks.yaml (+ config.ks.yaml if present)
├── app.ks.yaml             # Flux Kustomization -> ./app
├── config.ks.yaml          # (optional) Flux Kustomization -> ./config
├── app/
│   ├── kustomization.yaml
│   ├── oci-repository.yaml
│   └── helm-release.yaml
└── config/                 # (optional) only if the app needs supporting resources
    ├── kustomization.yaml
    ├── external-secret.yaml # (optional)
    └── http-route.yaml      # (optional)
```

Skip `config/` entirely for a simple app with no supporting resources (no
secrets, no route, no extra PVC) — see e.g. `apps/kube-system/intel-gpu-device-plugin/`.
Don't create an empty directory "just in case."

## Step 3: Create the files

Unless the app needs CRDs/operators/webhooks that only an official chart can
provide, use **bjw-s-labs app-template**
(`oci://ghcr.io/bjw-s-labs/helm/app-template`) — every generic app in this repo
already uses it (grep `apps/**/oci-repository.yaml` for `app-template` to see
the full list and copy the currently-pinned `tag` from one of them).

### 3a. `apps/<area>/<app-name>/kustomization.yaml`

```yaml
---
# yaml-language-server: $schema=https://json.schemastore.org/kustomization.json
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ./app.ks.yaml
  - ./config.ks.yaml # omit if there is no config/
```

### 3b. `apps/<area>/<app-name>/config.ks.yaml` (if `config/` exists)

```yaml
---
# yaml-language-server: $schema=https://kubernetes-schemas.pages.dev/kustomize.toolkit.fluxcd.io/kustomization_v1.json
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: <app-name>-config
  namespace: <area>
spec:
  interval: 10m
  prune: true
  wait: true
  targetNamespace: <area>

  path: ./apps/<area>/<app-name>/config
  sourceRef:
    kind: GitRepository
    name: flux-system
    namespace: flux-system

  dependsOn:
    - name: bitwarden-sdk-server-config # only if this config/ has an ExternalSecret
      namespace: security-system
```

### 3c. `apps/<area>/<app-name>/app.ks.yaml`

```yaml
---
# yaml-language-server: $schema=https://kubernetes-schemas.pages.dev/kustomize.toolkit.fluxcd.io/kustomization_v1.json
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: <app-name>
  namespace: <area>
spec:
  interval: 10m
  prune: true
  wait: true
  targetNamespace: <area>

  path: ./apps/<area>/<app-name>/app
  sourceRef:
    kind: GitRepository
    name: flux-system
    namespace: flux-system

  dependsOn:
    - name: <app-name>-config # omit if there is no config/
```

### 3d. `apps/<area>/<app-name>/app/oci-repository.yaml`

```yaml
---
# yaml-language-server: $schema=https://kubernetes-schemas.pages.dev/source.toolkit.fluxcd.io/ocirepository_v1.json
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  name: <app-name>
spec:
  interval: 15m
  url: oci://ghcr.io/bjw-s-labs/helm/app-template
  ref:
    tag: <copy the currently-pinned tag from an existing app>

  layerSelector:
    mediaType: application/vnd.cncf.helm.chart.content.v1.tar+gzip
    operation: copy
```

### 3e. `apps/<area>/<app-name>/app/helm-release.yaml`

Start minimal and secure, expand only as needed. This mirrors every existing
app-template app in the repo (e.g. `apps/observability-system/grafana-mcp/app/helm-release.yaml`):

```yaml
---
# yaml-language-server: $schema=https://kubernetes-schemas.pages.dev/helm.toolkit.fluxcd.io/helmrelease_v2.json
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: <app-name>
  namespace: <area>
  labels:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/part-of: <logical-group-or-app-name>
    app.kubernetes.io/managed-by: flux
spec:
  interval: 30m
  chartRef:
    kind: OCIRepository
    name: <app-name>

  values:
    global:
      createDefaultServiceAccount: false

    controllers:
      <app-name>:
        annotations:
          reloader.stakater.com/auto: "true" # drop if nothing reads a ConfigMap/Secret at startup
        containers:
          app:
            image:
              repository: <image-repo>
              tag: <image-tag>
            probes:
              liveness:
                enabled: true
              readiness:
                enabled: true
              startup:
                enabled: true
            resources:
              requests:
                cpu: 10m
                memory: 64Mi
              limits:
                memory: 256Mi # tune per app; this repo never sets limits.cpu
            securityContext:
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: true # keep true unless the app genuinely can't; comment why if relaxed
              capabilities:
                drop: ["ALL"]

    defaultPodOptions:
      automountServiceAccountToken: false
      enableServiceLinks: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000 # verify the image's actual UID (kubectl exec / image docs) rather than assuming
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: OnRootMismatch

    service:
      app:
        controller: <app-name>
        ports:
          http:
            port: <port>
```

**Writable paths under `readOnlyRootFilesystem: true`** — mount `emptyDir` for
anything the app writes to at runtime:

```yaml
persistence:
  tmp:
    type: emptyDir
    globalMounts:
      - path: /tmp
```

**Persistent config/state** (no backup solution exists yet — say so if asked):

```yaml
persistence:
  config:
    type: persistentVolumeClaim
    accessMode: ReadWriteOnce
    size: 2Gi
    globalMounts:
      - path: /config
```

**Shared media/library NFS mount** (matches the existing media-stack apps):

```yaml
persistence:
  data:
    type: nfs
    server: truenas.reli.cc
    path: /mnt/media/<share>
    globalMounts:
      - path: /data
```

**HTTP route** (only `envoy-internal` exists — confirm before adding any other
gateway), as `apps/<area>/<app-name>/config/http-route.yaml`:

```yaml
---
# yaml-language-server: $schema=https://kubernetes-schemas.pages.dev/gateway.networking.k8s.io/httproute_v1.json
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: <app-name>
  labels:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/component: httproute
    app.kubernetes.io/managed-by: flux
spec:
  parentRefs:
    - name: envoy-internal
      namespace: network-system
      sectionName: https
  hostnames:
    - <app-name>.internal.reli.cc
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: <app-name>
          port: <port>
```

**Secret from Bitwarden**, as `apps/<area>/<app-name>/config/external-secret.yaml`:

```yaml
---
# yaml-language-server: $schema=https://kubernetes-schemas.pages.dev/external-secrets.io/externalsecret_v1.json
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: <app-name>-secret
  labels:
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/managed-by: flux
spec:
  refreshInterval: 1h

  secretStoreRef:
    name: bitwarden
    kind: ClusterSecretStore

  target:
    name: <app-name>-secret
    creationPolicy: Owner

  data:
    - secretKey: <ENV_VAR_NAME>
      remoteRef:
        key: "<Bitwarden item name>"
```

Then reference it from the HelmRelease:

```yaml
env:
  <ENV_VAR_NAME>:
    valueFrom:
      secretKeyRef:
        name: <app-name>-secret
        key: <ENV_VAR_NAME>
```

**Dedicated Postgres** — add `components: [../../../../components/cnpg/]` and
`postBuild.substitute` (`APP`, optionally `CNPG_IMAGE`/storage sizes) to
`config.ks.yaml`, plus `dependsOn: [{name: cloudnative-pg-config, namespace: database-system}]`.
See `apps/media/immich/config.ks.yaml` for a full example.

### 3f. `apps/<area>/<app-name>/app/kustomization.yaml` and `config/kustomization.yaml`

List every file you created, e.g.:

```yaml
---
# yaml-language-server: $schema=https://json.schemastore.org/kustomization.json
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ./oci-repository.yaml
  - ./helm-release.yaml
```

## Step 4: Register the app in the area Kustomization

Add `./<app-name>` to `apps/<area>/kustomization.yaml`'s `resources:` list.
Flux will never see the new app otherwise — this is the single most common
reason a new app "does nothing."

## Step 5: Security checklist

- [ ] `global.createDefaultServiceAccount: false`
- [ ] `automountServiceAccountToken: false` and `enableServiceLinks: false` in `defaultPodOptions`
- [ ] `runAsNonRoot: true`, specific non-zero `runAsUser`/`runAsGroup`/`fsGroup` (verify, don't guess)
- [ ] `allowPrivilegeEscalation: false`, `capabilities.drop: ["ALL"]`
- [ ] `readOnlyRootFilesystem: true` unless proven impossible (comment why if `false`)
- [ ] `limits.cpu` is **not set** (repo convention — only `requests.cpu` and `limits.memory`)
- [ ] Secrets come from an `ExternalSecret`, never hardcoded in the `HelmRelease`

## Step 6: Validate

```sh
nix shell nixpkgs#yamllint --command yamllint --strict -c .yamllint.yaml apps/<area>/<app-name>

nix shell nixpkgs#docker --command docker run --rm \
  -v "$PWD:/github/workspace" -w /github/workspace \
  ghcr.io/home-operations/flate:0.7.3 test --path .github/flux-local
```

A plain `kustomize build apps/<area>/<app-name>/app` renders the chart but
does not apply `dependsOn` ordering or `postBuild.substitute` — it's a quick
sanity check, not full validation.

## Common pitfalls

- **Forgetting Step 4** — the app directory exists but Flux never builds it.
- **Wrong UID** — some images run as a non-1000 UID; verify with `kubectl exec`
  or the image's docs rather than assuming.
- **Shell variables in a ConfigMap** — if a ConfigMap contains `${VAR}` shell
  syntax, add `kustomize.toolkit.fluxcd.io/substitute: disabled` to it so Flux
  doesn't try to resolve it as a `postBuild.substitute` variable.
- **Secret filename** — if you ever add a SOPS-encrypted secret instead of an
  `ExternalSecret`, it must match `.sops.yaml`'s `*.secret(.sops)?.yaml` regex
  or it won't be encrypted.
