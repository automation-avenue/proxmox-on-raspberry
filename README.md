# PXVIRT Proxmox fork installation process on Raspberry Pi <br />
See script included to automatically run all pre-installation tasks. <br />
Proxmox VE is not yet officially available for ARM architecture on Proxmox website. <br />
There are many forks of that project that already work fine though. <br />
The script and README is based on instructions for pxvirt fork: <br />
https://docs.pxvirt.lierfang.com/en/installfromdebian.html <br />
It can be used with Raspberry Pi 3B or newer (3B+, Raspberry 4, 5, 500 etc) <br /> <br />
Although it will run on devices with just 1GB of RAM, it is advisable to get Raspberry with at least 4GB of RAM memory. <br />
It works with Debian 12 Bookworm and Debian 13 Trixie. <br />
Note - that if you first install Debian 12 on your Raspberry - you will get Proxmox 8, <br />
but if you install Debian 13 - you will get Proxmox 9. <br /> <br />

## Raspberry Pi flashing process: <br />
Download Raspberry Pi Imager from here: https://www.raspberrypi.com/software/ <br /> 
Connect your Raspberry Pi to your network using WIRED connection! <br />
(even though Pi has wireless module - it would be challenging to get it running with Proxmox). <br />
Flash your MicroSD card or SSD drive choosing Debian 12 (Bookworm) or Debian 13 (Trixie) - I would suggest going for the latter. <br />
Insert your MicroSD or SSD and start your Raspberry Pi. <br />
Follow the on-screen process to complete Debian installation. <br /> <br />

## Raspberry Pi preparation process: <br />
If you run your operating system on MicroSD, avoid using swapping as its not only slow <br />
but will also kill your MicroSD card very fast. <br />
You can run command `sudo swapoff -a`, check any entries for swap in `/etc/fstab` and reboot the system. <br />
Proxmox requires a root password when you log on to it and by default Raspberry does not have password configured for root user. <br />
You need to create one by running `sudo passwd root` and then type your password twice to get it configured. <br />
Check your current interfaces with `ip address` command, see if you have valid ip address and on what interface. <br />
Check your current configuration by running `cat /etc/network/interfaces` <br />

## Now run the pxvirt preparation script included <br />
Simply git clone the script or even copy-paste from here and remember to `chmod +x` . <br />
Run the script with sudo privileges - so `sudo ./pxvirtpreps.sh` <br />
When the process is completed - reboot the Pi. <br />
Check again network interfaces with `cat /etc/network/interfaces` <br />
You should now see the vmbr0 linux bridge created and it should have ip assigned, sth like: <br />
```bash
auto eth0
iface eth0 inet manual

auto vmbr0
iface vmbr0 inet manual
    address 192.168.1.59/24
    gateway 192.168.1.1
    bridge-ports eth0
    bridge-stp off
    bridge-fd 0
```
You can also run `cat /etc/apt/sources.list.d/pxvirt-sources.list` and you should see there this line: <br />
`deb  https://mirrors.lierfang.com/pxcloud/pxvirt $VERSION_CODENAME main` <br />
where the `$VERSION_CODENAME` will be replaced with bookworm or trixie depending on debian version you are running. <br />

## PXVIRT installation process <br />
Just run `apt update` and then: <br />
`apt install proxmox-ve pve-manager qemu-server pve-cluster -y` as per instruction on pxvirt website. <br />
This process might take over 10 minutes and you might see screen going off and on. <br />
Once its completed - you should be able to access Proxmox from any device on your network by going to: <br />
https://<vmbr0_ip_address>:8006 <br />

