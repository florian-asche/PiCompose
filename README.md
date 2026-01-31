# PiCompose

[![CI](https://github.com/florian-asche/PiCompose/actions/workflows/build-image.yml/badge.svg)](https://github.com/florian-asche/PiCompose/actions/workflows/build-image.yml) [![GitHub Release Version](https://img.shields.io/github/v/release/florian-asche/PiCompose?label=version)](https://github.com/florian-asche/PiCompose/releases) [![GitHub License](https://img.shields.io/github/license/florian-asche/PiCompose)](https://github.com/florian-asche/PiCompose/blob/main/LICENSE) [![GitHub last commit](https://img.shields.io/github/last-commit/florian-asche/PiCompose)](https://github.com/florian-asche/PiCompose/commits)

Ready to use Raspberry Pi Images with Docker for projects like [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant) [docker-snapcast](https://github.com/florian-asche/docker-snapcast) and soon more.


## Overview

PiCompose uses the official [pi-gen](https://github.com/RPi-Distro/pi-gen) tool from Raspberry Pi to create a customized Raspberry Pi OS image.

The image is configured to:

1. Install needed drivers for the hardware (2-MicHat)
2. Start seeed-voicecard service (If you use 2-MicHat)
3. Start Pipewire service
4. Start Keep-Audio-Alive service (If you use Respeaker Lite)
5. Set audio volume to 100%
6. Set hostname
7. Search for Docker Compose files in a special directory on the main partition
💡 **Note:** If you use the Linux-Voice-Assistant Image LVA and Snapcast will be included in the project directory.
8. Automatically deploy each Docker Compose project found
9. Optionally set up regular re-deployments via Crontab

This repository contains fully prepared images for specific voice hardware of Homeassistant with all needed drivers.


## Features

- Automated build of a customized Raspberry Pi OS image using GitHub Actions
- Easy addition of Docker Compose projects via the main partition (compose directory)
- Configurable regular re-deployments via a simple configuration file
- No manual configuration of the Raspberry Pi required
- Image prepared for audio usage with the pipewire server
- Prebuild images with drivers for various devices


## Usage

### Hardware

There is a seperated page for additional hardware like speaker or 3D-Prints here: [docs/hardware.md](docs/hardware.md).

### Images

Here is a Image Overview specific for each hardware if needed:

| Name                                               | Hardware                                                                                                   | What's in the Image?                                                                                                                                                                                                                                                                                                                                                                                  |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Base Image**                                     |                                                                                                            | • Docker & Docker Compose (piCompose)<br>• Automatic Docker Compose deployment<br>• Pipewire Audio Server<br>• SSH enabled (pi User)                                                                                                                                                                                                                                                              |
| **Satellite1 Hat**                           | <img src="docs/sattelite1-hat.jpg" alt="ReSpeaker Lite Board" style="width: 200px; height: auto;">         | • Base Image<br>• Satellite1 Hat Driver                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| **Sattelite1 Hat**<br>**+Linux-Voice-Assistant**<br>**+Snapcast**   | <img src="docs/sattelite1-hat.jpg" alt="ReSpeaker Lite Board" style="width: 200px; height: auto;">         | • Satellite1 Hat Image<br>• Linux-Voice-Assistant (OpenHomeFoundation)<br>• Snapcast MultiRoom Audio Client<br>• Pre-configured for Home Assistant                                                                                                                                                                                                                                                |
| **ReSpeaker 2-Mic HAT v1**                         | <img src="docs/respeaker_2michats.webp" alt="ReSpeaker 2-Mics Pi HAT" style="width: 200px; height: auto;"> | • Base Image<br>• Seeed Voicecard Driver                                                                                                                                                                                                                                                                                                                                                            |
| **ReSpeaker 2-Mic HAT v1**<br>**+Linux-Voice-Assistant**<br>**+Snapcast** | <img src="docs/respeaker_2michats.webp" alt="ReSpeaker 2-Mics Pi HAT" style="width: 200px; height: auto;"> | • 2-Mic HAT Image<br>• Linux-Voice-Assistant (OpenHomeFoundation)<br>• 2-Mic HAT GPIO LED Control<br>• Snapcast MultiRoom Audio Client<br>• Pre-configured for Home Assistant                                                                                                                                                                                                                        |
| **ReSpeaker Lite**                                 | <img src="docs/respeaker_lite.jpg" alt="ReSpeaker Lite Board" style="width: 200px; height: auto;">         | • Base Image<br>• Audio keep-alive service<br>• Workaround for connectivity issues in combination with the Pi Zero 2W.<br><br><span style="color: red;">There is a USB connectivity issue with the Pi Zero 2W. I cannot recommend this board if you want to use it with that. Use Pi3 or higher.</span>                                                                                                                                                                                                |
| **ReSpeaker Lite**<br>**+Linux-Voice-Assistant**<br>**+Snapcast**         | <img src="docs/respeaker_lite.jpg" alt="ReSpeaker Lite Board" style="width: 200px; height: auto;">         | • ReSpeaker Lite Image<br>• Linux-Voice-Assistant (OpenHomeFoundation)<br>• Snapcast MultiRoom Audio Client<br>• Pre-configured for Home Assistant<br>• Workaround for connectivity issues in combination with the Pi Zero 2W.<br><br><span style="color: red;">There is a USB connectivity issue with the Pi Zero 2W. If you want to use it with that, you need to use Pi3 or higher.</span>                                          |

### Download and installation

You can [download](https://github.com/florian-asche/PiCompose/releases) the image and configure keyboard, timezone and wifi credentials with the `raspi-config` tool. But if you use the Raspberry Pi Imager tool you can also configure the wifi credentials before you burn the image to your sd card.

In order to use the feature where you can change the settings in the `Raspberry Pi Imager >=v2.5.0` you need to set a custom image repository in the settings section.

Use the custom repo: `https://github.com/florian-asche/PiCompose/releases/download/v1.0.4/rpi-imager-repo.json`

### Customization (optional)

You can customize the PiCompose configuration in the /compose directory on the root filesystem. You can change how it is updated, how it is handling a reboot and you can remove snapcast if you dont want to use it.

You can also add your own docker-compose projects to the system:

1. Create directories for your Docker Compose projects in the `compose` folder on the main partition if you dont use a fully prebuild image.
2. Place your docker-compose.yml files and associated configurations in the appropriate subdirectories (see the example directory)
3. Configure the `picompose.conf` file to include your projects.

### First start's

Make sure, that you configured your wifi credentials before the first boot. You can do this with the RPI-Imager tool when burning the image to your sd card.

On the first boot in will create new ssh public keys for the ssh serve. You can see that if you have a monitor connected to your system.
The system will automatically reboot and install the audio drivers.

After that you can login with the user `pi`. You can change the password if you didnt change it before with the imager tool.
You will notice that the hardware is not visible if you run `aplay -L`.

❗ *You need to manually reboot one more time.*

After that `aplay -L` should show the `seeed2micvoicec` or `Lite` soundcard depending on your hardware.

piCompose should download and install the containers.
You can watch the /var/log/picompose.log logfile if you want to monitor the process.
The process can take some time, since it downloads images from the internet!


## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for information on the development and build process.

### Example projects, that you can run on this:

- [docker-snapcast](https://github.com/florian-asche/docker-snapcast) - A Docker image for Snapcast server and client, providing multi-room audio streaming capabilities
- [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant) - A remote voice satellite implementation using the ESPHome protocol

## License

This project is released under the [BSD-3-Clause License](LICENSE).
