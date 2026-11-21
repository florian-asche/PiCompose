#!/bin/bash -e

# The package brings the device tree overlay, the boot configuration and an ACP profile set for the ReSpeaker 2-Mics Pi HAT v1
on_chroot << EOF2
apt-get update
apt-get install -y picompose-driver-2michat-v1
EOF2
