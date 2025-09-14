cd ~/Downloads/
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
unzip "$filename"
if [ $? -ne 0 ]; then
    echo "Unzip failed. Exiting."
    exit 1
fi
mv cmdline-tools/* ~/Android/Sdk/cmdline-tools/latest/
rm "$filename"
rmdir cmdline-tools
# Set for current script session
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH
# Add to Bash
if [ -f ~/.bashrc ]; then
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> ~/.bashrc
    echo "export PATH=\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH" >> ~/.bashrc
    source ~/.bashrc
fi
# Add to Zsh
if [ -f ~/.zshrc ]; then
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> ~/.zshrc
    echo "export PATH=\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH" >> ~/.zshrc
    source ~/.zshrc
fi
# Add to Fish
if [ -d ~/.config/fish ]; then
    echo "set -x ANDROID_HOME \$HOME/Android/Sdk" >> ~/.config/fish/config.fish
    echo "set -x PATH \$ANDROID_HOME/cmdline-tools/latest/bin \$ANDROID_HOME/platform-tools \$PATH" >> ~/.config/fish/config.fish
fi
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
source ~/.config/fish/config.fish
echo "Android SDK installed. Restart your terminal for Fish/Zsh changes."
