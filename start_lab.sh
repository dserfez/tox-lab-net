#
# Launch network of routers 
#

### Config section
ISP_PEERING_PUBLIC_IP="192.168.1.7/24"


#DOCKER_IP="172.17.42.1"
DOCKER_IP=$(ip -o -f inet a s dev docker0 | awk '{print $4}' | cut -d"/" -f1)
FEATURE="-d"

workdir="$(cd $( dirname $( readlink -f con $0) ) && pwd)"


if [ ! -x /opt/bin/start_lab.sh ] ; then
  wget -O /opt/bin/pipework https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework
  chmod +x /opt/bin/pipework
fi

#pipework="sudo $workdir/pipework --wait"
pipework="sudo $workdir/pipework"

# Helper for starting router containers
start_container() {
  docker run --cap-add=NET_ADMIN --net=none $FEATURE \
    --name $CONTAINER -e "HOSTNAME=$CONTAINER" \
    -v "/opt/lab/$CONTAINER"_conf/:/etc/quagga/ \
     cycomf/docker-labrouter
#    cycomf/docker-quagga
}
# Create internal neteorks
BRIDGES="p-dcpe p-isp p-subspe"
for BRIDGE in $BRIDGES ; do
  IS_IT_THERE=$(brctl show | grep ^$BRIDGE | awk '{print $1}'  )
  if [[ $BRIDGE != $IS_IT_THERE ]] ; then
    sudo brctl addbr $BRIDGE
  fi
done

# Start router containmers
for CONTAINER in isp_peering dc_pe subs_pe pr ; do
  docker kill $CONTAINER
  docker rm $CONTAINER
  start_container
done

$pipework p-isp -i eth0 isp_peering 192.168.7.2/30
$pipework docker0 -i eth1 isp_peering "${ISP_PEERING_PUBLIC_IP}@${DOCKER_IP}"


# dc_pe networking
$pipework p-dcpe -i eth0 dc_pe 192.168.7.6/30
$pipework vboxnet0 -i eth1 dc_pe 192.168.56.8/24
#$pipework toxdata -i eth1 dc_pe 192.168.8.8/24
#$pipework p-dcpe -i eth0 dc_pe 0/0
#$pipework toxdata -i eth1 dc_pe 0/0


# subs_pe networking
$pipework p-subspe -i eth0 subs_pe 192.168.7.10/30
$pipework subs -i eth1 subs_pe 192.168.9.8/24
#$pipework p-subspe -i eth0 subs_pe 0/0
#$pipework subs -i eth1 subs_pe 0/0


# p networking
$pipework p-isp -i eth0 pr 192.168.7.1/30
$pipework p-dcpe -i eth1 pr 192.168.7.5/30
$pipework p-subspe -i eth2 pr 192.168.7.8/30
#$pipework p-isp -i eth0 pr 0/0
#$pipework p-dcpe -i eth1 pr 0/0
#$pipework p-subspe -i eth2 pr 0/0


sudo ip r a 192.168.7.0/24 via "${ISP_PEERING_PUBLIC_IP}"
sudo ip r a 192.168.8.0/24 via "${ISP_PEERING_PUBLIC_IP}"
sudo ip r a 192.168.9.0/24 via "${ISP_PEERING_PUBLIC_IP}"
