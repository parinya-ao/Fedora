#!/usr/bin/env fish

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
    echo "🚀 Installing JetBrains Toolbox..."
    cd ~/Downloads; or exit 1

    set url (curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
        | grep -oE 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-[0-9.]+.tar.gz' | head -n1)

    if test -z "$url"
        echo "❌ Failed to fetch Toolbox URL"
        return 1
    end

    set filename (basename $url)
    echo "⬇️ Downloading $filename ..."

    curl -L $url -o $filename --progress-bar | while read -l line
        # ใช้ regex ดึง %
        set percent (string match -r '([0-9]{1,3})%' $line | string replace -r '.*([0-9]{1,3}).*' '$1')
        if test -n "$percent"
            progress_bar $percent
        end
    end
    echo

    echo "📦 Extracting..."
    tar -xzf $filename; or return 1
    set folder (ls -d jetbrains-toolbox-* | head -n1)
    chmod +x $folder/jetbrains-toolbox
    sudo mv $folder/jetbrains-toolbox /usr/local/bin/
    rm -rf $folder $filename

    echo "✅ JetBrains Toolbox installed! Run: jetbrains-toolbox &"
end

# ===============================
#  INSTALL ANDROID STUDIO
# ===============================
function install_android_studio
    echo "🚀 Installing Android Studio..."
    cd ~/Downloads; or exit 1

    set url (curl -s https://developer.android.com/studio \
        | grep -oE 'https://redirector.gvt1.com/edgedl/android/studio/ide-zips/[0-9.]*/android-studio-[0-9.]+-linux.tar.gz' \
        | head -n1)

    if test -z "$url"
        echo "❌ Failed to fetch Android Studio URL"
        return 1
    end

    set filename (basename $url)
    echo "⬇️ Downloading $filename ..."

    curl -L $url -o $filename --progress-bar | while read -l line
        set percent (string match -r '([0-9]{1,3})%' $line | string replace -r '.*([0-9]{1,3}).*' '$1')
        if test -n "$percent"
            progress_bar $percent
        end
    end
    echo

    echo "📦 Extracting..."
    tar -xzf $filename; or return 1
    rm -rf ~/android-studio
    mv android-studio ~/android-studio
    rm -f $filename

    if not grep -q "android-studio/bin" ~/.config/fish/config.fish ^/dev/null
        echo "set -gx PATH \$HOME/android-studio/bin \$PATH" >> ~/.config/fish/config.fish
    end

    echo "✅ Android Studio installed! Run: studio.sh &"
end

# ===============================
#  MAIN MENU
# ===============================
if ask_yes_no "👉 Do you want to install JetBrains Toolbox?"
    install_toolbox
end

if ask_yes_no "👉 Do you want to install Android Studio?"
    install_android_studio
end

echo "🎉 All done!"
