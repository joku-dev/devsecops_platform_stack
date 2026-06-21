#!/usr/bin/env bash
set -euo pipefail

format="$(git config --global --get gpg.format || true)"
signing_key="$(git config --global --get user.signingkey || true)"
commit_signing="$(git config --global --get commit.gpgsign || true)"
tag_signing="$(git config --global --get tag.gpgsign || true)"

if [ "$format" != "ssh" ]; then
    echo "gpg.format must be ssh; run make git-signing-setup." >&2
    exit 1
fi

if [ -z "$signing_key" ] || [ ! -r "$signing_key" ]; then
    echo "user.signingkey must reference a readable SSH public key." >&2
    exit 1
fi

if [ "$commit_signing" != "true" ] || [ "$tag_signing" != "true" ]; then
    echo "commit.gpgsign and tag.gpgsign must both be true." >&2
    exit 1
fi

if [ -z "${SSH_AUTH_SOCK:-}" ]; then
    echo "SSH_AUTH_SOCK is not set; start an SSH agent or reopen the Dev Container." >&2
    exit 1
fi

if ! ssh-add -L >/dev/null 2>&1; then
    echo "No signing key is available through the SSH agent." >&2
    exit 1
fi

echo "SSH Git-signing configuration and SSH agent are available."
