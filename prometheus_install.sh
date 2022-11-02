#!/usr/bin/env bash

# add-copyright-here

set -e

SOURCE_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
INSTALL_DIR="$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)"

mkdir -p ${INSTALL_DIR}/printer_data/config
mkdir -p ${INSTALL_DIR}/nanodlp

copy_klipper_config () {
    cp -r ${SOURCE_DIR}/klipper_config/* ${INSTALL_DIR}/printer_data/config

    sed -i "s/SERIAL_DEVICE_LOCATION/${find_Serial_device}/" ${INSTALL_DIR}/printer_data/config/printer.cfg
} 

find_serial_device () {
    echo "Select the serial device to use for as your MCU (hit enter to leave blank)"
    select serial in */dev/serial/by-id/* ; do
        case $serial
            *) return ${serial:-""}; break;;
        ecas
    done
}

echo "Copying configuration files..."
if [ ! "$(ls -A ${INSTALL_DIR}/printer_data/config)" ]; then
    copy_klipper_config
else
    echo "Klipper configuration files detected. Do you wish to overrite them?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) copy_klipper_config; break;;
            No ) break;;
        esac
    done
fi

echo "Installing NanoDLP..."
if [ ! -d "${INSTALL_DIR}/nanodlp" ] ; then
    wget https://www.nanodlp.com/download/nanodlp.linux.arm64.stable.tar.gz -O - | tar -xz -C ${INSTALL_DIR}/nanodlp
else
    echo "NanoDLP already detected--re-install?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) wget https://www.nanodlp.com/download/nanodlp.linux.arm64.stable.tar.gz -O - | tar -xz -C ${INSTALL_DIR}/nanodlp; break;;
            No ) break;;
        esac
    done
fi

echo "Configuring NanoDLP..."
if [ ! "$(ls -A ${INSTALL_DIR}/nanodlp/db)" ]; then
    cp -r ${SOURCE_DIR}/nanodlp_db/* ${INSTALL_DIR}/nanodlp/db
else
    echo "NanoDLP configuration files detected. Do you wish to overrite them?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) cp -r ${SOURCE_DIR}/nanodlp_db/* ${INSTALL_DIR}/nanodlp/db; break;;
            No ) break;;
        esac
    done
fi

echo "Setting up NanoDLP service (may require SUDO)..."
sudo ${SOURCE_DIR}/scripts/generate_nanodlp_service.sh ${INSTALL_DIR}
sudo systemctl daemon-reload
sudo systemctl enable nanodlp.service

echo "Cloning Klipper Installation and Update Helper..."
if [ ! -d "${INSTALL_DIR}/kiauh" ] ; then
    git clone https://github.com/th33xitus/kiauh.git ${INSTALL_DIR}/kiauh
else
    git -C "${INSTALL_DIR}/kiauh" pull
fi

# TODO: Remove KIAUH, and actually just install Klipper and Mainsail ourselves
cp ${SOURCE_DIR}/klipper_repos.txt ${INSTALL_DIR}/kiauh/

${INSTALL_DIR}/kiauh/kiauh.sh

sudo systemctl start nanodlp.service
