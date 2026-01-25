# Getting Started with Ansible DevOps Automation

This guide will help you set up Ansible on your local machine (Windows 10/11 with WSL) and connect to your VPS.

## Prerequisites

- Windows 10/11
- VPS running Debian/Ubuntu or RHEL/Fedora
- SSH access to your VPS

## Step 1: Install WSL and Ubuntu

1. Open PowerShell as Administrator and run:
   ```powershell
   wsl --install
   ```

2. Restart your computer when prompted

3. Open Ubuntu from the Start menu and create a username/password

4. Update Ubuntu:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

## Step 2: Install Ansible

Install Ansible on your WSL Ubuntu:

```bash
sudo apt update
sudo apt install -y ansible git

# Verify installation
ansible --version
```

You should see output similar to:
```
ansible [core 2.x.x]
  python version = 3.x.x
```

## Step 3: Generate SSH Key

Generate an SSH key pair for Ansible to connect to your VPS:

```bash
# Generate SSH key (Ed25519 is recommended)
ssh-keygen -t ed25519 -C "ansible@local"

# Press Enter to accept default location (~/.ssh/id_ed25519)
# Optionally set a passphrase
```

Your keys will be created at:
- Private key: `~/.ssh/id_ed25519`
- Public key: `~/.ssh/id_ed25519.pub`

## Step 4: Copy SSH Key to VPS

Copy your SSH public key to your VPS:

```bash
# Replace with your VPS username and IP/domain
ssh-copy-id YOUR_USERNAME@YOUR_VPS_IP

# Example:
ssh-copy-id rocky@192.168.1.100
# or
ssh-copy-id myuser@myserver.com
```

Enter your VPS password when prompted. This is a one-time setup.

## Step 5: Test SSH Connection

Test that you can connect without a password:

```bash
ssh YOUR_USERNAME@YOUR_VPS_IP

# Example:
ssh rocky@192.168.1.100
```

If successful, you should be connected to your VPS without entering a password.

Exit the SSH session:
```bash
exit
```

## Step 6: Clone Ansible Repository

Clone this Ansible repository:

```bash
# Create projects directory
mkdir -p ~/projects
cd ~/projects

# Clone the repository (replace with your repo URL)
git clone <YOUR_REPO_URL> ansible
cd ansible
```

## Step 7: Configure Inventory

### Create Inventory File

Create an inventory file for your VPS:

```bash
# Create inventory directory if it doesn't exist
mkdir -p inventory/production

# Create hosts file
nano inventory/production/hosts.ini
```

Add your VPS details:

```ini
[debian_servers]
myvps ansible_host=YOUR_VPS_IP ansible_user=YOUR_USERNAME ansible_become=true

# Example:
# production ansible_host=192.168.1.100 ansible_user=rocky ansible_become=true
```

Save and exit (Ctrl+X, then Y, then Enter)

### Test Ansible Connection

Test that Ansible can connect to your VPS:

```bash
ansible all -i inventory/production/hosts.ini -m ping
```

Expected output:
```
myvps | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

## Step 8: Configure Variables (Optional)

Customize what gets installed by creating a group variables file:

```bash
mkdir -p group_vars/all
nano group_vars/all/main.yml
```

Add your customizations:

```yaml
---
# User configuration
system_users:
  - name: deploy
    comment: "Deployment User"
    groups: [docker]
    sudo_enabled: true
    ssh_keys:
      - "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"

# Tool configuration
install_minikube: false  # Skip minikube on production
install_kubectl: true
install_helm: true
install_terraform: true

# Environment configuration
environment_users:
  - "{{ ansible_user }}"
  - deploy
```

## Step 9: Run Ansible Playbook

### Dry Run (Check Mode)

First, run in check mode to see what would change:

```bash
ansible-playbook playbooks/site.yml -i inventory/production/hosts.ini --check
```

### Full Installation

If the dry run looks good, run the full installation:

```bash
ansible-playbook playbooks/site.yml -i inventory/production/hosts.ini
```

This will:
1. Create system users (deploy, jenkins)
2. Install Docker and Docker Compose
3. Install Kubernetes tools
4. Install GitOps tools (Helm, Kluctl, ArgoCD)
5. Install Cloud tools (AWS CLI, Terraform, Vault)
6. Configure shell environment with aliases and helpers

Installation typically takes 10-15 minutes depending on your internet speed.

## Step 10: Verify Installation

After installation completes, verify everything is installed:

```bash
# Run verification playbook
ansible-playbook playbooks/verify.yml -i inventory/production/hosts.ini

# Or SSH to VPS and check manually
ssh YOUR_USERNAME@YOUR_VPS_IP

# Check tool versions
docker --version
kubectl version --client
helm version --short
terraform version

# Test aliases
k version --client  # kubectl alias
d ps                # docker alias

# Test helper functions
kexec --help
cluster-info
```

## Troubleshooting

### SSH Connection Failed

If `ansible all -m ping` fails:

1. **Check SSH key**: Ensure `ssh-copy-id` was successful
2. **Test SSH manually**: `ssh YOUR_USERNAME@YOUR_VPS_IP`
3. **Check inventory file**: Verify IP and username are correct
4. **Check SSH permissions**: 
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```

### Sudo Password Required

If Ansible asks for sudo password:

1. Add to inventory file:
   ```ini
   [debian_servers]
   myvps ansible_host=IP ansible_user=USER ansible_become=true ansible_become_password=YOUR_SUDO_PASSWORD
   ```

2. Or use `--ask-become-pass` flag:
   ```bash
   ansible-playbook playbooks/site.yml -i inventory/production/hosts.ini --ask-become-pass
   ```

### Installation Fails Partway Through

If installation fails:

1. **Check the error message** - Most errors are descriptive
2. **Re-run the playbook** - Ansible is idempotent (safe to re-run)
3. **Run specific role** - Test individual roles:
   ```bash
   ansible-playbook playbooks/site.yml -i inventory/production/hosts.ini --tags docker
   ```

### Tools Not in PATH

If tools aren't found after installation:

1. **Reload shell**:
   ```bash
   source ~/.bashrc
   ```

2. **Check PATH**:
   ```bash
   echo $PATH | tr ':' '\n' | grep usr/local/bin
   ```

3. **Verify installation**:
   ```bash
   ls -la /usr/local/bin/ | grep -E "kubectl|helm|terraform"
   ```

## Next Steps

After successful installation:

1. **Configure AWS CLI** (if using AWS):
   ```bash
   aws configure
   ```

2. **Set up kubectl context** (if using Kubernetes):
   ```bash
   kubectl config set-context my-cluster --cluster=... --user=...
   ```

3. **Test Docker**:
   ```bash
   docker run hello-world
   ```

4. **Explore helper functions**:
   ```bash
   # See all functions
   declare -F | grep -E "k|cluster"
   
   # Try helper functions
   cluster-info
   kexec --help
   ```

5. **Read user guides** - See [docs/](../docs/) directory for role-specific documentation

## Additional Resources

- [User Management Guide](user-management.md) - Managing system users
- [Configuration Guide](configuration.md) - Customizing installations
- [Security Best Practices](security.md) - Security guidelines
- [Role Documentation](roles.md) - Detailed role documentation

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section above
2. Review role-specific documentation in `docs/`
3. Check Ansible output for error messages
4. Open an issue in the repository
