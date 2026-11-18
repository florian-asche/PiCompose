#!/bin/bash -e

# Create directorys
mkdir -p "${ROOTFS_DIR}/etc/pipewire"
mkdir -p "${ROOTFS_DIR}/etc/pipewire/pipewire.conf.d"
mkdir -p "${ROOTFS_DIR}/etc/wireplumber/wireplumber.conf.d"

# Copy configs
install -v -m 644 files/linux-voice-assistant.conf "${ROOTFS_DIR}/etc/pipewire/pipewire.conf.d/linux-voice-assistant.conf"
install -v -m 644 files/50-alsa-output.conf "${ROOTFS_DIR}/etc/wireplumber/wireplumber.conf.d/50-alsa-output.conf"

on_chroot << EOF
# Activate PipeWire-ALSA Bridge
echo "Activate PipeWire-ALSA Bridge"
ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/

# The rtprio/nice limits of PipeWire (/etc/security/limits.d/25-pw-rlimits.conf)
# only apply to members of the pipewire group
echo "Allow pi to use real-time scheduling for PipeWire"
usermod -aG pipewire pi

# Allow services to run without an active user session
echo "Allow services to run without an active user session"
mkdir -p /var/lib/systemd/linger
touch /var/lib/systemd/linger/pi
EOF
