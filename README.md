# tox-lab-net
Toxia Lab Network with routers

## Install

1. Downlaod CoreOS iso image: (http://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso)
2. Create new VirtualBox VM with following settings:
  - OS type: Linux, Other 3+ 64bit
  - Keep default settings, except:
    - Memory 1024MB
  - After creation, edit VM settings
    - Disable audio
    - Edit Network settings
      - **Stop here and ensure that:** there are 3 host-only interfaces created in VirtualBox host &gt; Preferences &gt; Network settings. First tested with Internal Network, but there was no network connectivity between router container and the host at the other side.
      - Adapter 1 from NAT to first host-only interface (vboxnet0)
      - Adapter 2 Enable, second host-only interface (vboxnet1), toxia
      - Adapter 3 Enable, third host-only interface (vboxnet2), subs
    - Storage: Attach CoreOS iso
    - System, Boot Order: Hard Disk, Optical
- Start VM
- After boot execute inside `curl -L http://grisia.com/toxnet | sudo bash `
- Disconnect ISO image
- Reboot `sudo reboot`
- SSH to internet facing interface (first interface)
- Start routers: `start_lab.sh` (first run may take longer due to docker images download)
- Enter router container: `con` and select name
- When in container, enter router CLI: `vtysh`

## Configure

### Router pr

#### Inside vtysh

$TOXIA_IP=IP address of toxia BGP component

```
 neighbor $TOXIA_IP remote-as 65000
 neighbor $TOXIA_IP description TOXIA
 neighbor $TOXIA_IP update-source Loopback0
 neighbor $TOXIA_IP prefix-list only32 in
 neighbor $TOXIA_IP route-map deny-all out
 neighbor $TOXIA_IP maximum-prefix 1000
```

### Router isp_peering

#### in system shell

Configure GRE tunnel.

Adapt from Cisco IOS config:

```
interface Tunnel1
 description Connection to TOXIA
 ip unnumbered Loopback0
 ip nat inside
 ip virtual-reassembly
 tunnel source Loopback0
 tunnel destination 192.168.8.25
```

Trying to adapt above config:

```
ip a a 192.168.6.6/32 dev lo
ip tunnel add Tunnel1 mode gre remote 192.168.8.25 local 192.168.6.6
ip link set Tunnel1 up
```


Add NAT for traffic going to internet

* $SUBS_NET=subscriber networks
* $TOXIA_NET=toxia network

```
iptables -t nat -I POSTROUTING -o enp0s3 -j NAT
iptables -t nat -N NAT
iptables -t nat -I NAT -s 192.168.6.66 -j MASQUERADE
iptables -t nat -I NAT -s $SUBS_NET -j MASQUERADE
iptables -t nat -I NAT -s $TOXIA_NET -j MASQUERADE
```

#### Inside vtysh

Add public internet facing network to BGP

```
router bgp 65000
  network 172.17.42.0 mask 255.255.255.0
```

Add default route through gateway on public facing interface

```
ip route 0.0.0.0 0.0.0.0 172.17.42.1
```

Add route to other side of GRE through GRE tunnel

```
ip route 192.168.6.66 255.255.255.255 Tunnel1
```

### Router dc_pe

#### in system shell

#### Inside vtysh

Add toxia network to BGP

```
router bgp 65000
 network 192.168.8.0
 neighbor 192.168.8.25 remote-as 65000
 neighbor 192.168.8.25 description TOXIA
 neighbor 192.168.8.25 update-source lo
 neighbor 192.168.8.25 prefix-list only32 in
 neighbor 192.168.8.25 route-map deny-all out
 neighbor 192.168.8.25 maximum-prefix 1000
```

### Router subs_pe

#### in system shell

#### Inside vtysh

Add Subscribers network to BGP

```
router bgp 65000
 network 192.168.9.0
 neighbor 192.168.8.25 remote-as 65000
 neighbor 192.168.8.25 description TOXIA
 neighbor 192.168.8.25 update-source lo
 neighbor 192.168.8.25 prefix-list only32 in
 neighbor 192.168.8.25 route-map deny-all out
 neighbor 192.168.8.25 maximum-prefix 1000
```


## Lab Host operations

## Take-away changes

Router configurations and changes to lab scripts can be all packed into one tar.gz archive by running `pack_lab.sh`. The archive file is created in current directory and is named _lab\_${TIMESTAMP}.tar.gz_ where _${TIMESTAMP}_ is epoch time of archive creation.

The archive cotains complete content of _/opt/lab_ and _/opt/bin_

### Bypass Authentication in CoreOS
From: (https://coreos.com/os/docs/latest/booting-with-iso.html)

If you need to bypass authentication in order to install, the kernel option `coreos.autologin` allows you to drop directly to a shell on a given console without prompting for a password. Useful for troubleshooting but use with caution.

For any console that doesn't normally get a login prompt by default be sure to combine with the console option:

```console=tty0 console=ttyS0 coreos.autologin=tty1 coreos.autologin=ttyS0```

Without any argument it enables access on all consoles. Note that for the VGA console the login prompts are on virtual terminals (tty1, tty2, etc), not the VGA console itself (tty0).


# LAB R&D notes

## DC_PE to toxdata Connection

### MACVLAN approach

* RESULT: not working; ebtables snat not working. Maybe MACVLAN approach is wrong for ebtables snat?

code:
```
HOST_IF_NAME="enp0s8"
# HOST_IF_MAC="08:00:27:b4:0f:dc"
HOST_IF_MAC="$(ip -o link show dev ${HOST_IF_NAME} | cut -d "\\" -f2 | awk '{print $2}')"

CONTAINER_NAME="dc_pe"
CONTAINER_IF_INSIDE_NAME="eth1"

#CONTAINER_IF_OUTSIDE_NAME="if_dc_out"

sudo ip link add link ${HOST_IF_NAME} mb_toxdata type macvlan mode bridge

sudo pipework mb_toxdata -i eth1 -l if_dc_out dc_pe 0.0.0.0/0

CONTAINER_IF_INSIDE_MAC="$(docker exec -ti ${CONTAINER_NAME} ip -o link show dev ${CONTAINER_IF_INSIDE_NAME} | cut -d "\\" -f2 | awk '{print $2}')"

#/sbin/ip link add link enp0s8 mb_toxdata address 56:61:4f:7c:77:db type macvlan

sudo ebtables -t nat -A POSTROUTING -o $HOST_IF_NAME -s ${CONTAINER_IF_INSIDE_MAC} -j snat --to-source ${HOST_IF_MAC}

sudo ebtables -t nat -A PREROUTING -i $HOST_IF_NAME -d ${HOST_IF_MAC} -j dnat --to-destination ${CONTAINER_IF_INSIDE_MAC}
```