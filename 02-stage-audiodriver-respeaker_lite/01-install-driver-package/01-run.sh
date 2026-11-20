#!/bin/bash -e

# The package brings the keep-audio-alive service. The default volume of the sound card comes from picompose-core.
on_chroot << EOF2
apt-get update
apt-get install -y picompose-driver-respeaker-lite
EOF2
