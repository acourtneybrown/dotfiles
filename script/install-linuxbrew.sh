#!/usr/bin/env bash

# TODO: make this work for non-Debian distro?
apt install ruby

# From https://docs.brew.sh/Homebrew-on-Linux#alternative-installation
if [ ! -d ~/.linuxbrew ]; then
  git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
  mkdir ~/.linuxbrew/bin
  ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
else
  git -C ~/.linuxbrew/Homebrew pull
fi
eval "$(~/.linuxbrew/bin/brew shellenv)"
