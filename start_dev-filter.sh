#!/bin/bash
FILE="remote_dev-filter.sh"

BINDIR="/opt/bin"
STORE="https://raw.githubusercontent.com/dserfez/tox-lab-net/master"


get_file() {
  wget -O "${BINDIR}/${FILE}" "${STORE}/${FILE}"
  chmod +x "${BINDIR}/${FILE}"
}

[ -x "${BINDIR}/${FILE}" ] || get_file

docker run --rm -ti --name toxia-filter --net=host --cap-add=NET_ADMIN \
  --privileged -p 172.17.42.1:7979:7979 \
  -e NFS_ROOT="192.168.56.1:/home/davors/dev" \
  -v /opt/dev/toxia-filter:/var/tmp \
  -v /opt/bin/remote_dev-filter.sh:/opt/bin/remote_dev-filter.sh \
  toxia-filter-base /opt/bin/remote_dev-filter.sh
