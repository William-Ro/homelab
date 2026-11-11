---
description: "Agents implement changes end-to-end (branch, commit, push, open PR) using Conventional Commits; the user reviews and merges in GitHub."
---

# PR Workflow Instructions

## Your Mission

This repo follows **GitHub Flow**: `main` is the only long-lived branch (it's
also the GitHub default branch; `delete_branch_on_merge` is enabled). Every
change — a new app, a fix, a docs update — gets its own short-lived feature
branch off `main`, merged back via PR, then deleted. No `develop`/release
branches, no long-running parallel branches.

Carry a change all the way to an open pull request without stopping to ask
for each git step. The user's job is reviewing and merging PRs in GitHub, not
running git commands for you. `main` requires a PR with `Lint`/`Validate`
passing to merge, with no bypass for the owner (see
[docs/decisions/0003](../../docs/decisions/0003-enforce-pr-required-workflow-for-owner.md)) —
direct pushes to `main` are rejected.

## Workflow

1. If currently on `main`, create a feature branch first: `git checkout -b <type>/<short-slug>`.
2. Make the change.
3. Commit it yourself using the Conventional Commits format below — don't
   just print the message and wait.
4. Push the branch: `git push -u origin <branch>`.
5. Open the PR: `gh pr create --fill` (or an explicit title/body matching the
   commit message). Report the PR URL back to the user.
6. Stop there. **Never merge the PR yourself** — the user reviews and merges
   it in GitHub. Don't approve, don't use `gh pr merge`.

One logical change = one commit = one PR. Don't bundle unrelated changes into
the same branch.

## Still ask first

The workflow above doesn't need per-step confirmation, but the existing
safety rules still apply — ask before:

- Anything in AGENTS.md's ["Stop and ask before"](../../AGENTS.md#stop-and-ask-before)
  list (PVC/PV deletion or resize, SOPS/secret handling changes, deleting a
  namespace or a CNPG `Cluster`/`Database`, changing CI/Renovate automerge
  policy).
- Force-pushing, rewriting published history, or deleting a branch.
- Merging the PR, which is always the user's call.

## Commit Message Format (Conventional Commits)

```
<type>(<scope>): <short description>
```

- **type** — what kind of change (required, see table below)
- **scope** — area affected, optional but preferred (e.g. `media`, `network-system`, `decisions`)
- **description** — lowercase, imperative mood, no period, under 72 characters

| Type       | When to use                                                     |
| ---------- | --------------------------------------------------------------- |
| `feat`     | A new file, resource, or capability was added                   |
| `fix`      | A bug or misconfiguration was corrected                         |
| `chore`    | Maintenance, tooling, restructuring without behavior change     |
| `docs`     | Documentation only changes (README, comments, instructions)     |
| `refactor` | Code/config restructured without adding features or fixing bugs |
| `style`    | Formatting, whitespace, naming — no logic change                |
| `ci`       | CI/CD pipeline changes                                          |
| `revert`   | Reverting a previous commit                                     |

Examples:

```
feat(media): add subsyncarr app
fix(sabnzbd): correct nfs mount path
chore(deps): bump app-template to 5.4.0
docs(decisions): record 0003 enforce pr-required workflow for owner
ci: run lint and validate on pull requests only
```

## PR Content

- PR title mirrors the primary commit message.
- PR body: a short summary of what changed and why, linking any relevant
  `docs/decisions/`, `docs/runbooks/`, or `docs/playbooks/` entry.
