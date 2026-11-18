#!/bin/bash -e

# The package brings the compose manager, the hostname service and the PipeWire configuration files
on_chroot << EOF2
apt-get update
apt-get install -y picompose-core
EOF2
