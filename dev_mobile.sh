# dev mobile
# flutter
curl -fsSL https://fvm.app/install.sh | bash

# please view doc https://fvm.app/documentation/getting-started/configuration
source ~/.config/fish/config.fish
fvm install stable
fvm list
fvm global stable
fvm flutter doctor
fvm dart pub get
