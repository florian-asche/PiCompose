#!/bin/bash -e

# ReSpeaker 2-Mics Pi HAT **V2.0** uses a TLV320AIC3104 codec on I2C 0x18 —
# NOT the WM8960 codec (0x1a) used on V1. No out-of-tree DKMS module is
# needed: the mainline `snd-soc-tlv320aic3x` driver already ships in the
# kernel. We just need the device-tree overlay that wires it up to the Pi's
# I2S pins. The overlay source is maintained by Seeed in their
# seeed-linux-dtoverlays repo.

echo "Building ReSpeaker 2-Mic HAT V2.0 device-tree overlay..."

SRC=/tmp/seeed-linux-dtoverlays
rm -rf "$SRC"
git clone --depth 1 https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git "$SRC"

cd "$SRC"
make overlays/rpi/respeaker-2mic-v2_0-overlay.dtbo

# detect boot config + overlays location
OVERLAYS_DIR=/boot/overlays
CONFIG=/boot/config.txt
if [ -d /boot/firmware/overlays ]; then
    OVERLAYS_DIR=/boot/firmware/overlays
fi
if [ -f /boot/firmware/config.txt ]; then
    CONFIG=/boot/firmware/config.txt
fi
if [ -f /boot/firmware/usercfg.txt ]; then
    CONFIG=/boot/firmware/usercfg.txt
fi

install -v -m 644 overlays/rpi/respeaker-2mic-v2_0-overlay.dtbo \
    "${OVERLAYS_DIR}/respeaker-2mic-v2_0.dtbo"

# set boot params: enable I2C and load the v2 overlay
sed -i -e 's:#dtparam=i2c_arm=on:dtparam=i2c_arm=on:g' "$CONFIG" || true
grep -q "^dtparam=i2c_arm=on$" "$CONFIG" || echo "dtparam=i2c_arm=on" >> "$CONFIG"
grep -q "^dtoverlay=respeaker-2mic-v2_0$" "$CONFIG" || \
    echo "dtoverlay=respeaker-2mic-v2_0" >> "$CONFIG"

cd /
rm -rf "$SRC"

echo "Done. After boot the card appears as 'seeed2micvoicec' (bcm2835-i2s-tlv320aic3x-hifi)."
