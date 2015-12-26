#!/bin/sh
rpcbind
cd /
mount "${NFS_ROOT}/toxia-filter" /opt/toxia-filter
cd /opt/toxia-filter
/bin/bash
