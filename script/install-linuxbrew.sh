#!/usr/bin/env bash

# From https://docs.brew.sh/Homebrew-on-Linux#alternative-installation
git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
mkdir ~/.linuxbrew/bin
ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
eval "$(~/.linuxbrew/bin/brew shellenv)"
