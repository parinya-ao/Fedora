sudo dnf install zram -y

sudo tee /usr/bin/systemd/zram-generator.conf << "EOF"
[zram0]
zram-fraction = 1
compression-algorithm = lz4
EOF

sudo tee /etc/sysctl.conf << "EOF"
vm.swappiness = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.nr_hugepages = 1024
EOF

sudo sysctl --system

sudo modprobe zram
