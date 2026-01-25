#!/bin/bash -e

# Install snapcast: Create an snapcast subdirectory
mkdir -p "${ROOTFS_DIR}/compose/snapcast"

# Install snapcast: Copy the snapcast docker-compose.yml
install -v -m 644 files/snapcast/docker-compose.yml "${ROOTFS_DIR}/compose/snapcast/docker-compose.yml"

# Install snapcast: Copy the snapcast configuration file
install -v -m 644 files/snapcast/picompose.conf "${ROOTFS_DIR}/compose/snapcast/picompose.conf"

# Install snapcast: Copy the snapcast environment
install -v -m 644 files/snapcast/.env "${ROOTFS_DIR}/compose/snapcast/.env"
