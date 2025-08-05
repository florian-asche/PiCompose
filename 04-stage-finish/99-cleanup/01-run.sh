#!/bin/bash -e

log "Cleaning up the system before creating the image"

on_chroot << EOF
# Clean apt cache
apt-get clean

# Remove temporary files
rm -rf /var/cache/apt/archives/*
rm -rf /var/cache/apt/*.bin
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

# Regenerate SSH host keys on first boot
rm -f /etc/ssh/ssh_host_*
touch /etc/ssh/reconfigure
EOF
