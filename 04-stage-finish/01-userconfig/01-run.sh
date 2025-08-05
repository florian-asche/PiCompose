#!/bin/bash -e

# Install root .bashrc
install -v -m 644 files/root.bashrc "${ROOTFS_DIR}/root/.bashrc"
chown -v root:root "${ROOTFS_DIR}/root/.bashrc"


# Install pi .bashrc
install -v -m 644 files/pi.bashrc "${ROOTFS_DIR}/home/pi/.bashrc"
chown -v 1000 "${ROOTFS_DIR}/home/pi/.bashrc"
