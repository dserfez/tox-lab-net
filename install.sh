#!/bin/bash
wget -O /home/rancher/cloud-config.yml https://raw.githubusercontent.com/dserfez/tox-lab-net/master/cloud-config.toxia-dev.yml
sudo ros install -d /dev/sda -c /home/rancher/cloud-config.yml
