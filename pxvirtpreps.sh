#!/bin/bash

# Get the IP address of the default network interface
IP_ADDR=$(hostname -I | awk '{print $1}')

# Backup the hosts file first
sudo cp /etc/hosts /etc/hosts.bak

# Replace the IP for raspberrypi
sudo sed -i "s/^127\.0\.1\.1[[:space:]]\+raspberrypi\$/${IP_ADDR} raspberrypi/" /etc/hosts

echo "Updated /etc/hosts: raspberrypi now points to $IP_ADDR"

# Download GPG key
curl -L https://mirrors.lierfang.com/pxcloud/lierfang.gpg -o /etc/apt/trusted.gpg.d/lierfang.gpg

# Add the repository to the sources list
source /etc/os-release
echo "deb  https://mirrors.lierfang.com/pxcloud/pxvirt $VERSION_CODENAME main">/etc/apt/sources.list.d/pxvirt-sources.list

# Disable NetworkManager
systemctl disable NetworkManager
systemctl stop NetworkManager

# Install ifupdown2 and remove interfaces.new
apt update
apt install ifupdown2 -y
rm /etc/network/interfaces.new

# Detect the primary active interface that is not a loopback, state is UP and carrier detected
INTERFACE=$(ip -o link show up | awk -F': ' '{print $2}' | grep -v lo | head -n1)

if [ -z "$INTERFACE" ]; then
    echo "No active network interface found."
    exit 1
fi

echo "Detected active interface: $INTERFACE"

# Auto detect default gateway
GATEWAY=$(ip route | grep '^default' | awk '{print $3}' | head -n1)
if [ -z "$GATEWAY" ]; then
    echo "No default gateway found."
    exit 1
fi
echo "Detected default gateway: $GATEWAY"

# Detect ip address with subnet mask
IP_CIDR=$(ip -o -f inet addr show $INTERFACE | awk '{print $4}' | head -n1)

INTERFACES_FILE="/etc/network/interfaces"

# Backup the original interfaces file
sudo cp $INTERFACES_FILE ${INTERFACES_FILE}.bak.$(date +%F-%T)

# Remove any existing configuration for the detected interface
sudo sed -i "/iface $INTERFACE inet manual/,/^\s*$/d" $INTERFACES_FILE
sudo sed -i "/auto $INTERFACE/d" $INTERFACES_FILE

# Append new static IP config for the detected interface
sudo bash -c "cat >> $INTERFACES_FILE" <<EOF

auto $INTERFACE
iface $INTERFACE inet manual

auto vmbr0
iface vmbr0 inet manual
    address $IP_CIDR
    gateway $GATEWAY
    bridge-ports $INTERFACE
    bridge-stp off
    bridge-fd 0
EOF

echo "Static IP configuration for interfaces $INTERFACE and vmbr0 added to $INTERFACES_FILE"
