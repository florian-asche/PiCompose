#!/bin/bash -e

# Install linux-voice-assistant: Create an linux-voice-assistant subdirectory
mkdir -p "${ROOTFS_DIR}/compose/lva"

# Install linux-voice-assistant: Copy the linux-voice-assistant docker-compose.yml
install -v -m 644 files/lva/docker-compose.yml "${ROOTFS_DIR}/compose/lva/docker-compose.yml"

# Install linux-voice-assistant: Copy the linux-voice-assistant configuration file
install -v -m 644 files/lva/picompose.conf "${ROOTFS_DIR}/compose/lva/picompose.conf"

# Install linux-voice-assistant: Copy the linux-voice-assistant environment
install -v -m 644 files/lva/.env "${ROOTFS_DIR}/compose/lva/.env"
