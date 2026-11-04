# OpenCode Agent Instructions

This file provides essential context for OpenCode agents working in this repository to avoid common mistakes and ramp up quickly.

## Repository Overview

This is a dotfiles repository that uses `dotdrop` for configuration management. It's designed to bootstrap and manage various system configurations across macOS, Linux, and Synology DSM environments.

## Key Commands

- `./script/bootstrap` - Main bootstrap script to install dotfiles
- `./script/os-setup` - OS-specific setup (requires sudo)
- `dotdrop install --force --profile="${PROFILE}" --cfg ../config.yaml` - Direct dotdrop installation command

## Architecture Notes

- Profiles are defined in `config.yaml` with hierarchical inheritance
- The bootstrap process creates profiles based on hostname, including special handling for `virtualbuddy` user
- Different profiles exist for macOS (`_mac`, `_dev_mac`, `_personal_mac`), Linux (`_linux`, `_linux_dev`, `_linux_desktop`), and Synology DSM (`_synology_dsm`)
- Profile-specific scripts are in `script/lib/profile.sh` and can be executed with `profile::<name>` functions

## Environment Requirements

- On macOS, Xcode command line tools are required (`xcode-select --install`)
- 1Password CLI is required for many operations (install via `./script/bootstrap` or manually)
- For Linux, some profiles require 1Password CLI to be installed via package manager
- Some environments expect specific `op` items to exist in 1Password

## Special Behaviors

- When running as the `virtualbuddy` user, several environment variables are set to skip updates and confirmations
- On macOS ARM machines, Rosetta 2 is installed automatically if needed
- SSH keys and other sensitive information are managed through 1Password integration
- The system uses `pyenv` and `goenv` for managing Python and Go versions, installed via the bootstrap process
- On Linux systems, Docker is installed as part of the dev profile (`_linux_dev`)
- SSH agent configuration varies by platform (macOS vs Linux vs Synology)

## Key Files and Paths

- `config.yaml` - Main configuration file defining profiles, variables, and dotfiles
- `script/bootstrap` - Entry point for dotfile installation
- `script/os-setup` - OS-specific setup script (requires sudo)
- `script/lib/profile.sh` - Profile-specific functions and installation logic
- `dotfiles/` - Contains actual dotfile content organized by type

## Setup Requirements

Some profile-specific commands and installations require:

1. `yq` command (YAML processor) - installed via Homebrew on macOS or package manager on Linux
2. `dotdrop` - installed as part of the bootstrap process via Homebrew or package manager
3. 1Password CLI - installed via the bootstrap process or manual installation

## Important Constraints

- Profile-specific commands (e.g., `profile::mac`, `profile::linux_dev`) must be run in the context of the bootstrap script or with proper environment setup
- Some profile logic requires `sudo` privileges (e.g., for installing packages or updating system configurations)
- Environment variables like `DOTFILES_SKIP_UPDATES`, `DOTFILES_SKIP_CONFIRMATION` and `DOTFILES_SKIP_LOGIN_WINDOW` can be set to skip certain steps during setup
- On macOS, the system requires manual confirmation for certain security settings (Full Disk Access) when running `os-setup`