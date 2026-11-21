# Project Context for AI Agents

## Behaviour

- NEVER automatically reply on GitHub (PRs, issues or discussions) and NEVER push or open a PR without explicit consent from the developer.
- Pushing a branch does not build images. A full image build of every variant, published as a prerelease named after the branch, only starts when the developer runs `Build All PiCompose` manually (`workflow_dispatch`) for that branch, because the build is expensive. See "Branching and PRs".
- Images cannot be built or booted locally. Never claim that image, driver, audio or boot behavior is verified unless it was actually exercised on hardware. State plainly what was only syntax-checked.
- When a change alters what users see or must configure (`picompose.conf` options, `/compose` layout, default services, supported hardware), update `README.md` and the matching file in `docs/` in the same change. Breaking changes also go into `breaking_changes.md`.
- When the code and the docs contradict each other, ask which one is wrong instead of silently picking one.

## Project Overview

**PiCompose** builds ready-to-use Raspberry Pi OS images (via `pi-gen`) that deploy Docker Compose projects automatically. The main use case is voice hardware for Home Assistant running [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant) (**LVA**) and Snapcast.

### Architecture
- **Image build**: GitHub Actions run `usimd/pi-gen-action` with a list of custom pi-gen stages. Each hardware variant is one stage list.
- **Runtime manager**: `compose-manager.sh` runs as a systemd oneshot (`picompose.service`). It scans `/compose/*/`, reads each project's `picompose.conf`, and runs `docker compose up -d`, optionally with image pull and a cron schedule.
- **Audio**: PipeWire with PulseAudio and ALSA bridges. Hardware stages add drivers and per-device volume handling.
- **Distribution**: images are attached to GitHub Releases. A generated `rpi-imager.json` makes them selectable in Raspberry Pi Imager.

### Key Components
- `01-stage-base/` - base stage: PiCompose APT repository (`picompose-archive-keyring`), Docker repository and packages, optional packages, the package `picompose-core` (compose manager, PipeWire config files, hostname service), PipeWire packages
- `02-stage-audiodriver-*/` - one stage per hardware (2-Mic HAT v1/v2, ReSpeaker Lite, Satellite1)
- `03-stage-linux-voice-assistant/` - preconfigured `lva` and `snapcast` compose projects under `/compose`
- `04-stage-finish/` - user shell config and image cleanup
- `.github/workflows/` - `build-all.yml` (all variants), `build-image-template.yml` (one image), `create-rpi-image-json.yml`, `gen_changelog.yml`
- `scripts/generate-imager-json.py` - builds `rpi-imager.json` from the GitHub releases
- `docs/` - one page per supported hardware plus PipeWire debugging

## Development Commands

There is no test suite and no linter configuration in this repository. Use these checks on whatever you changed:

```bash
bash -n path/to/script.sh                      # shell syntax check
yamllint -d relaxed .github/workflows/         # workflow YAML sanity check
python3 -I -m py_compile scripts/generate-imager-json.py
```

`shellcheck` is the preferred shell linter, use it if it is installed.

## Code Style

### Language

All documentation (`docs/`, `README.md`, `*.md`), code comments, log messages and commit/PR text are written in English, regardless of the language used in the conversation with the developer.

### Comments

Only use comments to explain complex, multi-line blocks of code or non-obvious system behavior (for example why a PipeWire setting exists). Do not comment obvious operations. Keep existing comments when editing code.

### Shell scripts

- pi-gen host scripts (`NN-run.sh`) start with `#!/bin/bash -e` and install files with `install -v -m <mode> files/<name> "${ROOTFS_DIR}/<target>"`.
- Commands that must run inside the image go into an `on_chroot << EOF ... EOF` block or a `NN-run-chroot.sh` file.
- Runtime scripts that ship in the image (`compose-manager.sh`, `configure_audio.sh`, ...) must not assume a user session or a specific audio device being present at start. Wait with a timeout instead.
- Quote variables and keep the style of the surrounding script.

### Commit and PR titles

Titles describe the change functionally in the style of the existing history, for example `fix(wireplumber): install no-suspend config under its real file name` or `feat(lva): add new environment configuration options`. Do not edit `CHANGELOG.md` by hand, it is generated from release notes.

## Branching and PRs

- All PRs target `main`.
- Release images are built from `v*.*.*` tags.
- Name the branch of a change after its type: `feature/<name>`, `fix/<name>`, `hotfix/<name>` or `bugfix/<name>` for changes to the image, `docs/<name>` or `ci/<name>` for documentation, AI instructions and repository settings.
- The image build of `build-all.yml` starts only for pushes to `main`, for `v*.*.*` tags and on request. A change to a stage, a driver, a configuration file or any other content of the image is tested before the merge by running `Build All PiCompose` manually for the branch (Actions tab, "Run workflow", or `gh workflow run build-all.yml --ref <branch>`). The branch name does not matter for this.
- Never start the build yourself. Ask the developer to start it and say in the PR that an image build is still pending.

## Verification Checklist

Before claiming completion:
- [ ] Ran `bash -n` on every changed shell script and checked workflow YAML
- [ ] Checked that every stage list in `build-all.yml` still points at existing stage directories
- [ ] Did NOT claim image or hardware behavior is verified unless it was actually run on a Raspberry Pi
- [ ] `README.md`, `docs/` and `breaking_changes.md` match the change
- [ ] Changes are focused on one feature or fix per change
- [ ] The branch name fits the change: `feature/`, `fix/`, `hotfix/` or `bugfix/` for changes to the image, `docs/` or `ci/` for the rest

## Areas Requiring Extra Care

- `compose-manager.sh` (in the package `picompose-core`, repository PiCompose-Package-Core, not in this repository) - runs as root on every boot and from cron, and can take down or redeploy user containers
- `02-stage-audiodriver-*/` - kernel driver builds and ALSA/WirePlumber configuration are hardware dependent
- `.github/workflows/` - a broken stage list or release step wastes a long ARM image build
- `scripts/generate-imager-json.py` - parses release asset file names, so renaming an `image-name` breaks hardware detection
