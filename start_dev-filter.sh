#!/bin/bash
FILE="remote_dev-filter.sh"
OPTIONS="-d"
BINDIR="/usr/local/bin"
STORE="https://raw.githubusercontent.com/dserfez/tox-lab-net/master"

docker rm -f toxia-filter

get_file() {
  wget -O "${BINDIR}/${FILE}" "${STORE}/${FILE}"
  chmod +x "${BINDIR}/${FILE}"
}

[ -x "${BINDIR}/${FILE}" ] || get_file

docker run "${OPTIONS}" --name toxia-filter --net=host --cap-add=NET_ADMIN \
  --privileged -p 172.17.42.1:7979:7979 \
  -e NFS_ROOT="192.168.56.1:/home/davors/dev" \
  -v /opt/dev/toxia-filter:/var/tmp \
  -v ${BINDIR}/remote_dev-filter.sh:${BINDIR}/remote_dev-filter.sh \
  toxia-filter-base ${BINDIR}/remote_dev-filter.sh
