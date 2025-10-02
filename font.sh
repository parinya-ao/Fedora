#!/bin/bash

# Install fonts directory
FONT_DIR_LOCAL="$HOME/.local/share/fonts"
FONT_DIR_GLOBAL="/usr/share/fonts"
TEMP_DIR=$(mktemp -d)

# Create local fonts directory if it doesn't exist
mkdir -p "$FONT_DIR_LOCAL"

# Function to download and install font
install_font() {
    local url=$1
    local font_name=$2
    local install_global=${3:-false}

    echo "Downloading $font_name..."
    cd "$TEMP_DIR"
    wget -O "${font_name}.zip" "$url"

    if [ $? -eq 0 ]; then
        echo "Extracting $font_name..."
        unzip -o "${font_name}.zip" -d "$font_name"

        if [ "$install_global" = true ]; then
            echo "Installing $font_name globally (requires sudo)..."
            sudo mkdir -p "$FONT_DIR_GLOBAL/$font_name"
            sudo cp -r "$font_name"/*.ttf "$font_name"/*.TTF "$font_name"/*.otf "$font_name"/*.OTF "$FONT_DIR_GLOBAL/$font_name/" 2>/dev/null
        else
            echo "Installing $font_name locally..."
            mkdir -p "$FONT_DIR_LOCAL/$font_name"
            cp -r "$font_name"/*.ttf "$font_name"/*.TTF "$font_name"/*.otf "$font_name"/*.OTF "$FONT_DIR_LOCAL/$font_name/" 2>/dev/null
        fi

        echo "$font_name installed successfully!"
    else
        echo "Failed to download $font_name"
    fi
}

# Install fonts
install_font "https://www.f0nt.com/?dl_name=sipafonts/THSarabunNew.zip" "THSarabunNew" false
install_font "https://font.download/dl/font/times-new-roman.zip" "TimesNewRoman" false

# Refresh font cache
echo "Refreshing font cache..."
fc-cache -fv

# Install Typst
echo "Installing Typst..."
rustup self update
cargo install --locked typst-cli

# Cleanup
rm -rf "$TEMP_DIR"

echo "Installation complete! Fonts are available for Typst."


