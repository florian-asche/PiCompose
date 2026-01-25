# PiCompose

[![CI](https://github.com/florian-asche/PiCompose/actions/workflows/build-image.yml/badge.svg)](https://github.com/florian-asche/PiCompose/actions/workflows/build-image.yml) [![GitHub Release Version](https://img.shields.io/github/v/release/florian-asche/PiCompose?label=version)](https://github.com/florian-asche/PiCompose/releases) [![GitHub License](https://img.shields.io/github/license/florian-asche/PiCompose)](https://github.com/florian-asche/PiCompose/blob/main/LICENSE) [![GitHub last commit](https://img.shields.io/github/last-commit/florian-asche/PiCompose)](https://github.com/florian-asche/PiCompose/commits)

Ready to use Raspberry Pi Images with Docker for projects like [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant) and [docker-snapcast](https://github.com/florian-asche/docker-snapcast).

Also a tool for creating customized Raspberry Pi OS images with automatic Docker Compose deployment.

## Overview

PiCompose uses the official [pi-gen](https://github.com/RPi-Distro/pi-gen) tool from Raspberry Pi to create a customized Raspberry Pi OS image.

The image is configured to:

1. Start seeed-voicecard service (If you use 2-MicHat)
2. Start Pipewire service
3. Start Keep-Audio-Alive service (If you use Respeaker Lite)
4. Set audio volume to 100%
5. Set hostname
6. Search for Docker Compose files in a special directory on the main partition
7. Automatically deploy each Docker Compose project found
8. Optionally set up regular re-deployments via Crontab

This repository also contains fully prepared images for specific voice hardware of Homeassistant with all needed drivers.

## Features

- Automated build of a customized Raspberry Pi OS image using GitHub Actions
- Easy addition of Docker Compose projects via the main partition (compose directory)
- Configurable regular re-deployments via a simple configuration file
- No manual configuration of the Raspberry Pi required
- Image prepared for audio usage with the pipewire server
- Prebuild images with drivers for various devices

## Usage

### Hardware

For a detailed overview on the hardware, i have a seperated page for that here: [docs/hardware.md](docs/hardware.mdhttps:/).

### Images

Here is a Image Overview specific for each hardware if needed:

| Name | Hardware | What's in the Image? |
|------|----------|---------------------|
| **Base Image** | | • Docker & Docker Compose (piCompose)<br>• Automatic Docker Compose deployment<br>• Pipewire Audio Server<br>• SSH enabled (pi User) |
| **ReSpeaker Lite** | <img src="docs/respeaker_lite.jpg" alt="ReSpeaker Lite Board" style="width: 200px; height: auto;"> | • Base Image<br>• Audio keep-alive service (Workaround) |
| **ReSpeaker Lite**<br>**+ Home Assistant** | <img src="docs/respeaker_lite.jpg" alt="ReSpeaker Lite Board" style="width: 200px; height: auto;"> | • ReSpeaker Lite Image<br>• Linux-Voice-Assistant (OpenHomeFoundation)<br>• Snapcast MultiRoom Audio Client<br>• Pre-configured for Home Assistant |
| **ReSpeaker 2-Mic HAT v1** | <img src="docs/respeaker_2michats.webp" alt="ReSpeaker 2-Mics Pi HAT" style="width: 200px; height: auto;"> | • Base Image<br>• Seeed Voicecard Driver |
| **ReSpeaker 2-Mic HAT v1**<br>**+ Home Assistant** | <img src="docs/respeaker_2michats.webp" alt="ReSpeaker 2-Mics Pi HAT" style="width: 200px; height: auto;"> | • 2-Mic HAT Image<br>• Linux-Voice-Assistant (OpenHomeFoundation)<br>• 2-Mic HAT GPIO LED Control<br>• Snapcast MultiRoom Audio Client<br>• Pre-configured for Home Assistant |

### Raspberry Pi Image

1. Download the latest image from [GitHub Releases](https://github.com/florian-asche/PiCompose/tagshttps:/).
2. Write the image to an SD card, you can use the Imager tool to copy the image onto your drive or sd card. Use the customization section to add your wifi credentials. If you want to change your pi user password or something else you can also do that. Note that the hostname is automatically generated one time.

### Customization (optional)

If you dont use a fully prebuild image inclusive homeassistant docker containers you can customize what piCompose will deploy in your docker instance.

1. Create directories for your Docker Compose projects in the `compose` folder on the main partition if you dont use a fully prebuild image.
2. Place your docker-compose.yml files and associated configurations in the appropriate subdirectories (see the example directory)

### First start's

Make sure, that you configured your wifi credentials before the first boot.

On the first boot in will create new ssh public keys for the ssh serve. You can see that if you have a monitor connected to your system.
The system will automatically reboot and install the audio drivers.

After that you can login with the user `pi`. You can change the password if you didnt change it before with the imager tool.
You will notice that the hardware is not visible if you run `aplay -L`.

*You need to manually reboot one more time.*

After that `aplay -L` should show the `seeed2micvoicec` or `Lite` soundcard depending on your hardware.

piCompose should download and install the containers.
You can watch the /var/log/picompose.log logfile if you want to monitor the process.
The process can take some time, since it downloads images from the internet!

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for information on local development and the build process.

### Example projects, that you can run on this:

- [docker-snapcast](https://github.com/florian-asche/docker-snapcast) - A Docker image for Snapcast server and client, providing multi-room audio streaming capabilities
- [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant) - A remote voice satellite implementation using the ESPHome protocol

## License

This project is released under the [BSD-3-Clause License](LICENSE).
