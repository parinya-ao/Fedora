#!/usr/bin/env bash

# ฟังก์ชันแสดง progress bar อย่างง่าย (ใช้เครื่องหมาย # เป็นแถบความคืบหน้า)
progress_bar() {
  local progress=$1
  local width=40
  local filled=$(( progress * width / 100 ))
  local empty=$(( width - filled ))
  # สร้าง string สำหรับแท็บความคืบหน้า
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="#"; done
  for ((i=0; i<empty; i++)); do bar+="."; done
  printf "\r%3d%% [%s]" "$progress" "$bar"
}

# ฟังก์ชันถามใช่/ไม่ (yes/no) จากผู้ใช้
ask_yes_no() {
  local prompt="$1"
  while true; do
    read -rp "$prompt (y/n): " ans
    case "$ans" in
      [Yy]*) return 0 ;;   # yes -> รีเทิร์น 0 (true)
      [Nn]*) return 1 ;;   # no  -> รีเทิร์น 1 (false)
      *) echo "กรุณาพิมพ์ y หรือ n." ;;
    esac
  done
}

# 1. ตรวจสอบสถาปัตยกรรมของระบบ
echo "🔍 ตรวจสอบสถาปัตยกรรม CPU..."
arch=""
uname_m=$(uname -m)
case "$uname_m" in
  x86_64) arch="amd64" ;;
  aarch64) arch="arm64" ;;
  armv7l) arch="armv6l" ;;  # Go ใช้คำว่า armv6l สำหรับ ARM 32-bit
  *)
    echo "❗ สถาปัตยกรรม $uname_m ไม่รองรับโดยสคริปต์นี้"
    echo "โปรดแก้ไขสคริปต์เพื่อเพิ่มการรองรับสถาปัตยกรรมนี้"
    exit 1
    ;;
esac

# 2. ค้นหา URL ไฟล์ Go เวอร์ชันล่าสุดที่ตรงกับสถาปัตยกรรม
echo "🌐 กำลังค้นหาเวอร์ชันล่าสุดของ Go สำหรับ linux-$arch..."
download_page="https://go.dev/dl/"
# ดึงชื่อไฟล์ล่าสุดที่เป็น goX.Y.Z.linux-ARCH.tar.gz จากหน้าเว็บ
filename=$(curl -s "$download_page" | grep -oE "go[0-9]{1,2}\.[0-9]{1,2}(\.[0-9]{1,2})?\.linux-$arch\.tar\.gz" | head -n1)
if [[ -z "$filename" ]]; then
  echo "❌ ไม่สามารถตรวจสอบชื่อไฟล์ดาวน์โหลดล่าสุดสำหรับ $arch ได้"
  echo "โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ตหรือระบุเวอร์ชันเอง"
  exit 1
fi
url="https://go.dev/dl/$filename"
echo "⬇️  เตรียมดาวน์โหลดไฟล์ $filename"
echo "    จาก $url"

# 3. ดาวน์โหลดไฟล์ด้วยความคืบหน้า
echo "📥 กำลังดาวน์โหลด Go..."
tempfile="$HOME/Downloads/$filename"  # ดาวน์โหลดที่ ~/Downloads
rm -f "$tempfile"
# ดาวน์โหลดในพื้นหลังและแสดง progress bar แบบสุ่ม
curl -L "$url" -o "$tempfile" --silent &
curl_pid=$!
# แสดง progress bar แบบสุ่มในขณะที่ดาวน์โหลด
current=0
while kill -0 $curl_pid 2>/dev/null; do
  # สุ่มค่า progress เพิ่ม 1-15 ต่อครั้ง
  increment=$((RANDOM % 15 + 1))
  current=$((current + increment))
  # จำกัดไม่ให้เกิน 99 ก่อนดาวน์โหลดเสร็จ
  if [ $current -gt 99 ]; then
    current=99
  fi
  progress_bar "$current"
  sleep 0.1
done
# รอให้ curl เสร็จสมบูรณ์
wait $curl_pid
curl_status=$?
# แสดง 100% เมื่อเสร็จสิ้น
progress_bar 100
printf "\n"  # ขึ้นบรรทัดใหม่หลังดาวน์โหลดเสร็จ

# ตรวจสอบว่าดาวน์โหลดสำเร็จ (ไฟล์ต้องมีอยู่จริง)
if [ $curl_status -ne 0 ] || [[ ! -f "$tempfile" ]]; then
  echo "❌ ดาวน์โหลดล้มเหลวหรือหาไฟล์ที่ดาวน์โหลดไม่พบ"
  exit 1
fi

# 4. ถามผู้ใช้ว่าจะลบ /usr/local/go เดิมหรือไม่ (ถ้ามี)
if [[ -d "/usr/local/go" ]]; then
  if ask_yes_no "พบโฟลเดอร์ /usr/local/go (Go เวอร์ชันก่อนหน้า) ต้องการลบเพื่อแทนที่ด้วยเวอร์ชันใหม่หรือไม่?"; then
    echo "🔁 กำลังลบ /usr/local/go เก่า..."
    sudo rm -rf /usr/local/go || { echo "❌ ลบโฟลเดอร์เก่าไม่สำเร็จ"; exit 1; }
  else
    echo "⚠️  เก็บโฟลเดอร์ /usr/local/go เดิมไว้ (จะติดตั้งซ้อนทับลงไป)"
  fi
fi

# 5. แตกไฟล์ tar ไปยัง /usr/local
echo "📦 กำลังติดตั้ง (แตกไฟล์) ไปที่ /usr/local (ต้องใช้ sudo)..."
sudo tar -C /usr/local -xzf "$tempfile" || { echo "❌ การแตกไฟล์ล้มเหลว"; exit 1; }

# 6. ลบไฟล์ tar ชั่วคราว
rm -f "$tempfile"

# 7. เพิ่ม PATH และตัวแปร GOPATH/GOBIN ใน config ของ shell
echo "🔧 กำลังตั้งค่าตัวแปรสภาพแวดล้อมในไฟล์ config ของ shell..."
user_shell=""
# ตรวจสอบจากตัวแปร SHELL (shell หลักของ user) ว่าเป็น fish, zsh หรือ bash
case "$(basename "$SHELL")" in
  fish) user_shell="fish" ;;
  zsh) user_shell="zsh" ;;
  bash) user_shell="bash" ;;
  *) user_shell="" ;;
esac

# ไฟล์ config ตามชนิด shell
fish_config="$HOME/.config/fish/config.fish"
bash_config="$HOME/.bashrc"
zsh_config="$HOME/.zshrc"

# บรรทัดที่จะเพิ่ม
path_line_export='export PATH=$PATH:/usr/local/go/bin'
gopath_line_export='export GOPATH=$HOME/go'
gobin_line_export='export GOBIN=$HOME/go/bin'
path_line_fish='set -gx PATH /usr/local/go/bin $PATH'
gopath_line_fish='set -gx GOPATH $HOME/go'
gobin_line_fish='set -gx GOBIN $GOPATH/bin'

if [[ "$user_shell" == "fish" ]]; then
  # สร้างโฟลเดอร์ config fish ถ้ายังไม่มี
  mkdir -p "$(dirname "$fish_config")"
  # เพิ่มบรรทัดใน config.fish ถ้ายังไม่มี
  if [[ ! -f "$fish_config" ]] || ! grep -Fq "/usr/local/go/bin" "$fish_config"; then
    echo -e "\n# Go (added by install script)" >> "$fish_config"
    echo "$path_line_fish" >> "$fish_config"
    echo "$gopath_line_fish" >> "$fish_config"
    echo "$gobin_line_fish" >> "$fish_config"
    echo "✅ เพิ่มการตั้งค่า PATH/GOPATH ใน $fish_config แล้ว"
  else
    echo "ℹ️ พบการตั้งค่า /usr/local/go/bin ใน $fish_config อยู่แล้ว (ข้ามขั้นตอนเพิ่ม PATH)"
  fi
elif [[ "$user_shell" == "zsh" ]]; then
  if [[ ! -f "$zsh_config" ]] || ! grep -Fq "/usr/local/go/bin" "$zsh_config"; then
    echo -e "\n# Go (added by install script)" >> "$zsh_config"
    echo "$path_line_export" >> "$zsh_config"
    echo "$gopath_line_export" >> "$zsh_config"
    echo "$gobin_line_export" >> "$zsh_config"
    echo "✅ เพิ่มการตั้งค่า PATH/GOPATH ใน $zsh_config แล้ว"
  else
    echo "ℹ️ พบการตั้งค่า /usr/local/go/bin ใน $zsh_config อยู่แล้ว"
  fi
elif [[ "$user_shell" == "bash" ]]; then
  if [[ ! -f "$bash_config" ]] || ! grep -Fq "/usr/local/go/bin" "$bash_config"; then
    echo -e "\n# Go (added by install script)" >> "$bash_config"
    echo "$path_line_export" >> "$bash_config"
    echo "$gopath_line_export" >> "$bash_config"
    echo "$gobin_line_export" >> "$bash_config"
    echo "✅ เพิ่มการตั้งค่า PATH/GOPATH ใน $bash_config แล้ว"
  else
    echo "ℹ️ พบการตั้งค่า /usr/local/go/bin ใน $bash_config อยู่แล้ว"
  fi
else
  # ถ้าตรวจไม่พบ shell ที่รองรับ
  echo "⚠️ ไม่สามารถตรวจจับ shell ของผู้ใช้ได้ หรือ shell ไม่ใช่ bash/zsh/fish"
  echo "โปรดตรวจสอบไฟล์ config shell ของคุณว่ามีการเพิ่ม PATH /usr/local/go/bin แล้วหรือไม่"
fi

# สร้างโฟลเดอร์ $HOME/go/bin ถ้ายังไม่มี (สำหรับ GOBIN)
mkdir -p "$HOME/go/bin"

# 8. โหลดไฟล์ config (สำหรับ shell ปัจจุบัน) เพื่อให้ค่าที่เพิ่มมีผลทันที
if [[ "$user_shell" == "fish" && -f "$fish_config" ]]; then
  echo "🔁 กำลังโหลด $fish_config เพื่อให้ค่า PATH มีผล..."
  # เรียก fish เพื่อ source config.fish
  fish -c "source $fish_config"
elif [[ "$user_shell" == "zsh" && -f "$zsh_config" ]]; then
  echo "🔁 กำลังโหลด $zsh_config เพื่อให้ค่า PATH มีผล..."
  # โหลด config zsh ในเชลล์ย่อย
  zsh -c "source $zsh_config"
elif [[ "$user_shell" == "bash" && -f "$bash_config" ]]; then
  echo "🔁 กำลังโหลด $bash_config เพื่อให้ค่า PATH มีผล..."
  # ใช้ source ใน subshell bash
  source "$bash_config"
fi

# 9. ตรวจสอบเวอร์ชันของ Go ที่ติดตั้ง
if command -v go >/dev/null 2>&1; then
  go_ver=$(go version)
  echo "🎉 การติดตั้งเสร็จสิ้น! ติดตั้ง $go_ver เรียบร้อย"
else
  echo "❗ ไม่พบคำสั่ง 'go' ใน PATH โปรดลองเปิดเทอร์มินัลใหม่หรือรัน 'source' ไฟล์ config"
fi
