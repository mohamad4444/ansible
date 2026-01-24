# Ansible Setup Tutorial on Windows 10 with VPS
Our local machine is on windows 10 and our VPS is using rocky linux
# Explanation about Ansible workflow
Ansible must be installed on host and it connects to VPS via ssh
# [Initial Setup](./docs/00InitialSetup)
# Useful Commands 

## Testing Ansible connection
```
ansible vps -i inventory.ini -m ping
ansible all -m ping -i inventory/development/hosts.ini


```
expected output
```
mahamid | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
## Run Ansible Playbook
```
ansible-playbook -i inventory.ini playbook.yml
ansible-playbook playbooks/site.yml

```
## Generate role structure
```
ansible-galaxy init jenkins

```
# RoadMap
- [x] Full Devops,Kubernetes setup for development
- [ ] Add Security to vps
- [ ] prevent DDOS attacks
- [ ] Add roles
- [ ] make it more Modular and expandable
