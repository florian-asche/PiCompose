#!/bin/bash -e

# Install the compose-manager script
install -v -m 755 files/configure_hostname.sh "${ROOTFS_DIR}/usr/bin/configure_hostname.sh"

# Copy the systemd service
install -v -m 644 files/configure_hostname.service "${ROOTFS_DIR}/etc/systemd/system/configure_hostname.service"

on_chroot << EOF
# Enable services
echo "Enable hostname services"
systemctl daemon-reload
systemctl enable configure_hostname.service
EOF
