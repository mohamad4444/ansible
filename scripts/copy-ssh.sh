#!/bin/bash
# Script to copy SSH keys from Windows to WSL
# Which already exist on Vps for passwordless authentication
cp -r /mnt/c/Users/$USER/.ssh ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
echo "✅ SSH keys copied from Windows to WSL"