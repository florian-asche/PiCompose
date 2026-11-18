#!/bin/bash -e

on_chroot << EOF2
apt-get update
apt-get install -y ca-certificates curl
curl -fsSL https://florian-asche.github.io/PiCompose-Repository/picompose-archive-keyring.gpg -o /usr/share/keyrings/picompose-archive-keyring.gpg
EOF2

# The apt proxy of the image build does not allow HTTPS tunnels, so apt has to reach the repository directly
install -v -m 644 files/52picompose-direct "${ROOTFS_DIR}/etc/apt/apt.conf.d/52picompose-direct"

install -v -m 644 files/picompose.sources "${ROOTFS_DIR}/etc/apt/sources.list.d/picompose.sources"

# The package takes over the key and the source file, so later key changes arrive as a normal upgrade
on_chroot << EOF2
apt-get update
apt-get install -y -o Dpkg::Options::=--force-confnew picompose-archive-keyring
EOF2
