# Ansible & Environment Setup Guide

This guide covers setting up your local development environment (Windows/Linux) to manage your VPS using Ansible.

## 1. Prerequisites (Windows Users)

### Install WSL and Ubuntu
If you are on Windows 10/11:
1. Open PowerShell as Administrator.
2. Run the following command to install the Windows Subsystem for Linux (WSL):
   ```bash
   wsl --install
   ```
3. Restart your computer if prompted.
4. Open "Ubuntu" from your Windows search bar to initialize your Linux environment.

*Note: If you are already running Linux (Debian, Ubuntu, etc.), skip to step 2.*

## 2. Generating SSH Keys

Generate an Ed25519 SSH key pair on your **local machine** (Control Node):
```bash
ssh-keygen -t ed25519 -C "ansible@local"
```
- Press Enter to accept the default file location (`~/.ssh/id_ed25519`).
- (Optional) Set a passphrase for extra security.

Your keys will be generated at:
- Private Key: `~/.ssh/id_ed25519`
- Public Key: `~/.ssh/id_ed25519.pub`

## 3. Copying SSH Keys to VPS

Copy your public key to the remote server (Managed Node) to enable passwordless authentication. Replace `YOUR_VPS_USERNAME` and `YOUR_VPS_IP` with your actual details.

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub YOUR_VPS_USERNAME@YOUR_VPS_IP
```

**Example:**
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub rocky@mahamid.net
```

### Verify Connection
Test that you can connect without a password:
```bash
ssh rocky@mahamid.net
```
Type `exit` to close the connection and return to your local machine.

## 4. Installing Ansible

Update your package lists and install Ansible on your local machine:

```bash
sudo apt update
sudo apt install -y ansible
```

### Verify Installation
Check the installed version:
```bash
ansible --version
```
