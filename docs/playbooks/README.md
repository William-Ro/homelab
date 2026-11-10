# Playbooks

Step-by-step guides for recurring build-time tasks in this repo. These are
distinct from the other two `docs/` categories:

- [`decisions/`](../decisions/README.md) record _why_ a tradeoff was made.
- [`runbooks/`](../runbooks/) cover _recovering_ when something merged to
  `main` is broken on the live cluster.
- Playbooks below cover _how to build_ something new, following the
  conventions already established in the repo.

| Playbook                               | Purpose                                                                                        |
| -------------------------------------- | ---------------------------------------------------------------------------------------------- |
| [deploy-new-app.md](deploy-new-app.md) | Add a new containerized app (from GitHub, a container registry, etc.) to the cluster via Flux. |
