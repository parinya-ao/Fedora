#!/usr/bin/env fish
# Minimal-noise installer with proper debug logging and desktop entries that actually show up.

set -q DEBUG; or set -g DEBUG 1  # 1=show debug, 0=silent except prompts

function dbg
    if test "$DEBUG" = "1"
        echo "[DBG] $argv"
    end
end

function err
    echo "[ERR] $argv" 1>&2
end

function die
    err $argv
    exit 1
end

function require_cmd
    for c in $argv
        command -v $c >/dev/null 2>&1; or die "missing command: $c"
    end
end

# safer curl: fail on HTTP errors, follow redirects, silent but show errors
set -g CURL "curl -fsSL --retry 3 --retry-delay 1"

# --- ask_yes_no (keep minimal prompt only) ---
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

function refresh_desktop
    dbg "refreshing desktop databases"
    if command -v update-desktop-database >/dev/null 2>&1
        update-desktop-database ~/.local/share/applications >/dev/null 2>&1
    end
    if command -v xdg-desktop-menu >/dev/null 2>&1
        xdg-desktop-menu forceupdate >/dev/null 2>&1
    end
end

# ===============================
#  INSTALL JETBRAINS TOOLBOX
# ===============================
function install_toolbox
    require_cmd curl tar sudo jq grep sed basename
    mkdir -p ~/Downloads ~/.local/share/applications ~/.local/share/icons/hicolor/256x256/apps
    cd ~/Downloads; or die "cd ~/Downloads failed"

    dbg "fetching toolbox releases json"
    set api_response ( $CURL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" )
    test -n "$api_response"; or die "fetch releases failed"

    # Primary extraction via jq, fallbacks via grep
    set url (echo $api_response | jq -r '.TBA[0].downloads.linux.link' 2>/dev/null)
    if test -z "$url" -o "$url" = "null"
        dbg "jq failed; fallback pattern 1"
        set url (echo $api_response | grep -oE '"link":"[^"]*\.tar\.gz"' | head -n1 | sed 's/"link":"//;s/"$//')
    end
    if test -z "$url"
        dbg "fallback pattern 2"
        set url (echo $api_response | grep -oE 'https://download\.jetbrains\.com/toolbox/jetbrains-toolbox-[0-9.]+\.tar\.gz' | head -n1)
    end
    test -n "$url"; or die "cannot extract toolbox url"

    dbg "downloading: $url"
    set filename (basename $url)
    $CURL "$url" -o "$filename"; or die "download failed"

    dbg "determining top-level dir from tar"
    set top (tar -tzf "$filename" | head -n1 | sed 's#/.*$##')
    test -n "$top"; or die "cannot read tar top dir"

    dbg "extracting"
    tar -xzf "$filename"; or die "extract failed"
    test -d "$top"; or die "extracted dir not found: $top"

    dbg "installing to /opt/jetbrains-toolbox"
    sudo rm -rf /opt/jetbrains-toolbox
    sudo mv "$top" /opt/jetbrains-toolbox; or die "move to /opt failed"
    # ensure permissions & executable
    sudo chmod a+rx -R /opt/jetbrains-toolbox
    sudo chmod +x /opt/jetbrains-toolbox/jetbrains-toolbox

    dbg "symlink /usr/local/bin/jetbrains-toolbox"
    sudo ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox

    # Icon (use a redirect-safe URL)
    set icon_dest "$HOME/.local/share/icons/hicolor/256x256/apps/jetbrains-toolbox.png"
    set icon_try1 "https://resources.jetbrains.com/storage/products/company/brand/logos/Toolbox_icon.png"
    set icon_try2 "https://resources.jetbrains.com/storage/products/toolbox/img/icons/toolbox-icon.png"
    set ok 0
    for u in $icon_try1 $icon_try2
        dbg "downloading icon: $u"
        if $CURL "$u" -o "$icon_dest"
            set ok 1
            break
        end
    end
    if test $ok -eq 0
        dbg "icon download failed; will use absolute Exec without icon cache reliance"
    end

    # Desktop entry
    set desktop "$HOME/.local/share/applications/jetbrains-toolbox.desktop"
    dbg "writing desktop entry: $desktop"
    printf '%s\n' \
"[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Toolbox
Comment=JetBrains IDE Manager
Exec=/opt/jetbrains-toolbox/jetbrains-toolbox %U
Icon=$icon_dest
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-toolbox
X-GNOME-UsesNotifications=true
NoDisplay=false" > $desktop
    chmod +x $desktop

    # cleanup
    rm -f "$filename"
    dbg "toolbox done"
end

# ===============================
#  INSTALL ANDROID STUDIO
# ===============================
function install_android_studio
    require_cmd curl tar sudo grep sed basename
    mkdir -p ~/Downloads ~/.local/share/applications ~/.local/share/icons/hicolor/256x256/apps
    cd ~/Downloads; or die "cd ~/Downloads failed"

    dbg "fetching android studio page"
    set page ( $CURL "https://developer.android.com/studio" )
    test -n "$page"; or die "fetch page failed"

    # Try multiple patterns (Google rotates CDNs)
    set url (echo $page | grep -oE 'https://redirector\.gvt1\.com/edgedl/android/studio/ide-zips/[^"]*android-studio-[^"]*-linux\.tar\.gz' | head -n1)
    if test -z "$url"
        dbg "pattern 2"
        set url (echo $page | grep -oE 'https://dl\.google\.com/dl/android/studio/ide-zips/[^"]*android-studio-[^"]*-linux\.tar\.gz' | head -n1)
    end
    if test -z "$url"
        dbg "pattern 3"
        set url (echo $page | grep -oE 'https://dl\.google\.com/android/studio/ide-zips/[^"]*android-studio-[^"]*-linux\.tar\.gz' | head -n1)
    end
    test -n "$url"; or die "cannot extract android studio url"

    dbg "downloading: $url"
    set filename (basename $url)
    $CURL "$url" -o "$filename"; or die "download failed"

    dbg "extracting"
    tar -xzf "$filename"; or die "extract failed"

    # Find the folder (usually 'android-studio')
    set folder (command find . -maxdepth 1 -type d -name 'android-studio*' -print | head -n1 | sed 's#^\./##')
    test -n "$folder"; or die "android-studio dir not found"

    dbg "installing to /opt/android-studio"
    sudo rm -rf /opt/android-studio
    sudo mv "$folder" /opt/android-studio; or die "move to /opt failed"
    sudo chmod a+rx -R /opt/android-studio
    sudo chmod +x /opt/android-studio/bin/studio.sh

    dbg "symlink /usr/local/bin/android-studio"
    sudo ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio

    # Use bundled icon if present; otherwise fetch official
    set icon_dest "$HOME/.local/share/icons/hicolor/256x256/apps/android-studio.png"
    if test -f /opt/android-studio/bin/studio.png
        cp /opt/android-studio/bin/studio.png "$icon_dest"
    else
        dbg "downloading android studio icon"
        $CURL "https://developer.android.com/static/studio/images/new-studio-logo-1_2x.png" -o "$icon_dest" >/dev/null 2>&1
    end

    # Desktop entry
    set desktop "$HOME/.local/share/applications/android-studio.desktop"
    dbg "writing desktop entry: $desktop"
    printf '%s\n' \
"[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Comment=The official Android IDE
Exec=/opt/android-studio/bin/studio.sh %f
TryExec=/opt/android-studio/bin/studio.sh
Icon=$icon_dest
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-studio
NoDisplay=false
X-GNOME-UsesNotifications=true" > $desktop
    chmod +x $desktop

    rm -f "$filename"
    dbg "android studio done"
end

# ===============================
#  MAIN
# ===============================
echo "IDE Installer (minimal prints; DEBUG=$DEBUG)"
if ask_yes_no "Install JetBrains Toolbox?"
    install_toolbox
end
if ask_yes_no "Install Android Studio?"
    install_android_studio
end
refresh_desktop
echo "Done."
