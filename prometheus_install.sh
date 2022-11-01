#!/usr/bin/env bash

# add-copyright-here

set -e

SOURCE_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"

mkdir -p ${HOME}/printer_data/config
mkdir -p ${HOME}/nanodlp

# TODO: Modify printer.cfg mcu location to match connected serial device
cp -r ${SOURCE_DIR}/klipper_config/* ${HOME}/printer_data/config

wget https://www.nanodlp.com/download/nanodlp.linux.arm64.stable.tar.gz -O - | tar -xz -C ${HOME}/nanodlp

cp -r ${SOURCE_DIR}/nanodlp_db/* ${HOME}/nanodlp/db

cp ${SOURCE_DIR}/service/nanodlp.service /etc/systemd/system/

# TODO: Ensure script is run with sudo, else this will fail
systemctl daemon-reload
systemctl enable nanodlp.service

if [ ! -d "${HOME}/kiauh" ] ; then
    git clone https://github.com/th33xitus/kiauh.git ${HOME}/kiauh
else
    git -C "${HOME}/kiauh" pull
fi

cp ${SOURCE_DIR}/klipper_repos.txt ${HOME}/kiauh/

./${HOME}/kiauh/kiauh.sh

systemctl start nanodlp.service
