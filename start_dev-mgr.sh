#!/bin/bash
FILE="remote_dev-mgr.sh"

BINDIR="/usr/local/bin"
STORE="https://raw.githubusercontent.com/dserfez/tox-lab-net/master"

docker rm -f toxia-mgr

get_file() {
  wget -O "${BINDIR}/${FILE}" "${STORE}/${FILE}"
  chmod +x "${BINDIR}/${FILE}"
}

[ -x "${BINDIR}/${FILE}" ] || get_file

#docker run --rm -ti --name toxia-mgr --net=host --cap-add=NET_ADMIN \
docker run -ti --name toxia-mgr \
  --privileged -p 8081:8081 \
  -e NFS_ROOT="192.168.56.1:/home/davors/dev" \
  -e DBFILE="/var/tmp/settings.db" -v /opt/dev/toxia-mgr:/var/tmp \
  -v ${BINDIR}/remote_dev-mgr.sh:${BINDIR}/remote_dev-mgr.sh \
  toxia-mgr-base ${BINDIR}/remote_dev-mgr.sh
