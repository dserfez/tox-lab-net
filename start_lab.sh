#!/bin/bash
#
# Launch network of routers 
#

### Config section
# Subscribers interface
: ${SUBS_IFACE:=enp0s9}
# Toxia facing interface
: ${TOXIA_IFACE:=enp0s8}
# Public/Internet facing interface
PUBLIC_IFACE="$(ip r | grep ^default | awk '{print $5}')"
### END of Config section

ROUTER_NAMES="subs_pe isp_peering pr dc_pe"

BRIDGES="p-dcpe p-isp p-subspe"

#DOCKER_IP="172.17.42.1"
DOCKER_IP=$(ip -o -f inet a s dev docker0 | awk '{print $4}' | cut -d"/" -f1)
FEATURE="-d"

workdir="$(cd $( dirname $( readlink -f con $0) ) && pwd)"

if [ ! -x /opt/bin/pipework ] ; then
  wget -O /opt/bin/pipework https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework
  chmod +x /opt/bin/pipework
fi

#pipework="sudo $workdir/pipework --wait"
pipework="sudo pipework"

# If router config files don't exist, create them
# (otherwise the router process wouldn't start)
for DIR in $ROUTER_NAMES ; do
  DIRNAME="/opt/lab/${DIR}_conf"
  [ -d ${DIRNAME} ] || mkdir ${DIRNAME}
  [ -e ${DIRNAME}/bgpd.conf ] || touch ${DIRNAME}/bgpd.conf
  [ -e ${DIRNAME}/zebra.conf ] || touch ${DIRNAME}/zebra.conf
done

# Helper for starting router containers
start_container() {
  docker run --cap-add=NET_ADMIN --net=none $FEATURE \
    --name $CONTAINER -e "HOSTNAME=$CONTAINER" \
    -v "/opt/lab/$CONTAINER"_conf/:/etc/quagga/ \
     cycomf/docker-labrouter
}

# Create internal networks
for BRIDGE in $BRIDGES ; do
  IS_IT_THERE=$(brctl show | grep ^$BRIDGE | awk '{print $1}'  )
  if [[ $BRIDGE != $IS_IT_THERE ]] ; then
    sudo brctl addbr $BRIDGE
  fi
done

# Start router containmers
for CONTAINER in $ROUTER_NAMES ; do
  docker kill $CONTAINER
  docker rm $CONTAINER
  start_container
done

# ISP peering router network interfaces
$pipework p-isp -i eth0 isp_peering 0.0.0.0/0
$pipework $PUBLIC_IFACE -i eth1 isp_peering 0.0.0.0/0

# DC_PE router network interfaces
$pipework p-dcpe -i eth0 dc_pe 0.0.0.0/0
$pipework $TOXIA_IFACE -i eth1 dc_pe 0.0.0.0/0

# SUBS_PE router network interfaces
$pipework p-subspe -i eth0 subs_pe 0.0.0.0/0
$pipework $SUBS_IFACE -i eth1 subs_pe 0.0.0.0/0

# P router network interfaces
$pipework p-isp -i eth0 pr 0.0.0.0/0
$pipework p-dcpe -i eth1 pr 0.0.0.0/0
$pipework p-subspe -i eth2 pr 0.0.0.0/0

