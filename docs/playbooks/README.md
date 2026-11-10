# Playbooks

Step-by-step guides for recurring build-time tasks in this repo. These are
distinct from the other two `docs/` categories:

- [`decisions/`](../decisions/README.md) record *why* a tradeoff was made.
- [`runbooks/`](../runbooks/) cover *recovering* when something merged to
  `main` is broken on the live cluster.
- Playbooks below cover *how to build* something new, following the
  conventions already established in the repo.

| Playbook | Purpose |
| --- | --- |
| [deploy-new-app.md](deploy-new-app.md) | Add a new containerized app (from GitHub, a container registry, etc.) to the cluster via Flux. |
