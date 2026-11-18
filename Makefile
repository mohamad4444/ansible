# Detect virtualenv if present
VENV_BIN := $(shell if [ -d ".venv/bin" ]; then echo ".venv/bin/"; fi)
ANSIBLE := $(VENV_BIN)ansible
ANSIBLE_PLAYBOOK := $(VENV_BIN)ansible-playbook
ANSIBLE_INVENTORY := $(VENV_BIN)ansible-inventory

.PHONY: help setup-local bootstrap bootstrap-dry test-connection run-local run-site syntax-check

# Default target
help:
	@echo "Ansible Infrastructure Project Makefile"
	@echo "======================================="
	@echo "Available commands:"
	@echo "  make help             - Show this help message"
	@echo "  make setup-local      - Install Ansible, collections & control node dependencies"
	@echo "  make bootstrap        - Setup SSH keys & remote Ansible prerequisites for hosts in bootstrap/hosts.yml"
	@echo "  make bootstrap-dry    - Preview bootstrap without making changes"
	@echo "  make test-connection  - Test connectivity and list inventory hosts"
	@echo "  make run-local        - Run the local playbook (asks for become pass)"
	@echo "  make run-site         - Run the main site playbook"
	@echo "  make syntax-check     - Check syntax of all playbooks"

setup-local:
	bash scripts/setup-control-node.sh
	
bootstrap:
	bash bootstrap/setup-ssh.sh

bootstrap-dry:
	bash bootstrap/setup-ssh.sh --dry-run

fixbadowner:
	bash scripts/fix-badowner.sh

test-connection:
	$(ANSIBLE_INVENTORY) -i ./inventory/development/hosts.ini --list
	$(ANSIBLE) all -m ping -i ./inventory/development/hosts.ini

run-local:
	$(ANSIBLE_PLAYBOOK) playbooks/local.yml --ask-become-pass

run-site:
	$(ANSIBLE_PLAYBOOK) -i inventory/development/hosts.ini playbooks/site.yml

syntax-check:
	$(ANSIBLE_PLAYBOOK) -i inventory/development/hosts.ini playbooks/site.yml --syntax-check
	$(ANSIBLE_PLAYBOOK) playbooks/local.yml --syntax-check