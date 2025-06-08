#!/usr/bin/fish

# Visual Studio Code Installation Script for Fedora Linux
# This script adds Microsoft repository and installs VS Code

# Step 1: Add Microsoft GPG key and repository
# Import Microsoft's GPG key for package verification
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Add Visual Studio Code repository to system
# This creates a new repo file with VS Code package source
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Step 2: Install Visual Studio Code
# Update package cache to include new repository
dnf check-update

# Install VS Code using dnf package manager
# Alternative: use 'code-insiders' for beta version
sudo dnf install code -y
