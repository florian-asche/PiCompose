@AGENTS.md

# AI Working Guide for PiCompose

Dense map of the repository for AI agents. `AGENTS.md` (imported above) holds the rules, this file holds the knowledge needed to change things without re-reading every stage. When this file and the code disagree, the code wins. Fix this file in the same change.

## Fast checks

| Task | Command |
|------|---------|
| Syntax of a shell script | `bash -n path/to/script.sh` |
| Workflow YAML | `yamllint -d relaxed .github/workflows/` |
| Imager script | `python3 -I -m py_compile scripts/generate-imager-json.py` |
| List stage directories | `ls -d 0*-stage-*` |

`shellcheck` and `actionlint` are not installed on the dev machine. A real image build only happens in GitHub Actions on an ARM runner and takes a long time.

## Build pipeline

```
push to main / feature/* / fix/* / hotfix/* / bugfix/*  or  tag v*.*.*
 └─ build-all.yml        one job per image variant
     └─ build-image-template.yml   (workflow_call)
         ├─ usimd/pi-gen-action  on ubuntu-24.04-arm, release trixie, user pi, SSH on
         ├─ SHA256 + file size
         └─ softprops/action-gh-release
              tag     → release with generated notes
              branch  → prerelease named after the branch, no notes
 └─ create-rpi-image-json.yml   recreates the `rpi-imager-json` release (runs with `if: always()`)
release published → gen_changelog.yml → CHANGELOG.md on main
```

`generate_release_notes` and `CHANGELOG.md` are driven by `.github/release.yml`, which groups PRs by label (`breaking-change`, `enhancement`, everything else).

### Stage lists per variant

Every variant is `stage0 stage1 stage2 ./01-stage-base <hardware stage> [./03-stage-linux-voice-assistant] ./04-stage-finish`. The image name decides the output file, so renaming one breaks `scripts/generate-imager-json.py`.

| Hardware stage | Plain image | With LVA + Snapcast |
|----------------|-------------|---------------------|
| `02-stage-audiodriver-other` | `PiCompose` | `PiCompose_Linux-Voice-Assistant` |
| `02-stage-audiodriver-2michat-v1` | `PiCompose-2MicHat-v1` | `PiCompose_2MicHat-v1_Linux-Voice-Assistant` |
| `02-stage-audiodriver-2michat-v2` | `PiCompose-2MicHat-v2` | `PiCompose_2MicHat-v2_Linux-Voice-Assistant` |
| `02-stage-audiodriver-respeaker_lite` | `PiCompose-Respeaker_lite` | `PiCompose_Respeaker_lite_Linux-Voice-Assistant` |
| `02-stage-audiodriver-satellite1-v1.0` | `PiCompose_Satellite1-v1.0` | `PiCompose_Satellite1-v1.0_Linux-Voice-Assistant` |

Driver approach differs per hardware, all in `01-driver/03-run-chroot.sh`:
- `2michat-v1` builds the seeed-voicecard DKMS driver and ships `seeed-voicecard.service`. The README flags this image as pinned to an older build, see the linked upstream issue.
- `2michat-v2` only builds a device-tree overlay, the codec driver is in the mainline kernel.
- `satellite1-v1.0` downloads a custom FutureProofHomes kernel and setup/SDK `.deb` packages from GitHub releases. Bumping those versions changes the image kernel.

## pi-gen conventions used here

- Each stage has a `prerun.sh` with `copy_previous` when `${ROOTFS_DIR}` is missing. Copy it for every new stage.
- Inside a stage, sub-directories run in numeric order. Inside a sub-directory: `NN-packages` (apt list), `NN-run.sh` (on the host, uses `${ROOTFS_DIR}`), `NN-run-chroot.sh` (inside the image), `files/` (payload).
- Services are installed with `install` into `${ROOTFS_DIR}/etc/systemd/system/` and enabled inside `on_chroot`.
- `04-stage-finish/99-cleanup` removes apt caches and SSH host keys (`/etc/ssh/reconfigure` regenerates them on first boot). Do not move cleanup work elsewhere.

## Runtime: compose-manager

`01-stage-base/02-picompose/files/compose-manager.sh` is installed as `/usr/bin/compose-manager.sh` and started by `picompose.service` (oneshot, `boot` argument, after Docker and network-online).

- `boot` and no argument: wait for Docker (90 s timeout), clear old cron entries, scan `/compose/*/`, for each project set up cron and deploy.
- `redeploy <project>`: deploy one project, called from cron.
- First boot is detected by the marker `/compose/.first_run_completed`. On the first run every project is deployed regardless of `BOOT_ENABLED`.
- Logs go to `/var/log/picompose.log`.
- Per-project `picompose.conf` is sourced as shell. Keys: `DISABLED`, `BOOT_ENABLED`, `BOOT_IMAGE_PULL`, `CRON_ENABLED`, `CRON_SCHEDULE`, `CRON_IMAGE_PULL`. The commented template is in `README.md`, keep it in sync when adding a key.
- A project is a directory with a compose file (`docker-compose.yml/.yaml` or `compose.yml/.yaml`) plus `picompose.conf`. Directories without a config are skipped with a log line.
- The script exports `HOSTNAME` before `docker compose up`, so compose files can use it.

Preinstalled projects: `example` (hello-world) from `01-stage-base`, and `lva` plus `snapcast` from `03-stage-linux-voice-assistant`. Snapcast ships with `DISABLED=true`. The `lva` project has a one-shot `fix-permissions` service that chowns the volumes before the main container starts, and uses the PipeWire PulseAudio socket of user 1000.

## Audio setup

- `01-stage-base/03-install-pipewire-audio`: PipeWire drop-in configs (clock rate, real-time scheduling module), a WirePlumber rule for ALSA outputs (volume, no suspend), the ALSA bridge, `pi` in the `pipewire` group for rtprio, and lingering for `pi` so services run without a login session.
- Hardware stages add a `configure_audio.service` plus script that waits (with a retry limit) for the card/control and sets the hardware volume through `wpctl`/`amixer`. The ReSpeaker Lite stage adds a keep-audio-alive service as a workaround for connectivity problems on the Pi Zero 2W.
- Some earlier file names in git history differ (for example `50-volume.conf`). Check `git log` before assuming a file never existed.
- Debugging notes for users: `docs/pipewire_debugging.md`.

## Change checklists

**New hardware variant**
1. New `02-stage-audiodriver-<name>/` with `prerun.sh` and its sub-directories.
2. Two jobs in `build-all.yml` (plain and `-lva`), and add both to `needs` of `generate-rpi-imager-json`.
3. Extend `extract_metadata()` in `scripts/generate-imager-json.py` so the new image name maps to a hardware label. It currently also knows a `Satellite1-v1.1` name that has no build job yet.
4. Row in the README image table and a `docs/hardware_<name>.md` page.

**New `picompose.conf` option**
1. Handle it in `compose-manager.sh` (`setup_cron` / `deploy_compose`) with a safe default.
2. Add it to the template files under `01-stage-base/02-picompose/files/example/`, `03-stage-linux-voice-assistant/*/files/*/` and to the README block.

**New preinstalled compose project**
1. Directory under `03-stage-linux-voice-assistant/` with `01-run.sh` and `files/<name>/{docker-compose.yml,.env,picompose.conf}`.
2. Mention it in the README overview.

**New LVA environment option**
The LVA options live in `03-stage-linux-voice-assistant/01-linux-voice-assistant/files/lva/.env` and are passed to the container via `env_file`. The names must match the LVA project (`docker-entrypoint.sh` and `.env.example` there).

## Gotchas

- Docker images in the preinstalled compose files come from `ghcr.io/ohf-voice/linux-voice-assistant`. A user report about a missing LVA feature is often a stale image tag in `.env` (`LVA_IMAGE_TAG`), not a PiCompose bug.
- The default login is `pi` / `raspberry`, and the Raspberry Pi Imager customization must keep the user `pi` because services and paths assume it.
- A manual reboot after the first boot is required for the audio driver to show up. This is documented behavior, not a bug.
- `DEVELOPMENT.md` and `scripts/test-compose-manager.sh` still reference the old `stage-picompose/00-boot-scripts/` layout, and the test script has German comments and log text. Do not trust their paths. New code and docs are English.
- Pushing a `feature/*`, `fix/*`, `hotfix/*` or `bugfix/*` branch builds all ten images and publishes prereleases. Do not push without consent. Changes to the image still need such a branch name (and a PR from it), because that build is the test. Documentation-only changes use a `docs/*` or `ci/*` branch, which is not built. See "Branching and PRs" in `AGENTS.md`.
- `README.md` links the badge to a workflow file named `build-image.yml`, the real file is `build-all.yml`.

## Documentation map

| Doc | Contents |
|-----|----------|
| `README.md` | Overview, image table, installation via Raspberry Pi Imager, `picompose.conf` reference, first start |
| `DEVELOPMENT.md` | Build process and release flow (partly outdated paths, see Gotchas) |
| `breaking_changes.md` | Per-version migration notes, update for every breaking change |
| `docs/hardware_*.md` | One page per supported hardware |
| `docs/pipewire_debugging.md` | Audio troubleshooting on the device |
| `CHANGELOG.md` | Generated from release notes, never edit by hand |

## Contribution constraints

- PR titles use the `type(scope): description` style seen in the history.
- Nothing is posted to GitHub without explicit consent from the developer.
- Check `git branch -r` before suggesting a base branch. Development happens on `main`.
