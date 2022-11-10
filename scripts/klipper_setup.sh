#!/usr/bin/env bash

INSTALL_DIR=$1

sudo apt install virtualenv python-dev libffi-dev build-essential libncurses-dev libusb-dev avrdude gcc-avr binutils-avr avr-libc stm32flash libnewlib-arm-none-eabi libusb-1.0 pkg-config -y

# Create virtualenv if it doesn't already exist
[ ! -d ${INSTALL_DIR}/klippy_env ] && virtualenv -p python3 ${INSTALL_DIR}/klippy_env

# Install/update dependencies
${INSTALL_DIR}/klippy_env/bin/pip install -r ${INSTALL_DIR}/klipper/scripts/klippy-requirements.txt