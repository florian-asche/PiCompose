#!/bin/bash -e

install -v -m 755 files/configure_audio.sh "${ROOTFS_DIR}/usr/bin/configure_audio.sh"
install -v -m 644 files/configure_audio.service "${ROOTFS_DIR}/etc/systemd/system/configure_audio.service"

on_chroot << EOF
echo "Enable audio services"
systemctl daemon-reload
systemctl enable configure_audio.service
EOF
