#!/usr/bin/env bash
cd ~/Downloads/ || exit 1

url=$(curl -s https://developer.android.com/studio#command-tools | \
grep -oP 'https://dl.google.com/android/repository/commandlinetools-linux-[0-9]+_latest.zip' | head -n1)
if [ -z "$url" ]; then
    echo "Failed to fetch Android SDK URL. Exiting."
    exit 1
fi
filename=$(basename "$url")
curl -O "$url"
if [ $? -ne 0 ]; then
    echo "Download failed. Exiting."
    exit 1
fi

mkdir -p ~/Android/Sdk/cmdline-tools/latest
unzip -q "$filename"
if [ $? -ne 0 ]; then
    echo "Unzip failed. Exiting."
    exit 1
fi

rsync -a cmdline-tools/ ~/Android/Sdk/cmdline-tools/latest/
rm -rf cmdline-tools
rm -f "$filename"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

if [ -f ~/.bashrc ]; then
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> ~/.bashrc
    echo "export PATH=\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH" >> ~/.bashrc
    source ~/.bashrc
fi

if [ -f ~/.zshrc ]; then
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> ~/.zshrc
    echo "export PATH=\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH" >> ~/.zshrc
    source ~/.zshrc
fi

if [ -d ~/.config/fish ]; then
    echo "set -gx ANDROID_HOME \$HOME/Android/Sdk" >> ~/.config/fish/config.fish
    echo "set -gx PATH \$ANDROID_HOME/cmdline-tools/latest/bin \$ANDROID_HOME/platform-tools \$PATH" >> ~/.config/fish/config.fish
fi

yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_HOME" --licenses

"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_HOME" "platform-tools" "platforms;android-34" "build-tools;34.0.0"

echo "Android SDK installed. Restart your terminal (or open a new fish shell) for Fish/Zsh changes."
