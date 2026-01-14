# Ansible Setup Tutorial on Windows 10 with VPS
Our local machine is on windows 10 and our VPS is using rocky linux
# Explanation about Ansible workflow
Ansible must be installed on host and it connects to VPS via ssh
# [Initial Setup](./docs/00InitialSetup)
# Useful Commands 

## Testing Ansible connection
```
ansible vps -i inventory.ini -m ping
```
expected output
```
mahamid | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
