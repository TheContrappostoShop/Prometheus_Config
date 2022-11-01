#!/usr/bin/env bash

# add-copyright-here

set -e

SOURCE_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
INSTALL_DIR="$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)"

mkdir -p ${INSTALL_DIR}/printer_data/config
mkdir -p ${INSTALL_DIR}/nanodlp

# TODO: Modify printer.cfg mcu location to match connected serial device
cp -r ${SOURCE_DIR}/klipper_config/* ${INSTALL_DIR}/printer_data/config

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

cp -r ${SOURCE_DIR}/nanodlp_db/* ${INSTALL_DIR}/nanodlp/db

sudo cp ${SOURCE_DIR}/service/nanodlp.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable nanodlp.service

if [ ! -d "${INSTALL_DIR}/kiauh" ] ; then
    git clone https://github.com/th33xitus/kiauh.git ${INSTALL_DIR}/kiauh
else
    git -C "${INSTALL_DIR}/kiauh" pull
fi

cp ${SOURCE_DIR}/klipper_repos.txt ${INSTALL_DIR}/kiauh/

${INSTALL_DIR}/kiauh/kiauh.sh

sudo systemctl start nanodlp.service
