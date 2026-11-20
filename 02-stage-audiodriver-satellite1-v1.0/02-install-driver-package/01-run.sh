#!/bin/bash -e

# The packages of FutureProofHomes bring the device tree overlay, the ALSA configuration, the ACP profile set and the Python SDK. The default volume of the sound card comes from picompose-core.
on_chroot << EOF2
apt-get update
apt-get install -y satellite1-rpi-setup-trixie satellite1-rpi-sdk
EOF2
