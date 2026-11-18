#!/bin/bash -e

# Install the compose-manager script
install -v -m 755 files/compose-manager.sh "${ROOTFS_DIR}/usr/bin/compose-manager.sh"

# Copy the systemd service
install -v -m 644 files/picompose.service "${ROOTFS_DIR}/etc/systemd/system/picompose.service"

# Enable the service directly
on_chroot << EOF
systemctl daemon-reload
systemctl enable picompose.service
EOF

# Create the compose folder on the boot partition
mkdir -p "${ROOTFS_DIR}/compose"
chmod 755 "${ROOTFS_DIR}/compose"

# Copy the README.txt to the compose folder
install -v -m 644 files/README.txt "${ROOTFS_DIR}/compose/README.txt" 


# #################
# Install example #
###################
# Install example: Create an example subdirectory
mkdir -p "${ROOTFS_DIR}/compose/example"

# Install example: Copy the example docker-compose.yml
install -v -m 644 files/example/docker-compose.yml "${ROOTFS_DIR}/compose/example/docker-compose.yml"

# Install example: Copy the example configuration file
install -v -m 644 files/example/picompose.conf "${ROOTFS_DIR}/compose/example/picompose.conf"
