#!/usr/bin/env bash

# add-copyright-here

set -e

SOURCE_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
INSTALL_DIR = "$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)"

mkdir -p ${INSTALL_DIR}/printer_data/config
mkdir -p ${INSTALL_DIR}/nanodlp

# TODO: Modify printer.cfg mcu location to match connected serial device
cp -r ${SOURCE_DIR}/klipper_config/* ${INSTALL_DIR}/printer_data/config

wget https://www.nanodlp.com/download/nanodlp.linux.arm64.stable.tar.gz -O - | tar -xz -C ${INSTALL_DIR}/nanodlp

cp -r ${SOURCE_DIR}/nanodlp_db/* ${INSTALL_DIR}/nanodlp/db

cp ${SOURCE_DIR}/service/nanodlp.service /etc/systemd/system/

# TODO: Ensure script is run with sudo, else this will fail
systemctl daemon-reload
systemctl enable nanodlp.service

if [ ! -d "${INSTALL_DIR}/kiauh" ] ; then
    git clone https://github.com/th33xitus/kiauh.git ${INSTALL_DIR}/kiauh
else
    git -C "${INSTALL_DIR}/kiauh" pull
fi

cp ${SOURCE_DIR}/klipper_repos.txt ${INSTALL_DIR}/kiauh/

${INSTALL_DIR}/kiauh/kiauh.sh

systemctl start nanodlp.service
