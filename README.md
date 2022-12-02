# Prometheus Config
This repository contains all of the configuration files needed to run Klipper 
and NanoDLP together on the Prometheus MSLA printer.

> :warning: **These files are a work in progress. Exercise caution when using 
them for the first time.**

## Easy Install

For a fully configured Raspberry Pi Installation, see the PrometheusOS image 
available here: https://github.com/TheContrappostoShop/PrometheusOS

## Scripted Install

## Manual Install

If you do not wish to use the custom RPi image, you can set up 
[Klipper](https://www.klipper3d.org/) and [NanoDLP](https://www.nanodlp.com/)
yourself, and copy these configuration files to your machine manually. See below
for a description of the included files and their proper destinations.

> Note: for best results, only use these config files with the 
[Contrapposto Klipper Fork](https://github.com/TheContrappostoShop/klipper)

### File Tree
```markdown
├── klipper
│   ├── .config
│   └── config
│       ├── fdm_module.cfg
│       ├── mainsail.cfg
│       └── printer.cfg
└── nanodlp
    ├── machine.json
    ├── profiles.json
    └── resins.csv
```

#### klipper/.config
This is the klipper make configuration file for the Prometheus board firmware, 
in the event that you need to recompile it yourself and reflash your board. It 
should be placed in the root of your klipper directory.

#### klipper/config/
This directory holds the klipper cfg files for the Prometheus board, and the
optional FDM expansion module.
They should be placed in your klipper config directory (usually either `~`, or `~/printer_data/config`).

#### nanodlp/
This directory holds the NanoDLP configuration files for the Prometheus MSLA--
both the machine configuration, a generic printing profile, and the default 
resin list. These should be placed in the NanoDLP db directory (usually either 
`~/nanodlp/db` or `~/printer/db` depending on your install).

They can also be installed via the `System->Tools->Import Machine Settings` menu
in the NanoDLP web interface. 
