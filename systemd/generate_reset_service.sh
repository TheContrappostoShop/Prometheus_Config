#!/usr/bin/env bash
echo """
[Unit]
Description=Force the RP2040 to reset its usb connection
Before=klipper.service

[Service]
ExecStart=$1/printer_data/scripts/openocd_reset.sh
RemainAfterExit=true
Type=oneshot

[Install]
WantedBy=multi-user.target
""" > /etc/systemd/system/board_reset.service

