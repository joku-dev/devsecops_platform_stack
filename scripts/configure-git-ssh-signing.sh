#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: configure-git-ssh-signing.sh --public-key PATH [--allowed-signers-file PATH]

Configures SSH signing for the current user. The private key stays in the SSH
agent or on the host; this script only reads the public key.
EOF
}

public_key_file=""
allowed_signers_file=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --public-key)
            public_key_file="${2:-}"
            shift 2
            ;;
        --allowed-signers-file)
            allowed_signers_file="${2:-}"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

if [ -z "$public_key_file" ] || [ ! -r "$public_key_file" ]; then
    echo "A readable SSH public key is required." >&2
    usage >&2
    exit 2
fi

public_key="$(head -n 1 "$public_key_file")"
case "$public_key" in
    ssh-*|ecdsa-*)
        ;;
    *)
        echo "The supplied file does not contain a supported SSH public key." >&2
        exit 2
        ;;
esac

git config --global gpg.format ssh
git config --global user.signingkey "$public_key_file"
git config --global commit.gpgsign true
git config --global tag.gpgsign true

if [ -n "$allowed_signers_file" ]; then
    git config --global gpg.ssh.allowedSignersFile "$allowed_signers_file"
fi

echo "SSH commit and tag signing is configured for $(git config --global user.signingkey)."
echo "Add the matching public key as a GitHub signing key before pushing signed commits."
