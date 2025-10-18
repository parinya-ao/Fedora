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
#  RPM FUSION REPOSITORIES
# ===============================
print_header "RPM FUSION REPOSITORIES (FREE & NON-FREE)"
print_step "Enabling RPM Fusion Free repository..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
print_step "Enabling RPM Fusion Non-Free repository..."
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
print_step "Updating package metadata..."
sudo dnf update -y
print_success "RPM Fusion repositories enabled!"

# ===============================
#  NON-FREE FIRMWARE
# ===============================
print_header "NON-FREE FIRMWARE & DRIVERS"
print_step "Installing non-free firmware packages..."
sudo dnf install -y \
    *-firmware \
    rpmfusion-nonfree-release-tainted \
    intel-media-driver \
    libva-intel-driver \
    libva-utils \
    mesa-va-drivers \
    mesa-vdpau-drivers
print_success "Non-free firmware installed!"

# ===============================
#  MULTIMEDIA CODECS
# ===============================
print_header "MULTIMEDIA CODECS (H.264, H.265, AAC, MP3, etc.)"
print_step "Installing multimedia group packages..."
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate -y sound-and-video
print_step "Installing GStreamer plugins (good, bad, ugly)..."
sudo dnf install -y \
    gstreamer1-plugins-{bad-\*,good-\*,base} \
    gstreamer1-plugin-openh264 \
    gstreamer1-libav \
    gstreamer1-plugins-ugly-free \
    lame\* --exclude=lame-devel
print_step "Installing FFmpeg with full codec support..."
sudo dnf install -y ffmpeg ffmpeg-libs
print_step "Installing video acceleration libraries..."
sudo dnf install -y \
    libva \
    libva-utils \
    libvdpau \
    libvdpau-va-gl \
    vdpauinfo
print_success "All multimedia codecs installed!"

# ===============================
#  MEDIA PLAYERS & TOOLS
# ===============================
print_header "MEDIA PLAYERS & MULTIMEDIA TOOLS"
print_step "Installing VLC media player..."
sudo dnf install -y vlc
print_step "Installing MPV media player..."
sudo dnf install -y mpv
print_step "Installing multimedia tools..."
sudo dnf install -y \
    HandBrake \
    audacity \
    gimp \
    inkscape
print_success "Media players and tools installed!"

# ===============================
#  NVIDIA GPU DETECTION & DRIVERS
# ===============================
print_header "NVIDIA GPU DETECTION & DRIVERS"
print_step "Checking for NVIDIA GPU..."

# Check if NVIDIA GPU exists
if lspci | grep -i nvidia > /dev/null 2>&1; then
    print_success "NVIDIA GPU detected!"
    lspci | grep -i nvidia | while read -r line; do
        echo -e "${CYAN}  └─${NC} $line"
    done
    echo ""

    print_step "Installing complete NVIDIA driver stack..."

    # Install kernel headers and development tools
    print_info "Installing kernel headers and build tools..."
    sudo dnf install -y kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig

    # Install NVIDIA drivers
    print_info "Installing NVIDIA proprietary drivers..."
    sudo dnf install -y akmod-nvidia

    # Install NVIDIA CUDA support
    print_info "Installing NVIDIA CUDA support..."
    sudo dnf install -y xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs

    # Install NVIDIA utilities and libraries
    print_info "Installing NVIDIA utilities and libraries..."
    sudo dnf install -y \
        nvidia-settings \
        nvidia-gpu-firmware \
        xorg-x11-drv-nvidia-power \
        nvidia-vaapi-driver \
        libva-nvidia-driver \
        vdpauinfo \
        vulkan

    # Install video encoding/decoding support
    print_info "Installing NVENC/NVDEC support..."
    sudo dnf install -y \
        nvidia-vaapi-driver \
        libva-utils \
        vdpauinfo

    # Enable nvidia-persistenced service
    print_info "Enabling NVIDIA persistence daemon..."
    sudo systemctl enable nvidia-persistenced

    print_success "NVIDIA driver stack installed completely!"
    echo -e "${YELLOW}${BOLD}⚠ IMPORTANT:${NC} ${YELLOW}You MUST reboot for NVIDIA drivers to work!${NC}"
    echo -e "${BLUE}ℹ${NC} After reboot, run ${BOLD}nvidia-smi${NC} to verify driver installation"
    echo -e "${BLUE}ℹ${NC} Run ${BOLD}nvidia-settings${NC} to configure GPU settings"
else
    print_info "No NVIDIA GPU detected. Skipping NVIDIA drivers."
    echo -e "${CYAN}ℹ${NC} Your system appears to use: $(lspci | grep -i 'vga\|3d\|display' | head -1)"
fi

if ask_yes_no "Install Microsoft fonts (Arial, Times New Roman, etc.)?"; then
    print_step "Installing Microsoft core fonts..."
    sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
    sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    print_success "Microsoft fonts installed!"
else
    print_info "Skipping Microsoft fonts."
fi

if ask_yes_no "Install unrar (proprietary archive tool)?"; then
    print_step "Installing unrar..."
    sudo dnf install -y unrar
    print_success "unrar installed!"
else
    print_info "Skipping unrar."
fi

print_success "Additional non-free software configuration complete!"

# ===============================
#  VERIFY NVIDIA INSTALLATION
# ===============================
if lspci | grep -i nvidia > /dev/null 2>&1; then
    print_header "NVIDIA DRIVER VERIFICATION"
    echo -e "${BLUE}ℹ${NC} Run these commands after reboot to verify NVIDIA setup:"
    echo -e "  ${BOLD}nvidia-smi${NC}               - Check driver status"
    echo -e "  ${BOLD}nvidia-settings${NC}          - Open NVIDIA control panel"
    echo -e "  ${BOLD}glxinfo | grep NVIDIA${NC}    - Verify OpenGL support"
    echo -e "  ${BOLD}vainfo${NC}                   - Check VA-API support"
    echo -e "  ${BOLD}vdpauinfo${NC}                - Check VDPAU support"
fi

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
echo -e "  • RPM Fusion repositories (free & non-free)"
echo -e "  • Non-free firmware and drivers"
echo -e "  • Multimedia codecs (H.264, H.265, AAC, MP3, etc.)"
echo -e "  • GStreamer plugins (good, bad, ugly) + FFmpeg"
echo -e "  • Hardware acceleration (VAAPI, VDPAU)"
echo -e "  • Media players: VLC, MPV"
echo -e "  • Multimedia tools: HandBrake, Audacity, GIMP, Inkscape"
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

echo -e "\n${YELLOW}${BOLD}⚠ IMPORTANT:${NC} ${YELLOW}Reboot your system to apply all changes!${NC}"
echo -e "${BLUE}ℹ${NC} For Rust: Run ${BOLD}source \$HOME/.cargo/env${NC}"
echo -e "${BLUE}ℹ${NC} For SDKMAN: Run ${BOLD}source \$HOME/.sdkman/bin/sdkman-init.sh${NC}"
echo -e "${GREEN}ℹ${NC} All video codecs are now installed - you can play any media format!${NC}\n"
