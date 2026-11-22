<a id="v1.2.0"></a>
# [v1.2.0](https://github.com/florian-asche/PiCompose/releases/tag/v1.2.0) - 2026-11-22

<!-- Release notes generated using configuration in .github/release.yml at main -->

See https://github.com/florian-asche/PiCompose/discussions/89 for more information about our news!

## What's Changed
### Breaking Changes 🛠
* Remove the audiodriver-other stage and build the plain images without a hardware stage by [@florian-asche](https://github.com/florian-asche) in [#96](https://github.com/florian-asche/PiCompose/pull/96)
* feat(2michat-v2): install picompose-driver-2michat-v2 from the APT repository by [@florian-asche](https://github.com/florian-asche) in [#97](https://github.com/florian-asche/PiCompose/pull/97)
* feat(2michat-v1): install picompose-driver-2michat-v1 from the APT repository by [@florian-asche](https://github.com/florian-asche) in [#98](https://github.com/florian-asche/PiCompose/pull/98)
* Install the Home Assistant satellite projects from the picompose-software-ha-satellite package by [@florian-asche](https://github.com/florian-asche) in [#85](https://github.com/florian-asche/PiCompose/pull/85)
* feat(respeaker-lite): install the audio setup from picompose-driver-respeaker-lite by [@florian-asche](https://github.com/florian-asche) in [#91](https://github.com/florian-asche/PiCompose/pull/91)
* feat(satellite1): install satellite1-rpi-setup-trixie and satellite1-rpi-sdk from the APT repository by [@florian-asche](https://github.com/florian-asche) in [#92](https://github.com/florian-asche/PiCompose/pull/92)
### Exciting New Features 🎉
* feat(apt): set up the PiCompose APT repository with picompose-archive-keyring by [@florian-asche](https://github.com/florian-asche) in [#82](https://github.com/florian-asche/PiCompose/pull/82)
### Bug Fixes 🐛
* fix(compose-manager): call the installed script path from cron by [@florian-asche](https://github.com/florian-asche) in [#80](https://github.com/florian-asche/PiCompose/pull/80)
* Add download and extract size to rpi-imager.json entries by [@florian-asche](https://github.com/florian-asche) in [#90](https://github.com/florian-asche/PiCompose/pull/90)
### Other Changes
* perf(pipewire): add pi user to the pipewire group for real-time priority by [@florian-asche](https://github.com/florian-asche) in [#69](https://github.com/florian-asche/PiCompose/pull/69)
* fix(pipewire): install linux-voice-assistant.conf into the directory PipeWire reads by [@florian-asche](https://github.com/florian-asche) in [#70](https://github.com/florian-asche/PiCompose/pull/70)
* fix(wireplumber): keep audio sink from suspending by [@florian-asche](https://github.com/florian-asche) in [#68](https://github.com/florian-asche/PiCompose/pull/68)
* fix(pipewire): do not force a 16 kHz clock rate by [@florian-asche](https://github.com/florian-asche) in [#71](https://github.com/florian-asche/PiCompose/pull/71)
* refactor(wireplumber): merge volume and no-suspend rules into one file by [@florian-asche](https://github.com/florian-asche) in [#72](https://github.com/florian-asche/PiCompose/pull/72)
* docs(ai): add AGENTS.md and CLAUDE.md for AI agents by [@florian-asche](https://github.com/florian-asche) in [#73](https://github.com/florian-asche/PiCompose/pull/73)
* ci(repo): add issue forms, PR template, PR label workflow, AI policy and Dependabot by [@florian-asche](https://github.com/florian-asche) in [#74](https://github.com/florian-asche/PiCompose/pull/74)
* docs(ai): name branches after their type so that changes to the image get built by [@florian-asche](https://github.com/florian-asche) in [#83](https://github.com/florian-asche/PiCompose/pull/83)
* docs(readme): link the CI badge to the workflow build-all.yml by [@florian-asche](https://github.com/florian-asche) in [#84](https://github.com/florian-asche/PiCompose/pull/84)
* Rename the stage 01-stage-picompose to 01-stage-base by [@florian-asche](https://github.com/florian-asche) in [#86](https://github.com/florian-asche/PiCompose/pull/86)
* Split Docker and helper packages of the base stage into separate steps by [@florian-asche](https://github.com/florian-asche) in [#87](https://github.com/florian-asche/PiCompose/pull/87)
* Install the compose manager, hostname and PipeWire config from picompose-core by [@florian-asche](https://github.com/florian-asche) in [#88](https://github.com/florian-asche/PiCompose/pull/88)
* bump softprops/action-gh-release from 2 to 3 by [@dependabot](https://github.com/dependabot)[bot] in [#76](https://github.com/florian-asche/PiCompose/pull/76)
* bump actions/checkout from 3 to 7 by [@dependabot](https://github.com/dependabot)[bot] in [#78](https://github.com/florian-asche/PiCompose/pull/78)
* ci(dependabot): check for updates daily by [@florian-asche](https://github.com/florian-asche) in [#94](https://github.com/florian-asche/PiCompose/pull/94)
* bump usimd/pi-gen-action from 1 to 2 by [@dependabot](https://github.com/dependabot)[bot] in [#95](https://github.com/florian-asche/PiCompose/pull/95)
* bump actions/cache from 4 to 6 by [@dependabot](https://github.com/dependabot)[bot] in [#79](https://github.com/florian-asche/PiCompose/pull/79)
* bump docker/setup-qemu-action from 3 to 4 by [@dependabot](https://github.com/dependabot)[bot] in [#75](https://github.com/florian-asche/PiCompose/pull/75)
* bump actions/github-script from 7 to 9 by [@dependabot](https://github.com/dependabot)[bot] in [#77](https://github.com/florian-asche/PiCompose/pull/77)
* fix(imager): fetch all releases so the development entry is generated by [@florian-asche](https://github.com/florian-asche) in [#99](https://github.com/florian-asche/PiCompose/pull/99)
* ci(imager): allow triggering the rpi-imager.json workflow manually by [@florian-asche](https://github.com/florian-asche) in [#100](https://github.com/florian-asche/PiCompose/pull/100)
* fix(imager): authenticate GitHub API requests to avoid the rate limit by [@florian-asche](https://github.com/florian-asche) in [#101](https://github.com/florian-asche/PiCompose/pull/101)
* ci(build): build images only on main, tags and manual runs by [@florian-asche](https://github.com/florian-asche) in [#102](https://github.com/florian-asche/PiCompose/pull/102)
* docs(readme): add local-audio and bt-proxy to the projects of the package by [@florian-asche](https://github.com/florian-asche) in [#105](https://github.com/florian-asche/PiCompose/pull/105)
* ci(release): delete prereleases older than three months by [@florian-asche](https://github.com/florian-asche) in [#103](https://github.com/florian-asche/PiCompose/pull/103)
* Regenerate the imager JSON after the cleanup workflows by [@florian-asche](https://github.com/florian-asche) in [#106](https://github.com/florian-asche/PiCompose/pull/106)
* Skip the image build for changes to docs and Markdown files by [@florian-asche](https://github.com/florian-asche) in [#107](https://github.com/florian-asche/PiCompose/pull/107)
* ci(imager): group imager entries into stable, other versions, development and branches by [@florian-asche](https://github.com/florian-asche) in [#104](https://github.com/florian-asche/PiCompose/pull/104)

## New Contributors
* [@dependabot](https://github.com/dependabot)[bot] made their first contribution in [#76](https://github.com/florian-asche/PiCompose/pull/76)

**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.4...v1.2.0

[Changes][v1.2.0]


<a id="v1.1.4"></a>
# [v1.1.4](https://github.com/florian-asche/PiCompose/releases/tag/v1.1.4) - 2026-07-26

<!-- Release notes generated using configuration in .github/release.yml at main -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

<!-- Release notes generated using configuration in .github/release.yml at v1.1.4 -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

<!-- Release notes generated using configuration in .github/release.yml at v1.1.4 -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

<!-- Release notes generated using configuration in .github/release.yml at v1.1.4 -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

<!-- Release notes generated using configuration in .github/release.yml at v1.1.4 -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

<!-- Release notes generated using configuration in .github/release.yml at v1.1.4 -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

<!-- Release notes generated using configuration in .github/release.yml at v1.1.4 -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

<!-- Release notes generated using configuration in .github/release.yml at v1.1.4 -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

<!-- Release notes generated using configuration in .github/release.yml at v1.1.4 -->

## What's Changed
### Other Changes
* feat(lva): add new environment configuration options by [@florian-asche](https://github.com/florian-asche) in [#64](https://github.com/florian-asche/PiCompose/pull/64)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4

[Changes][v1.1.4]


<a id="v1.1.3"></a>
# [v1.1.3](https://github.com/florian-asche/PiCompose/releases/tag/v1.1.3) - 2026-07-26

<!-- Release notes generated using configuration in .github/release.yml at main -->

## What's Changed
### Other Changes
* perf(pipewire): enable real-time scheduling by [@florian-asche](https://github.com/florian-asche) in [#60](https://github.com/florian-asche/PiCompose/pull/60)
* fix(sat1): Fix several documentation issues and default sat1 hardware volume by [@florian-asche](https://github.com/florian-asche) in [#63](https://github.com/florian-asche/PiCompose/pull/63)

**Full Changelog**: https://github.com/florian-asche/PiCompose/commits/v1.1.3

<!-- Release notes generated using configuration in .github/release.yml at main -->

<!-- Release notes generated using configuration in .github/release.yml at v1.1.3 -->

## What's Changed
### Other Changes
* fix(sat1): Fix several documentation issues and default sat1 hardware volume by [@florian-asche](https://github.com/florian-asche) in [#63](https://github.com/florian-asche/PiCompose/pull/63)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.2...v1.1.3

<!-- Release notes generated using configuration in .github/release.yml at v1.1.3 -->

## What's Changed
### Other Changes
* fix(sat1): Fix several documentation issues and default sat1 hardware volume by [@florian-asche](https://github.com/florian-asche) in [#63](https://github.com/florian-asche/PiCompose/pull/63)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.1.2...v1.1.3

[Changes][v1.1.3]


<a id="v1.1.2"></a>
# [v1.1.2](https://github.com/florian-asche/PiCompose/releases/tag/v1.1.2) - 2026-07-26

<!-- Release notes generated using configuration in .github/release.yml at main -->

## What's Changed
### Exciting New Features 🎉
* Add Satellite1 v1.0 from FutureProofHomes by [@florian-asche](https://github.com/florian-asche) in [#51](https://github.com/florian-asche/PiCompose/pull/51)
* Fix/sat1 audioconfig by [@florian-asche](https://github.com/florian-asche) in [#55](https://github.com/florian-asche/PiCompose/pull/55)
* Re-Enable the Respeaker v1 version builds by [@florian-asche](https://github.com/florian-asche) in [#61](https://github.com/florian-asche/PiCompose/pull/61)
* Sat1: Update kernel to v6.18.34 by [@florian-asche](https://github.com/florian-asche) in [#62](https://github.com/florian-asche/PiCompose/pull/62)
* perf(pipewire): enable real-time scheduling by [@florian-asche](https://github.com/florian-asche) in [#60](https://github.com/florian-asche/PiCompose/pull/60)

### Other Changes
* feat(lva): add support for custom docker image and tag overrides by [@florian-asche](https://github.com/florian-asche) in [#44](https://github.com/florian-asche/PiCompose/pull/44)
* docs: update hardware documentation and README by [@florian-asche](https://github.com/florian-asche) in [#48](https://github.com/florian-asche/PiCompose/pull/48)
* Fix/build images by [@florian-asche](https://github.com/florian-asche) in [#49](https://github.com/florian-asche/PiCompose/pull/49)


## New Contributors
* [@genericJE](https://github.com/genericJE) made their first contribution in [#41](https://github.com/florian-asche/PiCompose/pull/41)

**Full Changelog**: https://github.com/florian-asche/PiCompose/commits/v1.1.2

<!-- Release notes generated using configuration in .github/release.yml at v1.1.2 -->

[Changes][v1.1.2]


<a id="v1.1.1"></a>
# [v1.1.1](https://github.com/florian-asche/PiCompose/releases/tag/v1.1.1) - 2026-04-20

<!-- Release notes generated using configuration in .github/release.yml at main -->

## What's Changed

### Other Changes
* Bugfix: Set volume to 100% on startup by [@florian-asche](https://github.com/florian-asche) in [#34](https://github.com/florian-asche/PiCompose/pull/34)
* Fix github build by [@florian-asche](https://github.com/florian-asche) in [#30](https://github.com/florian-asche/PiCompose/pull/30)
* Disable voicecard install script after sucessfull run by [@florian-asche](https://github.com/florian-asche) in [#28](https://github.com/florian-asche/PiCompose/pull/28)
* skip hostname change if hostname is already changed by rpi-imager by [@florian-asche](https://github.com/florian-asche) in [#25](https://github.com/florian-asche/PiCompose/pull/25)
* Update LVA to latest version by [@florian-asche](https://github.com/florian-asche) in [#31](https://github.com/florian-asche/PiCompose/pull/31)
* add deploy on first boot by [@florian-asche](https://github.com/florian-asche) in [#32](https://github.com/florian-asche/PiCompose/pull/32)
* feat(picompose): add project disable flag and refactor deploy logic by [@florian-asche](https://github.com/florian-asche) in [#33](https://github.com/florian-asche/PiCompose/pull/33)
* ci(github): add release config and changelog generation workflow by [@florian-asche](https://github.com/florian-asche) in [#35](https://github.com/florian-asche/PiCompose/pull/35)
* fix(picompose): fix deploy function flow and variable references by [@florian-asche](https://github.com/florian-asche) in [#37](https://github.com/florian-asche/PiCompose/pull/37)
* Feature/reboot on driver install by [@florian-asche](https://github.com/florian-asche) in [#38](https://github.com/florian-asche/PiCompose/pull/38)



**Full Changelog**: https://github.com/florian-asche/PiCompose/commits/v1.1.1

<!-- Release notes generated using configuration in .github/release.yml at v1.1.1 -->

[Changes][v1.1.1]


<a id="v1.1.0"></a>
# [v1.1.0](https://github.com/florian-asche/PiCompose/releases/tag/v1.1.0) - 2026-02-16

## What's Changed
* Refactoring by [@florian-asche](https://github.com/florian-asche) in [#19](https://github.com/florian-asche/PiCompose/pull/19)
* remove wyoming-satellite by [@florian-asche](https://github.com/florian-asche) in [#20](https://github.com/florian-asche/PiCompose/pull/20)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.0.4...v1.1.0

## What's Changed
* Refactoring by [@florian-asche](https://github.com/florian-asche) in [#19](https://github.com/florian-asche/PiCompose/pull/19)
* remove wyoming-satellite by [@florian-asche](https://github.com/florian-asche) in [#20](https://github.com/florian-asche/PiCompose/pull/20)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.0.4...v1.1.0

## What's Changed
* Refactoring by [@florian-asche](https://github.com/florian-asche) in [#19](https://github.com/florian-asche/PiCompose/pull/19)
* remove wyoming-satellite by [@florian-asche](https://github.com/florian-asche) in [#20](https://github.com/florian-asche/PiCompose/pull/20)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.0.4...v1.1.0

## What's Changed
* Refactoring by [@florian-asche](https://github.com/florian-asche) in [#19](https://github.com/florian-asche/PiCompose/pull/19)
* remove wyoming-satellite by [@florian-asche](https://github.com/florian-asche) in [#20](https://github.com/florian-asche/PiCompose/pull/20)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.0.4...v1.1.0

## What's Changed
* Refactoring by [@florian-asche](https://github.com/florian-asche) in [#19](https://github.com/florian-asche/PiCompose/pull/19)
* remove wyoming-satellite by [@florian-asche](https://github.com/florian-asche) in [#20](https://github.com/florian-asche/PiCompose/pull/20)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.0.4...v1.1.0

[Changes][v1.1.0]


<a id="v1.0.4"></a>
# [v1.0.4](https://github.com/florian-asche/PiCompose/releases/tag/v1.0.4) - 2025-08-06

**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.0.3...v1.0.4

[Changes][v1.0.4]


<a id="v1.0.3"></a>
# [v1.0.3](https://github.com/florian-asche/PiCompose/releases/tag/v1.0.3) - 2025-08-06

## What's Changed
* PiCompose and audio setup by [@florian-asche](https://github.com/florian-asche) in [#11](https://github.com/florian-asche/PiCompose/pull/11)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/v1.0.1...v1.0.3

[Changes][v1.0.3]


<a id="v1.0.1"></a>
# [v1.0.1](https://github.com/florian-asche/PiCompose/releases/tag/v1.0.1) - 2025-08-06

## What's Changed
* add first initial version by [@florian-asche](https://github.com/florian-asche) in [#5](https://github.com/florian-asche/PiCompose/pull/5)
* Enable pull image on boot for the homeassistant images by [@florian-asche](https://github.com/florian-asche) in [#10](https://github.com/florian-asche/PiCompose/pull/10)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/initial-base...v1.0.1

[Changes][v1.0.1]


<a id="v1.0.0"></a>
# [v1.0.0](https://github.com/florian-asche/PiCompose/releases/tag/v1.0.0) - 2025-08-05

## What's Changed
* add first initial version by [@florian-asche](https://github.com/florian-asche) in [#5](https://github.com/florian-asche/PiCompose/pull/5)


**Full Changelog**: https://github.com/florian-asche/PiCompose/compare/initial-base...main

[Changes][v1.0.0]


[v1.2.0]: https://github.com/florian-asche/PiCompose/compare/v1.1.4...v1.2.0
[v1.1.4]: https://github.com/florian-asche/PiCompose/compare/v1.1.3...v1.1.4
[v1.1.3]: https://github.com/florian-asche/PiCompose/compare/v1.1.2...v1.1.3
[v1.1.2]: https://github.com/florian-asche/PiCompose/compare/v1.1.1...v1.1.2
[v1.1.1]: https://github.com/florian-asche/PiCompose/compare/v1.1.0...v1.1.1
[v1.1.0]: https://github.com/florian-asche/PiCompose/compare/v1.0.4...v1.1.0
[v1.0.4]: https://github.com/florian-asche/PiCompose/compare/v1.0.3...v1.0.4
[v1.0.3]: https://github.com/florian-asche/PiCompose/compare/v1.0.1...v1.0.3
[v1.0.1]: https://github.com/florian-asche/PiCompose/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/florian-asche/PiCompose/tree/v1.0.0

<!-- Generated by https://github.com/rhysd/changelog-from-release v3.9.1 -->
