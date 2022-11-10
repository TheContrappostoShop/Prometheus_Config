# Prometheus Config
This repository contains all of the configuration files needed to run Klipper 
and NanoDLP together on the Prometheus MSLA printer, as well as a companion 
installation script to get everything set up.

> :warning: **These files, and the included installation script, are a work in 
progress. Exercise caution when using them for the first time.**

## Instructions

### Scripted Install

Ensure you have git installed on your desired host machine, and execute the
following commands to utilize our installation script:
```
cd ~
git clone https://github.com/TheContrappostoShop/Prometheus_Config.git
./Prometheus_Config/prometheus_install.sh
```

This script will install NanoDLP as well Klipper and all of its configuration 
files. 

To install the NanoDLP configuration, you will need to import it from 
within NanoDLP. 

First, go to the NanoDLP web UI, and select the "NanoDLP" distribution, to finish
setup--it should be the first option presented. After you select it, NanoDLP will
restart, and you will need to refresh the page.

Then, go to System->Tools->Import Machine Settings, and paste the following link
into the "Download Machine Settings" field:
```
https://raw.githubusercontent.com/TheContrappostoShop/Prometheus_Config/main/nanodlp_db/machine.json
```
This will import the Prometheus machine settings, and your device will be ready
to go.

### Manual Install

If you do not wish you use the supplied script, you may simply clone the 
repository, and copy the files to their destinations manually. See below for a 
detailed listing of the included files and their proper destinations (Coming 
soon!).