#!/usr/bin/env bash

# add-copyright-here

set -e

SOURCE_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
INSTALL_DIR="$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)"

mkdir -p ${INSTALL_DIR}/printer_data/config
mkdir -p ${INSTALL_DIR}/printer_data/systemd
mkdir -p ${INSTALL_DIR}/printer_data/logs
mkdir -p ${INSTALL_DIR}/printer_data/comms
mkdir -p ${INSTALL_DIR}/nanodlp


copy_klipper_config () {
    cp -r ${SOURCE_DIR}/klipper_config/* ${INSTALL_DIR}/printer_data/config
}

setup_klipper_service () {
    sudo ${SOURCE_DIR}/systemd/generate_klipper_env.sh ${INSTALL_DIR}
    sudo ${SOURCE_DIR}/systemd/generate_klipper_service.sh ${INSTALL_DIR}
    sudo systemctl daemon-reload
    sudo systemctl enable klipper.service
}

setup_nanodlp_service () {
    sudo ${SOURCE_DIR}/systemd/generate_nanodlp_service.sh ${INSTALL_DIR}
    sudo systemctl daemon-reload
    sudo systemctl enable nanodlp.service
}

setup_openocd_service() {
    if [systemctl is-active --quiet board_reset.service] ; then
        sudo systemctl stop board_reset.service
    fi
    sudo ${SOURCE_DIR}/scripts/openocd_setup.sh ${INSTALL_DIR}
    mkdir -p ${INSTALL_DIR}/printer_data/scripts
    cp ${SOURCE_DIR}/scripts/openocd_board_reset.sh ${INSTALL_DIR}/printer_data/scripts

    sudo ${SOURCE_DIR}/systemd/generate_reset_service.sh ${INSTALL_DIR}
    sudo systemctl daemon-reload
    sudo systemctl enable board_reset.service
    sudo systemctl start board_reset.service
}

stop_running_services() {
    if [systemctl is-active --quiet klipper.service] ; then
        sudo systemctl stop klipper.service
    fi
    if [systemctl is-active --quiet nanodlp.service] ; then
        sudo systemctl stop nanodlp.service
    fi
}

echo "Running apt update..."
sudo apt update

echo "Ensuring git is up to date..."
sudo apt install git -y

echo "Stopping any running NanoDLP or Klipper instances..."
stop_running_services

echo "Installing/Updating Klipper..."
if [ ! -d "${INSTALL_DIR}/klipper" ] ; then
    git clone https://github.com/TheContrappostoShop/klipper.git ${INSTALL_DIR}/klipper
else
    git -C "${INSTALL_DIR}/klipper" pull
fi
echo "Updating Klippy Environment..."
${SOURCE_DIR}/scripts/klipper_setup.sh ${INSTALL_DIR}


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

echo "Setting up Klipper service (may require SUDO)..."
if [ ! -f "/etc/systemd/system/klipper.service" ] ; then
    setup_klipper_service
else
    echo "Klipper service file detected. Do you wish to overrite it?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) setup_klipper_service; break;;
            No ) break;;
        esac
    done
fi

echo "Installing NanoDLP..."
if [ ! -f "${INSTALL_DIR}/nanodlp/nanodlp" ] ; then
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

echo "Install OpenOCD and Prometheus Reset Service? (required for v3.5.1 boards)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) setup_openocd_service; break;;
        No ) break;;
    esac
done

sudo systemctl start klipper.service
sudo systemctl start nanodlp.service
