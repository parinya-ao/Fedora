# 1.download from this for linux only
https://www.jetbrains.com/toolbox-app/download/download-thanks.html?platform=linux

# 2. extract file
tar -xzf jetbrains-toolbox-*.tar.gz --one-top-level=jetbrains --strip-components 1

# 3. move file  jetbrains-toolbox to  ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox
mv ...   ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox

# 4. create destop shortcut
sudo cp ~/.local/share/applications/jetbrains-toolbox.desktop ~/Desktop/
gio set ~/Desktop/jetbrains-toolbox.desktop metadata::trusted true
sudo chmod a+x ~/Desktop/jetbrains-toolbox.desktop

