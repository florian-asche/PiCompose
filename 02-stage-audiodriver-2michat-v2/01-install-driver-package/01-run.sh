#!/bin/bash -e

# The package brings the device tree overlay and the boot configuration for the ReSpeaker 2-Mics Pi HAT V2.0
on_chroot << EOF2
apt-get update
apt-get install -y picompose-driver-2michat-v2
EOF2
