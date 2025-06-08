#!/usr/bin/fish

# ติดตั้ง Docker บน Fedora Linux
# สคริปต์นี้จะติดตั้ง Docker CE และกำหนดค่าให้พร้อมใช้งาน

# ขั้นตอนที่ 1: เพิ่ม repository ของ Docker
# ติดตั้ง dnf-plugins-core เพื่อให้สามารถจัดการ repository ได้
sudo dnf -y install dnf-plugins-core

# เพิ่ม official Docker repository สำหรับ Fedora
# repository นี้จะให้เราดาวน์โหลด Docker CE ได้
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# ขั้นตอนที่ 2: ติดตั้ง Docker และ components ที่จำเป็น
# docker-ce = Docker Community Edition (เวอร์ชันฟรี)
# docker-ce-cli = Command Line Interface สำหรับควบคุม Docker
# containerd.io = Container runtime ที่ Docker ใช้
# docker-buildx-plugin = Plugin สำหรับ build images แบบขั้นสูง
# docker-compose-plugin = Plugin สำหรับจัดการ multi-container applications
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# ขั้นตอนที่ 3: เริ่มต้นและเปิดใช้งาน Docker service
# enable --now = ทำให้ Docker เริ่มทำงานทันทีและเริ่มทำงานอัตโนมัติเมื่อเปิดเครื่อง
sudo systemctl enable --now docker

# start = เริ่มต้น Docker service (กรณีที่ยังไม่ทำงาน)
sudo systemctl start docker

# ขั้นตอนที่ 4: กำหนดสิทธิ์ให้ user สามารถใช้ Docker ได้โดยไม่ต้อง sudo
# เพิ่ม user ปัจจุบันเข้าใน docker group
sudo usermod -aG docker $USER

# เปลี่ยน group ของ session ปัจจุบันเป็น docker group
# ทำให้ไม่ต้อง logout/login ใหม่
newgrp docker