#!/bin/sh
mknod /dev/loop0 b 7 0
rpcbind
cd /
mount "${NFS_ROOT}/toxia-filter" /opt/toxia-filter
cd /opt/toxia-filter
/bin/bash
