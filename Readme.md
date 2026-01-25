# Ansible DevOps Automation

Comprehensive Ansible automation for DevOps, Kubernetes, Cloud infrastructure, and user management.

> **Quick Start**: New to this project? Start with [Getting Started Guide](docs/GETTING_STARTED.md)

## Features

✨ **Multi-OS Support** - Debian/Ubuntu and RHEL/Fedora  
🔐 **User Management** - Fine-grained sudo control and SSH keys  
☁️ **Cloud Tools** - AWS CLI, Terraform, Vault  
☸️ **Kubernetes** - kubectl, Helm, Kluctl, ArgoCD, Minikube  
🐳 **Containers** - Docker, Docker Compose, dive, lazydocker  
🛠️ **DevOps Tools** - GitOps stack with Helm, Kluctl, Tilt  
🎨 **Environment** - Shell aliases, completions, helper functions

## Quick Start

```bash
# 1. Install on WSL/Ubuntu
sudo apt install ansible git

# 2. Clone repository
git clone <repo-url> ansible && cd ansible

# 3. Configure inventory
nano inventory/production/hosts.ini

# 4. Run playbook
ansible-playbook playbooks/site.yml -i inventory/production
```

**Full setup guide**: [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md)

## Project Structure

```
ansible/
├── playbooks/
│   ├── site.yml       # Main playbook
│   └── verify.yml     # Verification playbook
├── roles/
│   ├── users/         # User management & sudo control
│   ├── environment/   # Shell config & aliases
│   ├── common/        # Base packages & utilities
│   ├── docker/        # Docker & Docker Compose
│   ├── k8s/           # Kubernetes tools
│   ├── devops_tools/  # GitOps tools (Helm, Kluctl, etc.)
│   └── cloud/         # AWS CLI, Terraform, Vault
├── inventory/         # Server inventories
├── group_vars/        # Configuration variables
└── docs/              # Documentation
```

## Documentation

| Document                                   | Description                  |
| ------------------------------------------ | ---------------------------- |
| [Getting Started](docs/GETTING_STARTED.md) | Initial setup & installation |
| [User Management](docs/USER_MANAGEMENT.md) | Managing users & permissions |
| [Configuration](docs/CONFIGURATION.md)     | Customizing installations    |
| [Roles](docs/ROLES.md)                     | Detailed role documentation  |
| [Security](docs/SECURITY.md)               | Security best practices      |

## Roles Overview

### 🔐 users
Creates system users with fine-grained sudo permissions.

**Default users**: `deploy` (CI/CD), `jenkins` (automation)

```yaml
system_users:
  - name: deploy
    groups: [docker]
    sudo_enabled: true
```

📖 [User Management Guide](docs/USER_MANAGEMENT.md)

---

### 🎨 environment
Configures shell environment with aliases and helper functions.

**Features**: kubectl aliases (`k`, `kg`, `kd`), helper functions (`kexec`, `cluster-info`), completions

```yaml
environment_users: ["{{ ansible_user }}", "deploy"]
```

---

### 📦 common
Installs base packages and CLI utilities.

**Includes**: yq, jq, hadolint, shellcheck, dive, ctop, lazydocker

---

### 🐳 docker
Installs Docker and Docker Compose.

---

### ☸️ k8s
Installs Kubernetes tools.

**Includes**: kubectl, minikube, kind, k9s, stern, kubectx/kubens, skaffold

```yaml
install_kubectl: true
kubectl_version: "stable"
```

---

### 🛠️ devops_tools
Installs GitOps and DevOps tools.

**Includes**: Helm, Helmfile, Kluctl, Kustomize, Tilt, ArgoCD CLI

```yaml
install_helm: true
install_kluctl: true
```

---

### ☁️ cloud
Installs cloud provider tools.

**Includes**: AWS CLI v2, Terraform, HashiCorp Vault

```yaml
install_terraform: true
terraform_version: "1.7.3"
```

📖 [Full Role Documentation](docs/ROLES.md)

## Usage Examples

### Full Installation
```bash
ansible-playbook playbooks/site.yml -i inventory/production
```

### Dry Run (Check Mode)
```bash
ansible-playbook playbooks/site.yml -i inventory/production --check
```

### Verify Installation
```bash
ansible-playbook playbooks/verify.yml -i inventory/production
```

### Install Specific Roles
```bash
ansible-playbook playbooks/site.yml -i inventory/production --tags docker,k8s
```

## Configuration

### Skip Unnecessary Tools

```yaml
# group_vars/all/main.yml
install_minikube: false
install_vault: false
```

### Add Custom Users

```yaml
system_users:
  - name: developer
    groups: [docker, sudo]
    sudo_enabled: true
```

### Customize Versions

```yaml
terraform_version: "1.6.0"
helm_version: "3.13.0"
```

📖 [Configuration Guide](docs/CONFIGURATION.md)

## Security

- ✅ Least privilege sudo access
- ✅ SSH key authentication
- ✅ Separate users for different purposes
- ✅ Command-specific sudo permissions
- ✅ No root login

📖 [Security Best Practices](docs/SECURITY.md)

## Requirements

- Ansible 2.9+
- Target: Debian 10+, Ubuntu 20.04+, RHEL 8+, Fedora 35+
- SSH access with sudo privileges
- Python 3 on target machines

## Verification

After installation, verify on your server:

```bash
# Check versions
docker --version
kubectl version --client
helm version
terraform version

# Test aliases
k version          # kubectl
d ps              # docker

# Test helper functions
cluster-info
kexec --help
```

## Troubleshooting

| Issue                  | Solution                                   |
| ---------------------- | ------------------------------------------ |
| SSH connection fails   | Check SSH keys: `ssh-copy-id user@server`  |
| Sudo password required | Add `ansible_become_password` to inventory |
| Tools not in PATH      | Reload shell: `source ~/.bashrc`           |
| User not created       | Check role output: `--tags users -v`       |

📖 [Full Troubleshooting Guide](docs/GETTING_STARTED.md#troubleshooting)

## Contributing

Contributions welcome! Please:
1. Test changes with `--check` mode
2. Update relevant documentation
3. Follow existing code style
4. Submit pull request

## License

MIT

## Support

- 📚 [Documentation](docs/)
- 🐛 [Issues](../../issues)
- 💬 [Discussions](../../discussions)

---

**Made with ❤️ for DevOps teams**
