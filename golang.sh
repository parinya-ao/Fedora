cd ~/Downloads
# Fetch the latest stable Go version filename for Linux amd64
filename=$(curl -s https://go.dev/dl/ | grep -oP 'go[0-9.]+.linux-amd64.tar.gz' | head -n1)
if [ -z "$filename" ]; then
    echo "Failed to fetch Go version. Exiting."
    exit 1
fi
url="https://go.dev/dl/$filename"
echo "Downloading $url"
curl -LO "$url"
if [ $? -ne 0 ]; then
    echo "Download failed. Exiting."
    exit 1
fi
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$filename"
if [ $? -ne 0 ]; then
    echo "Extraction failed. Exiting."
    exit 1
fi
rm "$filename"
# Set PATH for current script session
export PATH=$PATH:/usr/local/go/bin
# Add to Fish config if it exists
if [ -d ~/.config/fish ]; then
    echo "set -x PATH \$PATH /usr/local/go/bin" >> ~/.config/fish/config.fish
fi
cd ~/
echo "Go installed successfully. Restart your terminal for Fish."
# Verify installation
source ~/.config/fish/config.fish
go version
echo "Go version: $(go version)"
