# Factory Development Stack

## Purpose

`devsecops_platform_stack` is a standalone, versioned development toolchain for projects such as the AI-Native Engineering Factory. It provides tooling, image security and developer workflows. It does not contain Factory source code, Factory runtime data, Factory credentials or Factory services.

## Use With The Factory

After the workspace image has been published, copy `templates/factory-development/.devcontainer/` into the Factory repository as `.devcontainer/`. The Factory checkout remains the workspace mount; its project dependencies are installed only into that checkout's `.venv`.

```bash
cp -R templates/factory-development/.devcontainer /path/to/ai-native-engineering-factory/
```

The template uses the signed Workspace image from GHCR. Pin the image to a digest for controlled releases rather than relying on the moving `main` tag.

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

For local verification of other developers' SSH signatures, copy `templates/factory-development/.gitsigners.example` to a controlled `.gitsigners` file, add approved public keys, and configure it:

```bash
git config --global gpg.ssh.allowedSignersFile "$(pwd)/.gitsigners"
```

GitHub verifies commits against signing keys registered on each user's GitHub account. Repository administrators should additionally enable **Require signed commits** in branch protection for protected branches.

## Image Supply Chain

The Stack workflow publishes the Workspace image to GHCR, signs it with keyless Cosign and attaches GitHub build provenance. Verify the published image before using a pinned digest in a Factory Dev Container.
