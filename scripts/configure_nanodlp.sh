#!/usr/bin/env bash

# add-copyright-here

set -e

SOURCE_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
INSTALL_DIR="$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)"

cp -r ${SOURCE_DIR}/nanodlp_db/* ${INSTALL_DIR}/nanodlp/db

if [systemctl is-active --quiet nanodlp.service] ; then
    sudo systemctl restart nanodlp.service
fi