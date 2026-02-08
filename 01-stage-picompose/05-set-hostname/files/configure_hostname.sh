#!/bin/bash

# Get active interface
IFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

# Check if IFACE is empty
if [ -z "$IFACE" ]; then
    echo "No active network interface found."
    exit 1
fi

# Check if interface directory exists
if [ ! -e "/sys/class/net/$IFACE/address" ]; then
    echo "Interface $IFACE does not exist or has no MAC address."
    exit 1
fi

# Read MAC address and remove ':'
MAC=$(cat /sys/class/net/$IFACE/address | tr -d ':')

if [ -z "$MAC" ]; then
    echo "Could not read MAC address."
    exit 1
fi

# Generate CLIENT_NAME from it
CLIENT_NAME="picompose-${MAC}"

# Set hostname
echo "Setze Hostname auf $CLIENT_NAME"
hostnamectl set-hostname "$CLIENT_NAME"
