#!/usr/bin/env bash
# Script to generate SSH keys for local development
# Only in case Vps still uses password based authentication
set -e

KEY="$HOME/.ssh/id_ed25519"

if [ ! -f "$KEY" ]; then
  echo "🔑 No SSH key found, generating one..."
  ssh-keygen -t ed25519 -C "ansible@local" -f "$KEY" -N ""
else
  echo "✅ SSH key already exists"
fi

echo "Public key:"
cat "$KEY.pub"
