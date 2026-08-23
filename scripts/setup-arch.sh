#!/usr/bin/env bash
# Arch Linux Development Environment Setup Script
# This script prepares an Arch Linux system with the necessary packages,
# docker, and user setup that are required for the Ansible playbooks.

set -e

echo "Starting Arch Linux setup..."

# 1. System Update
echo "Updating system..."
sudo pacman -Syu --noconfirm

# 2. Essential Utilities
echo "Installing essential utilities..."
sudo pacman -S --noconfirm --needed \
    python \
    python-pip \
    git \
    curl \
    wget \
    vim \
    nano \
    bash-completion \
    bind \
    net-tools \
    socat \
    conntrack-tools \
    iproute2 \
    htop \
    tree \
    tmux \
    base-devel \
    rsync \
    unzip \
    tar \
    gnupg \
    lsof \
    jq \
    gettext \
    shellcheck

# 3. Docker & Docker Compose
echo "Installing Docker..."
sudo pacman -S --noconfirm --needed docker docker-compose docker-buildx

echo "Enabling and starting Docker service..."
sudo systemctl enable --now docker.service

echo "Adding current user ($USER) to the docker group..."
sudo usermod -aG docker "$USER"
echo "Note: You可能会 need to log out and log back in, or run 'newgrp docker' for the group change to take effect."

# 4. Ansible prerequisites
echo "Installing pip packages for linting (optional, but recommended)..."
pip install --user --upgrade yamllint ansible-lint || true

echo "Setup complete! Your Arch Linux system is now ready."
echo "You can now run 'make run-local' to execute the Ansible playbooks."
