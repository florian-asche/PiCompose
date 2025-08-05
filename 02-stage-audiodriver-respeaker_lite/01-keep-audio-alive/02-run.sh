#!/bin/bash -e

# Install the keep-audio-alive script
install -v -m 755 files/keep-audio-alive.sh "${ROOTFS_DIR}/usr/bin/keep-audio-alive.sh"

# Copy the systemd service
install -v -m 644 files/keep-audio-alive.service "${ROOTFS_DIR}/etc/systemd/system/keep-audio-alive.service"

# Enable the service directly
on_chroot << EOF
systemctl daemon-reload
systemctl enable keep-audio-alive.service
EOF
