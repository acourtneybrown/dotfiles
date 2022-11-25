# Bootstrap & Dotfiles

This repo borrows heavily from [`MikeMcQuaid/strap`](https://github.com/MikeMcQuaid/strap) (and associated [Heroku app](https://macos-strap.herokuapp.com/)) along with [`mathiasbynens/dottfiles`](https://github.com/mathiasbynens/dotfiles).
In addition, it relies on [`deadc0de6/dotdrop`](https://github.com/deadc0de6/dotdrop/) to manage the dotfiles.

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

## Operations performed

### [`script/os-setup`](script/os-setup)

#### On Mac
1. [optional] install OS updates
1. run `macos` script
1. install xcode tools
1. install homebrew/linuxbrew (& casks)
1. install brew bundle (Brewfile)

#### On Linux
1. install Homebrew on Linux
1. install brew bundle (Brewfile.linux)

Items in *italics* require manual intervention currently.

### [`script/bootstrap`](script/bootstrap)

Optionally takes any additional dotdrop profiles to add to the newly created machine profile (eg: `confluent`).

1. setup `.ssh` directory
1. create `dotdrop` profile if necessary & install
1. install `oh-my-zsh`
1. pull data from 1password
    1. *login to my.1password account*
    1. pull gpg key from 1password
1. run `bootstrap-<profile>` for any additional profiles specified as arguments

### `script/bootstrap-<profile>`

General approach for these files:

1. install brew bundle (Brewfile.<profile>)
2. install Python-based tools (& multiple versions of Python)
