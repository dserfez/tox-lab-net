#!/bin/bash
wget -O /home/core/cloud-config.yml https://raw.githubusercontent.com/dserfez/tox-lab-net/master/cc.yml
sudo coreos-install -d /dev/sda -c /home/core/cloud-config.yml

