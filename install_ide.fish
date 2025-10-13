
set download_url (curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -oP '"linux":\{"link":"https://[^"]+\.tar\.gz"' | grep -oP 'https://[^"]+')

curl -L -o jetbrains-toolbox.tar.gz $download_url

tar -xzf jetbrains-toolbox-*.tar.gz

cd jetbrains-toolbox*/bin
./jetbrains-toolbox

curl -f https://zed.dev/install.sh | sh
