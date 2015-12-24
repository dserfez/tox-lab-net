# tox-lab-net
Toxia Lab Network with routers

## Install

1. Downlaod CoreOS iso image: (http://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso)
- Boot a VM from it (tested in VirtualBox with 3 network interfaces: 1. Internet, 2. Toxia, 3. Subs
- After boot execute inside `curl -L http://grisia.com/tox | sudo bash `
- Disconnect ISO image
- Reboot `sudo reboot`
- SSH to internet facing interface

## Troubleshooting

### Bypass Authentication
From: (https://coreos.com/os/docs/latest/booting-with-iso.html)

If you need to bypass authentication in order to install, the kernel option `coreos.autologin` allows you to drop directly to a shell on a given console without prompting for a password. Useful for troubleshooting but use with caution.

For any console that doesn't normally get a login prompt by default be sure to combine with the console option:

```console=tty0 console=ttyS0 coreos.autologin=tty1 coreos.autologin=ttyS0```

Without any argument it enables access on all consoles. Note that for the VGA console the login prompts are on virtual terminals (tty1, tty2, etc), not the VGA console itself (tty0).