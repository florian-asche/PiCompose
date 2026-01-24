#!/bin/bash -e

# Install satellite: Create an satellite subdirectory
mkdir -p "${ROOTFS_DIR}/compose/satellite"

# Install satellite: Copy the satellite docker-compose.yml
install -v -m 644 files/satellite/docker-compose.yml "${ROOTFS_DIR}/compose/satellite/docker-compose.yml"

# Install satellite: Copy the satellite configuration file
install -v -m 644 files/satellite/picompose.conf "${ROOTFS_DIR}/compose/satellite/picompose.conf"

# Install satellite: Copy the satellite environment
install -v -m 644 files/satellite/.env "${ROOTFS_DIR}/compose/satellite/.env"
