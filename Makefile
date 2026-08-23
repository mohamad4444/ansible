.PHONY: help test-connection run-local run-site syntax-check

# Default target
help:
	@echo "Ansible Infrastructure Project Makefile"
	@echo "======================================="
	@echo "Available commands:"
	@echo "  make help             - Show this help message"
	@echo "  make test-connection  - Test connectivity and list inventory hosts"
	@echo "  make run-local        - Run the local playbook (asks for become pass)"
	@echo "  make run-site         - Run the main site playbook"
	@echo "  make syntax-check     - Check syntax of all playbooks"
	
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