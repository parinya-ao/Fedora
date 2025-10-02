#!/usr/bin/env bash
# System Setup Script with Browser Selection

set -e  # Exit on error

# Color codes for pretty UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "\n${CYAN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}  $1"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}\n"
}

function print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

function print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

function print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

function print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

function ask_yes_no() {
    local prompt="$1"
    while true; do
        echo -ne "${MAGENTA}?${NC} $prompt ${BOLD}(y/n):${NC} "
        read -r ans
        case $ans in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo -e "${RED}✗${NC} Please answer y or n." ;;
        esac
    done
}

function ask_multiple_choice() {
    local prompt="$1"
    shift
    local options=("$@")

    echo -e "\n${MAGENTA}?${NC} $prompt"
    for i in "${!options[@]}"; do
        echo -e "  ${BOLD}$((i+1)).${NC} ${options[$i]}"
    done

    while true; do
        echo -ne "${BOLD}Enter your choice (1-${#options[@]}):${NC} "
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            return $((choice-1))
        else
            echo -e "${RED}✗${NC} Invalid choice. Please enter a number between 1 and ${#options[@]}."
        fi
    done
}

# ===============================
#  SYSTEM UPDATE
# ===============================
print_header "SYSTEM UPDATE & UPGRADE"
print_step "Updating system packages..."
sudo dnf update -y && sudo dnf upgrade --refresh -y
print_step "Updating Flatpak packages..."
flatpak update -y
print_success "System updated successfully!"

# ===============================
#  ESSENTIAL TOOLS
# ===============================
print_header "ESSENTIAL DEVELOPMENT TOOLS"
print_step "Installing essential tools (fish, neovim, tmux, alacritty, git)..."
sudo dnf install fish neovim tmux alacritty git -y
print_success "Essential tools installed!"

# ===============================
#  COMPILERS & BUILD TOOLS
# ===============================
print_header "COMPILERS & BUILD TOOLS"
print_info "Installing all compilers and build tools..."
print_step "Installing C/C++ compilers (gcc, g++, clang)..."
sudo dnf install gcc gcc-c++ g++ clang -y
print_step "Installing Rust (rustc, cargo)..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
print_step "Installing Java/Kotlin/Scala via SDKMAN..."
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install kotlin
print_success "All compilers and build tools installed!"

# ===============================
#  GNOME TWEAKS
# ===============================
print_header "DESKTOP ENVIRONMENT"
print_step "Installing GNOME Tweaks..."
sudo dnf install gnome-tweaks -y
print_success "GNOME Tweaks installed!"

# ===============================
#  BROWSER SELECTION
# ===============================
print_header "WEB BROWSER INSTALLATION"
echo -e "${BOLD}Select which browser(s) to install:${NC}"
echo -e "  ${BOLD}1.${NC} Firefox only"
echo -e "  ${BOLD}2.${NC} Brave only"
echo -e "  ${BOLD}3.${NC} Both Firefox and Brave"
echo -e "  ${BOLD}4.${NC} Skip browser installation"

while true; do
    echo -ne "${BOLD}Enter your choice (1-4):${NC} "
    read -r browser_choice
    case $browser_choice in
        1)
            print_step "Installing Firefox..."
            sudo dnf install firefox -y
            print_success "Firefox installed!"
            break
            ;;
        2)
            print_step "Installing Brave..."
            curl -fsS https://dl.brave.com/install.sh | sh
            print_success "Brave installed!"
            break
            ;;
        3)
            print_step "Installing Firefox..."
            sudo dnf install firefox -y
            print_success "Firefox installed!"
            print_step "Installing Brave..."
            curl -fsS https://dl.brave.com/install.sh | sh
            print_success "Brave installed!"
            break
            ;;
        4)
            print_info "Skipping browser installation."
            break
            ;;
        *)
            echo -e "${RED}✗${NC} Invalid choice. Please enter a number between 1 and 4."
            ;;
    esac
done

# ===============================
#  SUMMARY
# ===============================
print_header "INSTALLATION COMPLETE!"
echo -e "${GREEN}${BOLD}✓ System setup completed successfully!${NC}\n"
echo -e "${BOLD}Installed components:${NC}"
echo -e "  • System packages updated"
echo -e "  • Essential tools: fish, neovim, tmux, alacritty, git"
echo -e "  • Compilers: gcc, g++, clang, rustc"
echo -e "  • Build tools: make, cmake, watchman, cargo"
echo -e "  • SDK Manager: SDKMAN"
echo -e "  • Desktop: GNOME Tweaks"
case $browser_choice in
    1) echo -e "  • Browser: Firefox" ;;
    2) echo -e "  • Browser: Brave" ;;
    3) echo -e "  • Browsers: Firefox, Brave" ;;
    4) echo -e "  • Browser: None (skipped)" ;;
esac

echo -e "\n${YELLOW}${BOLD}⚠ IMPORTANT:${NC} ${YELLOW}Restart your terminal to apply changes!${NC}"
echo -e "${BLUE}ℹ${NC} For Rust: Run ${BOLD}source \$HOME/.cargo/env${NC}"
echo -e "${BLUE}ℹ${NC} For SDKMAN: Run ${BOLD}source \$HOME/.sdkman/bin/sdkman-init.sh${NC}\n"
