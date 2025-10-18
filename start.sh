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
#  LAPTOP VENDOR DETECTION & DRIVERS
# ===============================
print_header "LAPTOP VENDOR DETECTION & DRIVERS"
print_step "Detecting laptop manufacturer..."

# Get system vendor information
VENDOR=$(sudo dmidecode -s system-manufacturer 2>/dev/null | tr '[:upper:]' '[:lower:]')
PRODUCT=$(sudo dmidecode -s system-product-name 2>/dev/null | tr '[:upper:]' '[:lower:]')

echo -e "${CYAN}Manufacturer:${NC} $VENDOR"
echo -e "${CYAN}Product:${NC} $PRODUCT"
echo ""

VENDOR_DETECTED=false

# Acer Detection
if echo "$VENDOR" | grep -iq "acer"; then
    print_success "Acer laptop detected!"
    VENDOR_DETECTED=true

    print_step "Installing Acer-specific drivers and tools..."

    # TLP for better battery management (common for all laptops)
    print_info "Installing TLP (battery optimization)..."
    sudo dnf install -y tlp tlp-rdw
    sudo systemctl enable tlp

    # Acer WMI kernel module support
    print_info "Installing Acer WMI support..."
    sudo dnf install -y kernel-modules-extra

    # Thermal management
    print_info "Installing thermal management tools..."
    sudo dnf install -y thermald
    sudo systemctl enable thermald

    # Sensors and monitoring
    print_info "Installing hardware monitoring tools..."
    sudo dnf install -y lm_sensors

    print_success "Acer-specific drivers and tools installed!"
    echo -e "${BLUE}ℹ${NC} Run ${BOLD}sensors-detect${NC} after reboot to detect all sensors"
fi

# ASUS Detection
if echo "$VENDOR" | grep -iq "asus\|asustek"; then
    print_success "ASUS laptop detected!"
    VENDOR_DETECTED=true

    print_step "Installing ASUS-specific drivers and tools..."

    # TLP for battery
    print_info "Installing TLP (battery optimization)..."
    sudo dnf install -y tlp tlp-rdw
    sudo systemctl enable tlp

    # ASUS WMI support
    print_info "Installing ASUS WMI and ROG support..."
    sudo dnf install -y kernel-modules-extra

    # ASUSctl for ROG laptops (if available in repos)
    print_info "Checking for ASUSctl (ROG laptop control)..."
    if sudo dnf search asusctl 2>/dev/null | grep -q asusctl; then
        sudo dnf install -y asusctl supergfxctl
        sudo systemctl enable power-profiles-daemon.service
        print_success "ASUSctl installed for ROG features!"
    else
        print_warning "ASUSctl not found in repos (not needed for non-ROG models)"
    fi

    # Thermal and fan control
    print_info "Installing thermal management..."
    sudo dnf install -y thermald lm_sensors
    sudo systemctl enable thermald

    print_success "ASUS-specific drivers and tools installed!"
    echo -e "${BLUE}ℹ${NC} For ROG laptops: Use ${BOLD}asusctl${NC} for performance profiles"
fi

# Lenovo/ThinkPad Detection
if echo "$VENDOR" | grep -iq "lenovo" || echo "$PRODUCT" | grep -iq "thinkpad"; then
    print_success "Lenovo/ThinkPad laptop detected!"
    VENDOR_DETECTED=true

    print_step "Installing Lenovo/ThinkPad-specific drivers and tools..."

    # TLP with ThinkPad-specific optimizations
    print_info "Installing TLP with ThinkPad support..."
    sudo dnf install -y tlp tlp-rdw

    # ThinkPad-specific kernel modules
    print_info "Installing ThinkPad ACPI support..."
    sudo dnf install -y kernel-modules-extra

    # Enable TLP with ThinkPad battery features
    sudo systemctl enable tlp

    # tp_smapi for older ThinkPads
    if sudo dnf search tp-smapi 2>/dev/null | grep -q tp-smapi; then
        print_info "Installing tp_smapi (for older ThinkPad battery control)..."
        sudo dnf install -y tp_smapi akmod-tp_smapi
    fi

    # Lenovo throttling fix (throttled)
    print_info "Installing throttled (Lenovo thermal throttling fix)..."
    if command -v pip3 &> /dev/null; then
        sudo pip3 install lenovo-throttling-fix 2>/dev/null || print_warning "Could not install lenovo-throttling-fix"
    fi

    # Sensors and monitoring
    print_info "Installing hardware monitoring tools..."
    sudo dnf install -y lm_sensors thermald
    sudo systemctl enable thermald

    print_success "Lenovo/ThinkPad-specific drivers and tools installed!"
    echo -e "${BLUE}ℹ${NC} ThinkPad features:"
    echo -e "  ${BOLD}tlp-stat${NC}                - Check TLP status and battery features"
    echo -e "  ${BOLD}sensors${NC}                 - Monitor temperatures"
fi

# Dell Detection
if echo "$VENDOR" | grep -iq "dell"; then
    print_success "Dell laptop detected!"
    VENDOR_DETECTED=true

    print_step "Installing Dell-specific drivers and tools..."

    # TLP for battery
    print_info "Installing TLP (battery optimization)..."
    sudo dnf install -y tlp tlp-rdw
    sudo systemctl enable tlp

    # Dell-specific tools
    print_info "Installing Dell command configure tools..."
    sudo dnf install -y kernel-modules-extra

    # Thermal management
    print_info "Installing thermal management..."
    sudo dnf install -y thermald lm_sensors
    sudo systemctl enable thermald

    # Dell BIOS updates (fwupd)
    print_info "Installing firmware update support..."
    sudo dnf install -y fwupd
    sudo systemctl enable fwupd

    print_success "Dell-specific drivers and tools installed!"
    echo -e "${BLUE}ℹ${NC} Run ${BOLD}fwupdmgr get-updates${NC} to check for BIOS/firmware updates"
fi

# HP Detection
if echo "$VENDOR" | grep -iq "hp\|hewlett"; then
    print_success "HP laptop detected!"
    VENDOR_DETECTED=true

    print_step "Installing HP-specific drivers and tools..."

    # TLP for battery
    print_info "Installing TLP (battery optimization)..."
    sudo dnf install -y tlp tlp-rdw
    sudo systemctl enable tlp

    # HP-specific support
    print_info "Installing HP support tools..."
    sudo dnf install -y kernel-modules-extra

    # HPLIP for HP printers (if laptop has integrated features)
    print_info "Installing HPLIP (HP printer/scanner support)..."
    sudo dnf install -y hplip

    # Thermal management
    print_info "Installing thermal management..."
    sudo dnf install -y thermald lm_sensors
    sudo systemctl enable thermald

    print_success "HP-specific drivers and tools installed!"
fi

# Generic laptop tools if no specific vendor detected
if [ "$VENDOR_DETECTED" = false ]; then
    print_info "Generic or unknown laptop manufacturer detected."
    print_step "Installing general laptop optimization tools..."

    sudo dnf install -y tlp tlp-rdw thermald lm_sensors
    sudo systemctl enable tlp
    sudo systemctl enable thermald

    print_success "General laptop tools installed!"
fi

# Common laptop utilities for all
print_step "Installing common laptop utilities..."
sudo dnf install -y \
    powertop \
    acpi \
    brightnessctl \
    light

print_success "Laptop vendor-specific drivers installed!"
echo -e "${BLUE}ℹ${NC} Common commands:"
echo -e "  ${BOLD}tlp-stat${NC}                - Check power/battery status"
echo -e "  ${BOLD}powertop${NC}                - Power consumption analyzer"
echo -e "  ${BOLD}sensors${NC}                 - Show temperature sensors"
echo -e "  ${BOLD}acpi -V${NC}                 - Show battery info"

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
#  UBUNTU-STYLE GNOME DESKTOP
# ===============================
print_header "UBUNTU-STYLE GNOME DESKTOP CUSTOMIZATION"

# Install base GNOME tools
print_step "Installing GNOME customization tools..."
sudo dnf install -y gnome-tweaks gnome-extensions-app dconf-editor

# Install GNOME Shell Extensions
print_step "Installing GNOME Shell Extensions (Ubuntu-style)..."
sudo dnf install -y \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-desktop-icons \
    gnome-shell-extension-user-theme \
    gnome-shell-extension-places-menu \
    gnome-shell-extension-apps-menu

# Install Yaru theme (Official Ubuntu theme)
print_step "Installing Yaru theme (Ubuntu's official theme)..."
sudo dnf install -y yaru-theme || {
    print_warning "Yaru theme not in repos, installing from source..."
    sudo dnf install -y git meson sassc gtk-murrine-engine
    git clone https://github.com/ubuntu/yaru.git /tmp/yaru
    cd /tmp/yaru
    meson build
    sudo ninja -C build install
    cd -
}

# Install Yaru icon theme
print_step "Installing Yaru icon theme..."
sudo dnf install -y yaru-icon-theme || {
    print_warning "Installing Yaru icons from source..."
    if [ ! -d "/tmp/yaru" ]; then
        git clone https://github.com/ubuntu/yaru.git /tmp/yaru
    fi
    sudo cp -r /tmp/yaru/icons/Yaru* /usr/share/icons/
}

# Install Ubuntu fonts
print_step "Installing Ubuntu fonts..."
sudo dnf install -y ubuntu-family-fonts || {
    print_warning "Installing Ubuntu fonts manually..."
    sudo dnf install -y google-roboto-fonts liberation-fonts
}

# Install Papirus icon theme (popular alternative)
print_step "Installing Papirus icon theme..."
sudo dnf install -y papirus-icon-theme

# Apply Ubuntu GNOME settings
print_step "Applying Ubuntu-style GNOME settings..."

# Enable extensions
gnome-extensions enable dash-to-dock@micxgx.gmail.com 2>/dev/null || true
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com 2>/dev/null || true
gnome-extensions enable desktop-icons@csoriano 2>/dev/null || true
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

# Configure Dash to Dock (Ubuntu-style left dock)
print_info "Configuring Dash to Dock (Ubuntu-style)..."
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC'
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'

# Set window buttons to left (Ubuntu style)
print_info "Moving window buttons to left (Ubuntu style)..."
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# Set Yaru theme
print_info "Applying Yaru theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
gsettings set org.gnome.desktop.wm.preferences theme 'Yaru'
gsettings set org.gnome.shell.extensions.user-theme name 'Yaru'

# Set Yaru icons
print_info "Applying Yaru icons..."
gsettings set org.gnome.desktop.interface icon-theme 'Yaru'

# Set Ubuntu fonts
print_info "Applying Ubuntu fonts..."
gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11'
gsettings set org.gnome.desktop.interface document-font-name 'Ubuntu 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 13'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 11'

# Set Ubuntu-style desktop preferences
print_info "Configuring desktop preferences..."
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.calendar show-weekdate true

# Set file manager preferences (Ubuntu style)
print_info "Configuring file manager..."
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.nautilus.list-view use-tree-view true

# Enable hot corner (top-left)
gsettings set org.gnome.desktop.interface enable-hot-corners true

# Set background color (Ubuntu default purple)
print_info "Setting Ubuntu-style background..."
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.background primary-color '#2C001E'

print_success "Ubuntu-style GNOME customization complete!"
echo -e "${GREEN}✓${NC} Your Fedora GNOME now looks like Ubuntu!"
echo -e "${BLUE}ℹ${NC} Changes applied:"
echo -e "  • Dash to Dock on left side"
echo -e "  • Window buttons on left (close, minimize, maximize)"
echo -e "  • Yaru theme and icons"
echo -e "  • Ubuntu fonts"
echo -e "  • Ubuntu-style settings"
echo -e "${YELLOW}⚠${NC} Log out and log back in for all changes to take effect!"

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
echo -e "  • Desktop: Ubuntu-style GNOME (Yaru theme, Dash to Dock, extensions)"
echo -e "  • Laptop vendor-specific drivers and optimizations"
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
