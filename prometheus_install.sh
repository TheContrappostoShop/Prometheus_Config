#!/usr/bin/env bash

# add-copyright-here

set -e

SOURCE_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
INSTALL_DIR="$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)"

mkdir -p ${INSTALL_DIR}/printer_data/config
mkdir -p ${INSTALL_DIR}/nanodlp


find_serial_device () {
    select serial in /dev/serial/by-id/* ; do
        case $serial in
            *) echo "${serial:-""}"; break;;
        esac
    done
}

copy_klipper_config () {
    cp -r ${SOURCE_DIR}/klipper_config/* ${INSTALL_DIR}/printer_data/config

    if [ -d "/dev/serial/by-id" ] && [ "$(ls -A /dev/serial/by-id)" ]; then
        echo "Select the serial device to use as your MCU (hit enter to leave blank for now [MUST BE ADDED FOR KLIPPER TO WORK])"
        SELECTED_SERIAL="$(find_serial_device)"
    fi
    sed -i "s|SERIAL_DEVICE_LOCATION|${SELECTED_SERIAL:-""}|" ${INSTALL_DIR}/printer_data/config/printer.cfg
}

setup_nanodlp_service () {
    sudo ${SOURCE_DIR}/scripts/generate_nanodlp_service.sh ${INSTALL_DIR}
    sudo systemctl daemon-reload
    sudo systemctl enable nanodlp.service
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
if [ ! -f "/etc/systemd/system/nanodlp.service" ] ; then
    setup_nanodlp_service
else
    echo "NanoDLP service file detected. Do you wish to overrite it?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) setup_nanodlp_service; break;;
            No ) break;;
        esac
    done
fi

# TODO: Remove KIAUH, and actually just install Klipper and Mainsail ourselves
echo "Preparing Klipper Installation and Update Helper..."
if [ ! -d "${INSTALL_DIR}/kiauh" ] ; then
    git clone https://github.com/th33xitus/kiauh.git ${INSTALL_DIR}/kiauh
else
    git -C "${INSTALL_DIR}/kiauh" pull
fi


echo "You will need to use KIAUH to install Klipper and Moonraker, and change "
echo "the Klipper repository to use The Contrapposto Shop's custom modifications."
echo "Would you like to run that now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) setup_nanodlp_service; break;;
        No ) break;;
    esac
done

${INSTALL_DIR}/kiauh/kiauh.sh

sudo systemctl start nanodlp.service
