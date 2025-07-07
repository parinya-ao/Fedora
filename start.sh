sudo dnf update -y
sudo dnf upgrade -y

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# brave install
sudo dnf install curl -y
sudo dnf install dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install brave-browser

# compiler
sudo dnf install watchman cmake make g++ clang neovim -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# golang

cd ~/Downloads
url=$(curl -s https://go.dev/dl/ | grep -oP 'https://go.dev/dl/go[0-9.]+.linux-amd64.tar.gz' | head -n1)
filename=$(basename "$url")
curl -LO "$url"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$filename"
rm "$filename"
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc
cd ~/

# vscode install
cd ~/Downloads
wget -O vscode.rpm 'https://update.code.visualstudio.com/latest/linux-rpm-x64/stable'
sudo dnf install ./vscode.rpm -y
echo "exclude=code" | sudo tee -a /etc/dnf/dnf.conf
rm vscode.rpm
cd ~

# install android sdk
cd ~/Downloads/

url=$(curl -s https://developer.android.com/studio#command-tools | \
grep -oP 'https://dl.google.com/android/repository/commandlinetools-linux-[0-9]+_latest.zip' | head -n1)

filename=$(basename "$url")

curl -O "$url"

mkdir -p ~/Android/Sdk/cmdline-tools/latest
unzip "$filename"
mv cmdline-tools/* ~/Android/Sdk/cmdline-tools/latest/
rm "$filename"
rmdir cmdline-tools

echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> ~/.bashrc
echo "export PATH=\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH" >> ~/.bashrc
source ~/.bashrc

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# install flutter
sudo dnf update -y && sudo dnf upgrade --refresh;
sudo dnf install -y curl git unzip xz-utils zip libglu1-mesa

sudo dnf install -y libc6:amd64 libstdc++6:amd64 lib32z1 libbz2-1.0:amd64



# install docker
# docker
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable --now docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker

# dev
curl -fsSL https://bun.sh/install | bash
bun i nodemon
# wireshark
sudo dnf install wireshark -y
# andorid studio
flatpak install flathub com.google.AndroidStudio -y
flatpak install flathub org.signal.Signal -y
flatpak install flathub com.rustdesk.RustDesk -y

# vscode path
git clone https://gist.github.com/parinya-ao/12332335e7c7acc1fc99038b5f50f7ca
cd 12332335e7c7acc1fc99038b5f50f7ca
mv gistfile1.txt settings.json
mv settings.json ~/.config/Code/User/settings.json

reboot
