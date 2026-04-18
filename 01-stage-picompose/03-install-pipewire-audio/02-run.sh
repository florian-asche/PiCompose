#!/bin/bash -e

# Create directorys
mkdir -p "${ROOTFS_DIR}/etc/pipewire"
mkdir -p "${ROOTFS_DIR}/etc/pipewire.conf.d"
mkdir -p "${ROOTFS_DIR}/etc/wireplumber/wireplumber.conf.d"

# Copy configs
install -v -m 644 files/linux-voice-assistant.conf "${ROOTFS_DIR}/etc/pipewire.conf.d/linux-voice-assistant.conf"
install -v -m 644 files/linux-voice-assistant.conf "${ROOTFS_DIR}/etc/pipewire.conf.d/linux-voice-assistant.conf"

on_chroot << EOF
# Activate PipeWire-ALSA Bridge
echo "Activate PipeWire-ALSA Bridge"
ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/

# Allow services to run without an active user session
echo "Allow services to run without an active user session"
mkdir -p /var/lib/systemd/linger
touch /var/lib/systemd/linger/pi
EOF
