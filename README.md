# Bootstrap & Dotfiles

This repo borrows heavily from [`MikeMcQuaid/strap`](https://github.com/MikeMcQuaid/strap) (and associated [app](https://strap.mikemcquaid.com/)) along with [`mathiasbynens/dottfiles`](https://github.com/mathiasbynens/dotfiles).
In addition, it relies on [`deadc0de6/dotdrop`](https://github.com/deadc0de6/dotdrop/) to manage the dotfiles.

## Flags affecting run

- `DOTFILES_SKIP_UPDATES`: if set, skip OS updates
- `DOTFILES_SKIP_CONFIRMATION`: on macOS, if set, skip the manual confirmation of setup that cannot be handled by the script
- `DOTFILES_SKIP_LOGIN_WINDOW`: on macOS, if set, skip the configuration of the login window message

## Setup

### macOS

On macOS, it may be necessary to run `xcode-select --install` if the `git` command is not initially available on the Mac.

When first setting up a (new?) machine, run the `os-setup` script.

Run the `bootstrap` script to install the dotfiles into the relevant location(s).

Ultimately, both of these files should be idempotent and thus can be used to re-run to update as needed.

**Note: During an initial installation run, you may see complaints about `_*env_install` dotdrop actions failing, but those are _not_ consequential.**

### Linux

The `os-setup` script currently works for Debian-based Linux distros, including Ubuntu & Raspbian.

It may be necessary to install git (`sudo apt install git`) in order to clone the repo for installation.

### General flow

```bash
git clone <this repo> .dotfiles
cd .dotfiles

# export SKIP_UPDATES=y if avoiding system updates

./script/os-setup

# some manual interaction initially

# log into 1Password app
# enable SSH agent in 1Password
# enable cli integration in 1Password

./script/bootstrap # optional dotdrop profiles to add for machine, like "confluent" or "personal"
```

### Windows

In an Powershell Administrator window:

```
irm https://raw.githubusercontent.com/acourtneybrown/dotfiles/master/script/win-admin-setup.ps1 | iex
```

In a Powershell windows (non-Administrator):

```
irm https://raw.githubusercontent.com/acourtneybrown/dotfiles/master/script/win-user-setup.ps1 | iex
```

## Operations performed

### [`script/os-setup`](script/os-setup)

#### On Mac
1. [optional] install OS updates
1. run `macos` script
1. install xcode tools

#### On Linux
1. [optional] install OS updates
2. Ensure en_US.UTF-8 locale is available & installed

Items in *italics* require manual intervention currently.

### [`script/bootstrap`](script/bootstrap)

Optionally takes any additional dotdrop profiles to add to the newly created machine profile (eg: `confluent`).

1. install homebrew/linuxbrew
1. add profile & included profiles to dotdrop config
1. for each profile, run the profile-specific installation
1. `dotdrop install`
1. for each profile, run the profile-specific after-installation

### `profile::<profile>` & `profile::<profile>_after`

General approach for these functions:

1. install brew bundle (`Brewfile.<profile>`)
2. install Python-based tools (& multiple versions of Python)
3. install any OS-specific packages via native (non-homebrew) package manager
