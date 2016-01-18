#!/bin/bash
FILE="remote_dev-bgp.sh"
#OPTIONS="-d"
OPTIONS="--rm -ti"
BINDIR="/usr/local/bin"
STORE="https://raw.githubusercontent.com/dserfez/tox-lab-net/master"

: ${NFS_ROOT:=192.168.56.1}
: ${DEV_ROOT:=/home/${USER}/dev}

docker rm -f toxia-bgp

get_file() {
  wget -O "${BINDIR}/${FILE}" "${STORE}/${FILE}"
  chmod +x "${BINDIR}/${FILE}"
}

[ -x "${BINDIR}/${FILE}" ] || get_file

docker run ${OPTIONS} --name toxia-bgp --net=host --cap-add=NET_ADMIN \
  --privileged -p 172.17.42.1:4567:4567 \
  -e NFS_ROOT="${NFS_ROOT}:${DEV_ROOT}" \
  -v /opt/toxia/config/bgp:/etc/quagga \
  -v ${BINDIR}/remote_dev-bgp.sh:${BINDIR}/remote_dev-bgp.sh \
  toxia-bgp-base ${BINDIR}/remote_dev-bgp.sh

#  -v /opt/dev/toxia-bgp:/var/tmp \
