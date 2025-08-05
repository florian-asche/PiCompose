#!/bin/bash -e

# Installs drivers for the ReSpeaker 2mic and 4mic HATs on Raspberry Pi OS.
# Must be run with sudo.
# Requires: curl raspberrypi-kernel-headers dkms i2c-tools libasound2-plugins alsa-utils

echo "Starting respeaker driver installation..."

if [ -d "/seeedstudio_driver" ]; then
    echo "/seeedstudio_driver directory already existent. I delete it now!"
    rm -rf /seeedstudio_driver
fi
mkdir /seeedstudio_driver
cd /seeedstudio_driver

ver="0.3"
OVERLAYS=/boot/overlays

echo "Debug1"
ls -l /proc/version
echo "Debug2"
cat /proc/version
echo "Debug3"
ls -l /boot/
echo "Debug4"
ls -l

all_kernel_versions=$(ls /boot/vmlinuz-* | grep -oP '(?<=/boot/vmlinuz-)\K[0-9]+\.[0-9]+' | sort -u)

# Schleife über alle gefundenen Kernel
for kernel_version in $all_kernel_versions; do
    echo "Verarbeite Kernel: $kernel"
    # Read the kernel version
    #kernel_formatted="$(echo $kernel | grep -oP '\K[0-9]+\.[0-9]+' | sort -V | tail -n 1)"

    mkdir $kernel_version
    cd $kernel_version

    echo "Checking download source"
    driver_url_status="$(curl -ILs https://github.com/HinTak/seeed-voicecard/archive/refs/heads/v$kernel_version.tar.gz | tac | grep -o "^HTTP.*" | cut -f 2 -d' ' | head -1)"
    if  [ ! "$driver_url_status" = 200 ]; then
    echo "Could not find driver for kernel $kernel_version"
    exit 1
    fi

    # Download source code to temporary directory
    # NOTE: There are different branches in the repo for different kernel versions.
    echo 'Downloading source code'
    wget "https://github.com/HinTak/seeed-voicecard/archive/refs/heads/v$kernel_version.tar.gz"
    tar -xf v$kernel_version.tar.gz
    cd "seeed-voicecard-$kernel_version"

    # 1. Build kernel module
    echo 'Building kernel module'
    mod='seeed-voicecard'
    version="$kernel_version"   # 6.6
    src='./'
    marker='0.0.0'

    mkdir -p "/usr/src/${mod}-${version}"
    cp -a "${src}"/* "/usr/src/${mod}-${version}/"
    dkms add -m "${mod}" -v "${version}"

    # get all possible kernels for this version
    kernels=$(ls /boot/vmlinuz-* | grep -oP '(?<=/boot/vmlinuz-).*' | grep $kernel_version)

    # build module for each possible kernel
    for kernel in $kernels; do
      dkms build -k "${kernel}" -m "${mod}" -v "${version}" && {
          dkms install --force -k "${kernel}" -m "${mod}" -v "${version}"
      }
    done

    mkdir -p "/var/lib/dkms/${mod}/${version}/${marker}"

    # Copy  Device Tree Overlays
    cp seeed-*-voicecard.dtbo /boot/overlays

    #install config files
    mkdir /etc/voicecard || true
    cp *.conf /etc/voicecard
    cp *.state /etc/voicecard

    cd ..
    cd ..
done

#set kernel modules
grep -q "^snd-soc-seeed-voicecard$" /etc/modules || \
  echo "snd-soc-seeed-voicecard" >> /etc/modules
grep -q "^snd-soc-ac108$" /etc/modules || \
  echo "snd-soc-ac108" >> /etc/modules
grep -q "^snd-soc-wm8960$" /etc/modules || \
  echo "snd-soc-wm8960" >> /etc/modules

# detect boot config
CONFIG=/boot/config.txt
[ -f /boot/firmware/config.txt ] && CONFIG=/boot/firmware/config.txt
[ -f /boot/firmware/usercfg.txt ] && CONFIG=/boot/firmware/usercfg.txt

# set boot params
sed -i -e 's:#dtparam=i2c_arm=on:dtparam=i2c_arm=on:g'  $CONFIG || true
sed -i -e 's:#dtparam=i2s=on:dtparam=i2s=on:g'  $CONFIG || true
sed -i -e 's:#dtparam=spi=on:dtparam=spi=on:g'  $CONFIG || true
grep -q "^dtoverlay=i2s-mmap$" $CONFIG || \
  echo "dtoverlay=i2s-mmap" >> $CONFIG

echo 'Done. Please reboot the system.'
