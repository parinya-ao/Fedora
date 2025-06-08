#!/usr/bin/fish

# Rust Programming Language Installation Script for Fedora Linux
# This script installs the Rust compiler and toolchain using rustup

# Install Rust using the official rustup installer
# --proto '=https': Force HTTPS protocol for security
# --tlsv1.2: Use TLS version 1.2 for secure connection
# -sSf: Silent mode, show errors, fail on server errors
# The installer will download and install rustc, cargo, and rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

set -gx PATH $HOME/.cargo/bin $PATH 

# Note: After installation, you may need to:
# 1. Restart your terminal or run: source ~/.config/fish/config.fish
# 2. Verify installation with: rustc --version && cargo --version


