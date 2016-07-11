#!/bin/sh
rpcbind
cd /
mount -t nfs4 -o proto=tcp,port=2049 "${NFS_ROOT}/toxia-mgr" /opt/toxia-mgr
cd /opt/toxia-mgr
/bin/sh
