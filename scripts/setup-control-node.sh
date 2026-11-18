#!/usr/bin/env bash
# =============================================================================
# scripts/setup-control-node.sh
# Bootstrap the local machine (control node) with all requirements for Ansible:
#  - System dependencies: python3, sshpass, yq (Go), openssh
#  - Python virtual environment (.venv) with Ansible
#  - Ansible Galaxy collections (ansible.posix, community.general)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

info()    { echo -e "  \033[34mℹ\033[0m  $*"; }
success() { echo -e "  \033[32m✔\033[0m  $*"; }
warn()    { echo -e "  \033[33m⚠\033[0m  $*"; }
error()   { echo -e "  \033[31m✖\033[0m  $*" >&2; }
header()  { echo -e "\n\033[1m▸ $*\033[0m"; }

header "Step 1: System Packages Detection & Installation"

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    echo "${ID:-unknown}"
  elif command -v pacman &>/dev/null; then
    echo "arch"
  elif command -v apt-get &>/dev/null; then
    echo "debian"
  else
    echo "unknown"
  fi
}

DISTRO=$(detect_distro)
info "Detected control node distro: $DISTRO"

install_system_deps() {
  case "$DISTRO" in
    arch|manjaro|endeavouros|garuda)
      info "Installing packages via pacman..."
      sudo pacman -S --noconfirm --needed python python-pip openssh sshpass yq make
      ;;
    debian|ubuntu|linuxmint|pop|kali|raspbian)
      info "Installing packages via apt..."
      sudo apt-get update -qq
      sudo apt-get install -y python3 python3-venv python3-pip openssh-client sshpass make curl wget
      # Install Go yq binary if not present
      if ! command -v yq &>/dev/null || ! yq --version 2>&1 | grep -q "mikefarah"; then
        info "Installing mikefarah/yq binary..."
        local arch
        arch=$(uname -m)
        case "$arch" in
          x86_64)  arch="amd64" ;;
          aarch64) arch="arm64" ;;
          *)       arch="amd64" ;;
        esac
        sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}"
        sudo chmod +x /usr/local/bin/yq
      fi
      ;;
    fedora|rhel|centos|rocky|almalinux)
      info "Installing packages via dnf..."
      sudo dnf install -y python3 python3-pip openssh openssh-clients sshpass make curl wget
      if ! command -v yq &>/dev/null || ! yq --version 2>&1 | grep -q "mikefarah"; then
        info "Installing mikefarah/yq binary..."
        local arch
        arch=$(uname -m)
        case "$arch" in
          x86_64)  arch="amd64" ;;
          aarch64) arch="arm64" ;;
          *)       arch="amd64" ;;
        esac
        sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}"
        sudo chmod +x /usr/local/bin/yq
      fi
      ;;
    *)
      warn "Unknown distro. Ensure python3, python3-venv, sshpass, openssh, and yq are installed."
      ;;
  esac
  success "System dependencies verified"
}

install_system_deps

header "Step 2: Python Virtual Environment & Ansible"
cd "$ROOT_DIR"

if [[ ! -d ".venv" ]]; then
  info "Creating Python virtual environment in .venv..."
  if command -v uv &>/dev/null; then
    uv venv .venv
  else
    python3 -m venv .venv
  fi
  success "Virtual environment created"
else
  info "Virtual environment already exists in .venv"
fi

info "Installing Ansible and Python dependencies..."
if command -v uv &>/dev/null; then
  VIRTUAL_ENV=.venv uv pip install -r requirements.txt
else
  ./.venv/bin/pip install --upgrade pip
  ./.venv/bin/pip install -r requirements.txt
fi
success "Ansible installed into .venv"

header "Step 3: Ansible Galaxy Collections"
info "Installing required collections from requirements.yml..."
./.venv/bin/ansible-galaxy collection install -r requirements.yml --upgrade
success "Ansible Galaxy collections up to date"

echo ""
success "Control node environment setup complete! 🎉"
info "You can now run:"
echo "    make bootstrap-dry    # preview VPS bootstrap"
echo "    make bootstrap        # initialize VPS access and target user"
echo "    make syntax-check     # verify playbooks syntax"
echo "    make run-site         # run provisioning playbooks"
echo ""
