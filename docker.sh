# filepath: /home/parinya/workspace/Fedora/docker_fedora.sh
#!/bin/bash

# Alternative Docker installation using Fedora repositories
echo "Installing Docker using Fedora native repositories..."

# Remove old Docker packages if any
sudo dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine 2>/dev/null || true

sudo dnf install -y docker docker-compose podman-docker
sudo systemctl enable --now docker
sudo systemctl start docker
sudo usermod -aG docker $USER
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USER
sudo systemctl status docker --no-pager
echo "Docker version:"
sudo docker --version
echo "Docker Compose version:"
sudo docker-compose --version 2>/dev/null || echo "Docker Compose not available, but docker compose plugin should work"

echo "To use Docker without sudo, logout and login again."
