sudo tee /etc/dnf/dnf.conf << "EOF
max_parallel_downloads=15
fastestmirror=True
deltarpm=True
EOF
