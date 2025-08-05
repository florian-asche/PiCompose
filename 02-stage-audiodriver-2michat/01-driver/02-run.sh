#!/bin/bash -e

echo "installing respeaker systemd daemon"

# Install the new seeed-voicecard-v2 script
install -v -m 755 files/seeed-voicecard-v2 "${ROOTFS_DIR}/usr/bin/seeed-voicecard-v2"

# Copy the systemd service
install -v -m 644 files/seeed-voicecard.service "${ROOTFS_DIR}/etc/systemd/system/seeed-voicecard.service"

# Enable the service directly
on_chroot << EOF
systemctl daemon-reload
systemctl enable seeed-voicecard.service
EOF
