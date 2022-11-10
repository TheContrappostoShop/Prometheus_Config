#!/usr/bin/env bash

INSTALL_DIR=$1

# Install prerequisites
sudo apt install automake autoconf build-essential texinfo libtool libftdi-dev libusb-1.0-0-dev gdb-multiarch

git clone https://github.com/raspberrypi/openocd.git ${INSTALL_DIR}/openocd --recursive --branch rp2040 --depth=1

cd openocd

./bootstrap

./configure --enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio

make -j4

sudo make install