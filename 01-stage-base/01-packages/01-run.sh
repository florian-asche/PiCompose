#!/bin/bash -e
on_chroot << EOF
# Install dependencies for Docker repository
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

# Create directory for Docker GPG key
mkdir -p /etc/apt/keyrings

# Download Docker's official GPG key
curl -fsSL http://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set permissions for GPG key
chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  http://download.docker.com/linux/debian \
  \$(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists
apt-get update
EOF
