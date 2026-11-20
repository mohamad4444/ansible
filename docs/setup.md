# Ansible Infrastructure Setup

## 1. Overview

This project uses Ansible to manage a Debian VPS and multiple Arch Linux workstations.

The infrastructure follows three stages:

1. **Local setup:** Prepare each workstation using `setup.sh`.
2. **VPS bootstrap:** Initialize a new VPS using its initial Root password.
3. **Ongoing management:** Configure machines and manage SSH access using Ansible.

The VPS bootstrap is only required when provisioning or reinstalling a server.

Every workstation receives its own SSH key pair, allowing individual devices to be authorized or revoked independently.

## 2. Project structure

```text
.
├── setup.sh
├── ansible.cfg
├── requirements.txt
├── requirements.yml
│
├── inventory/
│   ├── hosts.ini
│   ├── bootstrap.ini
│   ├── group_vars/
│   │   ├── all.yml
│   │   ├── workstations.yml
│   │   └── debian_servers.yml
│   └── host_vars/
│       └── mahamid-vps.yml
│
├── playbooks/
│   ├── bootstrap.yml
│   ├── workstation.yml
│   ├── vps.yml
│   ├── access.yml
│   └── sync-state.yml
│
├── public_keys/
│   ├── precisiontower-direct-<uuid>.pub
│   └── precisiontower-netbird-<uuid>.pub
│
├── files/infrastructure/
│   ├── Caddyfile.j2
│   ├── docker-compose.yml.j2
│   └── generate-setup-key.py
│
├── secrets/          gitignored live credentials
├── state/            gitignored restored NetBird database
├── apps/portfolio/   portfolio source served by Caddy
│
└── roles/
    ├── bootstrap/
    ├── ssh_client/
    ├── ssh_server/
    ├── ssh_access/
    ├── firewall/
    ├── netbird_client/
    ├── netbird_server/
    └── caddy/
```

The `public_keys/` directory stores approved public SSH keys. Private keys must never be committed to the repository.

## 3. First workstation setup

On the first Arch Linux workstation, clone the infrastructure repository and enter it:

```bash
git clone <repository-url>
cd ansible-vps-provisioning
```

Run:

```bash
./setup.sh
```

The script:

- Installs Python, OpenSSH, sshpass, and make.
- Creates the Python virtual environment `.venv`.
- Installs Ansible and its required collections.
- Generates `~/.ssh/ansible_mahamid` if it does not exist.
- Restores the matching public key if it is missing.

The private key remains on the workstation. Copy the public key into the repository:

```bash
cp ~/.ssh/ansible_mahamid.pub "public_keys/$(hostname -s)-direct-$(python3 -c 'import uuid; print(uuid.uuid4())').pub"
```

Public SSH keys may safely be stored in Git. Review the key before approving it for server access. Name each file `<machine>-<path>-<uuid>.pub` so keys from different machines never collide. `playbooks/access.yml` discovers every `*.pub` in `public_keys/` automatically.

## 4. Initial VPS bootstrap

On a newly provisioned Host-Unlimited VPS, the only initial access may be the Root password.

Verify the VPS SSH host-key fingerprint through a trusted channel before connecting.

Run the bootstrap playbook from the first workstation:

```bash
.venv/bin/ansible-playbook \
  -i inventory/bootstrap.ini \
  playbooks/bootstrap.yml \
  --ask-pass
```

The bootstrap playbook connects as `root` and:

1. Installs Python and sudo if required.
2. Creates the `debian` administrative user.
3. Configures sudo privileges.
4. Installs the first workstation's approved public SSH key.
5. Prepares the VPS for normal Ansible administration.

Do not disable Root access until the new connection has been tested successfully.

Verify:

```bash
ssh -i ~/.ssh/ansible_mahamid debian@mahamid.net
```

Then:

```bash
.venv/bin/ansible mahamid-vps -m ping
```

Also verify that `debian` can use sudo. Once verified, apply the SSH-hardening role (`ssh_server`) by running the VPS playbook to disable Root SSH login and password authentication.

**Important:** VPS bootstrap is not a routine workstation setup operation.

## 5. Adding a second workstation

See [Adding a new device](new-device.md) for the full onboarding flow, including automatic key distribution and peer SSH access.

For example, adding an Arch Linux laptop.

### Step 1 - Prepare the laptop

Clone the repository and run:

```bash
./setup.sh
```

This generates a separate private/public SSH key pair on the laptop.

### Step 2 - Register the public key

Copy the laptop's public key into the infrastructure repository:

```bash
cp ~/.ssh/ansible_mahamid_netbird.pub "public_keys/$(hostname -s)-netbird-$(python3 -c 'import uuid; print(uuid.uuid4())').pub"
```

Commit and push the public key using your normal Git workflow. The laptop's public key is now available for review and approval.

### Step 3 - Authorize the laptop on the VPS

On the already-authorized desktop, pull the repository changes and run:

```bash
.venv/bin/ansible-playbook playbooks/access.yml
```

The access playbook uses the `ssh_access` role to update the VPS `authorized_keys` file from the approved public keys in `public_keys/`.

The role adds keys without removing other authorized keys. When you want to centrally manage the entire approved list, extend `ssh_access` to remove revoked keys deliberately, after verifying all required keys are included.

### Step 4 - Verify laptop access

On the laptop:

```bash
ssh -i ~/.ssh/ansible_mahamid debian@mahamid.net
```

The laptop can now manage the VPS without using the Root password.

## 6. Regular configuration

Configure whichever Arch workstation you are currently using:

```bash
.venv/bin/ansible-playbook \
  playbooks/workstation.yml \
  --ask-become-pass
```

Because the workstation inventory uses `localhost` with a local connection, this configures the machine the command runs on.

To manage the VPS:

```bash
.venv/bin/ansible-playbook playbooks/vps.yml
```

The normal VPS connection uses the `debian` user and SSH key authentication.

## 7. Rules

- Run `setup.sh` on each new workstation.
- Generate a unique SSH key pair for every workstation.
- Never transfer or share private SSH keys between devices.
- Run VPS bootstrap only when a server is newly provisioned or reinstalled.
- Use an existing authorized workstation to approve additional public keys.
- Use Ansible roles for installation and configuration.
- Use Ansible Vault or another secrets manager for credentials and tokens.
- Keep Root password authentication disabled after successful initialization.
- Avoid disabling SSH host-key verification.
- Use Git to track infrastructure configuration and approved public keys.

## 8. Restored VPS stack

The previous CentOS VPS stack was migrated into this repository. Three directories are involved:

- `secrets/` (gitignored): `management.json`, `relay.env`, and `dashboard.env`. Matching `*.example` files are tracked as references.
- `state/netbird_management/` (gitignored): the restored NetBird database, including `store.db` with its existing users and peers, plus the GeoIP data files.
- `apps/portfolio/`: the React/Nginx portfolio source that Caddy serves on the apex domains.

The VPS playbook deploys the whole stack:

```bash
.venv/bin/ansible-playbook playbooks/vps.yml
```

The `caddy` role installs Docker, creates `caddy_net`, writes the Caddyfile from `files/infrastructure/`, deploys and builds the portfolio app. The `netbird_server` role then validates that the relay secret in `management.json` matches `NB_AUTH_SECRET` in `relay.env`, backs up any existing remote NetBird state, copies the restored state and configuration, and starts the stack from `files/infrastructure/docker-compose.yml.j2`. The resulting files live under `/opt/infrastructure` and `/opt/portfolio`.

The VPS is also a NetBird client and enrolls itself without manual steps. The `netbird_client` role adds the NetBird apt repository, installs the client, and if `secrets/netbird_setup_key` is missing or a placeholder, generates a reusable setup key on the VPS via `files/infrastructure/generate-setup-key.py` with `Home` as its auto-group. The key is saved locally and used for enrollment through a temporary root-only file, so it never appears on the command line. Already-connected peers are not re-enrolled. If a restored peer was originally enrolled through an external SSO provider and its session expired, the role deregisters that stale peer and retries enrollment with the setup key.

The restored `state/netbird_management/idp.db` may contain an external Google connector whose credentials depend on a separate Google Cloud project. On every deployment `netbird_server` removes external Google connectors and their sessions with `files/infrastructure/remove-google-connector.py`, then restarts management, so a VPS reinstall never depends on Google billing or API keys. Local email/password accounts and setup keys keep working.

Two SSH keys are generated by `setup.sh`: `~/.ssh/ansible_mahamid` for direct access and `~/.ssh/ansible_mahamid_netbird` for access over NetBird. Their public keys live in `public_keys/` as UUID-named files and are authorized by `playbooks/access.yml`, which discovers all `*.pub` files automatically.
 The `Home SSH` policy allows TCP 22 between all `Home` peers.

Headless SSO is not available with the embedded IdP: `netbird up --qr` and `--no-browser` use the OAuth device-code flow, which the embedded IdP rejects with `invalid_request`. Use a setup key, or run `netbird up` interactively from the VPS console if you prefer browser SSO.

Container images are pinned by digest in `inventory/group_vars/all.yml` so the restored database runs against the same image versions recorded in the original setup. Firewall rules allow TCP 22/80/443 and UDP 443/3478.

Before running the playbook, verify the VPS SSH host-key fingerprint through your hosting provider's console and accept it in `known_hosts`. Host-key checking stays enabled.

## 9. Future improvements

- Add safe key revocation to the `ssh_access` role.
- Replace the gitignored `secrets/` files with Ansible Vault variables.
- Enroll workstations and the VPS as NetBird peers using a fresh setup key; the archived setup key is invalid.
- Add Makefile commands for setup, bootstrap, enrollment, validation, and deployment.
