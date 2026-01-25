# User Management Guide

Complete guide to managing system users with the `users` role.

## Overview

The `users` role creates and manages system users with:
- Fine-grained sudo permissions
- SSH key management
- Group assignments
- Security best practices

## Default Users

### deploy
**Purpose:** CI/CD deployments, manual deployments

**Configuration:**
- Groups: `docker`
- Sudo: Full access (requires password)
- Use case: GitLab CI, GitHub Actions, manual deployments

### jenkins  
**Purpose:** Jenkins automation user (account only)

**Configuration:**
- Groups: `docker`
- Sudo: No password required for specific commands:
  - `/usr/bin/docker`
  - `/usr/bin/docker-compose`
  - `/usr/bin/kubectl`
  - `/usr/bin/systemctl`

**Important:** This role creates the user account only. Jenkins itself must be installed separately.

## Adding Custom Users

### Method 1: Edit defaults file

Edit `roles/users/defaults/main.yml`:

```yaml
system_users:
  - name: myapp
    comment: "MyApp Service User"
    shell: /bin/bash
    groups: [docker, www-data]
    create_home: true
    sudo_enabled: true
    sudo_nopasswd: true
    sudo_commands:
      - /usr/bin/systemctl restart myapp
      - /usr/bin/systemctl status myapp
      - /usr/bin/systemctl reload myapp
    ssh_keys:
      - "ssh-rsa AAAAB3... myapp@deploy-server"
```

### Method 2: Use group variables

Create `group_vars/all/users.yml`:

```yaml
system_users:
  # Keep default users
  - name: deploy
    comment: "Deployment User"
    groups: [docker]
    sudo_enabled: true
    
  - name: jenkins  
    comment: "Jenkins CI User"
    groups: [docker]
    sudo_enabled: true
    sudo_nopasswd: true
    sudo_commands:
      - /usr/bin/docker
      - /usr/bin/kubectl
  
  # Add your custom users
  - name: webapp
    comment: "Web Application User"
    groups: [www-data, docker]
    sudo_enabled: true
    sudo_nopasswd: false
    ssh_keys:
      - "{{ lookup('file', '~/.ssh/webapp_rsa.pub') }}"
```

## User Configuration Options

### Basic Options

| Option        | Type    | Default   | Description             |
| ------------- | ------- | --------- | ----------------------- |
| `name`        | string  | required  | Username                |
| `comment`     | string  | ""        | GECOS field (full name) |
| `shell`       | string  | /bin/bash | User's shell            |
| `groups`      | list    | []        | Additional groups       |
| `create_home` | boolean | true      | Create home directory   |

### Sudo Options

| Option          | Type    | Default | Description                                  |
| --------------- | ------- | ------- | -------------------------------------------- |
| `sudo_enabled`  | boolean | false   | Enable sudo access                           |
| `sudo_nopasswd` | boolean | false   | No password for sudo                         |
| `sudo_commands` | list    | []      | Specific sudo commands (empty = full access) |

### SSH Options

| Option     | Type | Default | Description     |
| ---------- | ---- | ------- | --------------- |
| `ssh_keys` | list | []      | SSH public keys |

## Security Levels

### Level 1: No Sudo (Most Secure)
```yaml
- name: webapp
  sudo_enabled: false
```
User can only run commands as themselves.

### Level 2: Specific Commands with Password
```yaml
- name: operator
  sudo_enabled: true
  sudo_nopasswd: false
  sudo_commands:
    - /usr/bin/systemctl restart myapp
```
User must enter password to run specific commands with sudo.

### Level 3: Specific Commands without Password
```yaml
- name: jenkins
  sudo_enabled: true
  sudo_nopasswd: true
  sudo_commands:
    - /usr/bin/docker
    - /usr/bin/kubectl
```
User can run specific commands with sudo without password. **Use only for trusted automation.**

### Level 4: Full Sudo with Password
```yaml
- name: deploy
  sudo_enabled: true
  sudo_nopasswd: false
  sudo_commands: []
```
User has full sudo access but must enter password.

### Level 5: Full Sudo without Password (Least Secure)
```yaml
- name: admin
  sudo_enabled: true
  sudo_nopasswd: true
  sudo_commands: []
```
**⚠️ Not recommended.** Only use for highly trusted users.

## SSH Key Management

### Add Single SSH Key

```yaml
- name: deploy
  ssh_keys:
    - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... deploy@laptop"
```

### Add Multiple SSH Keys

```yaml
- name: deploy
  ssh_keys:
    - "ssh-rsa AAAAB3... deploy@laptop"
    - "ssh-rsa AAAAB3... deploy@desktop"
    - "ssh-rsa AAAAB3... gitlab-runner@ci"
```

### Load SSH Key from File

```yaml
- name: deploy
  ssh_keys:
    - "{{ lookup('file', '~/.ssh/deploy_rsa.pub') }}"
    - "{{ lookup('file', '/path/to/backup_key.pub') }}"
```

## Common Use Cases

### CI/CD User

```yaml
- name: gitlab-runner
  comment: "GitLab CI Runner"
  groups: [docker]
  sudo_enabled: true
  sudo_nopasswd: true
  sudo_commands:
    - /usr/bin/docker
    - /usr/bin/systemctl restart myapp
    - /usr/bin/systemctl reload nginx
  ssh_keys:
    - "{{ lookup('file', '~/.ssh/gitlab_runner.pub') }}"
```

### Application Service User

```yaml
- name: myapp
  comment: "MyApp Service Account"
  shell: /bin/bash
  groups: [www-data]
  sudo_enabled: false
  ssh_keys: []
```

### Developer User

```yaml
- name: developer
  comment: "Development User"
  groups: [docker, sudo]
  sudo_enabled: true
  sudo_nopasswd: false
  ssh_keys:
    - "{{ lookup('file', '~/.ssh/developer_key.pub') }}"
```

## Verification

### Check User Exists

```bash
id username
```

### Check Groups

```bash
groups username
```

### Check Sudo Permissions

```bash
sudo -l -U username
```

Expected output for jenkins user:
```
User jenkins may run the following commands:
    (ALL) NOPASSWD: /usr/bin/docker, /usr/bin/kubectl, /usr/bin/systemctl
```

### Test SSH Access

```bash
ssh username@your-server
```

### Check Sudoers File

```bash
sudo cat /etc/sudoers.d/username
```

## Troubleshooting

### User Not Created

1. Check if role ran:
   ```bash
   ansible-playbook playbooks/site.yml -i inventory/production --tags users -v
   ```

2. Check for errors in output

3. Verify variable syntax in YAML

### Sudo Not Working

1. Check sudoers file:
   ```bash
   sudo cat /etc/sudoers.d/username
   ```

2. Test sudo:
   ```bash
   sudo -l -U username
   ```

3. Verify sudoers file syntax:
   ```bash
   sudo visudo -c -f /etc/sudoers.d/username
   ```

### SSH Key Not Working

1. Check authorized_keys:
   ```bash
   cat /home/username/.ssh/authorized_keys
   ```

2. Check permissions:
   ```bash
   ls -la /home/username/.ssh/
   # Should be:
   # drwx------ .ssh/
   # -rw------- authorized_keys
   ```

3. Fix permissions if needed:
   ```bash
   chmod 700 /home/username/.ssh
   chmod 600 /home/username/.ssh/authorized_keys
   chown -R username:username /home/username/.ssh
   ```

## Best Practices

1. **Least Privilege**: Only grant the minimum permissions needed
2. **Unique Users**: Create separate users for different purposes
3. **SSH Keys**: Always use SSH keys, never passwords
4. **No Root**: Never allow direct root login
5. **Audit**: Regularly review sudo permissions
6. **Group Management**: Use groups for permission management
7. **Documentation**: Document why each user has specific permissions

## Security Considerations

### ⚠️ Never Do This

```yaml
# DON'T: Full sudo without password for untrusted user
- name: untrusted
  sudo_nopasswd: true
  sudo_commands: []

# DON'T: Allow shell commands with sudo
- name: baduser
  sudo_commands:
    - /bin/bash
    - /bin/sh
```

### ✅ Do This Instead

```yaml
# DO: Specific commands only
- name: trusted
  sudo_enabled: true
  sudo_nopasswd: true
  sudo_commands:
    - /usr/bin/systemctl restart myapp
    - /usr/bin/docker

# DO: Require password for full access
- name: admin
  sudo_enabled: true
  sudo_nopasswd: false
```

## Removing Users

To remove a user, remove them from the `system_users` list and set state:

```yaml
- name: olduser
  state: absent
```

Or manually on the server:
```bash
sudo userdel -r olduser
sudo rm -f /etc/sudoers.d/olduser
```
