#!/bin/sh
rpcbind
cd /
mount "${NFS_ROOT}/toxia-bgp" /opt/toxia-bgp
cd /opt/toxia-bgp
/bin/sh
