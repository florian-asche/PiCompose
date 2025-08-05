# Development Guide

This guide provides information about local development and the build process for PiCompose.

## Overview

PiCompose uses [pi-gen-action](https://github.com/usimd/pi-gen-action), a wrapper for the official pi-gen tool, to create Raspberry Pi OS images with automatic Docker Compose deployment capabilities.

## Prerequisites for Local Development

- Git
- Basic knowledge of Bash shell programming
- An IDE for editing shell scripts (e.g., VS Code)

## Project Structure

The project follows the standard structure for custom pi-gen stages:

- `stage-picompose/` - Custom stage for PiCompose
  - `00-boot-scripts/` - Boot scripts and Docker Compose manager
    - `files/compose-manager.sh` - The main script for the Docker Compose manager
    - `01-run.sh` - Installation script for the manager and systemd service
  - `00-packages/` - Docker installation and repository setup
    - `00-packages-nr` - List of packages to be installed
    - `01-run.sh` - Script to set up the Docker repository
  - `99-cleanup/` - Cleanup scripts for the final image
- `.github/workflows/` - GitHub Actions workflow files

## Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/YOURUSERNAME/PiCompose.git
   cd PiCompose
   ```

2. The main development work focuses on:
   - Modifying the Compose manager script (`stage-picompose/00-boot-scripts/files/compose-manager.sh`)
   - Adjusting the installation scripts in `stage-picompose/`

3. To perform local tests of the pi-gen process, you can consult the [pi-gen-action](https://github.com/usimd/pi-gen-action) README and apply the methods described there.

## Build Process

The build process runs automatically via GitHub Actions:

1. Checkout of the repository
2. Execution of the build with pi-gen-action and the specified parameters
   - The existing `stage-picompose` is directly referenced in the `stage-list`
3. Compression and upload of the finished image

The workflow supports:
- Detailed output for better troubleshooting (`verbose-output: true`)
- Increased disk space for large images (`increase-runner-disk-size: true`)
- Automatic releases for tags

## Local Testing of the Compose Manager

You can test the `compose-manager.sh` script locally without creating a complete image:

```bash
./scripts/test-compose-manager.sh
```

This script creates a temporary test environment and simulates the boot partition with Docker Compose projects.

## Publishing

The project uses GitHub Actions to automatically build images and publish them as GitHub Releases.

1. Create a new tag to trigger a release build:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. The GitHub Actions workflow will automatically start and build and publish the image.

## Example Scenarios

Based on the [pi-gen-action examples](https://github.com/usimd/pi-gen-action#scenarios), the following features have been implemented:

1. **Custom Stage Structure**: Using a custom stage structure in `stage-picompose/`
2. **Detailed Build Output**: Activation of the `verbose-output` option for better troubleshooting
3. **Disk Space Optimization**: Activation of the `increase-runner-disk-size` option for larger images

## Troubleshooting

### Common Issues

- **Build fails in workflow**: Check the GitHub Action logs for details.
- **Problems with boot scripts**: Test the `compose-manager.sh` script locally with the test script. 