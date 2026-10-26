---
description: "After making any changes, always suggest a conventional commit message following the Conventional Commits spec."
---

# Conventional Commits Instructions

## Your Mission

After every change to files in this project, suggest a conventional commit message that is clear, consistent, and machine-parseable. Never run `git commit` — only output the suggested message as a plain code block.

## Commit Format

```
<type>(<scope>): <short description>
```

- **type** — what kind of change (required, see table below)
- **scope** — area affected, optional but preferred (e.g. `auth`, `api`, `ui`, `database`)
- **description** — lowercase, imperative mood, no period, under 72 characters

## Commit Types

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

## Scope Guidelines

- Use the **folder or module name** as the scope when a single area changed
- Use a **feature/domain name** when the change spans multiple files in one area
- Omit scope only when the change is truly cross-cutting (e.g. `chore: update lockfile`)

## Examples

```
feat(auth): add OAuth2 login flow
fix(api): handle null response from user endpoint
chore(deps): bump eslint to 9.0.0
docs(readme): add installation instructions
refactor(database): extract query builder into separate module
style(ui): fix button alignment in header
ci: add lint step to pull request workflow
chore: update lockfile
```

## Commit Checklist

- [ ] Type accurately reflects the nature of the change
- [ ] Scope matches the primary area changed
- [ ] Description is lowercase and imperative (e.g. "add", "fix", "remove")
- [ ] Description is under 72 characters
- [ ] Multiple unrelated changes use separate messages
- [ ] No quotes around the message — plain code block only

## Best Practices Summary

1. Always suggest a commit message after finishing changes
2. Use the correct type — `feat` for additions, `fix` for corrections, `chore` for everything else
3. Prefer a scope over omitting it — it adds useful context
4. Keep descriptions short, imperative, and lowercase
5. One logical change = one commit message
6. When in doubt about scope, use the folder or module name
