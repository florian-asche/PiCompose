# Contributing to PiCompose

Everybody is invited and welcome to contribute to PiCompose. Documentation fixes, hardware reports and new hardware support are all appreciated.

- Fork the PiCompose repository.
- Create a branch and make your change. See [DEVELOPMENT.md](../DEVELOPMENT.md) for the stage layout and build process.
- Check your changes (`bash -n` for shell scripts, `yamllint` for workflows).
- Create a Pull Request against the `main` branch and tick exactly one box under "Types of changes". CI derives the label from it, and the label decides where the PR appears in the release notes.

Images are not built for branches or pull requests automatically. A maintainer starts the `Build All PiCompose` workflow manually for a branch when an image is needed to test a change. In your fork you can run it yourself from the Actions tab if Actions are enabled there, so expect long build times.

## Feature suggestions

If you want to suggest a new feature or hardware, please open a discussion on GitHub.

## Issue Tracker

If you want to report a problem with the image, the boot process or `compose-manager`, please create an issue and use the template. Problems inside the voice assistant itself belong in the [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant/issues) repository.

## AI Policy

AI tools are allowed, but a human is responsible and must review and understand every change. Autonomous agents and unreviewed AI output will be rejected. See [AI_POLICY.md](AI_POLICY.md).
