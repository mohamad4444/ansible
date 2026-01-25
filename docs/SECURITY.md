# Security Best Practices

Security guidelines for your Ansible DevOps setup.

## User Management Security

### Principle of Least Privilege

**✅ Good Practice:**
```yaml
- name: webapp
  sudo_commands:
    - /usr/bin/systemctl restart webapp
    - /usr/bin/systemctl status webapp
```

**❌ Bad Practice:**
```yaml
- name: webapp
  sudo_nopasswd: true
  sudo_commands: []  # Full sudo access!
```

### SSH Key Authentication

**Always use SSH keys**, never passwords.

```yaml
# Good: SSH keys
- name: deploy
  ssh_keys:
    - "{{ lookup('file', '~/.ssh/deploy_key.pub') }}"

# Good: Disable password authentication
users_password_auth: false
```

### User Separation

Create separate users for different purposes:

- `deploy` - CI/CD deployments
- `jenkins` - Jenkins automation  
- `webapp` - Application service
- `monitoring` - Monit oring agents

**Never** use one user for everything.

## Sudo Permission Best Practices

### Security Levels

1. **No Sudo** (Most Secure)
   ```yaml
   sudo_enabled: false
   ```

2. **Specific Commands + Password**
   ```yaml
   sudo_enabled: true
   sudo_nopasswd: false
   sudo_commands: ["/usr/bin/systemctl restart myapp"]
   ```

3. **Specific Commands + No Password** (Automation only)
   ```yaml
   sudo_enabled: true
   sudo_nopasswd: true
   sudo_commands: ["/usr/bin/docker", "/usr/bin/kubectl"]
   ```

4. **Full Sudo + Password**
   ```yaml
   sudo_enabled: true
   sudo_nopasswd: false
   sudo_commands: []
   ```

5. **Full Sudo + No Password** (⚠️ Avoid)
   ```yaml
   sudo_enabled: true
   sudo_nopasswd: true
   sudo_commands: []
   ```

### Dangerous Sudo Permissions

**❌ Never allow shell access via sudo:**
```yaml
# DANGEROUS - Don't do this!
sudo_commands:
  - /bin/bash
  - /bin/sh
  - /usr/bin/python
```

This effectively gives full sudo access.

**✅ Instead, grant specific commands:**
```yaml
sudo_commands:
  - /usr/bin/systemctl restart myapp
  - /usr/bin/docker ps
  - /usr/bin/kubectl get pods
```

## SSH Security

### Key Management

1. **Use strong key types:**
   ```bash
   # Good: Ed25519 (recommended)
   ssh-keygen -t ed25519 -C "user@host"
   
   # Good: RSA 4096
   ssh-keygen -t rsa -b 4096 -C "user@host"
   ```

2. **Protect private keys:**
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   chmod 700 ~/.ssh
   ```

3. **Use different keys** for different purposes:
   - `id_deploy` - Deployment key
   - `id_jenkins` - Jenkins automation
   - `id_personal` - Personal access

### Server SSH Hardening

Edit `/etc/ssh/sshd_config`:

```bash
# Disable root login
PermitRootLogin no

# Disable password authentication
PasswordAuthentication no
PubkeyAuthentication yes

# Disable empty passwords
PermitEmptyPasswords no

# Limit SSH protocol
Protocol 2

# Restart SSH
sudo systemctl restart sshd
```

## Docker Security

### User Groups

Only add trusted users to docker group:

```yaml
system_users:
  - name: trusted_user
    groups: [docker]  # Can run docker commands
    
  - name: untrusted_user
    groups: []  # Cannot run docker
```

**Note:** Docker group members have effective root access.

### Docker Socket Permissions

If using docker via sudo instead of group:

```yaml
- name: jenkins
  groups: []  # Not in docker group
  sudo_commands:
    - /usr/bin/docker  # Can only run docker via sudo
```

## Secrets Management

### Don't Store Secrets in Git

**❌ Never:**
```yaml
# vars/secrets.yml (DO NOT COMMIT)
aws_access_key: "AKIA..."
aws_secret_key: "secret123"
```

**✅ Use Ansible Vault:**
```bash
# Encrypt secrets
ansible-vault encrypt group_vars/all/secrets.yml

# Run with vault password
ansible-playbook playbooks/site.yml --ask-vault-pass
```

### SSH Keys in Playbooks

**✅ Load from files:**
```yaml
ssh_keys:
  - "{{ lookup('file', '~/.ssh/deploy_key.pub') }}"
```

**❌ Don't hardcode:**
```yaml
ssh_keys:
  - "ssh-rsa AAAA... deploy@server"  # Visible in Git
```

## Firewall Configuration

### UFW (Ubuntu/Debian)

```bash
# Enable firewall
sudo ufw enable

# Allow SSH
sudo ufw allow 22/tcp

# Allow Docker (if needed)
sudo ufw allow 2375/tcp

# Allow specific services
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Firewalld (RHEL/Fedora)

```bash
# Enable firewall
sudo systemctl enable --now firewalld

# Allow SSH
sudo firewall-cmd --permanent --add-service=ssh

# Allow HTTP/HTTPS
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Reload
sudo firewall-cmd --reload
```

## Regular Audits

### Check User Permissions

```bash
# List all users with sudo
grep -r "NOPASSWD" /etc/sudoers.d/

# Check docker group members
getent group docker
```

### Check SSH Access

```bash
# List authorized keys for all users
find /home -name authorized_keys -exec cat {} \;
```

### Review Logs

```bash
# Check sudo usage
sudo cat /var/log/auth.log | grep sudo

# Check SSH logins
sudo cat /var/log/auth.log | grep sshd
```

## Security Checklist

- [ ] All users use SSH keys (no passwords)
- [ ] Root login disabled
- [ ] Each user has minimum required permissions
- [ ] No unnecessary sudo access
- [ ] Docker group membership restricted
- [ ] Firewall configured and enabled
- [ ] Regular security updates
- [ ] SSH keys rotated periodically
- [ ] Audit logs reviewed regularly
- [ ] No secrets in Git repository

## Incident Response

### Compromised User Account

1. **Disable the user:**
   ```bash
   sudo usermod -L username
   ```

2. **Remove SSH keys:**
   ```bash
   sudo rm /home/username/.ssh/authorized_keys
   ```

3. **Check for damage:**
   ```bash
   sudo cat /var/log/auth.log | grep username
   sudo history -r /home/username/.bash_history
   ```

4. **Remove sudo access:**
   ```bash
   sudo rm /etc/sudoers.d/username
   ```

### Compromised SSH Key

1. **Remove from all servers:**
   ```bash
   ssh-keygen -R hostname
   ```

2. **Generate new key:**
   ```bash
   ssh-keygen -t ed25519 -C "new-key"
   ```

3. **Deploy new key:**
   ```bash
   ssh-copy-id -i ~/.ssh/new_key user@server
   ```

## Additional Resources

- [SSH Security Best Practices](https://www.ssh.com/academy/ssh/security)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [Linux Security](https://www.cisecurity.org/benchmark/distribution_independent_linux)
