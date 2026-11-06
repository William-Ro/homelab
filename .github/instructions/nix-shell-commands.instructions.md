---
description: "Enforce nix shell wrapping for all external commands since no tools are globally installed in Nix-based environments."
---

# Nix Shell Command Enforcement

## Your Mission

Ensure every external command is wrapped with `nix shell nixpkgs#<package> --command` before execution. In Nix-based environments no tools are globally installed — shell built-ins are the only exception.

## Catch-All Rule

If a command invokes any external tool (anything that is not a shell built-in like `cd`, `echo`, `export`), it **must** be wrapped in `nix shell nixpkgs#<package> --command`. If a tool is not in the table below, look up its nixpkgs attribute name and wrap it the same way.

## Required Format

```bash
# Single tool
nix shell nixpkgs#nodejs --command npm run build

# Multiple tools
nix shell nixpkgs#nodejs nixpkgs#nodePackages.typescript --command tsc --noEmit
```

## Tool → nixpkgs Package Mapping

### JavaScript / Node.js

| Tool(s)              | nix shell prefix                                                     |
| -------------------- | -------------------------------------------------------------------- |
| `node`, `npm`, `npx` | `nix shell nixpkgs#nodejs --command`                                 |
| `yarn`               | `nix shell nixpkgs#yarn --command`                                   |
| `pnpm`               | `nix shell nixpkgs#nodePackages.pnpm --command`                      |
| `tsc`                | `nix shell nixpkgs#nodejs nixpkgs#nodePackages.typescript --command` |
| `eslint`             | `nix shell nixpkgs#nodejs nixpkgs#nodePackages.eslint --command`     |
| `prettier`           | `nix shell nixpkgs#nodePackages.prettier --command`                  |
| `jest` / `vitest`    | `nix shell nixpkgs#nodejs --command npx jest`                        |
| `vite` / `webpack`   | `nix shell nixpkgs#nodejs --command npx vite`                        |

### JVM (Java / Kotlin / Scala)

| Tool(s)             | nix shell prefix                     |
| ------------------- | ------------------------------------ |
| `java`, `javac`     | `nix shell nixpkgs#jdk --command`    |
| `mvn`               | `nix shell nixpkgs#maven --command`  |
| `gradle`, `gradlew` | `nix shell nixpkgs#gradle --command` |
| `kotlin`, `kotlinc` | `nix shell nixpkgs#kotlin --command` |
| `scala`, `scalac`   | `nix shell nixpkgs#scala --command`  |
| `sbt`               | `nix shell nixpkgs#sbt --command`    |

### Python

| Tool(s)             | nix shell prefix                                                            |
| ------------------- | --------------------------------------------------------------------------- |
| `python`, `python3` | `nix shell nixpkgs#python3 --command`                                       |
| `pip`, `pip3`       | `nix shell nixpkgs#python3 --command pip`                                   |
| `pytest`            | `nix shell nixpkgs#python3 nixpkgs#python3Packages.pytest --command pytest` |
| `poetry`            | `nix shell nixpkgs#poetry --command`                                        |
| `uv`                | `nix shell nixpkgs#uv --command`                                            |

### Go / Rust / Other Languages

| Tool(s)                    | nix shell prefix                    |
| -------------------------- | ----------------------------------- |
| `go`                       | `nix shell nixpkgs#go --command`    |
| `cargo`, `rustc`, `rustup` | `nix shell nixpkgs#cargo --command` |
| `ruby`, `gem`, `bundle`    | `nix shell nixpkgs#ruby --command`  |
| `php`, `composer`          | `nix shell nixpkgs#php --command`   |

### Infrastructure / Cloud

| Tool(s)                    | nix shell prefix                               |
| -------------------------- | ---------------------------------------------- |
| `terraform`                | `nix shell nixpkgs#terraform --command`        |
| `kubectl`                  | `nix shell nixpkgs#kubectl --command`          |
| `helm`                     | `nix shell nixpkgs#kubernetes-helm --command`  |
| `docker`, `docker-compose` | `nix shell nixpkgs#docker --command`           |
| `aws`                      | `nix shell nixpkgs#awscli2 --command`          |
| `gcloud`                   | `nix shell nixpkgs#google-cloud-sdk --command` |
| `az`                       | `nix shell nixpkgs#azure-cli --command`        |

### Build / Make

| Tool(s)      | nix shell prefix                      |
| ------------ | ------------------------------------- |
| `make`       | `nix shell nixpkgs#gnumake --command` |
| `cmake`      | `nix shell nixpkgs#cmake --command`   |
| `gcc`, `g++` | `nix shell nixpkgs#gcc --command`     |

### CLI Utilities

| Tool(s)          | nix shell prefix                         |
| ---------------- | ---------------------------------------- |
| `git`            | `nix shell nixpkgs#git --command`        |
| `curl`           | `nix shell nixpkgs#curl --command`       |
| `wget`           | `nix shell nixpkgs#wget --command`       |
| `jq`             | `nix shell nixpkgs#jq --command`         |
| `yq`             | `nix shell nixpkgs#yq --command`         |
| `rg` / `ripgrep` | `nix shell nixpkgs#ripgrep --command`    |
| `fzf`            | `nix shell nixpkgs#fzf --command`        |
| `bat`            | `nix shell nixpkgs#bat --command`        |
| `psql`           | `nix shell nixpkgs#postgresql --command` |
| `redis-cli`      | `nix shell nixpkgs#redis --command`      |
| `sqlite3`        | `nix shell nixpkgs#sqlite --command`     |

## Common Workflows

```bash
# Node - install / build / lint / test
nix shell nixpkgs#nodejs --command npm install
nix shell nixpkgs#nodejs --command npm run build
nix shell nixpkgs#nodejs --command npm run lint
nix shell nixpkgs#nodejs --command npm run test

# Java - Maven build & test
nix shell nixpkgs#maven --command mvn clean install
nix shell nixpkgs#maven --command mvn test

# Java - Gradle build & test
nix shell nixpkgs#gradle --command gradle build
nix shell nixpkgs#gradle --command gradle test

# Python
nix shell nixpkgs#python3 --command python -m pytest

# Go
nix shell nixpkgs#go --command go build ./...
nix shell nixpkgs#go --command go test ./...
```

## Command Checklist

- [ ] Command is not a shell built-in (`cd`, `echo`, `export`, etc.)
- [ ] Tool is wrapped in `nix shell nixpkgs#<package> --command`
- [ ] Multiple tools use multiple `nixpkgs#<pkg>` entries before `--command`
- [ ] Package name is verified against the mapping table above
- [ ] Unknown tools have their nixpkgs attribute looked up before wrapping

## Best Practices Summary

1. Never assume a tool is globally available — always wrap with `nix shell`
2. Use the mapping table as the first reference for package names
3. Combine multiple packages in a single `nix shell` invocation when needed
4. Shell built-ins (`cd`, `echo`, `export`) are the only commands that don't need wrapping
5. When a tool is not in the table, look up its nixpkgs attribute at search.nixos.org
6. Keep commands concise — chain with `&&` rather than chaining `nix shell` invocations
