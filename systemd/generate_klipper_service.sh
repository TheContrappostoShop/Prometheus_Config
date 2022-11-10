#!/usr/bin/env bash
echo """
[Unit]
Description=Klipper 3D Printer Firmware SV1
Documentation=https://www.klipper3d.org/
After=network-online.target
Wants=udev.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=ragwa
RemainAfterExit=yes
WorkingDirectory=$1/klipper
EnvironmentFile=$1/printer_data/systemd/klipper.env
ExecStart=$1/klippy-env/bin/python \$KLIPPER_ARGS
Restart=always
RestartSec=10
""" > /etc/systemd/system/klipper.service
