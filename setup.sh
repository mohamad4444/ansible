
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

VENV_DIR=".venv"
KEY_PATH="$HOME/.ssh/ansible_mahamid"

# 1. Install local dependencies
sudo pacman -Syu --needed --noconfirm \
  python \
  python-pip \
  openssh \
  sshpass \
  make

# 2. Create Python environment
if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi

# 3. Install Ansible
"$VENV_DIR/bin/python" -m pip install \
  -r requirements.txt

# 4. Install Ansible collections
"$VENV_DIR/bin/ansible-galaxy" collection install \
  -r requirements.yml

# 5. Ensure SSH directory exists
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# 6. Generate SSH key if necessary
if [[ ! -e "$KEY_PATH" ]]; then
  if [[ -e "$KEY_PATH.pub" ]]; then
    echo "Public key exists without private key. Check manually."
    exit 1
  fi

  ssh-keygen -t ed25519 \
    -f "$KEY_PATH" \
    -C "ansible-mahamid"
fi

# 7. Restore missing public key if needed
if [[ ! -f "$KEY_PATH.pub" ]]; then
  ssh-keygen -y -f "$KEY_PATH" > "$KEY_PATH.pub"
fi

chmod 600 "$KEY_PATH"
chmod 644 "$KEY_PATH.pub"

echo
echo "Local Ansible environment is ready."
echo "Verify your VPS SSH host key before bootstrapping."
echo
echo "Run bootstrap with:"
echo "  .venv/bin/ansible-playbook -i inventory/bootstrap.yml bootstrap.yml --ask-pass"
