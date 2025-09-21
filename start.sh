sudo dnf update -y && sudo dnf upgrade --refresh -y && flatpak update -y
sudo dnf install fish neovim tmux alacritty git  -y
sudo dnf install watchman cmake make g++ clang openjdk-21-jdk -y
sudo dnf install gnome-tweaks -y

curl -fsS https://dl.brave.com/install.sh | sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

