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
#PUBLIC_IFACE="$(ip r | grep ^default | awk '{print $5}')"
PUBLIC_IFACE="docker0"

# IP for the public facing interface
PUBLIC_IP="172.17.42.10/24"

# IP for the interface facing toxia
TOXIA_IP="192.168.56.8/24"

# IP for the interface facing subscribers
SUBS_IP="192.168.9.9/24"

### END of Config section

ROUTER_NAMES="subs_pe isp_peering pr dc_pe"

BRIDGES="br_p-dcpe br_p-isp br_p-subspe br_toxdata br_subs"

#DOCKER_IP="172.17.42.1"
DOCKER_IP=$(ip -o -f inet a s dev docker0 | awk '{print $4}' | cut -d"/" -f1)
FEATURE="-d"

workdir="$(cd $( dirname $( readlink -f con $0) ) && pwd)"

if [ ! -d /opt/bin ] ; then
  sudo mkdir -p /opt/bin
fi

if [ ! -x /opt/bin/pipework ] ; then
  sudo wget -O /opt/bin/pipework https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework
  sudo chmod +x /opt/bin/pipework
fi

#pipework="sudo $workdir/pipework --wait"
pipework="sudo pipework"

# If router config files don't exist, create them
# (otherwise the router process wouldn't start)
for DIR in $ROUTER_NAMES ; do
  DIRNAME="/opt/lab/${DIR}_conf"
  [ -d ${DIRNAME} ] || sudo mkdir -p ${DIRNAME}
  #[ -e ${DIRNAME}/bgpd.conf ] || sudo touch ${DIRNAME}/bgpd.conf
  #[ -e ${DIRNAME}/zebra.conf ] || sudo touch ${DIRNAME}/zebra.conf
  [ -e ${DIRNAME}/bgpd.conf ] || sudo wget -O ${DIRNAME}/bgpd.conf https://raw.githubusercontent.com/dserfez/tox-lab-net/master/${DIR}_conf/bgpd.conf
  [ -e ${DIRNAME}/bgpd.conf ] || sudo wget -O ${DIRNAME}/zebra.conf https://raw.githubusercontent.com/dserfez/tox-lab-net/master/${DIR}_conf/zebra.conf
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
    sudo brctl addbr "${BRIDGE}"
  fi
done

# Start router containmers
for CONTAINER in $ROUTER_NAMES ; do
  docker kill $CONTAINER
  docker rm $CONTAINER
  start_container
done

# ISP peering router network interfaces
$pipework br_p-isp -i eth0 -l if_isp_p isp_peering 0.0.0.0/0
$pipework $PUBLIC_IFACE -i eth1 -l if_isp_out isp_peering $PUBLIC_IP

# DC_PE router network interfaces
$pipework br_p-dcpe -i eth0 -l if_dc_p dc_pe 0.0.0.0/0
$pipework $TOXIA_IFACE -i eth1 -l if_dc_out dc_pe $TOXIA_IP

# SUBS_PE router network interfaces
$pipework br_p-subspe -i eth0 -l if_subs_p subs_pe 0.0.0.0/0
$pipework $SUBS_IFACE -i eth1 -l if_subs_out subs_pe $SUBS_IP

# P router network interfaces
$pipework br_p-isp -i eth0 -l if_p_isp pr 0.0.0.0/0
$pipework br_p-dcpe -i eth1 -l if_p_dc pr 0.0.0.0/0
$pipework br_p-subspe -i eth2 -l if_p_subs pr 0.0.0.0/0