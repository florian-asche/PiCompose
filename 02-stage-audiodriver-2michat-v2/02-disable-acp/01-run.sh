#!/bin/bash -e

# disable acp
mkdir -p "${ROOTFS_DIR}/etc/wireplumber/wireplumber.conf.d"
install -v -m 644 files/51-disable-acp.conf "${ROOTFS_DIR}/etc/wireplumber/wireplumber.conf.d/51-disable-acp.conf"
