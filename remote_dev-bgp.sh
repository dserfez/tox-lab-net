#!/bin/sh
rpcbind
cd /
mount -t nfs4 -o proto=tcp,port=2049 "${NFS_ROOT}/toxia-bgp" /opt/toxia-bgp
cd /opt/toxia-bgp
/bin/sh
