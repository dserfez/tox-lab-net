#!/bin/bash

#TIMESTAMP=$(date +"%Y-%m-%d_%s")
TIMESTAMP=$(date +"%s")

tar czvf lab_${TIMESTAMP}.tar.gz /opt/lab /opt/bin


