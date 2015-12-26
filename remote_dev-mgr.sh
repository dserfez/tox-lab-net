#!/bin/sh
rpcbind
cd /
mount "${NFS_ROOT}/toxia-mgr" /opt/toxia-mgr
cd /opt/toxia-mgr
/bin/sh
