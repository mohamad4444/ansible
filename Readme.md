# Ansible Infrastructure Project

This repository manages our server infrastructure (Rocky Linux VPS) using Ansible.

## Getting Started

If you are setting up this project for the first time, please follow our Setup Guide:

**[Setup Guide](docs/setup.md)**
*(Contains instructions for WSL/Linux installation, SSH configuration, and Ansible setup)*

## Essential Commands

Once you have completed the setup, you can use the following commands to manage the infrastructure.

### Check Connectivity (Ping Pong)
Test that Ansible can communicate with all hosts defined in your inventory:

```bash
ansible all -m ping
```

*Expected output should show `SUCCESS` and `"ping": "pong"` for your hosts.*

### Starting Ansible Playbooks
To run the main playbook (or any specific playbook), use the `ansible-playbook` command:

```bash
# Run the main site playbook (example)
ansible-playbook playbooks/site.yml

# Run on LOCAL MACHINE (e.g., Laptop)
ansible-playbook playbooks/local.yml --ask-become-pass

# Run with a specific inventory file
ansible-playbook -i inventory/development/hosts.ini playbooks/site.yml

# Run with a specific inventory file
ansible-playbook -i inventory/development/hosts.ini playbooks/site.yml

# Limit execution to a specific host
ansible-playbook playbooks/site.yml --limit specific_host

# Check syntax before running
ansible-playbook --syntax-check playbooks/site.yml
```

### Basic Ad-Hoc Commands
You can run simple module commands directly from the CLI without writing a playbook:

```bash
# Check uptime on all servers
ansible all -a "uptime"

# Gather facts about hosts
ansible all -m setup
```

## Roadmap
- [x] Full Devops,Kubernetes setup for development
- [ ] Add Security to vps
- [ ] prevent DDOS attacks
- [ ] Add roles
- [ ] make it more Modular and expandable
