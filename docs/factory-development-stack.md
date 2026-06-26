# Factory Development Stack

## Purpose

`devsecops_platform_stack` is the standalone, versioned development toolchain for projects such as the AI-Native Engineering Factory. It provides the shared Dev Container, tooling, image security and developer workflows. It does not contain Factory source code, Factory runtime data, Factory credentials or Factory services.

## Use With The Factory

Open this repository in its Dev Container, then clone the Factory as a separate checkout in the shared host workspace. Do not add a `.devcontainer/` directory to the Factory repository.

Before starting the Dev Container, copy `docker/.env.example` to `docker/.env` and set `WORKSPACE_ROOT` to the absolute host directory that contains both repositories. The local Compose configuration mounts it at `/workspace`.

```bash
cd /workspace
git clone git@github.com:joku-dev/ai-native-engineering-factory.git ai-native-engineering-factory
cd /workspace/ai-native-engineering-factory
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -e '.[dev,neo4j]'
```

Open `/workspace/ai-native-engineering-factory` in the already running Dev Container to work on the Factory. The checkout and its `.venv` remain separate from this stack repository, while every developer uses the same versioned Stack image and editor configuration.

## GitHub Authentication

Inside the Dev Container, authenticate per user:

```bash
gh auth login
gh auth status
```

The token remains in the container user's home directory. Never copy it into the Factory repository, image, Compose files or CI configuration.

## SSH Commit Signing

Generate a dedicated signing key on the host if you do not already have one:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_signing -C "your-email@example.com"
ssh-add ~/.ssh/id_ed25519_signing
```

Add `~/.ssh/id_ed25519_signing.pub` to GitHub as a **Signing Key**. Then, inside the Dev Container:

```bash
configure-git-ssh-signing.sh --public-key ~/.ssh/id_ed25519_signing.pub
check-git-ssh-signing.sh
git commit -S -m "Example signed commit"
git log --show-signature -1
```

The setup enables signed commits and tags globally for the developer. Private keys stay on the host or in its SSH agent; only the public-key path is stored in Git configuration.

## Local Verification

For local verification of other developers' SSH signatures, copy `templates/factory-development/.gitsigners.example` to a controlled `.gitsigners` file in the Factory checkout, add approved public keys, and configure it:

```bash
git config --global gpg.ssh.allowedSignersFile "$(pwd)/.gitsigners"
```

GitHub verifies commits against signing keys registered on each user's GitHub account. Repository administrators should additionally enable **Require signed commits** in branch protection for protected branches.

## Image Supply Chain

The Stack workflow publishes the Workspace image to GHCR, signs it with keyless Cosign and attaches GitHub build provenance. Verify the published image before using a pinned digest in a Factory Dev Container.
