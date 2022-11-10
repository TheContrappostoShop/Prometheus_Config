#!/usr/bin/env bash
echo """
KLIPPER_ARGS=\"$1/klipper/klippy/klippy.py $1/printer_data/config/printer.cfg -I $1/printer_data/comms/klippy.serial -l $1/printer_data/logs/klippy.log -a $1/printer_data/comms/klippy.sock\"
""" > $1/printer_data/systemd/klipper.env
