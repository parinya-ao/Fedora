#!/usr/bin/fish

# Android SDK Command Line Tools Setup for Web Scraping
# This script sets up minimal Android SDK for automation and web scraping

# Step 1: Install Java Development Kit (required for Android tools)
# OpenJDK 17 is the recommended version for modern Android SDK
echo "Installing Java 17 OpenJDK..."
sudo dnf install java-17-openjdk-devel -y

# Step 2: Download Android Command Line Tools
# Check latest version at: https://developer.android.com/studio/index.html#command-line-tools-only
echo "Downloading Android Command Line Tools..."
cd ~/Downloads/

# Download the latest Linux command line tools (update URL if needed)
curl -O https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip

# Step 3: Create Android SDK directory structure
echo "Setting up Android SDK directory..."
mkdir -p ~/Android/Sdk/cmdline-tools/latest

# Step 4: Extract and organize the tools
echo "Extracting command line tools..."
unzip commandlinetools-linux-13114758_latest.zip

# Move extracted tools to proper location
mv cmdline-tools/* ~/Android/Sdk/cmdline-tools/latest/

# Clean up downloaded files
rm commandlinetools-linux-13114758_latest.zip
rmdir cmdline-tools

# Step 5: Set up environment variables for Fish shell
echo "Configuring environment variables..."
# Set ANDROID_HOME (persistent across sessions)
set -U ANDROID_HOME $HOME/Android/Sdk

# Add Android tools to PATH (persistent across sessions)
set -U fish_user_paths $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $fish_user_paths

# Step 6: Accept SDK licenses (required for package installation)
echo "Accepting Android SDK licenses..."
yes | sdkmanager --licenses

# Step 7: Install minimal packages for web scraping
echo "Installing essential Android packages for web scraping..."
# platform-tools: includes adb for device communication
# platforms: Android API level (adjust version as needed)
# build-tools: for app building and debugging
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

echo "Android SDK setup complete!"
echo "You can now use adb and other Android tools for web scraping automation."
echo "Restart your terminal or run 'source ~/.config/fish/config.fish' to use the tools."
