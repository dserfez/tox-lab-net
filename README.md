# tox-lab-net
Toxia Lab Network with routers

## Install

1. Downlaod CoreOS iso image: (http://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso)
2. Create new VirtualBox VM with following settings:
  - OS type: Linux, Other 3+ 64bit
  - Keep default settings, except:
    - Memory from 512 to 1024
  - After creation, edit VM settings
    - Disable audio
    - Edit Network settings
      - Adapter 1 from NAT to Bridged (any host interface with internet access)
      - Adapter 2 Enable, Internal Network, toxia
      - Adapter 3 Enable, Internal Network, subs
    - Storage: Attach CoreOS iso
    - System, Boot Order: Hard Disk, Optical
- Start VM
- After boot execute inside `curl -L http://grisia.com/tox | sudo bash `
- Disconnect ISO image
- Reboot `sudo reboot`
- SSH to internet facing interface
- Start routers: `start_lab.sh` (first run may take longer)
- Enter router container: `con` and select name
- When in container, enter router CLI: `vtysh`

## Troubleshooting

### Bypass Authentication
From: (https://coreos.com/os/docs/latest/booting-with-iso.html)

If you need to bypass authentication in order to install, the kernel option `coreos.autologin` allows you to drop directly to a shell on a given console without prompting for a password. Useful for troubleshooting but use with caution.

For any console that doesn't normally get a login prompt by default be sure to combine with the console option:

```console=tty0 console=ttyS0 coreos.autologin=tty1 coreos.autologin=ttyS0```

Without any argument it enables access on all consoles. Note that for the VGA console the login prompts are on virtual terminals (tty1, tty2, etc), not the VGA console itself (tty0).
