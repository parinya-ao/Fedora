#!/usr/bin/fish

# Fish Shell and Neovim Installation Script for Fedora Linux
# This script installs fish shell and neovim editor

# Step 1: Install fish shell
# Fish is a user-friendly command line shell with syntax highlighting and autosuggestions
sudo dnf install fish -y

# Step 2: Change default shell to fish
# This makes fish the default shell for the current user
chsh -s /usr/bin/fish

# Step 3: Install Neovim
# Neovim is a modern, extensible text editor based on Vim
sudo dnf install neovim -y

# 4. add path
alias --save vi="nvim"
set -U fish_greeting ''             
set -gx EDITOR nvim                 
set -gx VISUAL nvim

# Note: After changing shell, you may need to:
# 1. Log out and log back in for the shell change to take effect
# 2. Configure fish with: fish_config
# 3. Install fish plugins or customize ~/.config/fish/config.fish