.PHONY: help bootstrap bootstrap-dry test-connection run-local run-site syntax-check

# Default target
help:
	@echo "  make bootstrap        - Setup SSH keys for all hosts in bootstrap/hosts.yml"
	@echo "  make bootstrap-dry    - Preview bootstrap without making changes"
	@echo "Ansible Infrastructure Project Makefile"
	@echo "======================================="
	@echo "Available commands:"
	@echo "  make help             - Show this help message"
	@echo "  make test-connection  - Test connectivity and list inventory hosts"
	@echo "  make run-local        - Run the local playbook (asks for become pass)"
	@echo "  make run-site         - Run the main site playbook"
	@echo "  make syntax-check     - Check syntax of all playbooks"
	
bootstrap:
	bash bootstrap/setup-ssh.sh

bootstrap-dry:
	bash bootstrap/setup-ssh.sh --dry-run

fixbadowner:
	bash scripts/fix-badowner.sh


test-connection:
	ansible-inventory -i ./inventory/development/hosts.ini --list
	ansible all -m ping -i ./inventory/development/hosts.ini

run-local:
	ansible-playbook playbooks/local.yml --ask-become-pass

run-site:
	ansible-playbook -i inventory/development/hosts.ini playbooks/site.yml

syntax-check:
	ansible-playbook -i inventory/development/hosts.ini playbooks/site.yml --syntax-check
	ansible-playbook playbooks/local.yml --syntax-check