#!/bin/bash
wget -O cloud-config.yml https://raw.githubusercontent.com/dserfez/tox-lab-net/master/cc.yml
sudo coreos-install -d /dev/sda -c cloud-config.yml

