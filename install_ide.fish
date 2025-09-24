#!/usr/bin/env fish

# Helper functions
function progress_bar
    set -l percent $argv[1]
    set -l width 40
    set -l filled (math -s0 "($percent * $width) / 100")
    set -l empty (math "$width - $filled")
    set -l bar (string repeat -n $filled "█")(string repeat -n $empty "░")
    echo -ne "\r$percent% [$bar]"
end

function ask_yes_no
    set -l prompt $argv[1]
    while true
        read -l -P "$prompt (y/n): " ans
        switch $ans
            case y Y
                return 0
            case n N
                return 1
            case '*'
                echo "Please answer y or n."
        end
    end
end

# ===============================
#  INSTALL JETBRAINS TOOLBOX
# ===============================
function install_toolbox
    echo "🚀 Installing JetBrains Toolbox to /opt..."

    # Create downloads directory if needed
    mkdir -p ~/Downloads
    cd ~/Downloads; or exit 1

    # Fetch the latest Toolbox URL with better error handling
    echo "🔍 Fetching latest Toolbox download URL..."
    set api_response (curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release")

    if test -z "$api_response"
        echo "❌ Failed to fetch API response"
        return 1
    end

    # Debug: show part of response
    echo "📋 API Response preview:"
    echo $api_response | head -c 200
    echo "..."

    # Extract URL using more robust pattern
    set url (echo $api_response | jq -r '.TBA[0].downloads.linux.link' 2>/dev/null)

    # Fallback if jq fails
    if test -z "$url" -o "$url" = "null"
        echo "🔄 Trying alternative URL extraction..."
        set url (echo $api_response | grep -oE '"link":"[^"]*\.tar\.gz"' | head -n1 | sed 's/"link":"//g' | sed 's/"//g')
    end

    # Another fallback
    if test -z "$url"
        echo "🔄 Trying direct pattern match..."
        set url (echo $api_response | grep -oE 'https://download\.jetbrains\.com/toolbox/jetbrains-toolbox-[0-9.]+\.tar\.gz' | head -n1)
    end

    if test -z "$url"
        echo "❌ Failed to extract Toolbox URL from API response"
        echo "📋 Full API response:"
        echo $api_response
        return 1
    end

    echo "🔗 Found URL: $url"
    set filename (basename $url)

    echo "⬇️ Downloading $filename..."
    if not curl -L "$url" -o "$filename" --progress-bar
        echo "❌ Download failed"
        return 1
    end

    echo ""
    echo "📦 Extracting..."
    if not tar -xzf "$filename"
        echo "❌ Extraction failed"
        return 1
    end

    set folder (ls -d jetbrains-toolbox-* | head -n1)
    if test -z "$folder"
        echo "❌ Could not find extracted folder"
        return 1
    end

    echo "🔧 Installing to /opt..."
    sudo mkdir -p /opt/jetbrains-toolbox
    sudo cp -r "$folder"/* /opt/jetbrains-toolbox/
    sudo chmod +x /opt/jetbrains-toolbox/jetbrains-toolbox

    # Create symlink
    sudo ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox

    # Create desktop entry for GUI launcher
    echo "🎨 Creating desktop entry and icon..."
    mkdir -p ~/.local/share/applications
    mkdir -p ~/.local/share/icons/hicolor/256x256/apps

    # Download and install JetBrains Toolbox icon
    set icon_url "https://resources.jetbrains.com/storage/products/company/brand/logos/Toolbox_icon.svg"
    if curl -s "$icon_url" -o ~/.local/share/icons/hicolor/256x256/apps/jetbrains-toolbox.svg
        set icon_path "jetbrains-toolbox"
        echo "✅ Downloaded JetBrains Toolbox icon"
    else
        echo "⚠️ Failed to download icon, using fallback"
        set icon_path "application-x-executable"
    end

    # Create JetBrains Toolbox desktop entry
    cat > ~/.local/share/applications/jetbrains-toolbox.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Toolbox
Icon=$icon_path
Exec=/opt/jetbrains-toolbox/jetbrains-toolbox
Comment=JetBrains IDE Manager
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-toolbox
StartupNotify=true
EOF

    chmod +x ~/.local/share/applications/jetbrains-toolbox.desktop

    # Update desktop database and icon cache
    if command -v update-desktop-database >/dev/null 2>&1
        update-desktop-database ~/.local/share/applications/
    end

    # Update icon cache
    if command -v gtk-update-icon-cache >/dev/null 2>&1
        gtk-update-icon-cache -t ~/.local/share/icons/hicolor/ 2>/dev/null
    end

    # Cleanup
    rm -rf "$folder" "$filename"

    echo "✅ JetBrains Toolbox installed to /opt! Now searchable in applications menu with icon."
end

# ===============================
#  INSTALL ANDROID STUDIO
# ===============================
function install_android_studio
    echo "🚀 Installing Android Studio to /opt..."

    mkdir -p ~/Downloads
    cd ~/Downloads; or exit 1

    echo "🔍 Fetching latest Android Studio download URL..."
    set page_content (curl -s https://developer.android.com/studio)

    if test -z "$page_content"
        echo "❌ Failed to fetch Android Studio page"
        return 1
    end

    # Try multiple patterns for URL extraction
    set url (echo $page_content | grep -oE 'https://redirector\.gvt1\.com/edgedl/android/studio/ide-zips/[^"]*android-studio-[^"]*-linux\.tar\.gz' | head -n1)

    if test -z "$url"
        echo "🔄 Trying alternative URL pattern..."
        set url (echo $page_content | grep -oE 'https://dl\.google\.com/dl/android/studio/ide-zips/[^"]*android-studio-[^"]*-linux\.tar\.gz' | head -n1)
    end

    if test -z "$url"
        echo "❌ Failed to extract Android Studio URL"
        echo "🔍 Searching for any studio download links..."
        echo $page_content | grep -oE 'https://[^"]*android-studio[^"]*linux[^"]*\.tar\.gz' | head -5
        return 1
    end

    echo "🔗 Found URL: $url"
    set filename (basename $url)

    echo "⬇️ Downloading $filename..."
    if not curl -L "$url" -o "$filename" --progress-bar
        echo "❌ Download failed"
        return 1
    end

    echo ""
    echo "📦 Extracting..."
    if not tar -xzf "$filename"
        echo "❌ Extraction failed"
        return 1
    end

    echo "🔧 Installing to /opt..."
    sudo rm -rf /opt/android-studio
    sudo mv android-studio /opt/android-studio
    sudo chmod +x /opt/android-studio/bin/studio.sh

    # Create symlink
    sudo ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio

    # Add to PATH in fish config if not already there
    set config_file ~/.config/fish/config.fish
    mkdir -p (dirname $config_file)
    if not test -f $config_file; or not grep -q "/opt/android-studio/bin" $config_file
        echo "set -gx PATH /opt/android-studio/bin \$PATH" >> $config_file
    end

    # Create desktop entry for GUI launcher
    echo "🎨 Creating desktop entry and icon..."
    mkdir -p ~/.local/share/applications
    mkdir -p ~/.local/share/icons/hicolor/256x256/apps

    # Download and install Android Studio icon
    set icon_url "https://developer.android.com/static/studio/images/new-studio-logo-1_2x.png"
    if curl -s "$icon_url" -o ~/.local/share/icons/hicolor/256x256/apps/android-studio.png
        set icon_path "android-studio"
        echo "✅ Downloaded Android Studio icon"
    else
        echo "⚠️ Failed to download icon, checking for bundled icon..."
        if test -f /opt/android-studio/bin/studio.png
            cp /opt/android-studio/bin/studio.png ~/.local/share/icons/hicolor/256x256/apps/android-studio.png
            set icon_path "android-studio"
            echo "✅ Using bundled Android Studio icon"
        else
            echo "⚠️ Using fallback icon"
            set icon_path "application-x-executable"
        end
    end

    # Create Android Studio desktop entry
    cat > ~/.local/share/applications/android-studio.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Icon=$icon_path
Exec=/opt/android-studio/bin/studio.sh
Comment=The official Android IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-studio
StartupNotify=true
EOF

    chmod +x ~/.local/share/applications/android-studio.desktop

    # Update desktop database and icon cache
    if command -v update-desktop-database >/dev/null 2>&1
        update-desktop-database ~/.local/share/applications/
    end

    # Update icon cache
    if command -v gtk-update-icon-cache >/dev/null 2>&1
        gtk-update-icon-cache -t ~/.local/share/icons/hicolor/ 2>/dev/null
    end

    rm -f "$filename"

    echo "✅ Android Studio installed to /opt! Now searchable in applications menu with icon."
end

# ===============================
#  MAIN MENU
# ===============================

echo "🛠️ IDE Installer Script"
echo "======================="

if ask_yes_no "👉 Do you want to install JetBrains Toolbox?"
    install_toolbox
    echo ""
end

if ask_yes_no "👉 Do you want to install Android Studio?"
    install_android_studio
    echo ""
end

echo "🎉 Installation complete!"
echo ""
echo "📝 Usage:"
echo "  Search 'JetBrains Toolbox' or 'Android Studio' in your applications menu"
echo "  Or run from terminal:"
echo "    JetBrains Toolbox: jetbrains-toolbox &"
echo "    Android Studio: android-studio &"
echo ""
echo "💡 You may need to restart your terminal or run 'source ~/.config/fish/config.fish' for PATH changes to take effect."

