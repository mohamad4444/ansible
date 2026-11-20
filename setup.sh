#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

VENV_DIR=".venv"
KEY_PATHS=("$HOME/.ssh/ansible_mahamid" "$HOME/.ssh/ansible_mahamid_netbird")
KEY_COMMENTS=("ansible-mahamid" "ansible-mahamid-netbird")
KEY_LABELS=("direct" "netbird")

sudo pacman -Syu --needed \
  python \
  python-pip \
  openssh \
  sshpass \
  make

if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi

"$VENV_DIR/bin/python" -m pip install \
  -r requirements.txt

"$VENV_DIR/bin/ansible-galaxy" collection install \
  -r requirements.yml

mkdir -p "$HOME/.ssh" public_keys
chmod 700 "$HOME/.ssh"

for i in "${!KEY_PATHS[@]}"; do
  key_path="${KEY_PATHS[$i]}"
  key_comment="${KEY_COMMENTS[$i]}"

  if [[ ! -e "$key_path" ]]; then
    if [[ -e "$key_path.pub" ]]; then
      echo "Public key exists without private key: $key_path. Check manually."
      exit 1
    fi

    ssh-keygen -t ed25519 \
      -f "$key_path" \
      -C "$key_comment"
  fi

  if [[ ! -f "$key_path.pub" ]]; then
    ssh-keygen -y -f "$key_path" > "$key_path.pub"
  fi

  chmod 600 "$key_path"
  chmod 644 "$key_path.pub"

  key_body=$(awk '{print $1, $2}' "$key_path.pub")
  if ! grep -q -F "$key_body" public_keys/*.pub 2>/dev/null; then
    key_id=$(python3 -c 'import uuid; print(uuid.uuid4())')
    dest="public_keys/$(hostname -s)-${KEY_LABELS[$i]}-${key_id}.pub"
    cp "$key_path.pub" "$dest"
    echo "Added public key: $dest"
  fi
done

echo
echo "Local Ansible environment is ready."
echo "Verify your VPS SSH host key before bootstrapping."
echo "Public keys are stored under public_keys/ with UUID-based names."
echo
echo "Run bootstrap with:"
echo "  .venv/bin/ansible-playbook -i inventory/bootstrap.ini playbooks/bootstrap.yml --ask-pass"
