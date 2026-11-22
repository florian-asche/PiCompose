#!/bin/bash -e

# The package installs its Docker Compose projects into /compose
on_chroot << EOF2
apt-get update
apt-get install -y picompose-software-ha-satellite
EOF2
