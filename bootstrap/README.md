# Bootstrap — SSH Key Setup

This folder handles **initial SSH access** to remote hosts before Ansible can take over.

## Files

| File | Description |
|------|-------------|
| `hosts.template.yml` | Template — commit this, edit and copy to `hosts.yml` |
| `hosts.yml` | Your actual config with secrets — **gitignored, never commit** |
| `setup-ssh.sh` | Bash script that reads `hosts.yml` and sets up SSH keys |

## Quick Start

```bash
# 1. Copy the template
cp bootstrap/hosts.template.yml bootstrap/hosts.yml

# 2. Edit hosts.yml with your host details
nano bootstrap/hosts.yml

# 3. Run the bootstrap script
bash bootstrap/setup-ssh.sh

# Process only one host
bash bootstrap/setup-ssh.sh --host my-vps

# Overwrite existing SSH key pairs
bash bootstrap/setup-ssh.sh --overwrite

# Preview without making changes
bash bootstrap/setup-ssh.sh --dry-run
```

## What the script does

For each host in `hosts.yml`:

1. **Generates an SSH key pair** (or uses an existing one)
   - Supports `ed25519`, `rsa`, `ecdsa`
   - Custom key name or default (`~/.ssh/id_<type>`)
2. **Deploys the public key** to the remote host via `ssh-copy-id`
   - Supports password auth (`use_password: true`) using `sshpass`
   - Supports passwordless / existing key auth
3. **Provisions target user** (if connecting initially as `root` and `authorize_for_user` is a regular user like `debian`):
   - Installs `sudo` if missing
   - Creates the user and adds them to `sudo` group with passwordless sudo
   - Deploys SSH authorized keys to `~/.ssh/authorized_keys` for that user
4. **Verifies the connection** works with the target user
5. **Cleans up root SSH keys** (removes the key from root's `authorized_keys` if `delete_root_authorized_keys: true`)
6. **Prints the inventory line** to add to Ansible

## hosts.yml Config Reference

```yaml
hosts:
  - name: my-vps              # Friendly label
    host: 1.2.3.4             # IP or hostname
    port: 22                  # SSH port

    initial_user: root        # User to connect as initially
    use_password: true        # true if host needs a password
    password: "s3cr3t"        # Leave "" to be prompted at runtime
    set_password: ""          # Optional: password to set on remote host for initial_user (e.g. root)

    key:
      generate: true          # true → generate a new key pair
                              # false → use an existing key (see below)
      overwrite: false        # true → overwrite local key file if it already exists
      type: ed25519           # ed25519 | rsa | ecdsa
      bits: 4096              # rsa only
      comment: "ansible@vps"  # Key comment
      use_default_name: false # true → ~/.ssh/id_ed25519
      custom_name: "my-vps"  # false → ~/.ssh/my-vps
      passphrase: ""          # Key passphrase (empty = none)

      # --- Only used when generate: false (pick ONE) ---
      existing_path: "~/.ssh/id_ed25519"  # Path to existing private key
      public_key: ""                      # OR: raw public key string to authorize

    authorize_for_user: debian  # Which remote user gets the key
    delete_root_authorized_keys: true # Clean up key from root's authorized_keys after setting up target user
```

### `generate: false` modes

| Field | What it does |
|-------|-------------|
| `existing_path` | Points to a local private key. Its `.pub` sibling is deployed. Connection is verified afterwards. |
| `public_key` | Pastes a raw public key string directly (useful for keys from another machine). No local private key needed; verification step is skipped. |

## Dependencies

The script auto-detects your distro and **offers to install missing tools for you** when you run it.

| Tool | Arch Linux | Debian/Ubuntu | Fedora/RHEL |
|------|-----------|---------------|-------------|
| `openssh` | `pacman -S openssh` | `apt install openssh-client` | `dnf install openssh-clients` |
| `sshpass` | `pacman -S sshpass` | `apt install sshpass` | `dnf install sshpass` |
| `yq` | AUR (`yay -S yq`) or binary | binary from GitHub | binary from GitHub |

> **yq** is not in official Debian/Ubuntu/Fedora repos at a usable version — the script downloads the binary from GitHub automatically.
