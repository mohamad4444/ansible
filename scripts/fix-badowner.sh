#!/usr/bin/env bash

# ===== Configure this =====
SSH_DIR="${SSH_DIR:-$HOME/.ssh}"
# ==========================

# Expand ~ if someone sets it manually
SSH_DIR="/home/aaa/scripts/aaa/.ssh/"

if [ ! -d "$SSH_DIR" ]; then
  echo "Directory $SSH_DIR does not exist."
  exit 1
fi

echo "Fixing permissions in: $SSH_DIR"

# Make sure you own the files
chown -R "$USER:$USER" "$SSH_DIR"

# Fix directory permissions
chmod 700 "$SSH_DIR"

# Fix config file permissions (if it exists)
[ -f "$SSH_DIR/config" ] && chmod 600 "$SSH_DIR/config"

# Fix private keys
find "$SSH_DIR" -type f \( -name "id_*" ! -name "*.pub" \) -exec chmod 600 {} \;

# Fix public keys
find "$SSH_DIR" -type f -name "*.pub" -exec chmod 644 {} \;

echo "Done."