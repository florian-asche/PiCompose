#!/bin/bash -e

# The package brings the WirePlumber configuration (ACP disabled). The default volume of the sound card comes from picompose-core.
on_chroot << EOF2
apt-get update
apt-get install -y picompose-driver-satellite1
EOF2
