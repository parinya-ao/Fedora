# Hardware development libraries and tools
sudo dnf install -y \
  arduino arduino-core avrdude dfu-util openocd \
  raspberrypi-tools raspberrypi-vc-libs raspberrypi-firmware \
  libgpiod libgpiod-devel wiringpi wiringpi-devel \
  i2c-tools spi-tools libi2c-devel libusb-devel \
  libftdi-devel libserialport-devel \
  fpga-toolchain-quartus fpga-toolchain-icestorm \
  verilator yosys nextpnr \
  platformio platformio-core \
  esptool pyusb \
  libmraa libmraa-devel libupm libupm-devel
