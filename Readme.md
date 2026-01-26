# Ansible DevOps Automation

Comprehensive Ansible automation for DevOps, Kubernetes, Cloud infrastructure, and user management.

## Table of Contents

- [Ansible DevOps Automation](#ansible-devops-automation)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Quick Start](#quick-start)
  - [Useful Commands](#useful-commands)
    - [Connection Check](#connection-check)
    - [Full Installation](#full-installation)
    - [Dry Run (Check Mode)](#dry-run-check-mode)
    - [Verification](#verification)
    - [Install Specific Tags](#install-specific-tags)
  - [Roles Overview](#roles-overview)
  - [Documentation](#documentation)
  - [Project Structure](#project-structure)
  - [Roadmap](#roadmap)
    - [Project Status](#project-status)
    - [Operating System Support Note](#operating-system-support-note)

## Features

- ✨ **Multi-OS Support** - Debian/Ubuntu (Primary) and RHEL/Fedora (Legacy/Partial)
- 🔐 **User Management** - Fine-grained sudo control and SSH keys
- ☁️ **Cloud Tools** - AWS CLI, Terraform, Vault
- ☸️ **Kubernetes** - kubectl, Helm, Kluctl, ArgoCD, Minikube
- 🐳 **Containers** - Docker, Docker Compose, dive, lazydocker
- 🛠️ **DevOps Tools** - GitOps stack with Helm, Kluctl, Tilt
- 🎨 **Environment** - Shell aliases, completions, helper functions

## Quick Start

```bash
# 1. Install on WSL/Ubuntu
sudo apt install ansible git

# 2. Clone repository
git clone <repo-url> ansible && cd ansible

# 3. Run playbook
ansible-playbook playbooks/site.yml -i inventory/development/hosts.ini
```

> **Note**: This setup uses the `inventory/development` environment by default.

## Useful Commands

Here are some common commands to manage your infrastructure using the development inventory.

### Connection Check
Verify connectivity to all hosts:
```bash
ansible -i inventory/development/hosts.ini all -m ping
```

### Full Installation
Run the main playbook to configure everything:
```bash
ansible-playbook -i inventory/development/hosts.ini playbooks/site.yml
```

### Dry Run (Check Mode)
See what changes would be made without applying them:
```bash
ansible-playbook -i inventory/development/hosts.ini playbooks/site.yml --check
```

### Verification
Run tests to verify the installation:
```bash
ansible-playbook -i inventory/development/hosts.ini playbooks/verify.yml
```

### Install Specific Tags
Run only specific parts of the playbook (e.g., only docker and k8s):
```bash
ansible-playbook -i inventory/development/hosts.ini playbooks/site.yml --tags docker,k8s
```

## Roles Overview

- **preflight**: Updates system package caches and installs essential packages before other roles run.
- **users**: Creates system users with specific groups and fine-grained sudo permissions.
- **environment**: Configures shell aliases (like `k` for `kubectl`), command completions, and helper functions.
- **common**: Installs base utilities like `jq`, `yq`, `curl`, and `git`.
- **docker**: Sets up Docker engine and Docker Compose.
- **k8s**: Installs Kubernetes tools including `kubectl`, `minikube`, `k9s`, and `stern`.
- **devops_tools**: Sets up a GitOps stack with `helm`, `helmfile`, `kluctl`, and `argocd`.
- **cloud**: Installs CLI tools for cloud providers, including AWS CLI, Terraform, and Vault.

## Documentation

- [Getting Started](docs/GETTING_STARTED.md): Initial setup & detailed installation guide.
- [User Management](docs/USER_MANAGEMENT.md): How to add users and configure permissions.
- [Configuration](docs/CONFIGURATION.md): Customizing tool versions and role behavior.
- [Roles](docs/ROLES.md): Detailed documentation for each ansible role.
- [Security](docs/SECURITY.md): Security features and best practices.

## Project Structure

```
ansible/
├── playbooks/         # Entry points (site.yml, verify.yml)
├── roles/             # Logic for each component (k8s, docker, etc.)
├── inventory/         # Host definitions (development, production)
├── group_vars/        # Global configuration variables
└── docs/              # Detailed documentation
```

## Roadmap

This project is actively developed to provide a comprehensive DevOps workstation and server setup.

### Project Status

- ✅ **Full DevOps & Kubernetes Setup**: Complete automated setup for local development.
- ✅ **Modular Architecture**: Reusable and expandable Ansible roles.
- ✅ **VPS Security**: Basic hardening, SSH key management, and sudo configuration.
- ⬜ **Advanced Security**: Prevent DDOS attacks, Fail2Ban configuration, and advanced firewall rules.
- ⬜ **Expanded Monitoring**: Prometheus/Grafana stack integration.

### Operating System Support Note

> **Important**: This project was initially developed for **Rocky Linux/RHEL/Fedora** systems. However, due to challenges with Docker support and package management on those platforms, the primary development focus has shifted to **Debian/Ubuntu** systems.
>
> While some legacy configuration methods for RHEL/Fedora still exist in the codebase, they are **not fully supported** at this time. We recommend using Debian 11+ or Ubuntu 20.04+ for the best experience.
