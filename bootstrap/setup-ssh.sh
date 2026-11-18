#!/usr/bin/env bash
# =============================================================================
# bootstrap/setup-ssh.sh
# Bootstrap SSH key generation and deployment for Ansible.
#
# Reads:  bootstrap/hosts.yml  (secrets, gitignored)
# Uses:   yq (https://github.com/mikefarah/yq) for YAML parsing
#
# Usage:
#   bash bootstrap/setup-ssh.sh                  # process all hosts
#   bash bootstrap/setup-ssh.sh --host my-vps    # process one host by name
#   bash bootstrap/setup-ssh.sh --dry-run        # preview without making changes
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/hosts.yml"

# ---------------------------------------------------------------------------
# CLI flags
# ---------------------------------------------------------------------------
TARGET_HOST=""
DRY_RUN=false
FORCE_OVERWRITE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)      TARGET_HOST="$2"; shift 2 ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --overwrite) FORCE_OVERWRITE=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--host <name>] [--dry-run] [--overwrite]"
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()    { echo -e "  \033[34mℹ\033[0m  $*"; }
success() { echo -e "  \033[32m✔\033[0m  $*"; }
warn()    { echo -e "  \033[33m⚠\033[0m  $*"; }
error()   { echo -e "  \033[31m✖\033[0m  $*" >&2; }
header()  { echo -e "\n\033[1m▸ $*\033[0m"; }
dry()     { echo -e "  \033[90m[dry-run]\033[0m $*"; }

run() {
  if $DRY_RUN; then
    dry "$*"
  else
    eval "$@"
  fi
}

# ---------------------------------------------------------------------------
# Distro detection
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Install a missing package — distro-aware
# ---------------------------------------------------------------------------
install_pkg() {
  local tool="$1"
  local distro="$2"

  case "$distro" in
    arch|manjaro|endeavouros|garuda)
      case "$tool" in
        # yq from the official Arch extra repo IS the Go/mikefarah version.
        # AUR 'yq' may be the Python wrapper — always use pacman first.
        yq)         sudo pacman -S --noconfirm yq || _install_yq_binary ;;
        sshpass)    sudo pacman -S --noconfirm sshpass ;;
        ssh-keygen) sudo pacman -S --noconfirm openssh ;;
        ssh-copy-id) sudo pacman -S --noconfirm openssh ;;
        *)          sudo pacman -S --noconfirm "$tool" ;;
      esac ;;

    debian|ubuntu|linuxmint|pop|kali|raspbian)
      case "$tool" in
        # Debian's 'yq' package is the Python wrapper — always use binary.
        yq)         _install_yq_binary ;;
        sshpass)    sudo apt-get install -y sshpass ;;
        ssh-keygen) sudo apt-get install -y openssh-client ;;
        ssh-copy-id) sudo apt-get install -y openssh-client ;;
        *)          sudo apt-get install -y "$tool" ;;
      esac ;;

    fedora|rhel|centos|rocky|almalinux)
      case "$tool" in
        yq)         _install_yq_binary ;;
        sshpass)    sudo dnf install -y sshpass ;;
        ssh-keygen) sudo dnf install -y openssh ;;
        ssh-copy-id) sudo dnf install -y openssh-clients ;;
        *)          sudo dnf install -y "$tool" ;;
      esac ;;

    *)
      warn "Unknown distro '$distro' — cannot auto-install '$tool'."
      return 1 ;;
  esac
}

# Download the Go/mikefarah yq binary from GitHub (guaranteed correct flavor)
_install_yq_binary() {
  info "Downloading mikefarah/yq binary from GitHub..."
  local arch
  arch=$(uname -m)
  case "$arch" in
    x86_64)  arch="amd64" ;;
    aarch64) arch="arm64" ;;
    armv7l)  arch="arm" ;;
    *)       arch="amd64" ;;
  esac
  local url="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}"
  sudo wget -qO /usr/local/bin/yq "$url"
  sudo chmod +x /usr/local/bin/yq
  hash -r   # clear shell's command cache so new binary is picked up
  success "yq (Go/mikefarah) installed to /usr/local/bin/yq"
}

# ---------------------------------------------------------------------------
# Verify yq is the Go/mikefarah build, not the Python wrapper.
# The Python yq uses jq syntax: calling `yq e '.' file` causes
#   jq: error: e/0 is not defined
# The Go yq reports its URL in --version output.
# ---------------------------------------------------------------------------
_ensure_go_yq() {
  local ver_output
  ver_output=$(yq --version 2>&1 || true)

  # mikefarah Go yq always prints "https://github.com/mikefarah/yq"
  if echo "$ver_output" | grep -q "mikefarah"; then
    return 0
  fi

  warn "Installed 'yq' is NOT the Go/mikefarah version (found: $ver_output)"
  warn "The Python yq wrapper is incompatible — installing the correct binary..."
  _install_yq_binary

  # Confirm it worked
  ver_output=$(yq --version 2>&1 || true)
  if echo "$ver_output" | grep -q "mikefarah"; then
    success "Correct yq (Go/mikefarah) is now active"
  else
    error "yq flavor check failed even after binary install."
    error "Please manually install: https://github.com/mikefarah/yq#install"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Dependency check — auto-installs missing tools, enforces correct yq flavor
# ---------------------------------------------------------------------------
check_deps() {
  local distro
  distro=$(detect_distro)
  info "Detected distro: $distro"

  local apt_updated=false

  local missing=()
  for cmd in yq ssh-keygen ssh-copy-id sshpass; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    warn "Missing tools: ${missing[*]}"
    echo ""

    local reply
    read -rp "  Install missing tools now? [Y/n] " reply
    reply="${reply:-Y}"
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      echo ""
      _print_install_hint "$distro"
      exit 1
    fi

    echo ""

    if [[ "$distro" =~ ^(debian|ubuntu|linuxmint|pop|kali|raspbian)$ ]] && ! $apt_updated; then
      info "Running apt-get update..."
      sudo apt-get update -qq
      apt_updated=true
    fi

    local failed=()
    for tool in "${missing[@]}"; do
      info "Installing $tool..."
      if install_pkg "$tool" "$distro"; then
        success "$tool installed"
      else
        failed+=("$tool")
      fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
      error "Failed to install: ${failed[*]}"
      echo ""
      _print_install_hint "$distro"
      exit 1
    fi

    success "All dependencies installed"
  else
    success "All dependencies present"
  fi

  # Always verify yq is the correct Go flavor (even if already installed)
  _ensure_go_yq
}

# Manual install hints
_print_install_hint() {
  local distro="${1:-unknown}"
  echo "  Install manually:"
  case "$distro" in
    arch|manjaro|endeavouros|garuda)
      echo "    sudo pacman -S openssh sshpass yq" ;;
    debian|ubuntu|linuxmint|pop|kali|raspbian)
      echo "    sudo apt-get install -y openssh-client sshpass"
      echo "    sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64"
      echo "    sudo chmod +x /usr/local/bin/yq" ;;
    fedora|rhel|centos|rocky|almalinux)
      echo "    sudo dnf install -y openssh openssh-clients sshpass"
      echo "    sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64"
      echo "    sudo chmod +x /usr/local/bin/yq" ;;
    *)
      echo "    openssh, sshpass — use your distro's package manager"
      echo "    yq (Go) — https://github.com/mikefarah/yq#install" ;;
  esac
  echo ""
}

# ---------------------------------------------------------------------------
# Config file check
# ---------------------------------------------------------------------------
check_config() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Config file not found: $CONFIG_FILE"
    echo ""
    echo "  Copy the template to get started:"
    echo "    cp bootstrap/hosts.template.yml bootstrap/hosts.yml"
    echo "  Then edit bootstrap/hosts.yml with your host details."
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Read a yq field with a fallback default
# Usage: yq_get <index> <field> [default]
# ---------------------------------------------------------------------------
yq_get() {
  local idx="$1"
  local field="$2"
  local default="${3:-}"
  local val
  val=$(yq e ".hosts[$idx].$field" "$CONFIG_FILE" 2>/dev/null)
  if [[ "$val" == "null" || -z "$val" ]]; then
    echo "$default"
  else
    echo "$val"
  fi
}

# ---------------------------------------------------------------------------
# Count hosts
# ---------------------------------------------------------------------------
host_count() {
  yq e '.hosts | length' "$CONFIG_FILE"
}

# ---------------------------------------------------------------------------
# Process a single host by its array index
# ---------------------------------------------------------------------------
process_host() {
  local idx="$1"

  # -- Read all fields from YAML -------------------------------------------
  local name         ; name=$(yq_get "$idx" "name" "host-$idx")
  local host         ; host=$(yq_get "$idx" "host")
  local port         ; port=$(yq_get "$idx" "port" "22")
  local initial_user ; initial_user=$(yq_get "$idx" "initial_user" "root")
  local use_password ; use_password=$(yq_get "$idx" "use_password" "false")
  local password     ; password=$(yq_get "$idx" "password" "")
  local set_password ; set_password=$(yq_get "$idx" "set_password" "")
  local auth_user    ; auth_user=$(yq_get "$idx" "authorize_for_user" "$initial_user")
  local del_root_keys; del_root_keys=$(yq_get "$idx" "delete_root_authorized_keys" "true")

  local key_generate      ; key_generate=$(yq_get "$idx" "key.generate" "true")
  local key_overwrite     ; key_overwrite=$(yq_get "$idx" "key.overwrite" "false")
  local key_type          ; key_type=$(yq_get "$idx" "key.type" "ed25519")
  local key_bits          ; key_bits=$(yq_get "$idx" "key.bits" "4096")
  local key_comment       ; key_comment=$(yq_get "$idx" "key.comment" "ansible@$name")
  local key_use_default   ; key_use_default=$(yq_get "$idx" "key.use_default_name" "false")
  local key_custom_name   ; key_custom_name=$(yq_get "$idx" "key.custom_name" "$name")
  local key_passphrase    ; key_passphrase=$(yq_get "$idx" "key.passphrase" "")
  local key_existing_path ; key_existing_path=$(yq_get "$idx" "key.existing_path" "")
  local key_public_key    ; key_public_key=$(yq_get "$idx" "key.public_key" "")

  # Validate required fields
  if [[ -z "$host" || "$host" == "null" ]]; then
    error "[$name] 'host' is required but missing in hosts.yml entry $idx"
    return 1
  fi

  header "Host: $name ($host)"

  # -- Resolve key path and public key content --------------------------------
  # key_path        = local private key (for verification; empty if public_key mode)
  # pub_key_content = the public key string to authorize on the remote host
  local key_path=""
  local pub_key_content=""

  if [[ "$key_generate" == "true" ]]; then
    # ---- GENERATE a new key pair -------------------------------------------
    if [[ "$key_use_default" == "true" ]]; then
      key_path="$HOME/.ssh/id_${key_type}"
    else
      key_path="$HOME/.ssh/${key_custom_name}"
    fi

    local should_overwrite=false
    if [[ "$FORCE_OVERWRITE" == "true" || "$key_overwrite" == "true" ]]; then
      should_overwrite=true
    fi

    if [[ -f "$key_path" && "$should_overwrite" != "true" ]]; then
      warn "[$name] Key already exists at $key_path — skipping generation (use --overwrite or key.overwrite: true to overwrite)"
    else
      if [[ -f "$key_path" && "$should_overwrite" == "true" ]]; then
        info "[$name] Overwriting existing key at $key_path..."
        run "rm -f \"$key_path\" \"${key_path}.pub\""
      fi

      info "[$name] Generating $key_type key → $key_path"

      local keygen_args="-t $key_type -C \"$key_comment\" -f \"$key_path\" -N \"$key_passphrase\""
      if [[ "$key_type" == "rsa" ]]; then
        keygen_args="-t rsa -b $key_bits -C \"$key_comment\" -f \"$key_path\" -N \"$key_passphrase\""
      fi

      run "ssh-keygen $keygen_args"
      run "chmod 600 \"$key_path\""
      run "chmod 644 \"${key_path}.pub\""
      success "[$name] Key generated: $key_path"
    fi

    pub_key_content=$(cat "${key_path}.pub")

  else
    # ---- USE an existing key — two sub-modes --------------------------------

    if [[ -n "$key_existing_path" && "$key_existing_path" != "null" ]]; then
      # Sub-mode A: existing_path — point to a private key on disk
      key_path="${key_existing_path/#\~/$HOME}"
      if [[ ! -f "$key_path" ]]; then
        error "[$name] existing_path '$key_path' not found. Skipping."
        return 1
      fi
      local pub_path="${key_path}.pub"
      if [[ ! -f "$pub_path" ]]; then
        error "[$name] Public key '$pub_path' not found alongside private key. Skipping."
        return 1
      fi
      pub_key_content=$(cat "$pub_path")
      info "[$name] Using existing key: $key_path"

    elif [[ -n "$key_public_key" && "$key_public_key" != "null" ]]; then
      # Sub-mode B: raw public_key string — no private key needed locally
      pub_key_content="$key_public_key"
      key_path=""
      info "[$name] Using provided public key string (no local private key)"

    else
      error "[$name] generate=false but neither 'existing_path' nor 'public_key' is set."
      error "       Set key.existing_path (path to private key) OR key.public_key (raw pub key string)."
      return 1
    fi
  fi

  # -- Prompt for password if needed but not supplied ------------------------
  if [[ "$use_password" == "true" && -z "$password" ]]; then
    echo -n "  🔒 [$name] Password for $initial_user@$host: "
    read -rs password
    echo ""
  fi

  # -- Clear stale known_hosts entry (handles reinstalled servers) -----------
  info "[$name] Clearing any stale known_hosts entry for $host..."
  ssh-keygen -R "$host"           2>/dev/null || true
  ssh-keygen -R "[$host]:$port"   2>/dev/null || true

  # -- Deploy public key to host ---------------------------------------------
  info "[$name] Deploying public key to $initial_user@$host (authorizing for user: $auth_user)"

  # UserKnownHostsFile=/dev/null: ignore stale keys during bootstrap.
  # StrictHostKeyChecking=accept-new: accept new host keys but never replace changed ones
  #   (changed key still warns, so we use /dev/null to bypass for bootstrap).
  local ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o BatchMode=no -p $port"

  local remote_cmd=""
  if [[ "$initial_user" == "root" && "$auth_user" != "root" ]]; then
    # Connect as root, install prerequisite packages for Ansible (sudo, python3, python3-apt),
    # ensure auth_user exists with sudo permissions,
    # set up authorized_keys for auth_user, and optionally remove the key from root's authorized_keys.
    info "[$name] Initial user is root and target user is '$auth_user'. Ensuring user '$auth_user' exists with sudo & python..."
    remote_cmd="export DEBIAN_FRONTEND=noninteractive; \
which apt-get >/dev/null 2>&1 && apt-get update -qq && apt-get install -y sudo python3 python3-apt; \
id -u '$auth_user' >/dev/null 2>&1 || useradd -m -s /bin/bash -G sudo '$auth_user'; \
usermod -aG sudo '$auth_user' 2>/dev/null || true; \
mkdir -p /etc/sudoers.d && echo '$auth_user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99-bootstrap-$auth_user && chmod 0440 /etc/sudoers.d/99-bootstrap-$auth_user; \
USER_HOME=\$(eval echo ~$auth_user); \
mkdir -p \"\$USER_HOME/.ssh\" && chmod 700 \"\$USER_HOME/.ssh\"; \
grep -qxF '$pub_key_content' \"\$USER_HOME/.ssh/authorized_keys\" 2>/dev/null || echo '$pub_key_content' >> \"\$USER_HOME/.ssh/authorized_keys\"; \
chmod 600 \"\$USER_HOME/.ssh/authorized_keys\" && chown -R ${auth_user}:${auth_user} \"\$USER_HOME/.ssh\""
  else
    remote_cmd="export DEBIAN_FRONTEND=noninteractive; \
which apt-get >/dev/null 2>&1 && apt-get update -qq && apt-get install -y sudo python3 python3-apt; \
mkdir -p ~/.ssh && chmod 700 ~/.ssh && grep -qxF '$pub_key_content' ~/.ssh/authorized_keys 2>/dev/null || echo '$pub_key_content' >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys"
  fi

  local deploy_ok=false
  if [[ "$use_password" == "true" ]]; then
    if ! command -v sshpass &>/dev/null; then
      error "sshpass is required for password authentication. Install: sudo apt install sshpass"
      return 1
    fi
    if $DRY_RUN; then
      dry "sshpass -p '***' ssh $ssh_opts \"${initial_user}@${host}\" \"$remote_cmd\""
      deploy_ok=true
    elif sshpass -p "$password" ssh $ssh_opts "${initial_user}@${host}" "$remote_cmd"; then
      deploy_ok=true
    fi
  else
    if $DRY_RUN; then
      dry "ssh $ssh_opts \"${initial_user}@${host}\" \"$remote_cmd\""
      deploy_ok=true
    elif ssh $ssh_opts "${initial_user}@${host}" "$remote_cmd"; then
      deploy_ok=true
    fi
  fi

  if ! $deploy_ok; then
    error "[$name] Failed to deploy public key to ${initial_user}@${host}"
    error "       Check: correct user? host reachable? password correct?"
    return 1
  fi

  success "[$name] Public key deployed for user '$auth_user' ✔"

  # -- Verify connection (only possible when we have a private key) ----------
  local verify_user="$auth_user"
  if [[ -n "$key_path" ]]; then
    info "[$name] Verifying connection as $verify_user..."
    if $DRY_RUN; then
      dry "ssh $ssh_opts -i \"$key_path\" \"${verify_user}@${host}\" 'echo ok'"
    elif ssh $ssh_opts -i "$key_path" "${verify_user}@${host}" 'echo ok' &>/dev/null; then
      success "[$name] Connection verified — passwordless SSH as $verify_user works ✔"
    else
      error "[$name] Connection test failed — key was deployed but login as $verify_user failed."
      error "       Possible causes: wrong authorize_for_user, sshd AllowUsers restriction, firewall."
      return 1
    fi
  else
    warn "[$name] Skipping connection verification (public_key mode — no local private key)"
  fi

  # -- Delete root authorized_keys if requested and target user is non-root --
  if [[ "$initial_user" == "root" && "$auth_user" != "root" && "$del_root_keys" == "true" ]]; then
    info "[$name] Cleaning up root authorized_keys..."
    local cleanup_cmd="if [ -f /root/.ssh/authorized_keys ]; then \
grep -vF '$pub_key_content' /root/.ssh/authorized_keys > /root/.ssh/authorized_keys.tmp 2>/dev/null || true; \
mv /root/.ssh/authorized_keys.tmp /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys; \
fi"
    if $DRY_RUN; then
      dry "ssh $ssh_opts -i \"$key_path\" \"${verify_user}@${host}\" \"sudo bash -c \\\"$cleanup_cmd\\\"\""
    else
      # Run via verify_user using sudo, or fallback to root sshpass if verify without key
      if [[ -n "$key_path" ]]; then
        ssh $ssh_opts -i "$key_path" "${verify_user}@${host}" "sudo bash -c \"$cleanup_cmd\"" &>/dev/null || true
      elif [[ "$use_password" == "true" ]]; then
        sshpass -p "$password" ssh $ssh_opts "${initial_user}@${host}" "$cleanup_cmd" &>/dev/null || true
      fi
      success "[$name] Cleaned up root authorized keys ✔"
    fi
  fi

  # -- Optionally set initial password for user on the remote host -----------
  if [[ -n "$set_password" && "$set_password" != "null" ]]; then
    info "[$name] Setting password on remote host for ${initial_user}..."
    local chpasswd_cmd="echo '${initial_user}:${set_password}' | chpasswd"
    if $DRY_RUN; then
      dry "Setting password for ${initial_user} on ${host}"
    else
      local pass_set_ok=false
      if [[ -n "$key_path" ]]; then
        # Use SSH key we just verified
        if ssh $ssh_opts -i "$key_path" "${initial_user}@${host}" "$chpasswd_cmd" &>/dev/null; then
          pass_set_ok=true
        fi
      elif [[ "$use_password" == "true" ]]; then
        if sshpass -p "$password" ssh $ssh_opts "${initial_user}@${host}" "$chpasswd_cmd" &>/dev/null; then
          pass_set_ok=true
        fi
      fi

      if $pass_set_ok; then
        success "[$name] Password updated for ${initial_user} on remote host ✔"
      else
        warn "[$name] Could not update password for ${initial_user}. (Ensure user has root permissions or chpasswd rights)"
      fi
    fi
  fi

  # -- Print ansible inventory hint -----------------------------------------
  echo ""
  info "[$name] Add to inventory/development/hosts.ini:"
  echo ""
  echo "        [servers]"
  if [[ -n "$key_path" ]]; then
    echo "        $host ansible_host=$host ansible_user=$auth_user ansible_ssh_private_key_file=$key_path"
  else
    echo "        $host ansible_host=$host ansible_user=$auth_user"
    echo "        # (no local private key — ensure Ansible's default key or ssh-agent has access)"
  fi
  echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║   Ansible Bootstrap — SSH Key Setup      ║"
  echo "╚══════════════════════════════════════════╝"
  $DRY_RUN && warn "DRY RUN MODE — no changes will be made"
  echo ""

  check_deps
  check_config

  local count
  count=$(host_count)

  if [[ "$count" -eq 0 ]]; then
    warn "No hosts defined in $CONFIG_FILE"
    exit 0
  fi

  info "Found $count host(s) in config"

  local processed=0
  local failed=0

  for ((i = 0; i < count; i++)); do
    local entry_name
    entry_name=$(yq_get "$i" "name" "host-$i")

    # Filter by --host flag if given
    if [[ -n "$TARGET_HOST" && "$entry_name" != "$TARGET_HOST" ]]; then
      continue
    fi

    if process_host "$i"; then
      ((processed++)) || true
    else
      ((failed++)) || true
    fi
  done

  echo ""
  echo "──────────────────────────────────────────"
  success "Done. Processed: $processed  |  Failed: $failed"
  echo ""
}

main "$@"
