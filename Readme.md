# Ansible Setup Tutorial on Windows 10 with VPS
Our local machine is on windows 10 and our VPS is using rocky linux
## Explanation about Ansible workflow
Ansible must be installed on host and it connects to VPS via ssh
## Steps
### Installing WSL and Ubuntu on windows 10
1. `wsl --install` installing wsl on windows 10
2. opening ubuntu from search bar
### Generating SSL
3. Generate SSL on local machine `ssh-keygen -t ed25519 -C "ansible@local"`
4. keys would exist on 
```
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```
### Copying SSH to VPS
5. Copy SSH key to the VPS
```ssh-copy-id YOUR_VPS_USERNAME@YOUR_VPS_IP```
6. Test VPS
```ssh rocky@mahamid.net```
7. Exit
`exit`
### Installing Ansible
8. 
```
sudo apt update
sudo apt install -y ansible

#Verify
ansible --version
```
### Creating Ansible Project 
9. basically this git repo
