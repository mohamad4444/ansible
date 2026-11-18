# Ansible Infrastructure Project

Ansible playbooks for provisioning a Debian VPS and configuring a local Debian development environment.

The project organizes setup into reusable roles for system packages, Docker, users and SSH access, Kubernetes tooling, cloud CLI tools, and shell configuration. Tool versions and feature flags are configured in the development inventory.

## Getting Started

If you are setting up this project for the first time, please follow our Setup Guide:

**[Setup Guide](docs/setup.md)**
*(Contains instructions for WSL/Linux installation, SSH configuration, and Ansible setup)*

### Requirements

To run this project, ensure you have the following installed on your control node:
- **Ansible** (for configuration management)
- **Make** (for running the simplified Makefile commands)

## Essential Commands

Once you have completed the setup, you can use the following commands to manage the infrastructure.

### Check Connectivity (Ping Pong)

Test that Ansible can communicate with all hosts defined in your inventory:

```bash
ansible all -m ping
```

*Expected output should show `SUCCESS` and `"ping": "pong"` for your hosts.*

### Starting Ansible Playbooks

To run the main playbook (or any specific playbook), we highly recommend using the `make` utility which abstracts away the raw `ansible-playbook` commands:

```bash
# View all available commands
make help

# Run the main site playbook on the remote infrastructure
make run-site

# Run on LOCAL MACHINE (e.g., Laptop)
make run-local

# Test connectivity to servers
make test-connection

# Check syntax before running any playbooks
make syntax-check
```

### Basic Ad-Hoc Commands

You can run simple module commands directly from the CLI without writing a playbook:

```bash
# Check uptime on all servers
ansible all -a "uptime"

# Gather facts about hosts
ansible all -m setup
```
# to update verions of packages in vars directory run 
```bash
.venv/bin/ansible-playbook \
  -i localhost, \
  maintenance/update-versions.yml
```

.venv/bin/ansible-playbook \
  -i inventory/bootstrap.ini \
  bootstrap.yml \
  --ask-pass

.venv/bin/ansible-playbook \
  playbooks/workstation.yml \
  --ask-become-pass


## Roadmap

- [x] Full Devops,Kubernetes setup for development
- [ ] Add Security to vps
- [ ] prevent DDOS attacks
- [ ] Add roles
- [ ] make it more Modular and expandable
