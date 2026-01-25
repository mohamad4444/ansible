# Configuration Guide

How to customize your Ansible  DevOps setup.

## Quick Reference

```yaml
# group_vars/all/main.yml

# Skip tools you don't need
install_minikube: false
install_vault: false

# Customize tool versions
terraform_version: "1.7.3"
helm_version: "3.14.2"

# Add custom users
system_users:
  - name: myuser
    groups: [docker]
    sudo_enabled: true
```

## Configuration Locations

| What to Configure      | Where         | File                             |
| ---------------------- | ------------- | -------------------------------- |
| Tool versions          | Role defaults | `roles/*/defaults/main.yml`      |
| Which tools to install | Group vars    | `group_vars/all/main.yml`        |
| Users & permissions    | Group vars    | `group_vars/all/users.yml`       |
| Environment config     | Group vars    | `group_vars/all/environment.yml` |
| Server inventory       | Inventory     | `inventory/*/hosts.ini`          |

## Common Customizations

### Skip Unnecessary Tools

```yaml
# group_vars/all/main.yml

# Kubernetes - skip for non-K8s servers
install_kubectl: false
install_minikube: false
install_k8s_tools: false
install_helm: false
install_kluctl: false

# Cloud - skip tools you don't use
install_aws_cli: false
install_terraform: true  # keep what you need
install_vault: false
```

### Customize Tool Versions

```yaml
# group_vars/all/main.yml

# Override default versions
terraform_version: "1.6.0"
helm_version: "3.13.0"
kubectl_version: "1.28.0"
```

### Add Custom Users

See [User Management Guide](USER_MANAGEMENT.md) for details.

```yaml
# group_vars/all/users.yml
system_users:
  - name: devops
    comment: "DevOps Team User"
    groups: [docker, sudo]
    sudo_enabled: true
    ssh_keys:
      - "ssh-rsa AAAAB3... team@devops"
```

### Configure Environment for Multiple Users

```yaml
# group_vars/all/environment.yml
environment_users:
  - "{{ ansible_user }}"
  - deploy
  - devops
  - developer
```

### Disable Verification

```yaml
# group_vars/all/main.yml
common_run_verification: false
```

## Role-Specific Configuration

### Docker Role

```yaml
# Add users to docker group (in addition to system_users)
docker_users:
  - "{{ ansible_user }}"
  - developer
```

### K8s Role

```yaml
# Kubernetes tools
install_kubectl: true
kubectl_version: "stable"  # or specific version
install_minikube: true
install_k8s_tools: true

# Individual K8s tool versions
stern_version: "1.28.0"
k9s_version: "0.31.9"
kind_version: "0.22.0"
```

### DevOps Tools Role

```yaml
# GitOps tools
install_helm: true
install_helmfile: true
install_kluctl: true
install_argocd: true

# Tool versions
helm_version: "3.14.2"
kluctl_version: "2.23.3"
argocd_version: "2.10.1"
```

### Cloud Role

```yaml
# Cloud tools
install_aws_cli: true
install_terraform: true
install_vault: false

# Versions
terraform_version: "1.7.3"
vault_version: "1.15.5"
```

### Environment Role

```yaml
# Which users get environment config
environment_users: ["{{ ansible_user }}", "deploy"]

# Features
environment_configure_bash: true
environment_install_kubectl_aliases: true
environment_create_kluctl_example: true
```

## Per-Host Configuration

Use host variables for host-specific settings:

```ini
# inventory/production/hosts.ini
[debian_servers]
web1 ansible_host=192.168.1.10 install_kubectl=false
web2 ansible_host=192.168.1.11 install_helm=false
k8s1 ansible_host=192.168.1.20 install_terraform=false
```

## Examples

### Minimal Docker-Only Server

```yaml
# group_vars/minimal/main.yml
install_kubectl: false
install_minikube: false
install_k8s_tools: false
install_helm: false
install_kluctl: false
install_argocd: false
install_terraform: false
install_aws_cli: false
install_vault: false

users_create_users: false
common_run_verification: false
```

### Full Kubernetes Development Server

```yaml
# group_vars/k8s_dev/main.yml
# All K8s tools enabled (default)
install_kubectl: true
install_minikube: true
install_k8s_tools: true
install_helm: true
install_kluctl: true

# Add developer user
system_users:
  - name: developer
    groups: [docker]
    sudo_enabled: true
    
environment_users: ["{{ ansible_user }}", "developer"]
```

### CI/CD Server

```yaml
# group_vars/cicd/main.yml
# Core CI/CD tools
install_kubectl: true
install_helm: true
install_terraform: true
install_aws_cli: true

# Skip unnecessary tools
install_minikube: false
install_k9s: false
install_vault: false

# Create CI users
system_users:
  - name: gitlab-runner
    groups: [docker]
    sudo_enabled: true
    sudo_nopasswd: true
    sudo_commands:
      - /usr/bin/docker
      - /usr/bin/kubectl
```

## Testing Configuration

Test your configuration with check mode:

```bash
ansible-playbook playbooks/site.yml -i inventory/production --check --diff
```

This shows what would change without making changes.
