# Information

This document contains information about breaking changes if a new version is released and the configuration changed.
If you use the homeassistant image please also follow the snapcast and satellite breaking changes.

# Versions
## Unreleased
The audio setup of the ReSpeaker Lite image is installed by the package `picompose-driver-respeaker-lite` instead of the image build. `keep-audio-alive.service` stays. `configure_audio.service` and `/usr/bin/configure_audio.sh` are gone, which set the volume of the default sink to 100 % at every start. The default volume of a sound card without a stored state is now 100 % through `picompose-core` (`51-default-volume.conf`), a volume that WirePlumber has already stored for the card is kept. On an existing image, `apt upgrade` leaves a dangling `configure_audio.service` symlink behind.

The compose manager, the hostname service and the PipeWire and WirePlumber configuration files are installed by the package `picompose-core` instead of the image build. `apt upgrade` updates `/usr/bin/compose-manager.sh` and `/usr/bin/configure_hostname.sh`. The two configuration files below `/etc/pipewire` and `/etc/wireplumber` are conffiles, so changes you made to them are kept and dpkg asks if both sides changed. `/compose` is never overwritten.

The `lva` and `snapcast` projects are installed by the package `picompose-software-ha-satellite` instead of the image build. `apt upgrade` replaces `/compose/lva/docker-compose.yml` and `/compose/snapcast/docker-compose.yml`, so changes you made to these two files are lost. `picompose.conf` and `.env` are never overwritten, but new options of a newer `.env` have to be added by hand.

## From unstable to v1.0.0
I released the first stable version from piCompose. There is still some things todo but i think this release can be marked as a first stable and working version.

## From v1.0.4 to v1.0.5
Switched from wyoming-satellite to linux-voice-assistant. This is a breaking change because the configuration and software changed.
