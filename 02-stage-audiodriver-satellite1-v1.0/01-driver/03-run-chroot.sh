#!/bin/bash -e

# Installs drivers for the ReSpeaker 2mic and 4mic HATs on Raspberry Pi OS.
# Must be run with sudo.
# Requires: curl raspberrypi-kernel-headers dkms i2c-tools libasound2-plugins alsa-utils

echo "Starting satellite1 driver installation..."

# 1. Install the Custom Kernel
echo "Download and install Custom Kernel"
wget https://github.com/FutureProofHomes/RPi-Kernel-Fusb302/releases/download/develop/linux-image-6.18.32-fusb302-rpi-v8_2_arm64.deb
dpkg -i linux-image-*-fusb302-rpi-v8_*_arm64.deb


# 2. Install System Configuration
echo "Download and install System configuration"
wget https://github.com/FutureProofHomes/Satellite1-RPi-Setup/releases/download/develop/satellite1-rpi-setup_1.0-1_arm64.deb
dpkg -i satellite1-rpi-setup_*_arm64.deb


# 3. Install the Python SDK
#echo "Download and install Python SDK"
wget https://github.com/FutureProofHomes/Satellite1-RPi-SDK/releases/download/develop/satellite1-rpi-sdk_0.1.5_arm64.deb
dpkg -i satellite1-rpi-sdk_*_arm64.deb
