# Fedora Linux Setup Scripts

A collection of Fish shell scripts for setting up essential development tools on Fedora Linux. These scripts automate the installation and configuration of a complete development environment.

## Available Scripts

### 🐚 Shell & Editor Setup
- **`fish.sh`** - Install Fish shell and Neovim
  - Installs Fish shell with syntax highlighting and autosuggestions
  - Sets Fish as default shell
  - Installs Neovim as modern text editor
  - Configures aliases and environment variables

### 🐳 Container Platform
- **`docker.sh`** - Complete Docker CE installation
  - Adds Docker official repository
  - Installs Docker CE, CLI, and plugins (buildx, compose)
  - Configures Docker service to start automatically
  - Sets up user permissions for non-sudo Docker usage

### 💻 Development Tools
- **`vscode.sh`** - Visual Studio Code installation
  - Adds Microsoft repository with GPG verification
  - Installs VS Code from official Microsoft repository

- **`rust.sh`** - Rust programming language setup
  - Installs Rust toolchain via rustup
  - Includes rustc compiler, cargo package manager
  - Configures PATH for Fish shell

### 🖥️ Desktop Applications
- **`program.sh`** - Essential desktop applications via Flatpak
  - Installs Alacritty terminal emulator
  - Installs Brave browser (privacy-focused web browser)
  - Installs RustDesk (remote desktop application)

### 📱 Mobile Development
- **`AndroidSdk.sh`** - Android SDK for web scraping & automation
  - Installs Java 17 OpenJDK (required dependency)
  - Downloads Android command-line tools (minimal setup)
  - Configures Android SDK directory structure
  - Installs essential packages: platform-tools, build-tools, Android API
  - Perfect for mobile app automation and web scraping

## Quick Start

Run all scripts in order for complete setup:
```bash
# Make all scripts executable
chmod +x *.sh

# 1. Install Fish shell first (recommended)
./fish.sh

# 2. Install development tools
./docker.sh
./vscode.sh
./rust.sh

# 3. Install desktop applications
./program.sh

# 4. Install Android SDK (optional, for mobile development)
./AndroidSdk.sh
```

## Individual Script Usage

Make scripts executable and run:
```bash
chmod +x script_name.sh
./script_name.sh
```

## Requirements
- Fedora Linux (tested on latest versions)
- Fish shell (install fish.sh first for optimal experience)
- sudo privileges for package installation

## Notes
- All scripts use Fish shell syntax
- Environment variables are configured persistently
- Scripts include detailed comments for maintenance
- Designed for automation and unattended installation 
