# Adding a new device

## 1. Prepare the device

Clone the repository and run the setup script:

```bash
git clone <repository-url>
cd ansible
./setup.sh
```

`setup.sh` creates `.venv`, installs Ansible collections, and generates two Ed25519 key pairs:

- `~/.ssh/ansible_mahamid` — direct SSH to the VPS.
- `~/.ssh/ansible_mahamid_netbird` — SSH to peers over NetBird.

The private keys never leave the device. The script copies only the `.pub` files into `public_keys/` with UUID-based names, so files from different machines never collide.

Copy `secrets/netbird_setup_key` from an existing authorized device into `secrets/` on the new one. It is gitignored; it is deliberately not part of the repository.

## 2. Publish and distribute the public key

Review the generated `public_keys/<host>-<path>-<uuid>.pub` file, then commit and push it:

```bash
git add public_keys/
git commit -m "feat: authorize new device"
git push
```

Distribution then happens automatically:

- The `Distribute SSH keys` GitHub Actions workflow runs on a push that changes `public_keys/*.pub` and installs all approved keys on the VPS. It needs the repository secret `ANSIBLE_SSH_KEY` (the private half of `~/.ssh/ansible_mahamid`).
- On every other device, a `post-merge` git hook runs `ansible-playbook playbooks/access.yml --limit workstations` after a `git pull` that changed `public_keys/`, installing the keys locally. `setup.sh` enables it with `git config core.hooksPath .githooks`.

To apply keys immediately instead of waiting for a pull:

```bash
.venv/bin/ansible-playbook playbooks/access.yml
```

## 3. Join NetBird

Enroll the device and enable NetBird's SSH server:

```bash
.venv/bin/ansible-playbook playbooks/workstation.yml --ask-become-pass
```

The `netbird_client` role installs the client, enrolls with the setup key, and passes `--allow-server-ssh` so the device offers NetBird SSH. Enabling the SSH server needs root, which is why the playbook uses `become`. If the device was previously enrolled through an external SSO provider whose session expired, the role deregisters the stale peer and retries with the setup key.

Check the result:

```bash
netbird status
```

Look for `Management: Connected` and `SSH Server: Enabled`.

## 4. Connect to another peer

Preferred — NetBird SSH (JWT plus the `Home SSH` policy, no `authorized_keys` involved):

```bash
netbird ssh <peer-name-or-netbird-ip>
```

Fallback — classic sshd over the NetBird IP, using the key distributed in step 2:

```bash
ssh -i ~/.ssh/ansible_mahamid_netbird <netbird-ip>
```

Re-enrollment can change a peer's NetBird IP and SSH host key. If a connection reports `Host key verification failed`, remove the cached entry on the client:

```bash
ssh-keygen -R <old-netbird-ip>
ssh-keygen -R <peer-name>.netbird.selfhosted
```

## 5. Rules

- Never commit private keys. Only `public_keys/*.pub` and the `secrets/*.example` templates are tracked.
- Generate a fresh key pair on each device; do not copy private keys between devices.
- Keep `ANSIBLE_SSH_KEY` in GitHub repository secrets, not in the repository.
- Run the VPS playbook only when provisioning or reinstalling the server.
