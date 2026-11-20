# Ansible Infrastructure Project

Ansible playbooks for bootstrapping and managing a Debian VPS, and for configuring Arch Linux workstations that connect to it.

The project is organized into a small number of meaningful roles: SSH client and server setup, SSH access management, firewall, Caddy, and NetBird (client and server). Shared version settings live in `inventory/group_vars/all.yml`; machine-specific values live in `inventory/host_vars/`.

## Getting Started

Follow the setup guide first:

**[Setup Guide](docs/setup.md)**

## Requirements

On the control node:

- Python 3 and a virtual environment
- Ansible and the collections in `requirements.yml`
- OpenSSH and sshpass for the initial Root-password bootstrap

`./setup.sh` installs the local prerequisites on Arch Linux, creates `.venv`, and generates the workstation SSH key.

## Structure

```text
inventory/              hosts.ini, bootstrap.ini, group_vars/, host_vars/
playbooks/              bootstrap.yml, workstation.yml, vps.yml, access.yml,
                        sync-state.yml
files/infrastructure/   Caddyfile.j2, docker-compose.yml.j2
public_keys/            approved workstation public keys
secrets/                gitignored live NetBird credentials and netbird_setup_key
state/                  gitignored restored NetBird database
apps/portfolio/         portfolio source served by Caddy
roles/                  bootstrap, ssh_client, ssh_server, ssh_access,
                        firewall, caddy, netbird_client, netbird_server
```

The Caddyfile and Docker Compose definitions used to start the VPS live in `files/infrastructure/` and are templated by the `caddy` and `netbird_server` roles. All four roles are listed explicitly in `playbooks/vps.yml`.

## Commands

Check connectivity:

```bash
.venv/bin/ansible mahamid-vps -m ping
```

Bootstrap a new VPS once, using the initial Root password:

```bash
.venv/bin/ansible-playbook \
  -i inventory/bootstrap.ini \
  playbooks/bootstrap.yml \
  --ask-pass
```

Configure whichever workstation you are running on:

```bash
.venv/bin/ansible-playbook \
  playbooks/workstation.yml \
  --ask-become-pass
```

Configure the VPS (SSH, firewall, Caddy, portfolio, NetBird server, and NetBird client):

```bash
.venv/bin/ansible-playbook playbooks/vps.yml
```

Authorize approved workstation public keys on the VPS:

```bash
.venv/bin/ansible-playbook playbooks/access.yml
```

Copy the live NetBird database back into `state/netbird_management/`:

```bash
.venv/bin/ansible-playbook playbooks/sync-state.yml
```

Validate syntax:

```bash
.venv/bin/ansible-playbook --syntax-check playbooks/bootstrap.yml
.venv/bin/ansible-playbook --syntax-check playbooks/workstation.yml
.venv/bin/ansible-playbook --syntax-check playbooks/vps.yml
.venv/bin/ansible-playbook --syntax-check playbooks/access.yml
```

## Deployment method and commands used

The VPS was configured **through Ansible**, not by manually editing files on the server. The only local steps were trusting the new SSH host key and running read-only checks.

Host key trust (the old key no longer matched the new VPS):

```bash
cp ~/.ssh/known_hosts ~/.ssh/known_hosts.before-migration
ssh-keygen -R mahamid.net -f ~/.ssh/known_hosts
ssh-keygen -R 45.133.9.101 -f ~/.ssh/known_hosts
ssh-keyscan -t ed25519,rsa,ecdsa mahamid.net >> ~/.ssh/known_hosts
ssh-keyscan -t ed25519,rsa,ecdsa 45.133.9.101 >> ~/.ssh/known_hosts
ssh-keyscan -t ed25519,rsa,ecdsa vpn.mahamid.net >> ~/.ssh/known_hosts
```

Connectivity and deployment:

```bash
.venv/bin/ansible mahamid-vps -m ping
.venv/bin/ansible-playbook playbooks/vps.yml --check
.venv/bin/ansible-playbook playbooks/vps.yml
```

Verification after deployment:

```bash
.venv/bin/ansible mahamid-vps -a "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
.venv/bin/ansible mahamid-vps -a "curl -s -o /dev/null -w '%{http_code}' https://mahamid.net"
.venv/bin/ansible mahamid-vps -a "curl -s -o /dev/null -w '%{http_code}' https://www.mahamid.net"
.venv/bin/ansible mahamid-vps -a "curl -s -o /dev/null -w '%{http_code}' https://vpn.mahamid.net"
.venv/bin/ansible mahamid-vps -a "netbird status"
.venv/bin/ansible mahamid-vps -a "python3 -c \"import sqlite3; c=sqlite3.connect('/opt/infrastructure/data/netbird_management/store.db'); print('users', c.execute('select count(*) from users').fetchone()[0], 'peers', c.execute('select count(*) from peers').fetchone()[0])\""
```

## NetBird state

The restored state in `state/netbird_management/` is copied to a new VPS only when `store.db` is missing, or when the playbook is run with `-e netbird_restore_state=true`. Normal runs never overwrite the live database, so setup keys and peers created in the dashboard persist. Because the management container needs root-owned files, the role copies the state as `root:root` (files `0600`, directory `0700`) and restarts management after a restore.

After enrolling peers, copy the updated database back into the repo so the local copy stays in sync with the VPS:

```bash
.venv/bin/ansible-playbook playbooks/sync-state.yml
```

`sync-state.yml` uses SQLite's online backup API on the VPS, then fetches `store.db`, `idp.db`, `events.db`, and `access_logs.db` into `state/netbird_management/`.

The network was reduced to two peers: `aaa-precisiontower5810` and the VPS. Both are members of the `Home` group. User and setup-key `auto_groups` are set to `Home`, so newly registered peers join it automatically. The `Home SSH` policy allows bidirectional TCP 22 between `Home` peers. A pre-cleanup database backup is kept on the VPS at `/opt/infrastructure/data/netbird_management/store.db.before-home-cleanup`.

Two SSH keys are used: `~/.ssh/ansible_mahamid` for direct SSH to the VPS, and `~/.ssh/ansible_mahamid_netbird` for SSH over NetBird. `setup.sh` generates both and copies them into `public_keys/` as `<machine>-<path>-<uuid>.pub`. `playbooks/access.yml` discovers every `public_keys/*.pub` automatically and authorizes them for the `debian`; no filename list is hardcoded.
 The workstation's `~/.ssh/config.d/10-ansible-networking.conf` selects the right key per host, so `ssh debian@100.112.28.199` uses the NetBird key. The VPS `sshd` now includes `/etc/ssh/sshd_config.d/*.conf`, making `PasswordAuthentication no` and `PermitRootLogin no` effective.

The VPS enrolls itself automatically. If `secrets/netbird_setup_key` is missing or still a placeholder, `netbird_client` runs `files/infrastructure/generate-setup-key.py` on the VPS to create a reusable setup key whose `auto_groups` is `Home`, saves the plaintext locally, and then connects. New users who register with that key land in `Home` and can SSH to the server over NetBird after their public key is added to `public_keys/` and `access.yml` is run.

## Roadmap

- [x] Middle-sized role structure for VPS and workstations
- [x] Separate bootstrap and regular inventories
- [x] Caddy, portfolio, and NetBird server deployed from restored state
- [ ] Add safe SSH key revocation to `ssh_access`
- [ ] Add Makefile commands
