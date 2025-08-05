#!/bin/bash -e

# Create the pipewire directory
mkdir -p "${ROOTFS_DIR}/etc/pipewire"

# Copy pipewire config
install -v -m 644 files/pipewire.conf "${ROOTFS_DIR}/etc/pipewire/pipewire.conf"

on_chroot << EOF
# Activate PipeWire-ALSA Bridge
echo "Activate PipeWire-ALSA Bridge"
ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/

# Allow services to run without an active user session
echo "Allow services to run without an active user session"
mkdir -p /var/lib/systemd/linger
touch /var/lib/systemd/linger/pi
EOF
