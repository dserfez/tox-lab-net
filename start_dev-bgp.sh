#!/bin/bash
FILE="remote_dev-bgp.sh"

BINDIR="/opt/bin"
STORE="https://raw.githubusercontent.com/dserfez/tox-lab-net/master"


get_file() {
  wget -O "${BINDIR}/${FILE}" "${STORE}/${FILE}"
  chmod +x "${BINDIR}/${FILE}"
}

[ -x "${BINDIR}/${FILE}" ] || get_file

docker run --rm -ti --name toxia-bgp --net=host --cap-add=NET_ADMIN \
  --privileged -p 172.17.42.1:4567:4567 \
  -e NFS_ROOT="192.168.56.1:/home/davors/dev" \
  -v /opt/dev/toxia-bgp:/var/tmp \
  -v /opt/bin/remote_dev-bgp.sh:/opt/bin/remote_dev-bgp.sh \
  toxia-bgp-base /opt/bin/remote_dev-bgp.sh
