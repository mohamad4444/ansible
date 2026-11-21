# Ansible VPS Provisioning

Playbooks for a Debian VPS (SSH, firewall, Caddy, NetBird) and the Arch Linux workstations that connect to it. The portfolio site is **not** stored in this repo — Ansible clones [portfolio-website](https://github.com/mohamad4444/portfolio-website) on the VPS and builds it with Docker Compose.

## Start here

1. `./setup.sh` — installs local prerequisites, creates `.venv`, generates the workstation SSH keys.
2. [Setup guide](docs/setup.md) — full first-time bootstrap and architecture details.
3. [Adding a new device](docs/new-device.md) — onboarding another workstation.

Requires Python 3, Ansible from `requirements.yml`, OpenSSH and `sshpass`.

## Common commands

```bash
# connectivity
.venv/bin/ansible mahamid-vps -m ping

# first-time VPS bootstrap (asks for the initial root password)
.venv/bin/ansible-playbook -i inventory/bootstrap.ini playbooks/bootstrap.yml --ask-pass

# configure the VPS / a workstation
.venv/bin/ansible-playbook playbooks/vps.yml
.venv/bin/ansible-playbook playbooks/workstation.yml --ask-become-pass

# re-pull the portfolio, rebuild it and reload Caddy
.venv/bin/ansible-playbook playbooks/portfolio.yml

# authorize approved public keys / copy back the NetBird database
.venv/bin/ansible-playbook playbooks/access.yml
.venv/bin/ansible-playbook playbooks/sync-state.yml

# syntax check
.venv/bin/ansible-playbook --syntax-check playbooks/vps.yml
```

## Layout

```text
inventory/              hosts, group_vars/, host_vars/
playbooks/              bootstrap, vps, workstation, access, portfolio, sync-state
roles/                  ssh_*, firewall, caddy, netbird_*
files/infrastructure/   Caddyfile and NetBird Compose templates
public_keys/            approved workstation public keys
secrets/  state/        gitignored live NetBird credentials and database
```

Shared settings (paths, versions, domains) live in `inventory/group_vars/all.yml`; machine-specific values in `inventory/host_vars/`. The portfolio repo branch/tag/SHA is set by `portfolio_version` in `roles/caddy/defaults/main.yml`.
